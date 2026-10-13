// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";

contract ClaimValidityOracle {
    uint256 amount;
    bool fail;

    function configure(uint256 value, bool fails) external {
        amount = value;
        fail = fails;
    }

    function balanceOf(address) external view returns (uint256) {
        require(!fail, "token");
        return amount;
    }

    function word(bytes32 value) external pure returns (bytes32) {
        return value;
    }
}

/**
 * @notice C85 across RAW_BYTES, STATIC_CALL and native/token BALANCE, eight
 *         non-OR constraint kinds, two-word positional checks, a two-leaf OR
 *         and six malformed fetcher encodings. Gas artifacts are explicit.
 */
contract ClaimValidityFamiliesSymbolicTest is Test {
    Assertions core;
    ClaimValidityOracle oracle;

    function setUp() public {
        core = new Assertions();
        oracle = new ClaimValidityOracle();
    }

    function check_extendedValidityLeafConstraints(bytes32 x, bytes32 lo, bytes32 hi, uint8 kind, bool staticRead)
        public
        view
    {
        vm.assume(kind < 8);
        constraintFamily(x, lo, hi, kind, staticRead, false);
    }

    function check_extendedValidityOrWordConstraints(bytes32 x, bytes32 lo, bytes32 hi, uint8 kind, bool staticRead)
        public
        view
    {
        vm.assume(kind >= 2 && kind < 8);
        constraintFamily(x, lo, hi, kind, staticRead, true);
    }

    function check_extendedValidityOrOrderedRanges(bytes32 x, bytes32 lo, bytes32 hi, bool signedRange, bool staticRead)
        public
        view
    {
        vm.assume(signedRange ? int256(uint256(lo)) <= int256(uint256(hi)) : uint256(lo) <= uint256(hi));
        constraintFamily(x, lo, hi, signedRange ? 1 : 0, staticRead, true);
    }

    function check_extendedValidityOrReversedRanges(
        bytes32 x,
        bytes32 lo,
        bytes32 hi,
        bool signedRange,
        bool staticRead
    ) public view {
        vm.assume(signedRange ? int256(uint256(lo)) > int256(uint256(hi)) : uint256(lo) > uint256(hi));
        constraintFamily(x, lo, hi, signedRange ? 1 : 0, staticRead, true);
    }

    function constraintFamily(bytes32 x, bytes32 lo, bytes32 hi, uint8 kind, bool staticRead, bool disjunction)
        internal
        view
    {
        vm.assume(kind < 8);
        InputParam memory p = raw(abi.encode(x));
        if (staticRead) {
            p.fetcherType = InputParamFetcherType.STATIC_CALL;
            p.paramData = abi.encode(address(oracle), abi.encodeCall(ClaimValidityOracle.word, (x)));
        }
        Constraint memory c;
        bool holds;
        bool wellFormed = true;
        if (kind == 0) {
            c = Constraint(ConstraintType.IN, abi.encode(lo, hi));
            wellFormed = uint256(lo) <= uint256(hi);
            holds = wellFormed && uint256(lo) <= uint256(x) && uint256(x) <= uint256(hi);
        } else if (kind == 1) {
            c = Constraint(ConstraintType.IN_SIGNED, abi.encode(lo, hi));
            wellFormed = int256(uint256(lo)) <= int256(uint256(hi));
            holds = wellFormed && int256(uint256(lo)) <= int256(uint256(x)) && int256(uint256(x)) <= int256(uint256(hi));
        } else if (kind == 2) {
            c = Constraint(ConstraintType.GTE_SIGNED, abi.encode(lo));
            holds = int256(uint256(x)) >= int256(uint256(lo));
        } else if (kind == 3) {
            c = Constraint(ConstraintType.LTE_SIGNED, abi.encode(lo));
            holds = int256(uint256(x)) <= int256(uint256(lo));
        } else if (kind == 4) {
            c = Constraint(ConstraintType.EQ, abi.encode(lo));
            holds = x == lo;
        } else if (kind == 5) {
            c = Constraint(ConstraintType.GTE, abi.encode(lo));
            holds = uint256(x) >= uint256(lo);
        } else if (kind == 6) {
            c = Constraint(ConstraintType.LTE, abi.encode(lo));
            holds = uint256(x) <= uint256(lo);
        } else {
            c = Constraint(ConstraintType.SKIP, "");
            holds = true;
        }
        p.constraints = new Constraint[](1);
        if (disjunction) {
            Constraint[] memory leaves = new Constraint[](2);
            leaves[0] = c;
            leaves[1] = Constraint(ConstraintType.EQ, abi.encode(hi));
            p.constraints[0] = Constraint(ConstraintType.OR, abi.encode(leaves));
            // A malformed first range raises an ordinary resolution error;
            // it is not a false leaf that permits evaluation of the next one.
            holds = wellFormed && (holds || x == hi);
        } else {
            p.constraints[0] = c;
        }
        assertValidity(p, holds);
    }

    function check_extendedValidityTwoWordConstraints(bytes32 a, bytes32 b, bytes32 lower, bytes32 upper, bool signed)
        public
        view
    {
        InputParam memory p = raw(abi.encode(a, b));
        p.constraints = new Constraint[](2);
        p.constraints[0] = Constraint(signed ? ConstraintType.GTE_SIGNED : ConstraintType.GTE, abi.encode(lower));
        p.constraints[1] = Constraint(signed ? ConstraintType.LTE_SIGNED : ConstraintType.LTE, abi.encode(upper));
        bool holds = signed
            ? int256(uint256(a)) >= int256(uint256(lower)) && int256(uint256(b)) <= int256(uint256(upper))
            : uint256(a) >= uint256(lower) && uint256(b) <= uint256(upper);
        assertValidity(p, holds);
    }

    function check_extendedValidityBalances(
        uint256 amount,
        uint256 referenceValue,
        address account,
        uint8 sourceCase,
        bool fails,
        bool constrained
    ) public {
        vm.assume(sourceCase < 3);
        oracle.configure(amount, fails);
        if (sourceCase == 0) vm.deal(account, amount);
        address token = sourceCase == 0 ? address(0) : sourceCase == 1 ? address(oracle) : address(0xE0A);
        InputParam memory p = raw("");
        p.fetcherType = InputParamFetcherType.BALANCE;
        p.paramData = abi.encodePacked(token, account);
        if (constrained) {
            p.constraints = new Constraint[](1);
            p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(referenceValue));
        }
        bool holds = sourceCase != 2 && (sourceCase != 1 || !fails) && (!constrained || amount == referenceValue);
        assertValidity(p, holds);
    }

    function check_extendedValidityMalformedFetchers(bytes32 body, uint8 caseId) public view {
        vm.assume(caseId < 6);
        InputParam memory p = raw("");
        if (caseId < 3) {
            p.fetcherType = InputParamFetcherType.STATIC_CALL;
            if (caseId == 1) {
                p.paramData = abi.encode(body);
                bytes memory data = p.paramData;
                assembly ("memory-safe") { mstore(data, 31) }
            } else if (caseId == 2) {
                p.paramData = abi.encode(address(oracle), type(uint256).max);
            }
        } else {
            p.fetcherType = InputParamFetcherType.BALANCE;
            if (caseId != 3) {
                p.paramData = abi.encodePacked(address(oracle), address(uint160(uint256(body))), bytes1(0));
                if (caseId == 4) {
                    bytes memory data = p.paramData;
                    assembly ("memory-safe") { mstore(data, 39) }
                }
            }
        }
        assertValidity(p, false);
    }

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function assertValidity(InputParam memory p, bool expected) internal view {
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.isValid, (p)));
        // Ordinary failures and failed constraints can spuriously satisfy
        // the gas guard in Halmos. Exact signal propagation is proved apart.
        vm.assume(ok || keccak256(out) != keccak256(abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector)));
        assertTrue(ok);
        assertEq(abi.decode(out, (uint256)), expected ? 1 : 0);
    }

    function test_extendedValiditySamples() public {
        constraintFamily(bytes32(0), bytes32(uint256(1) << 255), bytes32(0), 0, true, true);
        constraintFamily(bytes32(0), bytes32(uint256(1)), bytes32(0), 1, false, true);
        for (uint8 kind; kind < 8; kind++) {
            constraintFamily(bytes32(type(uint256).max), bytes32(uint256(7)), bytes32(uint256(19)), kind, true, false);
            constraintFamily(bytes32(uint256(19)), bytes32(uint256(7)), bytes32(uint256(19)), kind, false, true);
        }
        check_extendedValidityTwoWordConstraints(
            bytes32(uint256(7)), bytes32(uint256(19)), bytes32(uint256(5)), bytes32(uint256(20)), false
        );
        check_extendedValidityTwoWordConstraints(
            bytes32(type(uint256).max), bytes32(uint256(19)), bytes32(uint256(5)), bytes32(uint256(20)), true
        );
        for (uint8 i; i < 3; i++) {
            check_extendedValidityBalances(19, 19, address(0x1234), i, false, true);
            check_extendedValidityBalances(19, 7, address(0x1234), i, true, false);
        }
        for (uint8 i; i < 6; i++) {
            check_extendedValidityMalformedFetchers(bytes32(type(uint256).max), i);
        }
    }
}

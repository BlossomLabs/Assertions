// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../lib/ERC8211.sol";

/** @dev Reverts with exactly the calldata it receives */
contract Reverter {
    fallback() external {
        assembly {
            calldatacopy(0, 0, calldatasize())
            revert(0, calldatasize())
        }
    }
}

/** @dev Returns successfully, whatever the call */
contract Quiet {
    fallback() external {}
}

/**
 * @notice Halmos properties for the core's control primitives: cond,
 *         orElse, isValid, revertData, pick and gather, each stated from its
 *         NatSpec. Run with `pnpm halmos`.
 * @dev Every call expected to succeed checks its success explicitly: Halmos
 *      discards reverting paths. Lengths and indexes that become memory
 *      offsets are case-split into literal candidates.
 */
contract ControlSymbolicTest is Test {
    Assertions core;
    Reverter reverter;
    Quiet quiet;

    function setUp() public {
        core = new Assertions();
        reverter = new Reverter();
        quiet = new Quiet();
    }

    // ============ cond ============

    /**
     * @dev The first word of the condition picks the branch; the branch not
     *      taken is an operand that would fail, so it is never resolved; a
     *      condition shorter than a word reverts ReturnDataOutOfBounds(0, len)
     */
    function check_condIsLazyAndJudgesFirstWord(uint8 lengthCase, bytes32 c0, bytes32 c1, bytes32 v) public view {
        vm.assume(lengthCase < 4);
        uint256 length = lengthCase == 0 ? 0 : lengthCase == 1 ? 31 : lengthCase == 2 ? 32 : 64;
        bytes memory condition = truncate(abi.encodePacked(c0, c1), length);
        bool truthy = length >= 32 && c0 != bytes32(0);
        InputParam memory good = raw(abi.encode(v));
        InputParam memory bomb = failing();
        (bool ok, bytes memory out) = address(core).staticcall(
            abi.encodeCall(Assertions.cond, (raw(condition), truthy ? good : bomb, truthy ? bomb : good))
        );
        if (length < 32) {
            assertFalse(ok, "a short condition selects");
            assertEq(out, abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(0), length));
        } else {
            assertTrue(ok, "cond resolved the branch it did not take");
            assertEq(out, abi.encode(v));
        }
    }

    // ============ orElse / isValid ============

    /** @dev orElse yields `a` exactly when its constraint holds; isValid reports exactly that */
    function check_orElseAndIsValidAgree(bytes32 value, bytes32 ref, bytes32 fallbackValue) public view {
        InputParam memory a = raw(abi.encode(value));
        a.constraints = new Constraint[](1);
        a.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(ref));
        bool holds = value == ref;

        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(Assertions.orElse, (a, raw(abi.encode(fallbackValue)))));
        vm.assume(!outOfGasArtifact(ok, out));
        assertTrue(ok, "orElse reverted");
        assertEq(out, holds ? abi.encode(value) : abi.encode(fallbackValue));

        (ok, out) = address(core).staticcall(abi.encodeCall(Assertions.isValid, (a)));
        vm.assume(!outOfGasArtifact(ok, out));
        assertTrue(ok, "isValid reverted");
        assertEq(abi.decode(out, (uint256)), holds ? 1 : 0);
    }

    // ============ revertData ============

    /**
     * @dev A zero expectation returns the whole revert data; a matching one
     *      the data past the selector; anything else, including data shorter
     *      than a selector, reverts UnexpectedRevertData(expected, got)
     */
    function check_revertDataMatchesSelector(uint8 lengthCase, bytes32 d0, bytes32 d1, bytes4 expected) public view {
        vm.assume(lengthCase < 5);
        uint256 length = lengthCase == 0 ? 0 : lengthCase == 1 ? 3 : lengthCase == 2 ? 4 : lengthCase == 3 ? 36 : 64;
        bytes memory data = truncate(abi.encodePacked(d0, d1), length);
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(Assertions.revertData, (call(address(reverter), data), expected)));
        vm.assume(!outOfGasArtifact(ok, out));
        bytes4 got = length >= 4 ? bytes4(d0) : bytes4(0);
        if (expected == bytes4(0)) {
            assertTrue(ok, "a zero expectation is refused");
            assertEq(out, data);
        } else if (got == expected) {
            assertTrue(ok, "a matching selector is refused");
            assertEq(out, slice(data, 4));
        } else {
            assertFalse(ok, "a mismatched selector is accepted");
            assertEq(out, abi.encodeWithSelector(Assertions.UnexpectedRevertData.selector, expected, got));
        }
    }

    /**
     * @dev Halmos does not model gas: gasleft() is a fresh symbol each time,
     *      so the core's out-of-gas guard can fire on any failed subcall, a
     *      path no real execution takes. Such a SubcallOutOfGas outcome is
     *      discarded here; CoreReads.t.sol pins the guard at real gas values.
     */
    function outOfGasArtifact(bool ok, bytes memory out) internal pure returns (bool) {
        return !ok && keccak256(out) == keccak256(abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector));
    }

    /** @dev The probe's structural refusals, each with its own error */
    function check_revertDataRefusals(uint8 caseId, bytes4 expected, bytes32 w) public view {
        vm.assume(caseId < 4);
        bytes memory callData = abi.encode(w);
        InputParam memory p;
        bytes memory want;
        if (caseId == 0) {
            p = call(address(quiet), callData);
            want = abi.encodeWithSelector(Assertions.DidNotRevert.selector, address(quiet), callData);
        } else if (caseId == 1) {
            p = raw(callData);
            want = abi.encodeWithSelector(Assertions.RevertProbeNotACall.selector, uint8(InputParamFetcherType.RAW_BYTES));
        } else if (caseId == 2) {
            p = call(address(reverter), callData);
            p.constraints = new Constraint[](1);
            p.constraints[0] = Constraint(ConstraintType.SKIP, "");
            want = abi.encodeWithSelector(Assertions.RevertProbeConstrained.selector, uint256(1));
        } else {
            // A code-less target reverts nothing: only a zero expectation is met, with empty data.
            p = call(address(0xC0DE1E55), callData);
            want = expected == bytes4(0) ? bytes("") : abi.encodeWithSelector(Assertions.UnexpectedRevertData.selector, expected, bytes4(0));
        }
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.revertData, (p, expected)));
        if (caseId == 3 && expected == bytes4(0)) assertTrue(ok, "an empty account with no expectation is refused");
        else assertFalse(ok, "a structural refusal is accepted");
        assertEq(out, want);
    }

    // ============ pick ============

    /**
     * @dev Word i of the full words, negative from the end; outside them,
     *      a trailing partial word included, ReturnDataOutOfBounds(index, len)
     */
    function check_pickSelectsFullWords(uint8 lengthCase, uint8 indexCase, bytes32[4] memory w) public view {
        vm.assume(lengthCase < 5 && indexCase < 9);
        uint256 length = lengthCase == 0 ? 0 : lengthCase == 1 ? 32 : lengthCase == 2 ? 63 : lengthCase == 3 ? 96 : 128;
        int256 index = indexCase == 0 ? int256(0) : indexCase == 1 ? int256(1) : indexCase == 2 ? int256(3)
            : indexCase == 3 ? int256(4) : indexCase == 4 ? -1 : indexCase == 5 ? -3 : indexCase == 6 ? -4
            : indexCase == 7 ? -5 : type(int256).min;
        bytes memory data = truncate(abi.encodePacked(w), length);
        uint256 words = length / 32;
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.pick, (raw(data), index)));
        bool inRange = index >= 0 ? uint256(index) < words : index >= -int256(words);
        if (inRange) {
            uint256 wanted = index >= 0 ? uint256(index) : words - uint256(-index);
            assertTrue(ok, "an in-range word is refused");
            assertEq(abi.decode(out, (bytes32)), w[wanted]);
        } else {
            assertFalse(ok, "an out-of-range word is returned");
            assertEq(out, abi.encodeWithSelector(ReturnDataOutOfBounds.selector, index, length));
        }
    }

    // ============ gather ============

    /** @dev Each operand's raw bytes, once each, as a canonical bytes[] */
    function check_gatherReturnsRawValues(uint8 aCase, uint8 bCase, bytes32[2] memory wa, bytes32[2] memory wb)
        public
        view
    {
        vm.assume(aCase < 4 && bCase < 4);
        bytes memory a = truncate(abi.encodePacked(wa), aCase == 0 ? 0 : aCase == 1 ? 5 : aCase == 2 ? 32 : 64);
        bytes memory b = truncate(abi.encodePacked(wb), bCase == 0 ? 0 : bCase == 1 ? 5 : bCase == 2 ? 32 : 64);
        InputParam[] memory args = new InputParam[](2);
        args[0] = raw(a);
        args[1] = raw(b);
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.gather, (args)));
        assertTrue(ok, "gather reverted on raw operands");
        bytes[] memory expected = new bytes[](2);
        expected[0] = a;
        expected[1] = b;
        assertEq(out, abi.encode(expected));
    }

    // ============ Harness ============

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function call(address target, bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(target, data), new Constraint[](0)
        );
    }

    /** @dev An operand that always fails: an EQ constraint over no bytes at all */
    function failing() internal pure returns (InputParam memory p) {
        p = raw("");
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(0)));
    }

    function truncate(bytes memory data, uint256 length) internal pure returns (bytes memory out) {
        out = data;
        assembly ("memory-safe") { mstore(out, length) }
    }

    function slice(bytes memory data, uint256 from) internal pure returns (bytes memory out) {
        out = new bytes(data.length - from);
        for (uint256 i; i < out.length; i++) {
            out[i] = data[from + i];
        }
    }
}

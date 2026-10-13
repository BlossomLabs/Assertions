// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import {ClaimCoreConstraintHost} from "./ClaimCoreConstraintsSymbolic.t.sol";
import "./ERC8211ReferenceHarness.sol";
import "./BiconomyERC8211Runtime.sol";

/**
 * @notice W5/W6/W15: direct positions through fetchers, dynamic header words,
 *         and explicit stricter range refusal against the pinned runtime.
 */
contract ClaimWireBoundarySymbolicTest is Test {
    Assertions core;
    ClaimCoreConstraintHost host;
    ERC8211ReferenceHarness referenceHost;

    function setUp() public {
        core = new Assertions();
        host = new ClaimCoreConstraintHost();
        vm.etch(BICONOMY_ERC8211, BICONOMY_ERC8211_RUNTIME);
        referenceHost = new ERC8211ReferenceHarness();
    }

    function check_wireFetchedWordPositions(bytes32 a, bytes32 b, bytes32 lower, bytes32 upper, bool staticRead)
        public
        view
    {
        InputParam memory p =
            staticRead ? operand(abi.encodeCall(ClaimCoreConstraintHost.two, (a, b))) : raw(abi.encode(a, b));
        p.constraints = new Constraint[](2);
        p.constraints[0] = Constraint(ConstraintType.GTE, abi.encode(lower));
        p.constraints[1] = Constraint(ConstraintType.LTE, abi.encode(upper));
        bool firstBad = a < lower;
        bool holds = !firstBad && b <= upper;
        (bool ok, bytes memory out) = judge(p);
        assertEq(ok, holds);
        assertEq(
            out,
            holds
                ? bytes("")
                : failure(
                    firstBad ? 0 : 1,
                    firstBad ? ConstraintType.GTE : ConstraintType.LTE,
                    firstBad ? a : b,
                    abi.encode(firstBad ? lower : upper)
                )
        );
    }

    function check_wireBalanceScalarRange(uint256 value, uint256 lower, uint256 upper, bool native) public {
        vm.assume(lower <= upper);
        host.configure(value);
        vm.deal(address(host), value);
        InputParam memory p = InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.BALANCE,
            abi.encodePacked(native ? address(0) : address(host), address(host)),
            new Constraint[](1)
        );
        p.constraints[0] = Constraint(ConstraintType.IN, abi.encode(lower, upper));
        bool holds = lower <= value && value <= upper;
        (bool ok, bytes memory out) = judge(p);
        assertEq(ok, holds);
        assertEq(out, holds ? bytes("") : failure(0, ConstraintType.IN, bytes32(value), abi.encode(lower, upper)));
        p.constraints = new Constraint[](2);
        p.constraints[0] = Constraint(ConstraintType.GTE, abi.encode(lower));
        p.constraints[1] = Constraint(ConstraintType.LTE, abi.encode(upper));
        (ok, out) = judge(p);
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), uint256(32)));
    }

    function check_wireDynamicHeaderPositions(bytes32 payload, bool staticRead) public view {
        bytes memory blob = abi.encodePacked(payload, bytes1(0x7f));
        InputParam memory p =
            staticRead ? operand(abi.encodeCall(ClaimCoreConstraintHost.blob, (payload))) : raw(abi.encode(blob));
        p.constraints = new Constraint[](3);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(32)));
        p.constraints[1] = Constraint(ConstraintType.EQ, abi.encode(uint256(33)));
        p.constraints[2] = Constraint(ConstraintType.EQ, abi.encode(payload));
        (bool ok, bytes memory out) = judge(p);
        assertTrue(ok, "constraints judge raw head, length and payload words in that order");
        assertEq(out, bytes(""));
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(payload));
        (ok, out) = judge(p);
        assertEq(ok, payload == bytes32(uint256(32)));
        assertEq(out, ok ? bytes("") : failure(0, ConstraintType.EQ, bytes32(uint256(32)), abi.encode(payload)));
    }

    function check_wireStrictRangeTrailingBytes(
        bytes32 value,
        bytes32 lower,
        bytes32 upper,
        bytes32[2] memory tail,
        bool signedRange,
        uint8 lengthCase
    ) public view {
        vm.assume(lengthCase < 3);
        if (signedRange) {
            vm.assume(
                int256(uint256(lower)) <= int256(uint256(value)) && int256(uint256(value)) <= int256(uint256(upper))
                    && int256(uint256(lower)) <= int256(uint256(upper))
            );
        } else {
            vm.assume(lower <= value && value <= upper && lower <= upper);
        }
        uint256 n = lengthCase == 0 ? 64 : lengthCase == 1 ? 96 : 128;
        bytes memory referenceData = abi.encode(lower, upper, tail[0], tail[1]);
        assembly ("memory-safe") { mstore(referenceData, n) }
        InputParam memory p = raw(abi.encode(value));
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(signedRange ? ConstraintType.IN_SIGNED : ConstraintType.IN, referenceData);
        (bool theirs,) =
            address(referenceHost).staticcall(abi.encodeWithSelector(ERC8211ReferenceHarness.judge.selector, p));
        assertTrue(theirs, "pinned reference accepts the ordered range and trailing bytes");
        (bool ok, bytes memory out) = judge(p);
        assertEq(ok, n == 64);
        assertEq(
            out,
            n == 64
                ? bytes("")
                : abi.encodeWithSelector(InvalidConstraintData.selector, uint256(0), uint256(0), uint256(0), n)
        );
    }

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function operand(bytes memory data) internal view returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(host), data),
            new Constraint[](0)
        );
    }

    function judge(InputParam memory p) internal view returns (bool, bytes memory) {
        return address(core).staticcall(abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", p));
    }

    function failure(uint256 index, ConstraintType kind, bytes32 actual, bytes memory referenceData)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ConstraintFailed.selector, "PARAM", uint256(0), uint256(0), index, kind, actual, referenceData
        );
    }

    function test_wireFetcherPositionsSamples() public {
        check_wireFetchedWordPositions(
            bytes32(uint256(7)), bytes32(uint256(93)), bytes32(uint256(3)), bytes32(uint256(99)), false
        );
        check_wireFetchedWordPositions(
            bytes32(uint256(7)), bytes32(uint256(93)), bytes32(uint256(3)), bytes32(uint256(90)), true
        );
        check_wireBalanceScalarRange(42, 3, 99, true);
        check_wireBalanceScalarRange(42, 50, 99, false);
    }

    function test_wireHeaderSamples() public view {
        check_wireDynamicHeaderPositions(bytes32(uint256(42)), false);
        check_wireDynamicHeaderPositions(bytes32(uint256(32)), true);
    }

    function test_wireReferenceRangeSamples() public view {
        bytes32[2] memory tail = [bytes32(uint256(7)), bytes32(uint256(93))];
        for (uint8 i; i < 3; i++) {
            check_wireStrictRangeTrailingBytes(
                bytes32(uint256(42)), bytes32(uint256(3)), bytes32(uint256(99)), tail, false, i
            );
            check_wireStrictRangeTrailingBytes(
                bytes32(uint256(int256(-7))), bytes32(uint256(int256(-10))), bytes32(uint256(int256(3))), tail, true, i
            );
        }
    }
}

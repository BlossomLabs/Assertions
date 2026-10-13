// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../lib/AbiCodec.sol";
import {OutputParam} from "../lib/ERC8211.sol";

/**
 * @dev Deterministic leaf values with the same ghost-clock assumptions as the
 *      cache harness. The fallback independently reflects caller and calldata.
 */
contract ClaimConstructionObserver {
    Vm constant VM = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function word(bytes32 value) external returns (bytes32) {
        VM.warp(block.timestamp + 1);
        return value;
    }

    function blob(bytes32 value) external returns (bytes memory) {
        VM.warp(block.timestamp + 1);
        return abi.encodePacked(value, bytes1(0x7f));
    }

    function target(address value) external returns (address) {
        VM.warp(block.timestamp + 1);
        return value;
    }

    function count() external view returns (uint256) {
        return block.timestamp - 1000;
    }

    fallback(bytes calldata data) external returns (bytes memory) {
        return bytes.concat(abi.encode(msg.sender), data);
    }
}

contract ClaimProofExecutor {
    uint256 public changed;

    function run(Assertions core, InputParam calldata p, uint256 mark, bool swallow) external returns (bool ok) {
        changed = mark;
        bytes memory out;
        (ok, out) =
            address(core).staticcall(abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", p));
        if (!ok && !swallow) assembly ("memory-safe") { revert(add(out, 32), mload(out)) }
    }
}

/**
 * @dev Unused by the correct core. The caller-context mutant forwards through
 *      this relay while preserving the destination and exact calldata.
 */
contract ClaimCallerRelay {
    function forward(address target, bytes calldata data) external view {
        (bool ok, bytes memory out) = target.staticcall(data);
        if (!ok) assembly ("memory-safe") { revert(add(out, 32), mload(out)) }
        assembly ("memory-safe") { return(add(out, 32), mload(out)) }
    }
}

/**
 * @notice C24, C8, C57, C59 and bounded C1/C81-C83 obligations. Scalar words
 *         are unrestricted; operand counts, target positions and descriptors
 *         are literal cases. Expected calldata comes from solc's encoder.
 */
contract ClaimConstructionSymbolicTest is Test {
    Assertions core;
    ClaimConstructionObserver observer;
    ClaimProofExecutor executor;
    bytes4 constant ECHO = 0xcafef00d;

    function setUp() public {
        core = new Assertions();
        observer = new ClaimConstructionObserver();
        executor = new ClaimProofExecutor();
        vm.etch(address(0xCA11E2), address(new ClaimCallerRelay()).code);
    }

    function check_behaviorGatherResolvesEntriesOnce(bytes32 a, bytes32 b, uint8 size, bool dynamic) public {
        vm.assume(size < 4);
        uint256 n = size == 0 ? 0 : size == 1 ? 1 : size == 2 ? 2 : 3;
        vm.warp(1000);
        InputParam[] memory args = operands(a, b, n, dynamic);
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.gather, (args)));
        assertTrue(ok);
        bytes[] memory expected = new bytes[](n);
        for (uint256 i; i < n; i++) {
            expected[i] = value(i == 1 ? b : a, dynamic);
        }
        assertEq(out, abi.encode(expected));
        assertEq(observer.count(), n, "duplicated entries resolve independently");
    }

    function check_behaviorGetResolvesTargetAndEntriesOnce(bytes32 a, bytes32 b, uint8 size, bool dynamic) public {
        vm.assume(size < 4);
        uint256 n = size == 0 ? 0 : size == 1 ? 1 : size == 2 ? 2 : 3;
        vm.warp(1000);
        InputParam[] memory args = operands(a, b, n, dynamic);
        InputParam memory target = callParam(abi.encodeCall(ClaimConstructionObserver.target, (address(observer))));
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeCall(Assertions.get, (target, ECHO, descriptor(n, dynamic), args)));
        assertTrue(ok);
        bytes memory encoded;
        if (dynamic) {
            bytes memory x = payload(a);
            bytes memory y = payload(b);
            encoded = n == 0 ? bytes("") : n == 1 ? abi.encode(x) : n == 2 ? abi.encode(x, y) : abi.encode(x, y, x);
        } else {
            encoded = n == 0 ? bytes("") : n == 1 ? abi.encode(a) : n == 2 ? abi.encode(a, b) : abi.encode(a, b, a);
        }
        assertEq(out, bytes.concat(abi.encode(address(core)), ECHO, encoded));
        assertEq(observer.count(), n + 1, "target and independent entries resolve once");
    }

    function check_behaviorConstructedCallers(bytes32 word, uint8 route) public view {
        vm.assume(route < 3);
        InputParam memory target = raw(abi.encode(address(observer)));
        InputParam[] memory args = new InputParam[](1);
        args[0] = raw(abi.encode(word));
        bytes memory data;
        if (route == 0) {
            data = abi.encodeCall(Assertions.read, (target, ECHO, args));
        } else if (route == 1) {
            data = abi.encodeCall(Assertions.get, (target, ECHO, "(bytes32)", args));
        } else {
            bytes[] memory calls = new bytes[](1);
            calls[0] = bytes.concat(ECHO, abi.encode(word));
            data = abi.encodeCall(Assertions.chain, (target, calls));
        }
        (bool ok, bytes memory out) = address(core).staticcall(data);
        assertTrue(ok);
        assertEq(out, bytes.concat(abi.encode(address(core)), ECHO, abi.encode(word)));
    }

    function check_behaviorDirtyBatchTarget(uint96 upper, uint8 position, bool message) public view {
        vm.assume(upper != 0 && position < 4);
        uint256 entryIndex = position == 0 ? 0 : position == 1 ? 1 : position == 2 ? 2 : 3;
        bytes32 dirty = bytes32((uint256(upper) << 160) | uint160(address(observer)));
        ComposableExecution[] memory entries = new ComposableExecution[](1);
        entries[0].inputParams = new InputParam[](4);
        entries[0].outputParams = new OutputParam[](0);
        for (uint256 i; i < 4; i++) {
            entries[0].inputParams[i] = raw(abi.encode(i == entryIndex ? dirty : bytes32(i)));
            if (i == entryIndex) entries[0].inputParams[i].paramType = InputParamType.TARGET;
        }
        (bool ok, bytes memory out) = address(core).staticcall(batch(entries, message));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(InvalidAddressWord.selector, entryIndex, dirty));
    }

    function check_behaviorGetMalformedDescriptor(bytes32 word, uint8 which) public view {
        vm.assume(which < 4);
        string memory t = which == 0 ? "(uint8[0])" : which == 1 ? "()" : which == 2 ? "(uint256" : "(uint256 uint8)";
        InputParam[] memory args = new InputParam[](1);
        args[0] = raw(abi.encode(word));
        (bool ok, bytes memory out) = address(core)
            .staticcall(abi.encodeCall(Assertions.get, (raw(abi.encode(address(observer))), ECHO, t, args)));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(InvalidTypeDescriptor.selector, which == 1 ? uint256(1) : uint256(8)));
    }

    function check_behaviorEmptyBatch(bool message) public view {
        (bool ok, bytes memory out) = address(core).staticcall(batch(new ComposableExecution[](0), message));
        assertTrue(ok);
        assertEq(out, bytes(""));
    }

    function check_behaviorEmptyUnconstrainedRaw(uint8 paramType) public view {
        vm.assume(paramType < 3);
        InputParam memory p = raw("");
        p.paramType = InputParamType(paramType);
        (bool ok, bytes memory out) =
            address(core).staticcall(abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", p));
        assertTrue(ok);
        assertEq(out, bytes(""));
    }

    function check_behaviorBatchDiscardsSuccessfulReturndata(bytes32 word, bool dynamic, bool message) public {
        vm.warp(1000);
        ComposableExecution[] memory entries = new ComposableExecution[](1);
        entries[0].functionSig =
            dynamic ? ClaimConstructionObserver.blob.selector : ClaimConstructionObserver.word.selector;
        entries[0].inputParams = new InputParam[](2);
        entries[0].inputParams[0] = raw(abi.encode(address(observer)));
        entries[0].inputParams[0].paramType = InputParamType.TARGET;
        entries[0].inputParams[1] = raw(abi.encode(word));
        entries[0].outputParams = new OutputParam[](0);
        (bool ok, bytes memory out) = address(core).staticcall(batch(entries, message));
        assertTrue(ok, "successful returndata is not a batch predicate");
        assertEq(out, bytes(""));
        assertEq(observer.count(), 1);
    }

    function check_behaviorExecutorRollback(bytes32 actual, bytes32 expected, uint256 mark, bool swallow) public {
        InputParam memory p = raw(abi.encode(actual));
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(expected));
        bool holds = actual == expected;
        (bool ok, bytes memory out) =
            address(executor).call(abi.encodeCall(ClaimProofExecutor.run, (core, p, mark, swallow)));
        assertEq(ok, holds || swallow);
        assertEq(executor.changed(), ok ? mark : 0);
        if (ok) assertEq(out, abi.encode(holds));
    }

    function check_behaviorBatchStopsAtFirstFailure(bytes32 word, uint8 failingEntry, bool message) public {
        vm.assume(failingEntry < 3);
        uint256 entryIndex = failingEntry == 0 ? 0 : failingEntry == 1 ? 1 : 2;
        vm.warp(1000);
        ComposableExecution[] memory entries = new ComposableExecution[](3);
        for (uint256 i; i < 3; i++) {
            entries[i].inputParams = new InputParam[](1);
            entries[i].outputParams = new OutputParam[](0);
            entries[i].inputParams[0] = callParam(abi.encodeCall(ClaimConstructionObserver.word, (word)));
            if (i == entryIndex) {
                entries[i].inputParams[0].constraints = new Constraint[](1);
                entries[i].inputParams[0].constraints[0] =
                    Constraint(ConstraintType.EQ, abi.encode(word ^ bytes32(uint256(1))));
            }
        }
        (bool ok, bytes memory out) = address(core).staticcall(batch(entries, message));
        assertFalse(ok);
        assertEq(out, batchFailure(word, entryIndex, message));
        assertEq(observer.count(), entryIndex + 1, "later entries must not execute");
    }

    function batchFailure(bytes32 word, uint256 entryIndex, bool message) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(
            ConstraintFailed.selector,
            message ? "behavior" : "COMPOSABLE",
            entryIndex,
            uint256(0),
            uint256(0),
            ConstraintType.EQ,
            word,
            abi.encode(word ^ bytes32(uint256(1)))
        );
    }

    function operands(bytes32 a, bytes32 b, uint256 n, bool dynamic) internal view returns (InputParam[] memory args) {
        args = new InputParam[](n);
        for (uint256 i; i < n; i++) {
            args[i] = callParam(
                dynamic
                    ? abi.encodeCall(ClaimConstructionObserver.blob, (i == 1 ? b : a))
                    : abi.encodeCall(ClaimConstructionObserver.word, (i == 1 ? b : a))
            );
        }
    }

    function descriptor(uint256 n, bool dynamic) internal pure returns (string memory) {
        if (n == 0) return "()";
        if (dynamic) return n == 1 ? "(bytes)" : n == 2 ? "(bytes,bytes)" : "(bytes,bytes,bytes)";
        return n == 1 ? "(bytes32)" : n == 2 ? "(bytes32,bytes32)" : "(bytes32,bytes32,bytes32)";
    }

    function payload(bytes32 word) internal pure returns (bytes memory) {
        return abi.encodePacked(word, bytes1(0x7f));
    }

    function value(bytes32 word, bool dynamic) internal pure returns (bytes memory) {
        return dynamic ? abi.encode(payload(word)) : abi.encode(word);
    }

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function callParam(bytes memory data) internal view returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(observer), data),
            new Constraint[](0)
        );
    }

    function batch(ComposableExecution[] memory entries, bool message) internal pure returns (bytes memory) {
        return message
            ? abi.encodeWithSignature(
                "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[],string)",
                entries,
                "behavior"
            )
            : abi.encodeWithSignature(
                "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])", entries
            );
    }

    function test_behaviorResolveOnceSamples() public {
        bytes32 a = bytes32(uint256(42));
        bytes32 b = bytes32(uint256(93));
        vm.expectCall(address(observer), abi.encodeCall(ClaimConstructionObserver.word, (a)), uint64(8));
        vm.expectCall(address(observer), abi.encodeCall(ClaimConstructionObserver.word, (b)), uint64(4));
        vm.expectCall(address(observer), abi.encodeCall(ClaimConstructionObserver.blob, (a)), uint64(8));
        vm.expectCall(address(observer), abi.encodeCall(ClaimConstructionObserver.blob, (b)), uint64(4));
        vm.expectCall(
            address(observer), abi.encodeCall(ClaimConstructionObserver.target, (address(observer))), uint64(8)
        );
        for (uint8 i; i < 4; i++) {
            check_behaviorGatherResolvesEntriesOnce(a, b, i, false);
            check_behaviorGatherResolvesEntriesOnce(a, b, i, true);
            check_behaviorGetResolvesTargetAndEntriesOnce(a, b, i, false);
            check_behaviorGetResolvesTargetAndEntriesOnce(a, b, i, true);
        }
    }

    function test_behaviorCoreErrorsAndCallersSamples() public view {
        for (uint8 i; i < 4; i++) {
            check_behaviorDirtyBatchTarget(1, i, false);
            check_behaviorDirtyBatchTarget(3, i, true);
            check_behaviorGetMalformedDescriptor(bytes32(uint256(42)), i);
            if (i < 3) check_behaviorConstructedCallers(bytes32(uint256(42)), i);
        }
    }

    function test_behaviorEmptyAndDiscardSamples() public {
        check_behaviorEmptyBatch(false);
        check_behaviorEmptyBatch(true);
        for (uint8 i; i < 3; i++) {
            check_behaviorEmptyUnconstrainedRaw(i);
        }
        vm.expectCall(address(observer), abi.encodeCall(ClaimConstructionObserver.word, (bytes32(0))), uint64(1));
        vm.expectCall(
            address(observer), abi.encodeCall(ClaimConstructionObserver.blob, (bytes32(uint256(42)))), uint64(1)
        );
        check_behaviorBatchDiscardsSuccessfulReturndata(bytes32(0), false, false);
        check_behaviorBatchDiscardsSuccessfulReturndata(bytes32(uint256(42)), true, true);
    }

    function test_behaviorExecutorAndOrderSamples() public {
        check_behaviorExecutorRollback(bytes32(0), bytes32(uint256(1)), 42, false);
        check_behaviorExecutorRollback(bytes32(0), bytes32(uint256(1)), 42, true);
        // A new executor removes the previous sample's intentionally retained write.
        executor = new ClaimProofExecutor();
        check_behaviorExecutorRollback(bytes32(uint256(9)), bytes32(uint256(9)), 93, false);
        for (uint8 i; i < 3; i++) {
            check_behaviorBatchStopsAtFirstFailure(bytes32(uint256(7)), i, false);
            check_behaviorBatchStopsAtFirstFailure(bytes32(uint256(7)), i, true);
        }
    }
}

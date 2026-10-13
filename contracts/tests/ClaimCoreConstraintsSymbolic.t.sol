// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import {OutputParam} from "../lib/ERC8211.sol";
import {ClaimBoundaryTarget} from "./ClaimBoundaryCasesSymbolic.t.sol";

contract ClaimCoreConstraintHost {
    uint256 amount;

    function configure(uint256 value) external {
        amount = value;
    }

    function balanceOf(address) external view returns (uint256) {
        return amount;
    }

    function word(bytes32 value) external pure returns (bytes32) {
        return value;
    }

    function two(bytes32 a, bytes32 b) external pure returns (bytes32, bytes32) {
        return (a, b);
    }

    function blob(bytes32 value) external pure returns (bytes memory) {
        return abi.encodePacked(value, bytes1(0x7f));
    }

    function fail(bytes calldata reason) external pure {
        assembly ("memory-safe") {
            calldatacopy(0, reason.offset, reason.length)
            revert(0, reason.length)
        }
    }
}

/**
 * @notice C2/C4/C17/C19/C21 over selected fetchers, complete error context and
 *         finite nested calls. Ordinary failure gas artifacts are explicit;
 *         exact reserved-signal properties exclude no signal path.
 */
contract ClaimCoreConstraintsSymbolicTest is Test {
    Assertions core;
    ClaimCoreConstraintHost host;

    function setUp() public {
        core = new Assertions();
        host = new ClaimCoreConstraintHost();
        vm.etch(address(0), address(new ClaimBoundaryTarget()).code);
    }

    function check_judgeSingleParamFetchers(
        bytes32 word,
        bytes32 referenceData,
        uint8 fetcher,
        uint8 paramType,
        bool message
    ) public {
        vm.assume(fetcher < 4 && paramType < 3);
        host.configure(uint256(word));
        vm.deal(address(host), uint256(word));
        InputParam memory p = raw(abi.encode(word));
        if (fetcher == 1) p = operand(address(host), abi.encodeCall(ClaimCoreConstraintHost.word, (word)));
        if (fetcher >= 2) p = balance(fetcher == 2 ? address(0) : address(host));
        p.paramType = InputParamType(paramType);
        p.constraints = new Constraint[](1);
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(referenceData));
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                message
                    ? abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]),string)", p, "judge")
                    : abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", p)
            );
        assertEq(ok, word == referenceData);
        assertEq(
            out,
            word == referenceData
                ? bytes("")
                : constraintFailure(message ? "judge" : "PARAM", 0, 0, word, referenceData)
        );
    }

    function check_judgeResolveConstraints(bytes32[4] memory words, uint8 countCase, bool staticRead) public view {
        vm.assume(countCase < 3);
        uint256 n = countCase == 0 ? 0 : countCase == 1 ? 1 : 2;
        InputParam memory p = staticRead
            ? operand(address(host), abi.encodeCall(ClaimCoreConstraintHost.two, (words[0], words[1])))
            : raw(abi.encode(words[0], words[1]));
        p.constraints = new Constraint[](n);
        if (n > 0) p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(words[2]));
        if (n > 1) p.constraints[1] = Constraint(ConstraintType.EQ, abi.encode(words[3]));
        bool firstBad = n > 0 && words[0] != words[2];
        bool secondBad = n > 1 && words[1] != words[3];
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.resolve, (p)));
        assertEq(ok, !firstBad && !secondBad);
        if (ok) {
            assertEq(out, abi.encode(words[0], words[1]));
        } else if (firstBad) {
            assertEq(out, constraintFailure("", 0, 0, words[0], words[2]));
        } else {
            assertEq(out, constraintFailure("", 0, 1, words[1], words[3]));
        }
    }

    function check_judgePredicateOnlyBatches(bytes32[3] memory words, uint8 failureCase, bool staticRead, bool message)
        public
    {
        vm.assume(failureCase < 4);
        uint256 bad = failureCase == 0 ? 0 : failureCase == 1 ? 1 : failureCase == 2 ? 2 : 3;
        vm.warp(1000);
        ComposableExecution[] memory entries = new ComposableExecution[](3);
        for (uint256 i; i < 3; i++) {
            entries[i].functionSig = 0xcafef00d;
            entries[i].inputParams = new InputParam[](1);
            entries[i].outputParams = new OutputParam[](0);
            InputParam memory p = staticRead
                ? operand(address(host), abi.encodeCall(ClaimCoreConstraintHost.word, (words[i])))
                : raw(abi.encode(words[i]));
            p.constraints = new Constraint[](1);
            p.constraints[0] =
                Constraint(ConstraintType.EQ, abi.encode(i == bad ? words[i] ^ bytes32(uint256(1)) : words[i]));
            entries[i].inputParams[0] = p;
        }
        (bool ok, bytes memory out) = address(core)
            .staticcall(
                message
                    ? abi.encodeWithSignature(
                        "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[],string)",
                        entries,
                        "judge"
                    )
                    : abi.encodeWithSignature(
                        "assertBatch((bytes4,(uint8,uint8,bytes,(uint8,bytes)[])[],(uint8,bytes)[])[])", entries
                    )
            );
        assertEq(ok, bad == 3);
        bytes32 actual = bad == 0 ? words[0] : bad == 1 ? words[1] : words[2];
        assertEq(
            out,
            ok
                ? bytes("")
                : constraintFailure(message ? "judge" : "COMPOSABLE", bad, 0, actual, actual ^ bytes32(uint256(1)))
        );
        assertEq(ClaimBoundaryTarget(address(0)).count(), 0, "predicate entries must not construct calls");
    }

    function check_judgeStaticFailureContext(bytes32[3] memory words, uint8 lengthCase, uint8 depthCase) public view {
        vm.assume(lengthCase < 7 && depthCase < 3);
        uint256 n = lengthCase == 0
            ? 0
            : lengthCase == 1
                ? 3
                : lengthCase == 2 ? 4 : lengthCase == 3 ? 32 : lengthCase == 4 ? 33 : lengthCase == 5 ? 64 : 65;
        bytes memory reason = new bytes(n);
        bytes memory source = abi.encodePacked(words);
        for (uint256 i; i < n; i++) {
            reason[i] = source[i];
        }
        vm.assume(keccak256(reason) != keccak256(signal()));
        (InputParam memory p, address target, bytes memory data) =
            nested(reason, depthCase == 0 ? 0 : depthCase == 1 ? 1 : 2);
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.resolve, (p)));
        vm.assume(ok || keccak256(out) != keccak256(signal()));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(CallFailed.selector, target, data));
    }

    function check_judgeReservedFailurePropagation(uint8 depthCase) public view {
        vm.assume(depthCase < 3);
        (InputParam memory p,,) = nested(signal(), depthCase == 0 ? 0 : depthCase == 1 ? 1 : 2);
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.resolve, (p)));
        assertFalse(ok);
        assertEq(out, signal());
    }

    function nested(bytes memory reason, uint256 depth)
        internal
        view
        returns (InputParam memory p, address target, bytes memory data)
    {
        target = address(host);
        data = abi.encodeCall(ClaimCoreConstraintHost.fail, (reason));
        p = operand(target, data);
        for (uint256 i; i < depth; i++) {
            target = address(core);
            data = abi.encodeCall(Assertions.resolve, (p));
            p = operand(target, data);
        }
    }

    function raw(bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
    }

    function operand(address target, bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(target, data), new Constraint[](0)
        );
    }

    function balance(address token) internal view returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.BALANCE,
            abi.encodePacked(token, address(host)),
            new Constraint[](0)
        );
    }

    function signal() internal pure returns (bytes memory) {
        return abi.encodeWithSelector(Assertions.SubcallOutOfGas.selector);
    }

    function constraintFailure(
        string memory message,
        uint256 entry,
        uint256 index,
        bytes32 actual,
        bytes32 referenceData
    ) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(
            ConstraintFailed.selector,
            message,
            entry,
            uint256(0),
            index,
            ConstraintType.EQ,
            actual,
            abi.encode(referenceData)
        );
    }

    function test_judgeFetcherAndResolveSamples() public {
        for (uint8 i; i < 4; i++) {
            check_judgeSingleParamFetchers(bytes32(uint256(42)), bytes32(uint256(42)), i, 0, false);
            check_judgeSingleParamFetchers(bytes32(uint256(42)), bytes32(uint256(93)), i, 2, true);
        }
        for (uint8 i; i < 3; i++) {
            check_judgeResolveConstraints(
                [bytes32(uint256(42)), bytes32(uint256(93)), bytes32(uint256(42)), bytes32(uint256(93))], i, false
            );
            check_judgeResolveConstraints(
                [bytes32(uint256(42)), bytes32(uint256(93)), bytes32(uint256(42)), bytes32(uint256(7))], i, true
            );
        }
    }

    function test_judgePredicateSamples() public {
        bytes32[3] memory words = [bytes32(uint256(42)), bytes32(uint256(93)), bytes32(uint256(7))];
        for (uint8 i; i < 4; i++) {
            check_judgePredicateOnlyBatches(words, i, false, false);
            check_judgePredicateOnlyBatches(words, i, true, true);
        }
    }

    function test_judgeFailureSamples() public view {
        bytes32[3] memory words = [bytes32(uint256(42)), bytes32(uint256(93)), bytes32(uint256(7))];
        for (uint8 depth; depth < 3; depth++) {
            for (uint8 len; len < 7; len++) {
                check_judgeStaticFailureContext(words, len, depth);
            }
            check_judgeReservedFailurePropagation(depth);
        }
    }
}

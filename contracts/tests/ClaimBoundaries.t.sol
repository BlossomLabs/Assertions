// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operations.sol";
import "../Collections.sol";
import "../Expressions.sol";
import {OutputParam} from "../lib/ERC8211.sol";

contract CostlySuccess {
    function returnsFalse() external pure returns (bool) {
        return false;
    }

    function remainingGas() external view returns (uint256) {
        return gasleft();
    }

    function work(uint256) external pure returns (uint256) {
        bytes32 acc;
        for (uint256 i; i < 6000; i++) {
            acc = keccak256(abi.encode(acc, i));
        }
        return acc == bytes32(0) ? 0 : 1;
    }
}

contract ExampleExecutor {
    uint256 public changed;

    function run(Assertions core, InputParam calldata assertion, bool swallowFailure) external {
        changed = 1;
        if (swallowFailure) {
            (bool ok,) = address(core)
                .staticcall(abi.encodeWithSignature("assertParam((uint8,uint8,bytes,(uint8,bytes)[]))", assertion));
            require(!ok, "example expected failed assertion");
        } else {
            core.assertParam(assertion);
        }
    }
}

contract ClaimBoundariesTest is Test {
    Assertions core = new Assertions();
    Operations ops = new Operations();
    Collections collections = new Collections();
    CostlySuccess target = new CostlySuccess();

    function operand(address a, bytes memory data) internal pure returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA, InputParamFetcherType.STATIC_CALL, abi.encode(a, data), new Constraint[](0)
        );
    }

    function test_failedGuardedAttemptDiscardsCachedCalls() public {
        Expressions xp = new Expressions();
        Expressions.Node[] memory nodes = new Expressions.Node[](6);
        nodes[0] = Expressions.Node(
            Expressions.Kind.Literal, "address", abi.encode(address(target)), new uint256[](0), bytes4(0), ""
        );
        nodes[1] = Expressions.Node(
            Expressions.Kind.Call, "uint256", "", new uint256[](1), CostlySuccess.returnsFalse.selector, "()"
        );
        nodes[2] = Expressions.Node(
            Expressions.Kind.Literal, "uint8", abi.encode(uint256(256)), new uint256[](0), bytes4(0), ""
        );
        uint256[] memory pair = new uint256[](2);
        pair[0] = 1;
        pair[1] = 2;
        nodes[3] = Expressions.Node(Expressions.Kind.Tuple, "(uint256,uint8)", "", pair, bytes4(0), "(uint256,uint8)");
        uint256[] memory attempt = new uint256[](1);
        attempt[0] = 3;
        nodes[4] = Expressions.Node(Expressions.Kind.IsValid, "bool", "", attempt, bytes4(0), "");
        uint256[] memory result = new uint256[](2);
        result[0] = 4;
        result[1] = 1;
        nodes[5] = Expressions.Node(Expressions.Kind.Tuple, "(bool,uint256)", "", result, bytes4(0), "(bool,uint256)");
        vm.expectCall(address(target), abi.encodeCall(CostlySuccess.returnsFalse, ()), uint64(2));
        (bool ok, bytes memory out) = address(xp)
            .staticcall(
                abi.encodeCall(Expressions.evaluate, (Expressions.Expression(address(core), nodes, 5), new bytes[](0)))
            );
        assertTrue(ok);
        assertEq(out, abi.encode(false, uint256(0)));
    }

    function testAtomicityRequiresExecutorToPropagateFailure() public {
        InputParam memory p = InputParam(
            InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(uint256(0)), new Constraint[](1)
        );
        p.constraints[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(1)));
        ExampleExecutor executor = new ExampleExecutor();
        (bool ok,) = address(executor).call(abi.encodeCall(ExampleExecutor.run, (core, p, false)));
        assertFalse(ok);
        assertEq(executor.changed(), 0, "propagating the assertion rolls back prior changes");
        executor.run(core, p, true);
        assertEq(executor.changed(), 1, "swallowing the assertion leaves prior changes in place");
    }

    function testEmptyAndUnconstrainedAssertionsAndFalseReturnPass() public view {
        core.assertBatch(new ComposableExecution[](0));
        core.assertParam(InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, "", new Constraint[](0)));
        assertEq(core.isValid(operand(address(target), abi.encodeCall(CostlySuccess.returnsFalse, ()))), 1);
        ComposableExecution[] memory batch = new ComposableExecution[](1);
        batch[0].functionSig = CostlySuccess.returnsFalse.selector;
        batch[0].inputParams = new InputParam[](1);
        batch[0].inputParams[0] = InputParam(
            InputParamType.TARGET, InputParamFetcherType.RAW_BYTES, abi.encode(address(target)), new Constraint[](0)
        );
        batch[0].outputParams = new OutputParam[](0);
        core.assertBatch(batch);
    }

    function testMemoizationChangesGasSensitiveCallResults() public {
        Expressions xp = new Expressions();
        Expressions.Node[] memory nodes = new Expressions.Node[](3);
        nodes[0] = Expressions.Node(
            Expressions.Kind.Literal, "address", abi.encode(address(target)), new uint256[](0), bytes4(0), ""
        );
        nodes[1] = Expressions.Node(
            Expressions.Kind.Call, "uint256", "", new uint256[](1), CostlySuccess.remainingGas.selector, "()"
        );
        uint256[] memory refs = new uint256[](2);
        refs[0] = 1;
        refs[1] = 1;
        nodes[2] =
            Expressions.Node(Expressions.Kind.Tuple, "(uint256,uint256)", "", refs, bytes4(0), "(uint256,uint256)");
        (bool ok, bytes memory out) = address(xp).staticcall{gas: 1_000_000}(
            abi.encodeCall(Expressions.evaluate, (Expressions.Expression(address(core), nodes, 2), new bytes[](0)))
        );
        assertTrue(ok);
        (uint256 a, uint256 b) = abi.decode(out, (uint256, uint256));
        assertEq(a, b);
        Expressions.Node[] memory duplicated = new Expressions.Node[](4);
        duplicated[0] = nodes[0];
        duplicated[1] = nodes[1];
        duplicated[2] = nodes[1];
        duplicated[3] = nodes[2];
        duplicated[3].refs[1] = 2;
        (ok, out) = address(xp).staticcall{gas: 1_000_000}(
            abi.encodeCall(Expressions.evaluate, (Expressions.Expression(address(core), duplicated, 3), new bytes[](0)))
        );
        assertTrue(ok);
        (a, b) = abi.decode(out, (uint256, uint256));
        assertGt(a, b, "a view call can return different values in one evaluation");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Expressions.sol";
import {Operations} from "../Operations.sol";
import "../lib/ERC8211.sol";
import "./Mocks.sol";

/**
 * @notice Behaviour a symbolic run cannot observe: how many times an operand
 *         is called
 * @dev Call counts use forge's expectCall with an exact count. powMod's
 *      fallback for a missing or misbehaving modexp precompile is not tested
 *      here: forge refuses to replace code at a precompile address, and every
 *      chain that runs Cancun bytecode has modexp.
 */
contract CallCountsAndFallbacksTest is Test {
    Assertions core;
    Expressions expressions;
    Operations ops;
    MockTarget target;

    function setUp() public {
        core = new Assertions();
        expressions = new Expressions();
        ops = new Operations();
        target = new MockTarget();
    }

    function live() internal view returns (InputParam memory) {
        return InputParam(
            InputParamType.CALL_DATA,
            InputParamFetcherType.STATIC_CALL,
            abi.encode(address(target), abi.encodeCall(MockTarget.getValue, ())),
            new Constraint[](0)
        );
    }

    // ============ Each operand resolves once ============

    /**
     * @dev gather resolves each of its operands exactly once
     */
    function test_gatherResolvesEachOperandOnce() public {
        InputParam[] memory args = new InputParam[](1);
        args[0] = live();
        vm.expectCall(address(target), abi.encodeCall(MockTarget.getValue, ()), uint64(1));
        core.gather(args);
    }

    /**
     * @dev get resolves each argument exactly once, then makes its one call
     */
    function test_getResolvesEachArgumentOnce() public {
        InputParam[] memory args = new InputParam[](1);
        args[0] = live();
        InputParam memory to = InputParam(
            InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(address(ops)), new Constraint[](0)
        );
        vm.expectCall(address(target), abi.encodeCall(MockTarget.getValue, ()), uint64(1));
        (bool ok,) = address(core)
            .staticcall(abi.encodeCall(Assertions.get, (to, bytes4(keccak256("toString(uint256)")), "(uint256)", args)));
        assertTrue(ok);
    }

    /**
     * @dev A node shared by two references is evaluated once per evaluation
     */
    function test_sharedNodeEvaluatesOnce() public {
        Expressions.Node[] memory nodes = new Expressions.Node[](2);
        nodes[0] =
            Expressions.Node(Expressions.Kind.Resolve, "uint256", abi.encode(live()), new uint256[](0), bytes4(0), "");
        nodes[1] = Expressions.Node(
            Expressions.Kind.Tuple, "(uint256,uint256)", "", new uint256[](2), bytes4(0), "(uint256,uint256)"
        );
        vm.expectCall(address(target), abi.encodeCall(MockTarget.getValue, ()), uint64(1));
        (bool ok,) = address(expressions)
            .staticcall(
                abi.encodeCall(Expressions.evaluate, (Expressions.Expression(address(core), nodes, 1), new bytes[](0)))
            );
        assertTrue(ok);
    }
}

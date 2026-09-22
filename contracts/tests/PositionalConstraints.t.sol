// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Expressions.sol";
import "../lib/ERC8211.sol";

contract PositionalConstraintsTest is Test {
    Assertions core;

    function setUp() public {
        core = new Assertions();
    }

    function param(bytes memory value, Constraint[] memory cs) internal pure returns (InputParam memory) {
        return InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, value, cs);
    }

    function test_eachConstraintChecksItsOwnWord() public view {
        Constraint[] memory cs = new Constraint[](2);
        cs[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(42)));
        cs[1] = Constraint(ConstraintType.EQ, abi.encode(uint256(999)));
        core.assertParam(param(abi.encode(uint256(42), uint256(999)), cs));
    }

    function test_matchingFirstWordDoesNotHideWrongSecondWord() public {
        Constraint[] memory cs = new Constraint[](2);
        cs[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(42)));
        cs[1] = cs[0];
        vm.expectRevert(
            abi.encodeWithSelector(
                ConstraintFailed.selector,
                "PARAM",
                0,
                0,
                1,
                ConstraintType.EQ,
                bytes32(uint256(999)),
                abi.encode(uint256(42))
            )
        );
        core.assertParam(param(abi.encode(uint256(42), uint256(999)), cs));
    }

    function test_boundsPrecedePredicatesAndSkipNeedsAWord() public {
        Constraint[] memory cs = new Constraint[](2);
        cs[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(0)));
        cs[1] = Constraint(ConstraintType.SKIP, "");
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), uint256(63)));
        core.assertParam(param(bytes.concat(abi.encode(uint256(42)), new bytes(31)), cs));
    }

    function test_skipAndSignedRange() public view {
        Constraint[] memory cs = new Constraint[](3);
        cs[0] = Constraint(ConstraintType.SKIP, "");
        cs[1] = Constraint(ConstraintType.IN, abi.encode(uint256(900), uint256(1000)));
        cs[2] = Constraint(ConstraintType.IN_SIGNED, abi.encode(int256(-10), int256(0)));
        core.assertParam(param(abi.encode(uint256(42), uint256(999), int256(-7)), cs));
    }

    function test_orAlternativesCheckTheSameWord() public view {
        Constraint[] memory alternatives = new Constraint[](2);
        alternatives[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(0)));
        alternatives[1] = Constraint(ConstraintType.GTE_SIGNED, abi.encode(int256(-7)));
        Constraint[] memory cs = new Constraint[](1);
        cs[0] = Constraint(ConstraintType.OR, abi.encode(alternatives));
        core.assertParam(param(abi.encode(int256(-7)), cs));
    }

    function test_nestedOrRejectedEvenAfterMatchingLeaf() public {
        Constraint[] memory alternatives = new Constraint[](2);
        alternatives[0] = Constraint(ConstraintType.SKIP, "");
        alternatives[1] = Constraint(ConstraintType.OR, abi.encode(new Constraint[](0)));
        Constraint[] memory cs = new Constraint[](1);
        cs[0] = Constraint(ConstraintType.OR, abi.encode(alternatives));
        vm.expectRevert(abi.encodeWithSelector(InvalidOrConstraint.selector, 0, 0, 0));
        core.assertParam(param(abi.encode(uint256(42)), cs));
    }

    function test_emptyOrRejected() public {
        Constraint[] memory cs = new Constraint[](1);
        cs[0] = Constraint(ConstraintType.OR, abi.encode(new Constraint[](0)));
        vm.expectRevert(abi.encodeWithSelector(InvalidOrConstraint.selector, 0, 0, 0));
        core.assertParam(param(abi.encode(uint256(42)), cs));
    }

    function test_skipRejectsPayload() public {
        Constraint[] memory cs = new Constraint[](1);
        cs[0] = Constraint(ConstraintType.SKIP, hex"01");
        vm.expectRevert(abi.encodeWithSelector(InvalidConstraintData.selector, 0, 0, 0, 1));
        core.assertParam(param(abi.encode(uint256(42)), cs));
    }

    function test_invalidRangeCannotBeHiddenByLaterOrAlternative() public {
        Constraint[] memory alternatives = new Constraint[](2);
        alternatives[0] = Constraint(ConstraintType.IN_SIGNED, abi.encode(int256(10), int256(-10)));
        alternatives[1] = Constraint(ConstraintType.SKIP, "");
        Constraint[] memory cs = new Constraint[](1);
        cs[0] = Constraint(ConstraintType.OR, abi.encode(alternatives));
        vm.expectRevert(abi.encodeWithSelector(InvalidConstraintRange.selector, 0, 0, 0));
        core.assertParam(param(abi.encode(int256(0)), cs));
    }

    function test_balanceRejectsSecondConstraint() public {
        vm.deal(address(this), 42);
        Constraint[] memory cs = new Constraint[](2);
        cs[0] = Constraint(ConstraintType.EQ, abi.encode(uint256(42)));
        cs[1] = Constraint(ConstraintType.SKIP, "");
        InputParam memory p = InputParam(
            InputParamType.CALL_DATA, InputParamFetcherType.BALANCE, abi.encodePacked(address(0), address(this)), cs
        );
        vm.expectRevert(abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), uint256(32)));
        core.assertParam(p);
    }

    function test_expressionGraphResolvesNewConstraintKinds() public {
        Expressions expressions = new Expressions();
        Constraint[] memory cs = new Constraint[](2);
        cs[0] = Constraint(ConstraintType.SKIP, "");
        cs[1] = Constraint(ConstraintType.IN_SIGNED, abi.encode(int256(-10), int256(0)));
        bytes memory value = abi.encode(uint256(42), int256(-7));
        Expressions.Expression memory graph;
        graph.core = address(core);
        graph.nodes = new Expressions.Node[](1);
        graph.nodes[0].kind = Expressions.Kind.Resolve;
        graph.nodes[0].valueType = "(uint256,int256)";
        graph.nodes[0].data = abi.encode(param(value, cs));
        (bool ok, bytes memory result) =
            address(expressions).staticcall(abi.encodeCall(Expressions.evaluate, (graph, new bytes[](0))));
        assertTrue(ok);
        assertEq(result, value);

        cs[1].referenceData = abi.encode(int256(-10), int256(-8));
        graph.nodes[0].data = abi.encode(param(value, cs));
        (ok,) = address(expressions).staticcall(abi.encodeCall(Expressions.evaluate, (graph, new bytes[](0))));
        assertFalse(ok);
    }

    function test_wireEnumNumbersMatchReference() public pure {
        assertEq(uint8(ConstraintType.EQ), 0);
        assertEq(uint8(ConstraintType.GTE), 1);
        assertEq(uint8(ConstraintType.LTE), 2);
        assertEq(uint8(ConstraintType.IN), 3);
        assertEq(uint8(ConstraintType.GTE_SIGNED), 4);
        assertEq(uint8(ConstraintType.LTE_SIGNED), 5);
        assertEq(uint8(ConstraintType.OR), 6);
        assertEq(uint8(ConstraintType.SKIP), 7);
        assertEq(uint8(ConstraintType.IN_SIGNED), 8);
    }
}

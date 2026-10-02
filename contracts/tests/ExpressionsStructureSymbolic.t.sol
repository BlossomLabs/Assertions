// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Expressions.sol";
import {IExpressions} from "../Collections.sol";
import "../lib/ERC8211.sol";
import "../lib/AbiCodec.sol";

/**
 *  @dev Returns the selector it was called with and the calldata size, as two words
 */
contract SelectorEcho {
    fallback() external {
        assembly {
            mstore(0, shl(224, shr(224, calldataload(0))))
            mstore(32, calldatasize())
            return(0, 64)
        }
    }
}

/**
 * @notice Halmos properties for Expressions' graph structure and node
 *         semantics: the per-kind reference counts, the result index, one-word
 *         Parameter data, Wrap, Array, Tuple and bare-selector Call values,
 *         the self-only guarded entry point, and evaluateEncoded against
 *         evaluate. Run with `pnpm halmos`.
 * @dev Errors are compared byte for byte. Halmos has no gas model, so the
 *      out-of-gas guard's SubcallOutOfGas can fire on any failing subcall it
 *      explores; that outcome is discarded (see outOfGasArtifact).
 */
contract ExpressionsStructureSymbolicTest is Test {
    Assertions core;
    Expressions expressions;
    SelectorEcho echo;

    function setUp() public {
        core = new Assertions();
        expressions = new Expressions();
        echo = new SelectorEcho();
    }

    // ============ Structure ============

    /**
     * @dev The documented reference count of each kind
     */
    function countAllowed(uint8 kind, uint256 count) internal pure returns (bool) {
        if (kind == uint8(Expressions.Kind.Call)) return count >= 1;
        if (kind == uint8(Expressions.Kind.Select)) return count == 3;
        if (kind == uint8(Expressions.Kind.TryOrElse) || kind == uint8(Expressions.Kind.ProbeCall)) return count == 2;
        if (kind == uint8(Expressions.Kind.Wrap) || kind == uint8(Expressions.Kind.IsValid)) return count == 1;
        if (kind == uint8(Expressions.Kind.Array) || kind == uint8(Expressions.Kind.Tuple)) return true;
        return count == 0;
    }

    /**
     * @dev Every kind with every reference count from 0 to 4: a count the kind
     *      does not allow reverts InvalidNode at that node, and an allowed one
     *      never does (whatever evaluation then says). References point back at
     *      an address node and a bytes node, so ProbeCall's operand is typed.
     */
    function check_referenceCountsPerKind(uint8 kind, uint8 countCase) public view {
        vm.assume(kind < 11);
        uint256 count;
        if (countCase == 0) {
            count = 0;
        } else if (countCase == 1) {
            count = 1;
        } else if (countCase == 2) {
            count = 2;
        } else if (countCase == 3) {
            count = 3;
        } else {
            vm.assume(countCase == 4);
            count = 4;
        }
        Expressions.Node[] memory nodes = new Expressions.Node[](3);
        nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(echo)));
        nodes[1] = node(Expressions.Kind.Literal, "bytes", abi.encode(bytes("")));
        nodes[2] = node(Expressions.Kind(kind), "uint256", abi.encode(uint256(0)));
        nodes[2].refs = new uint256[](count);
        for (uint256 i; i < count; i++) {
            nodes[2].refs[i] = i % 2;
        }
        bytes[] memory params = new bytes[](1);
        params[0] = abi.encode(uint256(1));
        (bool ok, bytes memory out) = evaluate(nodes, 2, params);
        bytes memory invalid = abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(2));
        if (!countAllowed(kind, count)) {
            assertFalse(ok);
            assertEq(out, invalid, "a wrong reference count is accepted");
        } else {
            assertTrue(keccak256(out) != keccak256(invalid) || ok, "an allowed reference count is refused");
        }
    }

    /**
     * @dev A result index past the last node reverts InvalidNode(result) before anything runs
     */
    function check_resultIndexInRange(uint8 resultCase) public view {
        uint256 result;
        if (resultCase == 0) {
            result = 0;
        } else if (resultCase == 1) {
            result = 1;
        } else if (resultCase == 2) {
            result = 2;
        } else {
            vm.assume(resultCase == 3);
            result = type(uint256).max;
        }
        Expressions.Node[] memory nodes = new Expressions.Node[](2);
        nodes[0] = node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(7)));
        nodes[1] = node(Expressions.Kind.Literal, "uint256", abi.encode(uint256(8)));
        (bool ok, bytes memory out) = evaluate(nodes, result, new bytes[](0));
        if (result >= 2) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(Expressions.InvalidNode.selector, result));
        } else {
            assertTrue(ok);
            assertEq(out, abi.encode(uint256(7 + result)));
        }
    }

    /**
     * @dev A Parameter's data must be exactly one word (InvalidNode
     *      otherwise), naming a parameter that exists (InvalidReference
     *      otherwise). The index is a literal per case: a symbolic one is a
     *      calldata read at a symbolic offset.
     */
    function check_parameterDataIsOneWord(uint8 lengthCase, uint8 indexCase) public view {
        uint256 index;
        if (indexCase == 0) {
            index = 0;
        } else if (indexCase == 1) {
            index = 1;
        } else if (indexCase == 2) {
            index = 2;
        } else {
            vm.assume(indexCase == 3);
            index = type(uint256).max;
        }
        bytes memory data = abi.encodePacked(index, index);
        uint256 length;
        if (lengthCase == 0) {
            length = 0;
        } else if (lengthCase == 1) {
            length = 31;
        } else if (lengthCase == 2) {
            length = 32;
        } else if (lengthCase == 3) {
            length = 33;
        } else {
            vm.assume(lengthCase == 4);
            length = 64;
        }
        assembly ("memory-safe") { mstore(data, length) }
        Expressions.Node[] memory nodes = new Expressions.Node[](1);
        nodes[0] = node(Expressions.Kind.Parameter, "uint256", data);
        bytes[] memory params = new bytes[](2);
        params[0] = abi.encode(uint256(10));
        params[1] = abi.encode(uint256(11));
        (bool ok, bytes memory out) = evaluate(nodes, 0, params);
        if (length != 32) {
            assertEq(out, abi.encodeWithSelector(Expressions.InvalidNode.selector, uint256(0)));
        } else if (index >= 2) {
            assertEq(out, abi.encodeWithSelector(Expressions.InvalidReference.selector, uint256(0), index));
        } else {
            assertTrue(ok);
            assertEq(out, abi.encode(uint256(10 + index)));
            return;
        }
        assertFalse(ok);
    }

    /**
     * @dev evaluateGuarded refuses every caller but the contract itself
     */
    function check_evaluateGuardedIsSelfOnly(bytes32 w) public view {
        Expressions.Node[] memory nodes = new Expressions.Node[](1);
        nodes[0] = node(Expressions.Kind.Literal, "bytes32", abi.encode(w));
        Expressions.Cache memory cache =
            Expressions.Cache(new bytes[](1), new bool[](1), new bool[](1), new uint256[](1));
        (bool ok, bytes memory out) = address(expressions)
            .staticcall(
                abi.encodeCall(
                    Expressions.evaluateGuarded,
                    (Expressions.Expression(address(core), nodes, 0), new bytes[](0), 0, cache)
                )
            );
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(Expressions.NotSelf.selector, address(this)));
    }

    // ============ Values ============

    /**
     * @dev Wrap is abi.encode(bytes) of its operand, Array packs its operands
     *      as a canonical T[] of element type `arguments`, and Tuple encodes
     *      them as the `arguments` tuple, refusing a count that differs with
     *      ComponentCountMismatch
     */
    function check_wrapArrayTupleValues(bytes32 a, bytes32 b, uint8 kindCase) public view {
        Expressions.Node[] memory nodes = new Expressions.Node[](3);
        nodes[0] = node(Expressions.Kind.Literal, "bytes32", abi.encode(a));
        nodes[1] = node(Expressions.Kind.Literal, "bytes32", abi.encode(b));
        bytes memory expected;
        if (kindCase == 0) {
            nodes[2] = node(Expressions.Kind.Wrap, "bytes", "");
            nodes[2].refs = new uint256[](1);
            expected = abi.encode(abi.encode(a));
        } else if (kindCase == 1) {
            nodes[2] = node(Expressions.Kind.Array, "bytes32[]", "");
            nodes[2].arguments = "bytes32";
            nodes[2].refs = refs2();
            bytes32[] memory both = new bytes32[](2);
            both[0] = a;
            both[1] = b;
            expected = abi.encode(both);
        } else if (kindCase == 2) {
            nodes[2] = node(Expressions.Kind.Tuple, "(bytes32,bytes32)", "");
            nodes[2].arguments = "(bytes32,bytes32)";
            nodes[2].refs = refs2();
            expected = abi.encode(a, b);
        } else {
            vm.assume(kindCase == 3);
            nodes[2] = node(Expressions.Kind.Tuple, "(bytes32,bytes32,bytes32)", "");
            nodes[2].arguments = "(bytes32,bytes32,bytes32)";
            nodes[2].refs = refs2();
            (bool bad, bytes memory why) = evaluate(nodes, 2, new bytes[](0));
            assertFalse(bad);
            assertEq(why, abi.encodeWithSelector(AbiCodec.ComponentCountMismatch.selector, uint256(3), uint256(2)));
            return;
        }
        (bool ok, bytes memory out) = evaluate(nodes, 2, new bytes[](0));
        assertTrue(ok);
        assertEq(out, expected);
    }

    /**
     * @dev A Call node with arguments "()" and no operands sends the bare selector
     */
    function check_emptyTupleCallSendsBareSelector(bytes4 sel) public view {
        Expressions.Node[] memory nodes = new Expressions.Node[](2);
        nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(echo)));
        nodes[1] = node(Expressions.Kind.Call, "(bytes32,uint256)", "");
        nodes[1].refs = new uint256[](1);
        nodes[1].selector = sel;
        nodes[1].arguments = "()";
        (bool ok, bytes memory out) = evaluate(nodes, 1, new bytes[](0));
        vm.assume(!outOfGasArtifact(ok, out));
        assertTrue(ok);
        assertEq(out, abi.encode(bytes32(sel), uint256(4)));
    }

    /**
     * @dev evaluateEncoded returns what evaluate returns, and wraps evaluate's
     *      failure as NodeCallFailed(0, expressions, the evaluate call, reason)
     */
    function check_evaluateEncodedMatchesEvaluate(bytes32 w, bool narrow) public view {
        Expressions.Node[] memory nodes = new Expressions.Node[](1);
        nodes[0] = node(Expressions.Kind.Literal, narrow ? "uint8" : "bytes32", abi.encode(w));
        Expressions.Expression memory e = Expressions.Expression(address(core), nodes, 0);
        bytes[] memory params = new bytes[](0);
        (bool ok, bytes memory out) = address(expressions).staticcall(abi.encodeCall(Expressions.evaluate, (e, params)));
        (bool encodedOk, bytes memory encodedOut) =
            address(expressions).staticcall(abi.encodeCall(Expressions.evaluateEncoded, (abi.encode(e), params)));
        vm.assume(!outOfGasArtifact(encodedOk, encodedOut));
        assertEq(encodedOk, ok);
        if (ok) {
            assertEq(encodedOut, out);
        } else {
            assertEq(
                encodedOut,
                abi.encodeWithSelector(
                    Expressions.NodeCallFailed.selector,
                    uint256(0),
                    address(expressions),
                    abi.encodeCall(Expressions.evaluate, (e, params)),
                    out
                )
            );
        }
    }

    // ============ Shared selectors ============

    /**
     * @dev The errors and interfaces declared locally to keep contracts
     *      independent share their counterparts' selectors, so each side
     *      decodes the other's errors and calls
     */
    function test_sharedSelectorsMatch() public pure {
        assertEq(Expressions.DidNotRevert.selector, Assertions.DidNotRevert.selector);
        assertEq(Expressions.UnexpectedRevertData.selector, Assertions.UnexpectedRevertData.selector);
        assertEq(Expressions.SubcallOutOfGas.selector, Assertions.SubcallOutOfGas.selector);
        assertEq(ICore.resolve.selector, Assertions.resolve.selector);
        assertEq(IExpressions.evaluateEncoded.selector, Expressions.evaluateEncoded.selector);
    }

    // ============ Harness ============

    function node(Expressions.Kind kind, string memory valueType, bytes memory data)
        internal
        pure
        returns (Expressions.Node memory n)
    {
        n.kind = kind;
        n.valueType = valueType;
        n.data = data;
    }

    function refs2() internal pure returns (uint256[] memory r) {
        r = new uint256[](2);
        r[1] = 1;
    }

    function evaluate(Expressions.Node[] memory nodes, uint256 result, bytes[] memory params)
        internal
        view
        returns (bool ok, bytes memory out)
    {
        (ok, out) = address(expressions)
            .staticcall(
                abi.encodeCall(Expressions.evaluate, (Expressions.Expression(address(core), nodes, result), params))
            );
    }

    /**
     * @dev Halmos has no gas model: gasleft() is a fresh symbol, so the
     *      out-of-gas guard can fire on any failing subcall it explores, which
     *      no real execution takes. That outcome is discarded.
     */
    function outOfGasArtifact(bool ok, bytes memory out) internal pure returns (bool) {
        return !ok && keccak256(out) == keccak256(abi.encodeWithSelector(Expressions.SubcallOutOfGas.selector));
    }
}

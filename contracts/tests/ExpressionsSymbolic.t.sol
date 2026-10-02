// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Expressions.sol";

/**
 * @notice Halmos properties for Expressions: memoized sharing is
 *         transparent, Select is lazy and judges like the core's `cond`,
 *         guarded evaluation falls back exactly on failure, and every
 *         reference and parameter index is bounded. Run with `pnpm halmos`.
 * @dev Every evaluation goes through `staticcall` with its success checked:
 *      Halmos discards reverting paths. A SELF-reference is out of reach:
 *      allowed, it recurses until the frame fails, a path Halmos cannot finish
 *      and so drops; Expressions.t.sol pins it to InvalidReference(1, 1).
 */
contract ExpressionsSymbolicTest is Test {
    Expressions xp;

    function setUp() public {
        xp = new Expressions();
    }

    // ============ Sharing ============

    function solcTriple(bytes calldata d) external pure returns (uint8, uint256, uint8) {
        return abi.decode(d, (uint8, uint256, uint8));
    }

    /**
     * @dev A graph referencing one Parameter node twice equals the tree that
     *      duplicates it, and both accept exactly what solc decodes
     */
    function check_sharingEqualsDuplication(bytes32 p0, bytes32 p1) public view {
        bytes[] memory params = new bytes[](2);
        params[0] = abi.encode(p0);
        params[1] = abi.encode(p1);

        Expressions.Expression memory graph = expression(3);
        graph.nodes[0] = param("uint8", 0);
        graph.nodes[1] = param("uint256", 1);
        graph.nodes[2] = composite(Expressions.Kind.Tuple, "(uint8,uint256,uint8)", refs3(0, 1, 0));

        Expressions.Expression memory tree = expression(4);
        tree.nodes[0] = param("uint8", 0);
        tree.nodes[1] = param("uint256", 1);
        tree.nodes[2] = param("uint8", 0);
        tree.nodes[3] = composite(Expressions.Kind.Tuple, "(uint8,uint256,uint8)", refs3(0, 1, 2));

        (bool okGraph, bytes memory outGraph) = evaluate(graph, params);
        (bool okTree, bytes memory outTree) = evaluate(tree, params);
        (bool solcOk,) = address(this).staticcall(abi.encodeCall(this.solcTriple, (abi.encodePacked(p0, p1, p0))));
        assertEq(okGraph, solcOk, "graph and solc disagree");
        assertEq(okTree, solcOk, "tree and solc disagree");
        if (solcOk) {
            assertEq(outGraph, abi.encodePacked(p0, p1, p0));
            assertEq(outTree, outGraph);
        }
    }

    // ============ Select ============

    /**
     * @dev The first word of the condition picks the branch; the other
     *      branch, a node that would revert, never runs. Every node validates
     *      against its type and no type is shorter than a word, so a
     *      condition is one word or more.
     */
    function check_selectIsLazyAndJudgesFirstWord(uint8 lengthCase, bytes32 c0, bytes32 c1, bytes32 thenValue)
        public
        view
    {
        vm.assume(lengthCase < 2);
        uint256 length = lengthCase == 0 ? 32 : 64;
        bytes memory condition = abi.encodePacked(c0, c1);
        assembly ("memory-safe") { mstore(condition, length) }

        Expressions.Expression memory e = expression(4);
        e.nodes[0] = literal("bytes32", abi.encode(thenValue));
        // A Parameter past the end: InvalidReference if it is ever evaluated.
        e.nodes[1] = param("bytes32", 7);
        e.nodes[2] = literalRaw(condition);
        bool truthy = c0 != bytes32(0);
        // Whichever branch is NOT chosen is the bomb.
        e.nodes[3] = composite(Expressions.Kind.Select, "bytes32", truthy ? refs3(2, 0, 1) : refs3(2, 1, 0));

        (bool ok, bytes memory out) = evaluate(e, new bytes[](0));
        assertTrue(ok, "Select evaluated the branch it did not choose");
        assertEq(out, abi.encode(thenValue));
    }

    // ============ Guarded evaluation ============

    /**
     * @dev TryOrElse yields the attempt when it validates and the fallback
     *      otherwise; IsValid reports exactly that validity
     */
    function check_guardedEvaluationFallsBackExactly(bytes32 p0, bytes32 fallbackValue) public view {
        bytes[] memory params = new bytes[](1);
        params[0] = abi.encode(p0);
        bool valid = uint256(p0) < 256;

        Expressions.Expression memory e = expression(3);
        e.nodes[0] = param("uint8", 0);
        e.nodes[1] = literal("uint8", abi.encode(uint256(fallbackValue) & 0xff));
        e.nodes[2] = composite(Expressions.Kind.TryOrElse, "uint8", refs2(0, 1));
        (bool ok, bytes memory out) = evaluate(e, params);
        vm.assume(!outOfGasArtifact(ok, out));
        assertTrue(ok, "TryOrElse reverted");
        assertEq(out, valid ? abi.encode(p0) : abi.encode(uint256(fallbackValue) & 0xff));

        e.nodes[2] = composite(Expressions.Kind.IsValid, "bool", refs1(0));
        (ok, out) = evaluate(e, params);
        vm.assume(!outOfGasArtifact(ok, out));
        assertTrue(ok, "IsValid reverted");
        assertEq(out, abi.encode(valid));
    }

    // ============ References ============

    /**
     * @dev A reference is accepted exactly when it points strictly backwards
     */
    function check_referencesMustPointBackwards(uint8 refCase) public view {
        // A symbolic index is a symbolic array offset in the contract: case-split it.
        vm.assume(refCase < 4);
        uint256 ref = refCase == 0 ? 0 : refCase == 1 ? 1 : refCase == 2 ? 2 : type(uint256).max;
        Expressions.Expression memory e = expression(2);
        e.nodes[0] = literal("uint256", abi.encode(uint256(5)));
        e.nodes[1] = composite(Expressions.Kind.Wrap, "bytes", refs1(ref));
        (bool ok, bytes memory out) = evaluate(e, new bytes[](0));
        if (ref == 0) {
            assertTrue(ok, "a backward reference is refused");
            assertEq(out, abi.encode(abi.encode(uint256(5))));
        } else {
            assertFalse(ok, "a forward or self reference is accepted");
            assertEq(out, abi.encodeWithSelector(Expressions.InvalidReference.selector, uint256(1), ref));
        }
    }

    /**
     * @dev A Parameter index is accepted exactly when it is in range
     */
    function check_parameterIndexBounded(uint8 indexCase, bytes32 p0, bytes32 p1) public view {
        vm.assume(indexCase < 4);
        uint256 index = indexCase == 0 ? 0 : indexCase == 1 ? 1 : indexCase == 2 ? 2 : type(uint256).max;
        bytes[] memory params = new bytes[](2);
        params[0] = abi.encode(p0);
        params[1] = abi.encode(p1);
        Expressions.Expression memory e = expression(1);
        e.nodes[0] = param("bytes32", index);
        (bool ok, bytes memory out) = evaluate(e, params);
        if (index < 2) {
            assertTrue(ok, "an in-range parameter is refused");
            assertEq(out, index == 0 ? abi.encode(p0) : abi.encode(p1));
        } else {
            assertFalse(ok, "an out-of-range parameter is read");
            assertEq(out, abi.encodeWithSelector(Expressions.InvalidReference.selector, uint256(0), index));
        }
    }

    // ============ Harness ============

    function evaluate(Expressions.Expression memory e, bytes[] memory params)
        internal
        view
        returns (bool ok, bytes memory out)
    {
        (ok, out) = address(xp).staticcall(abi.encodeCall(Expressions.evaluate, (e, params)));
    }

    function expression(uint256 n) internal view returns (Expressions.Expression memory e) {
        e.core = address(this);
        e.nodes = new Expressions.Node[](n);
        e.result = n - 1;
    }

    function node(
        Expressions.Kind kind,
        string memory valueType,
        bytes memory data,
        uint256[] memory refs,
        string memory arguments
    ) internal pure returns (Expressions.Node memory) {
        return Expressions.Node(kind, valueType, data, refs, bytes4(0), arguments);
    }

    function param(string memory valueType, uint256 index) internal pure returns (Expressions.Node memory) {
        return node(Expressions.Kind.Parameter, valueType, abi.encode(index), new uint256[](0), "");
    }

    function literal(string memory valueType, bytes memory value) internal pure returns (Expressions.Node memory) {
        return node(Expressions.Kind.Literal, valueType, value, new uint256[](0), "");
    }

    /**
     * @dev A condition literal of 1 or 2 words, declared with the static type of that footprint
     */
    function literalRaw(bytes memory value) internal pure returns (Expressions.Node memory) {
        return literal(value.length == 32 ? "bytes32" : "(bytes32,bytes32)", value);
    }

    function composite(Expressions.Kind kind, string memory valueType, uint256[] memory refs)
        internal
        pure
        returns (Expressions.Node memory)
    {
        return node(kind, valueType, "", refs, valueType);
    }

    function refs1(uint256 a) internal pure returns (uint256[] memory r) {
        r = new uint256[](1);
        r[0] = a;
    }

    function refs2(uint256 a, uint256 b) internal pure returns (uint256[] memory r) {
        r = new uint256[](2);
        r[0] = a;
        r[1] = b;
    }

    function refs3(uint256 a, uint256 b, uint256 c) internal pure returns (uint256[] memory r) {
        r = new uint256[](3);
        r[0] = a;
        r[1] = b;
        r[2] = c;
    }

    /**
     * @dev Halmos does not model gas: gasleft() is a fresh symbol each time,
     *      so the out-of-gas guard can fire on any failed subcall, a path no
     *      real execution takes. Such a SubcallOutOfGas outcome is discarded
     *      here; Expressions.t.sol pins the guard at real gas values.
     */
    function outOfGasArtifact(bool ok, bytes memory out) internal pure returns (bool) {
        return !ok && keccak256(out) == keccak256(abi.encodeWithSelector(Expressions.SubcallOutOfGas.selector));
    }
}

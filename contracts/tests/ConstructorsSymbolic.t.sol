// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Expressions.sol";
import "../lib/AbiCodec.sol";

/**
 * @notice Halmos properties for the Expressions constructors over dynamic
 *         and narrow shapes, Call arity, and nav's sentinels away from the
 *         end of a path: a Tuple node over `(uint8,string)` matches
 *         `abi.encode` with its leading 0x20 word, an Array node over
 *         `uint8` enforces the element range and packs the empty array, a
 *         Call node with the wrong operand count reverts
 *         ComponentCountMismatch before calling, and `LEN`/`PAYLOAD`
 *         anywhere but last fall into the ordinary bounds check. Run with
 *         `pnpm halmos`.
 * @dev Errors are compared byte for byte. No property here reaches a
 *      subcall (the arity check precedes the call), so the out-of-gas
 *      artifact the other Expressions suites discard cannot arise.
 */
contract ConstructorsSymbolicTest is Test {
    struct Pair {
        uint8 number;
        string text;
    }
    Expressions expressions;
    Assertions core;

    function setUp() public {
        expressions = new Expressions();
        core = new Assertions();
    }

    function node(Expressions.Kind kind, string memory t, bytes memory data)
        internal
        pure
        returns (Expressions.Node memory n)
    {
        n.kind = kind;
        n.valueType = t;
        n.data = data;
    }

    function evaluate(Expressions.Node[] memory nodes, uint256 result) internal view returns (bool, bytes memory) {
        return address(expressions)
            .staticcall(
                abi.encodeCall(
                    Expressions.evaluate, (Expressions.Expression(address(core), nodes, result), new bytes[](0))
                )
            );
    }

    /**
     * @dev A Tuple node over a narrow word and a string (empty or two bytes)
     *      is `abi.encode` of the struct: the tail after the 0x20 word
     */
    function check_dynamicTupleConstructor(uint8 n, bytes2 text, bool empty) public view {
        string memory s = empty ? "" : string(abi.encodePacked(text));
        Expressions.Node[] memory nodes = new Expressions.Node[](3);
        nodes[0] = node(Expressions.Kind.Literal, "uint8", abi.encode(n));
        nodes[1] = node(Expressions.Kind.Literal, "string", abi.encode(s));
        nodes[2] = node(Expressions.Kind.Tuple, "(uint8,string)", "");
        nodes[2].arguments = "(uint8,string)";
        nodes[2].refs = new uint256[](2);
        nodes[2].refs[1] = 1;
        (bool ok, bytes memory out) = evaluate(nodes, 2);
        assertTrue(ok);
        assertEq(out, abi.encode(Pair(n, s)));
    }

    /**
     * @dev An Array node over `uint8` accepts two full-width leaves exactly
     *      when both words are in range, then equals `abi.encode(uint8[])`;
     *      with no references it packs the empty array
     */
    function check_narrowArrayConstructor(bytes32 a, bytes32 b, bool empty) public view {
        Expressions.Node[] memory nodes = new Expressions.Node[](3);
        // Full-width leaves deliberately force the Array constructor to enforce uint8.
        nodes[0] = node(Expressions.Kind.Literal, "bytes32", abi.encode(a));
        nodes[1] = node(Expressions.Kind.Literal, "bytes32", abi.encode(b));
        nodes[2] = node(Expressions.Kind.Array, "uint8[]", "");
        nodes[2].arguments = "uint8";
        nodes[2].refs = new uint256[](empty ? 0 : 2);
        if (!empty) nodes[2].refs[1] = 1;
        (bool ok, bytes memory out) = evaluate(nodes, 2);
        assertEq(ok, empty || (uint256(a) <= 255 && uint256(b) <= 255));
        if (ok) {
            uint8[] memory values = new uint8[](empty ? 0 : 2);
            if (!empty) {
                values[0] = uint8(uint256(a));
                values[1] = uint8(uint256(b));
            }
            assertEq(out, abi.encode(values));
        }
    }

    /**
     * @dev A Call node with one operand too many or too few for its
     *      `arguments` tuple reverts ComponentCountMismatch(declared, given)
     *      before any call is made
     */
    function check_callArityMismatch(bytes32 a, bool excess) public view {
        Expressions.Node[] memory nodes = new Expressions.Node[](3);
        nodes[0] = node(Expressions.Kind.Literal, "address", abi.encode(address(this)));
        nodes[1] = node(Expressions.Kind.Literal, "bytes32", abi.encode(a));
        nodes[2] = node(Expressions.Kind.Call, "bytes32", "");
        nodes[2].arguments = excess ? "(bytes32)" : "(bytes32,bytes32)";
        nodes[2].refs = new uint256[](excess ? 3 : 2);
        nodes[2].refs[1] = 1;
        if (excess) nodes[2].refs[2] = 1;
        (bool ok, bytes memory out) = evaluate(nodes, 2);
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(AbiCodec.ComponentCountMismatch.selector, excess ? 1 : 2, excess ? 2 : 1));
    }

    /**
     * @dev `LEN` and `PAYLOAD` at a non-final path position: as a tuple
     *      component index, as an index into a nested `uint8[]` and as an
     *      index into a `bytes[]`, each reverts ElementIndexOutOfBounds with
     *      the sentinel and the count of two
     */
    function check_nonterminalSentinels(bytes32 w, bool payload, uint8 shape) public view {
        vm.assume(shape < 3);
        int256 sentinel = type(int256).min + (payload ? int256(1) : int256(0));
        int256[] memory path = new int256[](shape == 0 ? 2 : 3);
        bytes memory data;
        string memory t;
        if (shape == 0) {
            t = "(bytes32,bytes32)";
            data = abi.encode(w, w);
            path[0] = sentinel;
        } else if (shape == 1) {
            t = "(bytes32,uint8[])";
            uint8[] memory values = new uint8[](2);
            data = abi.encode(w, values);
            path[0] = 1;
            path[1] = sentinel;
        } else {
            t = "(bytes[])";
            bytes[] memory values = new bytes[](2);
            values[0] = abi.encode(w);
            values[1] = "";
            data = abi.encode(values);
            path[1] = sentinel;
        }
        InputParam memory p =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
        (bool ok, bytes memory out) = address(core).staticcall(abi.encodeCall(Assertions.nav, (p, t, path)));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(ElementIndexOutOfBounds.selector, sentinel, uint256(2)));
    }

    /**
     * @dev Every case on a real EVM
     */
    function test_constructorGeometries() public view {
        check_dynamicTupleConstructor(7, "ab", false);
        check_dynamicTupleConstructor(255, "ab", true);
        check_narrowArrayConstructor(bytes32(uint256(1)), bytes32(uint256(2)), false);
        check_narrowArrayConstructor(bytes32(uint256(256)), bytes32(uint256(2)), false);
        check_narrowArrayConstructor(bytes32(uint256(1)), bytes32(uint256(256)), false);
        check_narrowArrayConstructor(bytes32(uint256(256)), bytes32(uint256(256)), true);
        check_callArityMismatch(bytes32("a"), false);
        check_callArityMismatch(bytes32("a"), true);
        for (uint8 s; s < 3; s++) {
            check_nonterminalSentinels(bytes32("a"), false, s);
            check_nonterminalSentinels(bytes32("a"), true, s);
        }
    }
}

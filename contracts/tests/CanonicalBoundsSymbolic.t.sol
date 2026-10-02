// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Collections.sol";
import "../Expressions.sol";
import "../lib/AbiCodec.sol";

/**
 * @notice Halmos properties pinning the EXACT rejection of non-canonical
 *         encodings: hostile element counts and payload lengths nested in a
 *         dynamic tuple, unpack's count bound for every element shape, the
 *         offset named for loose offsets and trailing bytes, and the
 *         Expressions constructors over dynamic elements and malformed
 *         components. Run with `pnpm halmos`.
 * @dev CodecCanonicalSymbolic and NarrowWordsSymbolic prove acceptance
 *      against solc; these prove WHICH error a rejection raises, since a
 *      revert-only property cannot tell InvalidValue from a Panic: a bound
 *      moved after the multiplication it protects still "rejects". Geometry
 *      (offsets, counts, lengths) is a literal per case; every content word
 *      stays symbolic.
 */
contract CanonicalBoundsSymbolicTest is Test {
    struct ArrayString {
        uint8[] numbers;
        string text;
    }

    Assertions core;
    Collections collections;
    Expressions expressions;

    uint256 constant PADDING_MASK = (uint256(1) << 240) - 1;

    function setUp() public {
        core = new Assertions();
        collections = new Collections();
        expressions = new Expressions();
    }

    // ============ Oracles and wrappers ============

    function validate(string calldata t, bytes calldata data) external pure {
        AbiCodec.validate(bytes(t), data);
    }

    function decodeArrayString(bytes calldata data) external pure returns (bytes memory) {
        return abi.encode(abi.decode(data, (ArrayString)));
    }

    /**
     * @dev Whether solc decodes `data` with `decoder` and re-encoding what it
     *      decoded reproduces `data` byte for byte
     */
    function canonical(bytes4 decoder, bytes memory data) internal view returns (bool) {
        (bool ok, bytes memory out) = address(this).staticcall(abi.encodeWithSelector(decoder, data));
        return ok && keccak256(abi.decode(out, (bytes))) == keccak256(data);
    }

    function invalidValue(uint256 offset) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(AbiCodec.InvalidValue.selector, offset);
    }

    function cleanPadding(bytes32 content) internal pure returns (bool) {
        return uint256(content) & PADDING_MASK == 0;
    }

    // ============ Bounds inside a dynamic tuple ============

    /**
     * @dev `(uint8[],string)`: the inner element count and the string length
     *      are bounded against the remaining data BEFORE any arithmetic on
     *      them. A count past the data is InvalidValue at the word that
     *      follows the count (where elements would begin), a length past it
     *      InvalidValue at the length word once the element passed its range
     *      check (an out-of-range element is named first), never a Panic; lengths that would overflow
     *      `n + 31` or `count * 32` are included. The canonical geometry is
     *      accepted exactly when solc decodes it and re-encodes it equal.
     */
    function check_nestedCountsAreBoundedBeforeMultiplying(bytes32 a, bytes32 text, uint8 lengthCase) public view {
        vm.assume(lengthCase < 5);
        uint256 count = 1;
        uint256 length = 2;
        if (lengthCase == 1) count = type(uint256).max;
        else if (lengthCase == 2) count = uint256(1) << 251;
        else if (lengthCase == 3) length = type(uint256).max;
        else if (lengthCase == 4) length = type(uint256).max - 30;
        bytes memory data = abi.encode(uint256(32), uint256(64), uint256(128), count, a, length, text);
        (bool ok, bytes memory out) =
            address(this).staticcall(abi.encodeCall(this.validate, ("(uint8[],string)", data)));
        if (lengthCase == 0) {
            assertEq(ok, canonical(this.decodeArrayString.selector, data), "validate and solc disagree");
            return;
        }
        assertFalse(ok);
        // The count word sits at 96 and the elements would begin at 128, where the count bound and the
        // element's range check both report; the length word sits at 160 and is reached only past them.
        bool lengthReached = lengthCase >= 3 && uint256(a) <= 255;
        assertEq(out, invalidValue(lengthReached ? 160 : 128), "a hostile count or length is not named");
    }

    /**
     * @dev `unpack` bounds the element count against the remaining data for
     *      every element shape (one word, dynamic, fixed array of words):
     *      the maximum, an overflowing and a one-past-fit count each revert
     *      InvalidValue(64), before any offset or word is read
     */
    function check_unpackCountIsBoundedBeforeMultiplying(uint8 typeCase, uint8 countCase, bytes32 w0, bytes32 w1)
        public
        view
    {
        vm.assume(typeCase < 3 && countCase < 3);
        string memory elementType = typeCase == 0 ? "uint8" : typeCase == 1 ? "string" : "uint8[2]";
        // Two words follow the count: uint8 and string fit two elements, uint8[2] fits one.
        uint256 count;
        if (countCase == 0) count = type(uint256).max;
        else if (countCase == 1) count = uint256(1) << 251;
        else count = typeCase == 2 ? 2 : 3;
        bytes memory data = abi.encode(uint256(32), count, w0, w1);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, (elementType, data)));
        assertFalse(ok);
        assertEq(out, invalidValue(64), "a hostile count is not named at the elements' start");
    }

    // ============ Named offsets ============

    /**
     * @dev A `string[]` of two strings through `unpack`: a loose or backward
     *      second offset is InvalidValue at that offset word (96), a loose
     *      first offset at its word (64), and a trailing byte at its own
     *      offset (the byte after the last tail). With dirty padding in a
     *      string the walk stops there first, so only the selector is pinned.
     */
    function check_unpackNamesLooseOffsetsAndTrailingBytes(bytes32 a, bytes32 b, uint8 geometry) public view {
        vm.assume(geometry < 4);
        bytes memory data;
        uint256 expected;
        if (geometry == 0) {
            data = abi.encode(
                uint256(32), uint256(2), uint256(64), uint256(160), uint256(2), a, uint256(0), uint256(2), b
            );
            expected = 96;
        } else if (geometry == 1) {
            data = abi.encode(uint256(32), uint256(2), uint256(64), uint256(64), uint256(2), a, uint256(2), b);
            expected = 96;
        } else if (geometry == 2) {
            data = bytes.concat(
                abi.encode(uint256(32), uint256(2), uint256(64), uint256(128), uint256(2), a, uint256(2), b), hex"00"
            );
            expected = 256;
        } else {
            data = abi.encode(
                uint256(32), uint256(2), uint256(96), uint256(160), uint256(0), uint256(2), a, uint256(2), b
            );
            expected = 64;
        }
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, ("string", data)));
        assertFalse(ok);
        bool reached = geometry == 3 || (cleanPadding(a) && (geometry != 2 || cleanPadding(b)));
        if (reached) assertEq(out, invalidValue(expected), "the loose offset or trailing byte is not named");
        else assertEq(bytes4(out), AbiCodec.InvalidValue.selector);
    }

    /**
     * @dev `validate` of `(uint8[2],string)`: a top envelope word other than
     *      0x20 is InvalidValue(0) before anything else is read, a loose
     *      string offset is named at its head word (96) once the static
     *      words passed their range check, and trailing bytes are reported
     *      at the first trailing byte, as `unpack` also reports.
     */
    function check_validateNamesTheOffendingWord(bytes32 a, bytes32 b, bytes32 text, uint8 geometry) public view {
        vm.assume(geometry < 3);
        bytes memory data;
        if (geometry == 0) data = abi.encode(uint256(64), uint256(0), a, b, uint256(96), uint256(2), text);
        else if (geometry == 1) data = abi.encode(uint256(32), a, b, uint256(128), uint256(0), uint256(2), text);
        else data = bytes.concat(abi.encode(uint256(32), a, b, uint256(96), uint256(2), text), hex"00");
        (bool ok, bytes memory out) =
            address(this).staticcall(abi.encodeCall(this.validate, ("(uint8[2],string)", data)));
        assertFalse(ok);
        bool inRange = uint256(a) <= 255 && uint256(b) <= 255;
        if (geometry == 0) {
            assertEq(out, invalidValue(0), "a wrong envelope word is not named first");
        } else if (geometry == 1 && inRange) {
            assertEq(out, invalidValue(96), "a loose offset is not named");
        } else if (geometry == 2 && inRange && cleanPadding(text)) {
            assertEq(out, invalidValue(data.length - 1), "trailing bytes");
        } else {
            assertEq(bytes4(out), AbiCodec.InvalidValue.selector);
        }
    }

    // ============ Expressions constructors ============

    /**
     * @dev An Array node over DYNAMIC elements: zero, one or two string
     *      literals pack as solc's `abi.encode(string[])`, and a referenced
     *      value that is not a canonical string envelope (a bare word) is
     *      refused with InvalidValue rather than packed
     */
    function check_dynamicElementArrayConstructor(bytes2 c0, bytes2 c1, bytes32 w, uint8 countCase) public view {
        // A literal count per case: a symbolic array size is a NotConcreteError.
        uint256 count;
        if (countCase == 0) {
            count = 0;
        } else if (countCase == 1) {
            count = 1;
        } else if (countCase == 2) {
            count = 2;
        } else {
            vm.assume(countCase == 3);
            count = 0;
        }
        string[] memory strings = new string[](count);
        if (count >= 1) strings[0] = string(abi.encodePacked(c0));
        if (count == 2) strings[1] = string(abi.encodePacked(c1));
        Expressions.Node[] memory nodes = new Expressions.Node[](4);
        nodes[0] = node(Expressions.Kind.Literal, "string", abi.encode(string(abi.encodePacked(c0))));
        nodes[1] = node(Expressions.Kind.Literal, "string", abi.encode(string(abi.encodePacked(c1))));
        nodes[2] = node(Expressions.Kind.Literal, "bytes32", abi.encode(w));
        nodes[3] = node(Expressions.Kind.Array, "string[]", "");
        nodes[3].arguments = "string";
        if (countCase == 3) {
            nodes[3].refs = new uint256[](1);
            nodes[3].refs[0] = 2;
        } else {
            nodes[3].refs = new uint256[](count);
            for (uint256 i; i < count; i++) {
                nodes[3].refs[i] = i;
            }
        }
        (bool ok, bytes memory out) = evaluate(nodes, 3);
        if (countCase == 3) {
            assertFalse(ok, "a bare word is packed as a string");
            assertEq(bytes4(out), AbiCodec.InvalidValue.selector);
            return;
        }
        assertTrue(ok);
        assertEq(out, abi.encode(strings), "the Array node and solc disagree on string[]");
    }

    /**
     * @dev A Tuple node checks each referenced value against its component:
     *      a bare word where `(uint8,string)` wants its string reverts
     *      InvalidComponentEnvelope(1, 32, the word), and a string envelope
     *      where it wants the uint8 reverts InvalidComponentLength(0, 32, 96)
     */
    function check_tupleComponentShapeIsChecked(bytes32 w, bytes2 text, bool staticSlot) public view {
        Expressions.Node[] memory nodes = new Expressions.Node[](3);
        nodes[0] = node(Expressions.Kind.Literal, "bytes32", abi.encode(w));
        nodes[1] = node(Expressions.Kind.Literal, "string", abi.encode(string(abi.encodePacked(text))));
        nodes[2] = node(Expressions.Kind.Tuple, "(uint8,string)", "");
        nodes[2].arguments = "(uint8,string)";
        nodes[2].refs = new uint256[](2);
        bytes memory expected;
        if (staticSlot) {
            nodes[2].refs[0] = 1;
            nodes[2].refs[1] = 1;
            expected =
                abi.encodeWithSelector(AbiCodec.InvalidComponentLength.selector, uint256(0), uint256(32), uint256(96));
        } else {
            vm.assume(uint256(w) <= 255);
            nodes[2].refs[0] = 0;
            nodes[2].refs[1] = 0;
            expected = abi.encodeWithSelector(AbiCodec.InvalidComponentEnvelope.selector, uint256(1), uint256(32), w);
        }
        (bool ok, bytes memory out) = evaluate(nodes, 2);
        assertFalse(ok);
        assertEq(out, expected, "a component of the wrong shape is not named");
    }

    // ============ Concrete sweep ============

    function test_boundsGeometries() public view {
        for (uint8 g; g < 5; g++) {
            check_nestedCountsAreBoundedBeforeMultiplying(bytes32(uint256(7)), bytes32("ab"), g);
            check_nestedCountsAreBoundedBeforeMultiplying(bytes32(uint256(256)), bytes32("ab"), g);
        }
        for (uint8 t; t < 3; t++) {
            for (uint8 c; c < 3; c++) {
                check_unpackCountIsBoundedBeforeMultiplying(t, c, bytes32(uint256(1)), bytes32(uint256(2)));
            }
        }
        for (uint8 g; g < 4; g++) {
            check_unpackNamesLooseOffsetsAndTrailingBytes(bytes32("ab"), bytes32("cd"), g);
            check_unpackNamesLooseOffsetsAndTrailingBytes(bytes32(uint256(1)), bytes32("cd"), g);
            check_unpackNamesLooseOffsetsAndTrailingBytes(bytes32("ab"), bytes32(uint256(1)), g);
            check_dynamicElementArrayConstructor("ab", "cd", bytes32(uint256(32)), g);
            check_dynamicElementArrayConstructor("", "cd", bytes32(uint256(7)), g);
        }
        for (uint8 g; g < 3; g++) {
            check_validateNamesTheOffendingWord(bytes32(uint256(7)), bytes32(uint256(8)), bytes32("ab"), g);
            check_validateNamesTheOffendingWord(bytes32(uint256(256)), bytes32(uint256(8)), bytes32("ab"), g);
            check_validateNamesTheOffendingWord(bytes32(uint256(7)), bytes32(uint256(8)), bytes32(uint256(1)), g);
        }
        check_tupleComponentShapeIsChecked(bytes32(uint256(7)), "ab", true);
        check_tupleComponentShapeIsChecked(bytes32(uint256(7)), "ab", false);
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

    function evaluate(Expressions.Node[] memory nodes, uint256 result) internal view returns (bool, bytes memory) {
        return address(expressions)
            .staticcall(
                abi.encodeCall(
                    Expressions.evaluate, (Expressions.Expression(address(core), nodes, result), new bytes[](0))
                )
            );
    }
}

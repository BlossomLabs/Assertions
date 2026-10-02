// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Collections.sol";
import "../Expressions.sol";
import "../lib/ERC8211.sol";
import "../lib/AbiCodec.sol";

/**
 * @notice Halmos properties: narrow words nested in DYNAMIC values are range
 *         checked on every path, the codec's, nav's re-encoding and every
 *         Expressions node, exactly as solc's decoder checks them. Run with
 *         `pnpm halmos`.
 * @dev The single-word, static-tuple and uint8[][] shapes are proved in
 *      AbiCodecSymbolic and NavSymbolic; these add a narrow word beside an
 *      offset and a tail. The oracle is solc's abi.decode. solc tolerates
 *      dirty bytes padding and loose offsets that this repo rejects by
 *      doctrine, so each property claims agreement on CANONICAL data only:
 *      accepted exactly when solc decodes the value and re-encoding it
 *      reproduces the bytes. Offsets and lengths are concrete; the narrow
 *      words and the string content word stay symbolic.
 */
contract NarrowWordsSymbolicTest is Test {
    struct AddressUint8 {
        address a;
        uint8 u;
    }

    struct Uint8Bool {
        uint8 u;
        bool b;
    }

    struct AddressBytes {
        address a;
        bytes b;
    }

    struct Uint8String {
        uint8 u;
        string s;
    }

    Assertions core;
    Collections collections;
    Expressions expressions;

    function setUp() public {
        core = new Assertions();
        collections = new Collections();
        expressions = new Expressions();
    }

    // ============ solc oracles ============

    function solcUint8String(bytes calldata d) external pure returns (uint8, string memory) {
        return abi.decode(d, (uint8, string));
    }

    function solcStringAddress(bytes calldata d) external pure returns (string memory, address) {
        return abi.decode(d, (string, address));
    }

    function solcBoolBytes(bytes calldata d) external pure returns (bool, bytes memory) {
        return abi.decode(d, (bool, bytes));
    }

    function solcNested(bytes calldata d) external pure returns (AddressUint8 memory, string memory) {
        return abi.decode(d, (AddressUint8, string));
    }

    function solcPairs(bytes calldata d) external pure returns (Uint8Bool[] memory) {
        return abi.decode(d, (Uint8Bool[]));
    }

    function solcWrappedTuple(bytes calldata d) external pure returns (Uint8String memory) {
        return abi.decode(d, (Uint8String));
    }

    function solcTupleArray(bytes calldata d) external pure returns (AddressBytes[] memory) {
        return abi.decode(d, (AddressBytes[]));
    }

    function solcUint8Array(bytes calldata d) external pure returns (uint8[] memory) {
        return abi.decode(d, (uint8[]));
    }

    function solcStringArray(bytes calldata d) external pure returns (string[] memory) {
        return abi.decode(d, (string[]));
    }

    /**
     * @dev Whether solc decodes `data` with `decoder` and re-encoding what it
     *      decoded reproduces `canonicalOf(decoded)` equal to `data`
     */
    function solcCanonical(bytes4 decoder, bytes memory data, uint8 shape) internal view returns (bool) {
        (bool ok, bytes memory raw) = address(this).staticcall(abi.encodeWithSelector(decoder, data));
        if (!ok) return false;
        bytes memory again;
        if (shape == 0) {
            (uint8 u, string memory s) = abi.decode(raw, (uint8, string));
            again = abi.encode(u, s);
        } else if (shape == 1) {
            (string memory s, address a) = abi.decode(raw, (string, address));
            again = abi.encode(s, a);
        } else if (shape == 2) {
            (bool b, bytes memory x) = abi.decode(raw, (bool, bytes));
            again = abi.encode(b, x);
        } else if (shape == 3) {
            (AddressUint8 memory t, string memory s) = abi.decode(raw, (AddressUint8, string));
            again = abi.encode(t, s);
        } else if (shape == 4) {
            again = abi.encode(abi.decode(raw, (Uint8Bool[])));
        } else if (shape == 5) {
            again = abi.encode(abi.decode(raw, (Uint8String)));
        } else if (shape == 6) {
            again = abi.encode(abi.decode(raw, (AddressBytes[])));
        } else if (shape == 7) {
            again = abi.encode(abi.decode(raw, (uint8[])));
        } else {
            again = abi.encode(abi.decode(raw, (string[])));
        }
        return keccak256(again) == keccak256(data);
    }

    // ============ Codec ============

    /**
     * @dev A dynamic tuple with narrow words beside an offset and a string
     *      tail: packArray accepts the single-value encoding exactly when the
     *      tuple is canonical and solc decodes it
     */
    function check_dynamicTupleWordsMatchSolc(uint8 shapeCase, bytes32 w0, bytes32 w1, bytes32 content) public view {
        vm.assume(shapeCase < 4);
        string memory descriptor;
        bytes memory body;
        bytes4 decoder;
        if (shapeCase == 0) {
            descriptor = "(uint8,string)";
            body = abi.encodePacked(w0, uint256(64), uint256(2), content);
            decoder = this.solcUint8String.selector;
        } else if (shapeCase == 1) {
            descriptor = "(string,address)";
            body = abi.encodePacked(uint256(64), w0, uint256(2), content);
            decoder = this.solcStringAddress.selector;
        } else if (shapeCase == 2) {
            descriptor = "(bool,bytes)";
            body = abi.encodePacked(w0, uint256(64), uint256(2), content);
            decoder = this.solcBoolBytes.selector;
        } else {
            descriptor = "((address,uint8),string)";
            body = abi.encodePacked(w0, w1, uint256(96), uint256(2), content);
            decoder = this.solcNested.selector;
        }
        bool canonical = solcCanonical(decoder, body, shapeCase);
        bytes[] memory values = new bytes[](1);
        values[0] = bytes.concat(abi.encode(uint256(32)), body);
        (bool ok,) = address(collections).staticcall(abi.encodeCall(Collections.packArray, (descriptor, values)));
        assertEq(ok, canonical, "the codec and solc disagree on a dynamic tuple's words");
    }

    /**
     * @dev A dynamic array of static tuples with narrow words: unpackArray
     *      accepts exactly the canonical encodings solc decodes, and returns
     *      each element as its own encoding
     */
    function check_arrayOfNarrowTuplesMatchesSolc(bytes32[4] memory w) public view {
        bytes memory encoded = abi.encodePacked(uint256(32), uint256(2), w);
        bool canonical = solcCanonical(this.solcPairs.selector, encoded, 4);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, ("(uint8,bool)", encoded)));
        assertEq(ok, canonical, "unpack and solc disagree on (uint8,bool)[]");
        if (ok) {
            bytes[] memory values = abi.decode(out, (bytes[]));
            assertEq(values.length, 2);
            assertEq(values[0], abi.encodePacked(w[0], w[1]));
            assertEq(values[1], abi.encodePacked(w[2], w[3]));
        }
    }

    /**
     * @dev Completeness for a flat uint8[] of zero to three elements: unpack
     *      accepts exactly the canonical encodings solc decodes (the soundness
     *      direction alone is AbiCodecSymbolic's), each element solc's
     */
    function check_unpackUint8ArrayIsComplete(uint8 lengthCase, bytes32[3] memory w) public view {
        uint256 count;
        if (lengthCase == 0) {
            count = 0;
        } else if (lengthCase == 1) {
            count = 1;
        } else if (lengthCase == 2) {
            count = 2;
        } else {
            vm.assume(lengthCase == 3);
            count = 3;
        }
        bytes memory encoded = abi.encodePacked(uint256(32), count);
        for (uint256 i; i < count; i++) {
            encoded = bytes.concat(encoded, w[i]);
        }
        bool canonical = solcCanonical(this.solcUint8Array.selector, encoded, 7);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, ("uint8", encoded)));
        assertEq(ok, canonical, "unpack and solc disagree on uint8[]");
        if (ok) {
            bytes[] memory values = abi.decode(out, (bytes[]));
            assertEq(values.length, count);
            for (uint256 i; i < count; i++) {
                assertEq(values[i], abi.encode(w[i]));
            }
        }
    }

    /**
     * @dev Completeness for a string[] holding one string of 0, 2, 32 or 33
     *      bytes (padding and the word boundary): unpack accepts exactly the
     *      canonical encodings solc decodes, the element solc's string in its
     *      own 0x20 envelope
     */
    function check_unpackStringArrayIsComplete(uint8 lengthCase, bytes32 c0, bytes32 c1) public view {
        bytes memory encoded;
        if (lengthCase == 0) {
            encoded = abi.encodePacked(uint256(32), uint256(1), uint256(32), uint256(0));
        } else if (lengthCase == 1) {
            encoded = abi.encodePacked(uint256(32), uint256(1), uint256(32), uint256(2), c0);
        } else if (lengthCase == 2) {
            encoded = abi.encodePacked(uint256(32), uint256(1), uint256(32), uint256(32), c0);
        } else {
            vm.assume(lengthCase == 3);
            encoded = abi.encodePacked(uint256(32), uint256(1), uint256(32), uint256(33), c0, c1);
        }
        bool canonical = solcCanonical(this.solcStringArray.selector, encoded, 8);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, ("string", encoded)));
        assertEq(ok, canonical, "unpack and solc disagree on string[]");
        if (ok) {
            bytes[] memory values = abi.decode(out, (bytes[]));
            assertEq(values.length, 1);
            string[] memory expected = abi.decode(encoded, (string[]));
            assertEq(values[0], abi.encode(expected[0]));
        }
    }

    /**
     * @dev A string's padding must be zero, and the first dirty padding byte is
     *      reported at its exact offset: a two-byte string inside a string[],
     *      its content word symbolic. The reported offset is checked rather
     *      than recomputed: that byte is nonzero and every padding byte before
     *      it is zero (a loop branching on each byte made the paths
     *      exponential).
     */
    function check_dirtyPaddingNamesItsByte(bytes32 content) public view {
        bytes memory encoded = abi.encodePacked(uint256(32), uint256(1), uint256(32), uint256(2), content);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, ("string", encoded)));
        uint256 word = uint256(content);
        if (word & ((uint256(1) << 240) - 1) == 0) {
            assertTrue(ok, "clean padding is refused");
            return;
        }
        assertFalse(ok);
        assertEq(bytes4(out), AbiCodec.InvalidValue.selector);
        uint256 k = abi.decode(slice(out, 4), (uint256)) - 128;
        assertTrue(k >= 2 && k <= 31, "the offset is outside the padding");
        assertTrue(content[k] != 0, "the named byte is clean");
        // Bytes 2 .. k - 1: shift the content's first two bytes out, keep k - 2 bytes.
        assertEq(k == 2 ? 0 : (word << 16) >> (256 - 8 * (k - 2)), 0, "a dirtier byte comes earlier");
    }

    function slice(bytes memory b, uint256 from) internal pure returns (bytes memory out) {
        out = new bytes(b.length - from);
        for (uint256 i; i < out.length; i++) {
            out[i] = b[from + i];
        }
    }

    // ============ nav ============

    function nav(bytes memory data, string memory types) internal view returns (bool ok, bytes memory out) {
        int256[] memory path = new int256[](1);
        InputParam memory p =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
        (ok, out) = address(core).staticcall(abi.encodeCall(Assertions.nav, (p, types, path)));
    }

    /**
     * @dev nav re-encodes a dynamic tuple, and an array of dynamic tuples,
     *      with narrow words: it returns a value exactly when that value is
     *      canonical and solc decodes it, and then returns it byte for byte
     */
    function check_navReencodedWordsMatchSolc(bool arrayCase, bytes32 w, bytes32 content) public view {
        bytes memory data;
        bool canonical;
        bool ok;
        bytes memory out;
        if (!arrayCase) {
            data = abi.encodePacked(uint256(32), w, uint256(64), uint256(2), content);
            canonical = solcCanonical(this.solcWrappedTuple.selector, data, 5);
            (ok, out) = nav(data, "((uint8,string))");
        } else {
            data = abi.encodePacked(uint256(32), uint256(1), uint256(32), w, uint256(64), uint256(2), content);
            canonical = solcCanonical(this.solcTupleArray.selector, data, 6);
            (ok, out) = nav(data, "((address,bytes)[])");
        }
        assertEq(ok, canonical, "nav and solc disagree on a re-encoded value's words");
        if (ok) assertEq(out, data, "nav's re-encoding differs from solc's");
    }

    // ============ Expressions ============

    /**
     * @dev A Literal node typed as a dynamic tuple with a narrow word is
     *      validated like the codec: the evaluation succeeds exactly when the
     *      value is canonical and solc decodes it
     */
    function check_nodeValueWordsMatchSolc(bytes32 w, bytes32 content) public view {
        bytes memory body = abi.encodePacked(w, uint256(64), uint256(2), content);
        bool canonical = solcCanonical(this.solcUint8String.selector, body, 0);
        Expressions.Node[] memory nodes = new Expressions.Node[](1);
        nodes[0] = Expressions.Node(
            Expressions.Kind.Literal,
            "(uint8,string)",
            bytes.concat(abi.encode(uint256(32)), body),
            new uint256[](0),
            bytes4(0),
            ""
        );
        (bool ok,) = address(expressions)
            .staticcall(
                abi.encodeCall(Expressions.evaluate, (Expressions.Expression(address(core), nodes, 0), new bytes[](0)))
            );
        assertEq(ok, canonical, "a node's value and solc disagree on a narrow word");
    }
}

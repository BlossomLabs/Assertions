// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";
import "../lib/AbiCodec.sol";

/**
 * @notice Halmos properties: nested geometries are accepted exactly when
 *         solc decodes them AND re-encodes them byte for byte: a fixed array
 *         nested in a dynamic tuple, fixed arrays as the elements of a
 *         dynamic array, and a two-element `string[]`, each over tight and
 *         loose offsets, a backward offset, trailing bytes and hostile
 *         counts and lengths. Run with `pnpm halmos`.
 * @dev Geometry (offsets, counts, lengths) is a literal per case; narrow
 *      words and payload words stay symbolic. A loose offset points at a
 *      concrete length word so solc's decode stays concrete. solc accepts
 *      some loose offsets and trailing bytes that this repo rejects by
 *      doctrine, which is why the oracle demands re-encoding equality and
 *      not decoding alone. CanonicalBoundsSymbolic pins WHICH error each
 *      rejection raises.
 */
contract CodecCanonicalSymbolicTest is Test {
    struct FixedString {
        uint8[2] numbers;
        string text;
    }
    Collections collections;

    function setUp() public {
        collections = new Collections();
    }

    function validate(string calldata t, bytes calldata data) external pure {
        AbiCodec.validate(bytes(t), data);
    }

    function decodeFixedString(bytes calldata data) external pure returns (bytes memory) {
        return abi.encode(abi.decode(data, (FixedString)));
    }

    function decodeFixedArray(bytes calldata data) external pure returns (bytes memory) {
        return abi.encode(abi.decode(data, (uint8[2][])));
    }

    function decodeStrings(bytes calldata data) external pure returns (bytes memory) {
        return abi.encode(abi.decode(data, (string[])));
    }

    function canonical(bytes4 decoder, bytes memory data) internal view returns (bool) {
        (bool ok, bytes memory out) = address(this).staticcall(abi.encodeWithSelector(decoder, data));
        return ok && keccak256(abi.decode(out, (bytes))) == keccak256(data);
    }

    /**
     * @dev `(uint8[2],string)`: tight offsets, a loose string offset (128,
     *      over a stale zero word, which solc decodes), a loose top offset
     *      (64) and a trailing byte; `validate` agrees with the oracle on
     *      every narrow word and payload word
     */
    function check_nestedFixedTupleCanonical(bytes32 a, bytes32 b, bytes32 text, uint8 geometry) public view {
        vm.assume(geometry < 4);
        bytes memory data;
        if (geometry == 0) data = abi.encode(uint256(32), a, b, uint256(96), uint256(2), text);
        // Loose offsets point at concrete length words, including valid solc decodes.
        else if (geometry == 1) data = abi.encode(uint256(32), a, b, uint256(128), uint256(0), uint256(2), text);
        else if (geometry == 2) data = abi.encode(uint256(64), uint256(0), a, b, uint256(96), uint256(2), text);
        else data = bytes.concat(abi.encode(uint256(32), a, b, uint256(96), uint256(2), text), hex"00");
        (bool ok,) = address(this).staticcall(abi.encodeCall(this.validate, ("(uint8[2],string)", data)));
        assertEq(ok, canonical(this.decodeFixedString.selector, data));
    }

    /**
     * @dev `uint8[2][]` over four symbolic words: a count of two is accepted
     *      exactly when every word is a uint8 and each element comes back as
     *      its two words; a count of zero leaves trailing words and the
     *      maximum count overruns the data, both rejected like solc
     */
    function check_nestedFixedArrayCanonical(bytes32[4] memory w, uint8 countCase) public view {
        vm.assume(countCase < 3);
        uint256 count;
        if (countCase == 0) count = 2;
        else if (countCase == 1) count = 0;
        else count = type(uint256).max;
        bytes memory data = abi.encode(uint256(32), count, w[0], w[1], w[2], w[3]);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, ("uint8[2]", data)));
        assertEq(ok, canonical(this.decodeFixedArray.selector, data));
        if (ok) {
            bytes[] memory values = abi.decode(out, (bytes[]));
            assertEq(values.length, 2);
            assertEq(values[0], abi.encode(w[0], w[1]));
            assertEq(values[1], abi.encode(w[2], w[3]));
        }
    }

    /**
     * @dev `string[]` of two two-byte strings through `unpack`: tight
     *      offsets, a loose second offset (160, over a stale word), a second
     *      offset pointing back at the first string (64) and a trailing byte;
     *      accepted exactly when canonical, each element then solc's string
     *      in its own 0x20 envelope
     */
    function check_twoStringsCanonical(bytes32 a, bytes32 b, uint8 geometry) public view {
        vm.assume(geometry < 4);
        bytes memory data;
        if (geometry == 0) {
            data = abi.encode(uint256(32), uint256(2), uint256(64), uint256(128), uint256(2), a, uint256(2), b);
        } else if (geometry == 1) {
            data = abi.encode(
                uint256(32), uint256(2), uint256(64), uint256(160), uint256(2), a, uint256(0), uint256(2), b
            );
        } else if (geometry == 2) {
            data = abi.encode(uint256(32), uint256(2), uint256(64), uint256(64), uint256(2), a, uint256(2), b);
        } else {
            data = bytes.concat(
                abi.encode(uint256(32), uint256(2), uint256(64), uint256(128), uint256(2), a, uint256(2), b), hex"00"
            );
        }
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, ("string", data)));
        assertEq(ok, canonical(this.decodeStrings.selector, data));
        if (ok) {
            string[] memory decoded = abi.decode(data, (string[]));
            bytes[] memory values = abi.decode(out, (bytes[]));
            assertEq(values.length, 2);
            assertEq(values[0], abi.encode(decoded[0]));
            assertEq(values[1], abi.encode(decoded[1]));
        }
    }

    /**
     * @dev The string nested in `(uint8[2],string)` at lengths 0, 2, 33 (one
     *      word past the data) and the maximum: accepted exactly when solc
     *      decodes and re-encodes it, so a hostile length is rejected rather
     *      than fed to the padding arithmetic
     */
    function check_nestedPayloadLengthBounds(uint8 a, uint8 b, bytes32 text, uint8 lengthCase) public view {
        vm.assume(lengthCase < 4);
        uint256 length;
        if (lengthCase == 0) length = 0;
        else if (lengthCase == 1) length = 2;
        else if (lengthCase == 2) length = 33;
        else length = type(uint256).max;
        bytes memory data = abi.encode(uint256(32), a, b, uint256(96), length, text);
        (bool ok,) = address(this).staticcall(abi.encodeCall(this.validate, ("(uint8[2],string)", data)));
        assertEq(ok, canonical(this.decodeFixedString.selector, data));
    }

    /**
     * @dev Every geometry on a real EVM, with in-range and out-of-range words
     */
    function test_canonicalGeometries() public view {
        for (uint8 g; g < 4; g++) {
            check_nestedPayloadLengthBounds(7, 8, bytes32("ab"), g);
            check_nestedFixedTupleCanonical(bytes32(uint256(7)), bytes32(uint256(8)), bytes32("ab"), g);
            check_nestedFixedTupleCanonical(bytes32(uint256(256)), bytes32(uint256(8)), bytes32("ab"), g);
            check_twoStringsCanonical(bytes32("ab"), bytes32("cd"), g);
            check_twoStringsCanonical(bytes32(uint256(1)), bytes32("cd"), g);
        }
        bytes32[4] memory w = [bytes32(uint256(1)), bytes32(uint256(2)), bytes32(uint256(3)), bytes32(uint256(4))];
        for (uint8 g; g < 3; g++) {
            check_nestedFixedArrayCanonical(w, g);
        }
        w[3] = bytes32(uint256(256));
        check_nestedFixedArrayCanonical(w, 0);
    }
}

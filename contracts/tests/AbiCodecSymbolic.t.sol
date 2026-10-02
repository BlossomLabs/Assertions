// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Collections.sol";
import "../Operations.sol";

/**
 * @notice Halmos properties over AbiCodec's pack/unpack, run with `pnpm halmos`.
 * @dev `check_` functions are invisible to both `forge test` and `hardhat test`;
 *      Halmos explores them for every value of the symbolic arguments at the
 *      lengths it is given. The oracle is solc's own abi.encode, never a
 *      re-derivation of AbiCodec's layout.
 */
contract AbiCodecSymbolicTest is Test {
    Collections collections;
    Operations ops;

    struct Pair {
        int8 a;
        bool b;
    }

    function setUp() public {
        collections = new Collections();
        ops = new Operations();
    }

    function check_packArrayMatchesSolc_uint8(uint8 a, uint8 b, uint8 c) public view {
        bytes[] memory values = new bytes[](3);
        values[0] = abi.encode(a);
        values[1] = abi.encode(b);
        values[2] = abi.encode(c);
        uint8[] memory expected = new uint8[](3);
        expected[0] = a;
        expected[1] = b;
        expected[2] = c;
        assertEq(packs("uint8", values), abi.encode(expected));
    }

    function check_packArrayMatchesSolc_string(string memory a, string memory b) public view {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(a);
        values[1] = abi.encode(b);
        string[] memory expected = new string[](2);
        expected[0] = a;
        expected[1] = b;
        assertEq(packs("string", values), abi.encode(expected));
    }

    /**
     * @dev No wrong-answer machine: unpackArray either reverts or was handed an
     *      encoding solc's own decoder accepts, yielding the same elements.
     *      Re-packing is not the oracle: pack shares unpack's validation, so a
     *      round-trip would pass on a misconception common to both. Halmos
     *      cannot follow a memory read at a symbolic offset, so the head words
     *      are case-split into concrete candidates (canonical and malformed)
     *      per path; the body words stay fully symbolic.
     */
    function check_unpackArrayAcceptsOnlyCanonical_uint8(
        uint8 offsetCase,
        uint8 lengthCase,
        uint8 bodyWords,
        bytes32 w0,
        bytes32 w1,
        bytes32 w2
    ) public view {
        uint256 offset = pickOffset(offsetCase);
        uint256 length = pickLength(lengthCase);
        bytes memory encoded = abi.encodePacked(offset, length);
        if (bodyWords > 0) encoded = abi.encodePacked(encoded, w0);
        if (bodyWords > 1) encoded = abi.encodePacked(encoded, w1);
        if (bodyWords > 2) encoded = abi.encodePacked(encoded, w2);
        try collections.unpackArray("uint8", encoded) returns (bytes[] memory values) {
            // Halmos discards reverting paths, so an oracle rejection must fail explicitly.
            try this.solcDecodeUint8Array(encoded) returns (uint8[] memory expected) {
                assertEq(values.length, expected.length);
                for (uint256 i; i < values.length; i++) {
                    assertEq(values[i], abi.encode(expected[i]));
                }
            } catch {
                assertTrue(false, "unpackArray accepted what solc rejects");
            }
        } catch {}
    }

    function solcDecodeUint8Array(bytes calldata encoded) external pure returns (uint8[] memory) {
        return abi.decode(encoded, (uint8[]));
    }

    /**
     * @dev packArray that must succeed: Halmos discards a reverting path, so a revert fails explicitly
     */
    function packs(string memory t, bytes[] memory values) internal view returns (bytes memory) {
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.packArray, (t, values)));
        assertTrue(ok, "packArray reverted on valid values");
        return abi.decode(out, (bytes));
    }

    function pickOffset(uint8 c) private pure returns (uint256) {
        if (c == 0) return 0x20;
        if (c == 1) return 0;
        if (c == 2) return 0x40;
        if (c == 3) return 0x1f;
        return type(uint256).max;
    }

    function pickLength(uint8 c) private pure returns (uint256) {
        // Literals, not `c`: returning the argument keeps the length symbolic.
        if (c == 0) return 0;
        if (c == 1) return 1;
        if (c == 2) return 2;
        if (c == 3) return 3;
        return type(uint256).max;
    }

    // ============ Every word, every narrow type ============

    function solcUint8(bytes calldata d) external pure returns (uint8) {
        return abi.decode(d, (uint8));
    }

    function solcUint64(bytes calldata d) external pure returns (uint64) {
        return abi.decode(d, (uint64));
    }

    function solcUint248(bytes calldata d) external pure returns (uint248) {
        return abi.decode(d, (uint248));
    }

    function solcInt8(bytes calldata d) external pure returns (int8) {
        return abi.decode(d, (int8));
    }

    function solcInt64(bytes calldata d) external pure returns (int64) {
        return abi.decode(d, (int64));
    }

    function solcInt248(bytes calldata d) external pure returns (int248) {
        return abi.decode(d, (int248));
    }

    function solcAddress(bytes calldata d) external pure returns (address) {
        return abi.decode(d, (address));
    }

    function solcBool(bytes calldata d) external pure returns (bool) {
        return abi.decode(d, (bool));
    }

    function solcBytes1(bytes calldata d) external pure returns (bytes1) {
        return abi.decode(d, (bytes1));
    }

    function solcBytes4(bytes calldata d) external pure returns (bytes4) {
        return abi.decode(d, (bytes4));
    }

    function solcBytes31(bytes calldata d) external pure returns (bytes31) {
        return abi.decode(d, (bytes31));
    }

    function solcUint256(bytes calldata d) external pure returns (uint256) {
        return abi.decode(d, (uint256));
    }

    /**
     * @dev For every word and every narrow type, the codec accepts exactly
     *      what solc's decoder accepts, and packs it as solc encodes it
     */
    function check_wordMatchesSolc(uint8 typeCase, bytes32 w) public view {
        vm.assume(typeCase < 12);
        (string memory name, bytes4 decoder) = wordType(typeCase);
        (bool solcOk,) = address(this).staticcall(abi.encodeWithSelector(decoder, abi.encode(w)));
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(w);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.packArray, (name, values)));
        assertEq(ok, solcOk, "codec and solc disagree on a word");
        if (ok) assertEq(abi.decode(out, (bytes)), abi.encodePacked(uint256(32), uint256(1), w));
    }

    /**
     * @dev A literal per path: indexing an array by `c` would be a symbolic offset
     */
    function wordType(uint8 c) internal pure returns (string memory, bytes4) {
        if (c == 0) return ("uint8", this.solcUint8.selector);
        if (c == 1) return ("uint64", this.solcUint64.selector);
        if (c == 2) return ("uint248", this.solcUint248.selector);
        if (c == 3) return ("int8", this.solcInt8.selector);
        if (c == 4) return ("int64", this.solcInt64.selector);
        if (c == 5) return ("int248", this.solcInt248.selector);
        if (c == 6) return ("address", this.solcAddress.selector);
        if (c == 7) return ("bool", this.solcBool.selector);
        if (c == 8) return ("bytes1", this.solcBytes1.selector);
        if (c == 9) return ("bytes4", this.solcBytes4.selector);
        if (c == 10) return ("bytes31", this.solcBytes31.selector);
        return ("uint256", this.solcUint256.selector);
    }

    function solcQuad(bytes calldata d) external pure returns (uint8, bool, address, bytes4) {
        return abi.decode(d, (uint8, bool, address, bytes4));
    }

    /**
     * @dev Operations.encode accepts exactly the components solc decodes
     */
    function check_encodeMatchesSolc(bytes32[4] memory w) public view {
        bytes[] memory args = new bytes[](4);
        for (uint256 i; i < 4; i++) {
            args[i] = abi.encode(w[i]);
        }
        bytes memory packed = abi.encodePacked(w);
        (bool solcOk,) = address(this).staticcall(abi.encodeCall(this.solcQuad, (packed)));
        (bool ok, bytes memory out) =
            address(ops).staticcall(abi.encodeCall(Operations.encodeBytes, ("(uint8,bool,address,bytes4)", args)));
        assertEq(ok, solcOk, "encode and solc disagree");
        if (ok) assertEq(abi.decode(out, (bytes)), packed);
    }

    function solcPairs(bytes calldata d) external pure returns (Pair[2] memory) {
        return abi.decode(d, (Pair[2]));
    }

    /**
     * @dev A fixed array of static tuples: every copy's words are held to their types
     */
    function check_fixedArrayOfTuplesMatchesSolc(bytes32[4] memory w) public view {
        bytes memory value = abi.encodePacked(w);
        (bool solcOk,) = address(this).staticcall(abi.encodeCall(this.solcPairs, (value)));
        bytes[] memory values = new bytes[](1);
        values[0] = value;
        (bool ok,) = address(collections).staticcall(abi.encodeCall(Collections.packArray, ("(int8,bool)[2]", values)));
        assertEq(ok, solcOk, "codec and solc disagree on (int8,bool)[2]");
    }

    function solcUint8Nested(bytes calldata d) external pure returns (uint8[][] memory) {
        return abi.decode(d, (uint8[][]));
    }

    /**
     * @dev unpack over a uint8[][] holding one inner array: accepted exactly
     *      when solc decodes it and it is canonical, and then each element is
     *      solc's inner array
     */
    function check_unpackNestedMatchesSolc(uint8 innerOffsetCase, uint8 countCase, bytes32[2] memory e) public view {
        // 0x40 would read the symbolic e[0] as the inner length.
        vm.assume(innerOffsetCase != 2 && innerOffsetCase < 5 && countCase < 5);
        uint256 innerOffset = pickOffset(innerOffsetCase);
        uint256 count = pickLength(countCase);
        bytes memory encoded = abi.encodePacked(uint256(32), uint256(1), innerOffset, count, e[0], e[1]);
        (bool solcOk, bytes memory raw) = address(this).staticcall(abi.encodeCall(this.solcUint8Nested, (encoded)));
        bool canonical;
        uint8[][] memory expected;
        if (solcOk) {
            expected = abi.decode(raw, (uint8[][]));
            canonical = keccak256(abi.encode(expected)) == keccak256(encoded);
        }
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, ("uint8[]", encoded)));
        if (ok) assertTrue(canonical, "unpack accepts what solc rejects or a non-canonical form");
        if (canonical) {
            assertTrue(ok, "unpack rejects a canonical uint8[][]");
            bytes[] memory values = abi.decode(out, (bytes[]));
            assertEq(values.length, 1);
            assertEq(values[0], abi.encode(expected[0]));
        }
    }
}

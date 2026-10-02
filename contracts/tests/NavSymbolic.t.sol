// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Assertions.sol";
import "../lib/ERC8211.sol";

/**
 * @notice Halmos properties: `nav` against solc's own decoder. Run with
 *         `pnpm halmos`.
 * @dev Two directions per shape. Soundness: whatever nav returns decodes
 *      under solc as the selected type and re-encodes to the same bytes, so
 *      nav never hands out a value solc would reject. Completeness: when solc
 *      decodes the whole data AND the data is canonical (abi.encode of what solc
 *      decoded), nav succeeds and returns solc's value for the selection. solc
 *      tolerates non-canonical forms (dirty bytes padding, loose offsets) that
 *      this repo rejects by doctrine, so completeness claims canonical data
 *      only. Head words (offsets, lengths) are case-split into literal
 *      candidates, canonical and malformed, because Halmos cannot follow a
 *      symbolic offset; every content word stays symbolic.
 */
contract NavSymbolicTest is Test {
    int256 constant LEN = type(int256).min;
    int256 constant PAYLOAD = type(int256).min + 1;

    Assertions core;

    function setUp() public {
        core = new Assertions();
    }

    // ============ solc oracles ============

    function decodeStatics(bytes calldata d) external pure returns (uint8, address, bool, int8, bytes4) {
        return abi.decode(d, (uint8, address, bool, int8, bytes4));
    }

    function decodeArray(bytes calldata d) external pure returns (uint256, uint8[] memory) {
        return abi.decode(d, (uint256, uint8[]));
    }

    function decodeBytes(bytes calldata d) external pure returns (bytes memory, uint8) {
        return abi.decode(d, (bytes, uint8));
    }

    function decodeUint8(bytes calldata d) external pure returns (uint8) {
        return abi.decode(d, (uint8));
    }

    function decodeAddress(bytes calldata d) external pure returns (address) {
        return abi.decode(d, (address));
    }

    function decodeBool(bytes calldata d) external pure returns (bool) {
        return abi.decode(d, (bool));
    }

    function decodeInt8(bytes calldata d) external pure returns (int8) {
        return abi.decode(d, (int8));
    }

    function decodeBytes4(bytes calldata d) external pure returns (bytes4) {
        return abi.decode(d, (bytes4));
    }

    function decodeUint8Array(bytes calldata d) external pure returns (uint8[] memory) {
        return abi.decode(d, (uint8[]));
    }

    function decodeBytesValue(bytes calldata d) external pure returns (bytes memory) {
        return abi.decode(d, (bytes));
    }

    // ============ Static tuple of narrow types ============

    function check_staticTerminals(uint8 index, bytes32[5] memory w, uint8 lengthCase) public {
        uint256 length = pick(lengthCase, [uint256(160), 128, 192, 159, 160, 160]);
        bytes memory data = truncate(abi.encodePacked(w, bytes32(0)), length);
        uint256 i = pick(index, [uint256(0), 1, 2, 3, 4, 4]);
        (bool ok, bytes memory out) = nav(data, "(uint8,address,bool,int8,bytes4)", path1(int256(i)));
        bytes4[5] memory decoders = [
            this.decodeUint8.selector,
            this.decodeAddress.selector,
            this.decodeBool.selector,
            this.decodeInt8.selector,
            this.decodeBytes4.selector
        ];
        if (ok) sound(decoders[i], out);
        (bool solcOk,) = address(this).staticcall(abi.encodeCall(this.decodeStatics, (data)));
        if (solcOk) {
            assertTrue(ok, "nav rejects data solc decodes");
            assertEq(out, abi.encode(w[i]));
        }
    }

    // ============ uint8[] behind an offset ============

    function check_dynamicArray(
        uint8 offsetCase,
        uint8 lengthCase,
        uint8 bodyWords,
        uint8 pathCase,
        bytes32 w0,
        bytes32[3] memory e
    ) public {
        // Every candidate leaves the length word concrete: 0x20 reads the offset itself.
        uint256 offset = pick(offsetCase, [uint256(0x40), 0x20, 0x1000, type(uint256).max, 0x40, 0x40]);
        uint256 count = pick(lengthCase, [uint256(0), 1, 2, 3, type(uint256).max, 2]);
        uint256 n = pick(bodyWords, [uint256(0), 1, 2, 3, 3, 3]);
        bytes memory data = abi.encodePacked(w0, offset, count);
        for (uint256 k; k < n; k++) {
            data = abi.encodePacked(data, e[k]);
        }
        int256[] memory path;
        if (pathCase == 0) path = path1(1);
        else if (pathCase == 1) path = path2(1, LEN);
        else if (pathCase == 2) path = path2(1, 0);
        else if (pathCase == 3) path = path2(1, 1);
        else path = path2(1, -1);
        (bool ok, bytes memory out) = nav(data, "(uint256,uint8[])", path);
        if (ok && pathCase == 0) sound(this.decodeUint8Array.selector, out);
        if (ok && pathCase >= 2) sound(this.decodeUint8.selector, out);

        (bool solcOk, bytes memory raw) = address(this).staticcall(abi.encodeCall(this.decodeArray, (data)));
        if (!solcOk) return;
        (uint256 first, uint8[] memory arr) = abi.decode(raw, (uint256, uint8[]));
        if (keccak256(abi.encode(first, arr)) != keccak256(data)) return;
        if (pathCase == 0) {
            assertTrue(ok, "nav rejects an array solc decodes");
            assertEq(out, abi.encode(arr));
        } else if (pathCase == 1) {
            assertTrue(ok, "nav rejects LEN of an array solc decodes");
            assertEq(out, abi.encode(arr.length));
        } else {
            uint256 j = pathCase == 2 ? 0 : pathCase == 3 ? 1 : arr.length - 1;
            if (arr.length > j) {
                assertTrue(ok, "nav rejects an element solc decodes");
                assertEq(out, abi.encode(arr[j]));
            } else {
                assertFalse(ok, "nav selects past the end");
            }
        }
    }

    // ============ bytes with PAYLOAD and LEN ============

    function check_bytesValue(uint8 offsetCase, uint8 lengthCase, uint8 pathCase, bytes32 w1, bytes32[2] memory p)
        public
    {
        // Every candidate leaves the length word concrete: 0x00 reads the offset itself.
        uint256 offset = pick(offsetCase, [uint256(0x40), 0x00, 0x1000, type(uint256).max, 0x40, 0x40]);
        uint256 size = pick(lengthCase, [uint256(0), 1, 31, 32, 33, 64]);
        bytes memory data = abi.encodePacked(offset, w1, size, p[0], p[1]);
        int256[] memory path =
            pathCase == 0 ? path1(0) : pathCase == 1 ? path2(0, PAYLOAD) : pathCase == 2 ? path2(0, LEN) : path1(1);
        (bool ok, bytes memory out) = nav(data, "(bytes,uint8)", path);
        if (ok && pathCase == 0) sound(this.decodeBytesValue.selector, out);
        if (ok && pathCase == 3) sound(this.decodeUint8.selector, out);

        (bool solcOk, bytes memory raw) = address(this).staticcall(abi.encodeCall(this.decodeBytes, (data)));
        if (!solcOk) return;
        (bytes memory value, uint8 small) = abi.decode(raw, (bytes, uint8));
        if (keccak256(abi.encode(value, small)) != keccak256(data)) return;
        assertTrue(ok, "nav rejects data solc decodes");
        if (pathCase == 0) assertEq(out, abi.encode(value));
        else if (pathCase == 1) assertEq(out, value);
        else if (pathCase == 2) assertEq(out, abi.encode(value.length));
        else assertEq(out, abi.encode(small));
    }

    // ============ bytes[]: elements behind relative offsets ============

    function decodeBytesArray(bytes calldata d) external pure returns (uint8, bytes[] memory) {
        return abi.decode(d, (uint8, bytes[]));
    }

    function decodeBytesList(bytes calldata d) external pure returns (bytes[] memory) {
        return abi.decode(d, (bytes[]));
    }

    function check_arrayOfBytes(
        uint8 countCase,
        uint8 firstCase,
        uint8 secondCase,
        uint8 lengthCases,
        uint8 pathCase,
        bytes32 w0,
        bytes32[2] memory payload
    ) public {
        // Distinct candidates only: every extra case value multiplies the paths.
        vm.assume(countCase < 4 && firstCase < 3 && secondCase < 3 && lengthCases < 9 && lengthCases & 3 < 3);
        vm.assume(pathCase < 5);
        bytes memory data = bytesArrayData(countCase, firstCase, secondCase, lengthCases, w0, payload);
        int256[] memory path;
        if (pathCase == 0) path = path1(1);
        else if (pathCase == 1) path = path2(1, LEN);
        else if (pathCase == 2) path = path2(1, 0);
        else if (pathCase == 3) path = path2(1, -1);
        else path = path3(1, 0, PAYLOAD);
        (bool ok, bytes memory out) = nav(data, "(uint8,bytes[])", path);
        if (ok && pathCase == 0) sound(this.decodeBytesList.selector, out);
        if (ok && (pathCase == 2 || pathCase == 3)) sound(this.decodeBytesValue.selector, out);
        completeBytesArray(data, pathCase, ok, out);
    }

    /**
     * @dev (uint8, bytes[]) with the count, both element offsets (relative
     *      to the first element head; canonical first) and both element
     *      lengths case-split, payload words symbolic
     */
    function bytesArrayData(
        uint8 countCase,
        uint8 firstCase,
        uint8 secondCase,
        uint8 lengthCases,
        bytes32 w0,
        bytes32[2] memory payload
    ) internal pure returns (bytes memory data) {
        uint256 len0 = pick(lengthCases & 3, [uint256(0), 5, 33, 0, 0, 0]);
        uint256 len1 = pick(lengthCases >> 2, [uint256(5), 0, 33, 5, 5, 5]);
        uint256 words0 = (len0 + 31) / 32;
        data = abi.encodePacked(
            w0,
            uint256(0x40),
            pick(countCase, [uint256(2), 1, 0, 3, 2, 2]),
            // Each candidate lands on a concrete length word: canonical, the
            // other head (0x20) or element (0x40), or out of bounds.
            pick(firstCase, [uint256(0x40), 0x20, 0x1000, 0x40, 0x40, 0x40]),
            pick(secondCase, [0x40 + 32 + words0 * 32, 0x40, 0x1000, 0x40, 0x40, 0x40]),
            len0
        );
        for (uint256 k; k < words0; k++) {
            data = abi.encodePacked(data, payload[0]);
        }
        data = abi.encodePacked(data, len1);
        for (uint256 k; k < (len1 + 31) / 32; k++) {
            data = abi.encodePacked(data, payload[1]);
        }
    }

    /**
     * @dev Completeness for check_arrayOfBytes, on canonical data only
     */
    function completeBytesArray(bytes memory data, uint8 pathCase, bool ok, bytes memory out) internal view {
        (bool solcOk, bytes memory raw) = address(this).staticcall(abi.encodeCall(this.decodeBytesArray, (data)));
        if (!solcOk) return;
        (uint8 first, bytes[] memory list) = abi.decode(raw, (uint8, bytes[]));
        if (keccak256(abi.encode(first, list)) != keccak256(data)) return;
        if (pathCase == 0) {
            assertTrue(ok, "nav rejects a bytes[] solc decodes");
            assertEq(out, abi.encode(list));
        } else if (pathCase == 1) {
            assertTrue(ok, "nav rejects LEN of a bytes[] solc decodes");
            assertEq(out, abi.encode(list.length));
        } else if (list.length == 0) {
            assertFalse(ok, "nav selects in an empty array");
        } else {
            bytes memory element = pathCase == 3 ? list[list.length - 1] : list[0];
            assertTrue(ok, "nav rejects an element solc decodes");
            assertEq(out, pathCase == 4 ? element : abi.encode(element));
        }
    }

    // ============ Harness ============

    function path3(int256 a, int256 b, int256 c) internal pure returns (int256[] memory p) {
        p = new int256[](3);
        p[0] = a;
        p[1] = b;
        p[2] = c;
    }

    /**
     * @dev Soundness: `out` decodes under solc through `decoder` and
     *      re-encodes to itself. A rejection must fail explicitly: Halmos
     *      discards reverting paths.
     */
    function sound(bytes4 decoder, bytes memory out) internal view {
        (bool ok, bytes memory decoded) = address(this).staticcall(abi.encodeWithSelector(decoder, out));
        assertTrue(ok, "nav returned a value solc rejects");
        assertEq(decoded, out, "nav returned a non-canonical encoding");
    }

    function nav(bytes memory data, string memory types, int256[] memory path)
        internal
        view
        returns (bool ok, bytes memory out)
    {
        InputParam memory p =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
        (ok, out) = address(core).staticcall(abi.encodeCall(Assertions.nav, (p, types, path)));
    }

    function path1(int256 a) internal pure returns (int256[] memory p) {
        p = new int256[](1);
        p[0] = a;
    }

    function path2(int256 a, int256 b) internal pure returns (int256[] memory p) {
        p = new int256[](2);
        p[0] = a;
        p[1] = b;
    }

    /**
     * @dev A concrete candidate per path: returning `c` itself would stay symbolic
     */
    function pick(uint8 c, uint256[6] memory candidates) internal pure returns (uint256) {
        if (c == 0) return candidates[0];
        if (c == 1) return candidates[1];
        if (c == 2) return candidates[2];
        if (c == 3) return candidates[3];
        if (c == 4) return candidates[4];
        return candidates[5];
    }

    function truncate(bytes memory data, uint256 length) internal pure returns (bytes memory out) {
        out = data;
        assembly ("memory-safe") { mstore(out, length) }
    }
}

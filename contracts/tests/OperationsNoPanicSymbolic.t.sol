// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import {Operations} from "../Operations.sol";

/**
 * @notice Halmos properties: Operations' index arithmetic over every signed
 *         and unsigned index, against references written from the NatSpec.
 *         Run with `pnpm halmos`.
 * @dev Each index is either fully symbolic and outside the data,
 *      int256.min and type(uint256).max included (where `-index` and
 *      `start + len` would overflow, and where the result stays concrete),
 *      or one of the literal boundaries 0, 1, -1, length - 1, -length and
 *      length. An in-range symbolic index would make the copy's calldata
 *      offset symbolic, which Halmos cannot follow (NotConcreteError).
 *      Data contents are symbolic at Halmos' default lengths, except where
 *      the UTF-8 validator scans them: a branch per symbolic byte explodes
 *      paths, so those properties take concrete strings or at most four
 *      symbolic bytes. The byte-scanning functions are fuzzed in
 *      OperationsNoPanic.t.sol. Calls go through `staticcall` because Halmos
 *      discards reverting paths.
 */
contract OperationsNoPanicSymbolicTest is Test {
    Operations ops;

    function setUp() public {
        ops = new Operations();
    }

    // ============ Bytes ============

    /**
     * @dev slice succeeds exactly within bounds and returns that window; otherwise SliceOutOfBounds
     */
    function check_sliceBounds(bytes memory data, uint8 startCase, uint256 startSym, uint8 lenCase, uint256 lenSym)
        public
        view
    {
        uint256 start = pickUnsigned(startCase, startSym, data.length);
        uint256 len = pickUnsigned(lenCase, lenSym, data.length);
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.slice, (data, start, len)));
        bool inBounds = start <= data.length && len <= data.length - start;
        assertEq(ok, inBounds, "slice and its bounds disagree");
        if (ok) {
            assertEq(abi.decode(out, (bytes)), window(data, start, start + len));
        } else {
            assertEq(out, abi.encodeWithSelector(Operations.SliceOutOfBounds.selector, start, len, data.length));
        }
    }

    /**
     * @dev sliceRange never reverts and returns the clamped window, empty when it is inverted
     */
    function check_sliceRangeClamps(bytes memory data, uint8 aCase, int256 aSym, uint8 bCase, int256 bSym) public view {
        int256 a = pickSigned(aCase, aSym, data.length);
        int256 b = pickSigned(bCase, bSym, data.length);
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.sliceRange, (data, a, b)));
        assertTrue(ok, "sliceRange reverted");
        uint256 from = clamp(a, data.length);
        uint256 to = clamp(b, data.length);
        assertEq(abi.decode(out, (bytes)), to > from ? window(data, from, to) : bytes(""));
    }

    /**
     * @dev byteAt succeeds exactly for -length <= index < length; otherwise InvalidByteIndex
     */
    function check_byteAtStrict(bytes memory data, uint8 indexCase, int256 indexSym) public view {
        int256 index = pickSigned(indexCase, indexSym, data.length);
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.byteAt, (data, index)));
        int256 n = int256(data.length);
        assertEq(ok, index >= -n && index < n, "byteAt and its bounds disagree");
        if (ok) {
            uint256 p = index < 0 ? uint256(n + index) : uint256(index);
            assertEq(abi.decode(out, (bytes)), window(data, p, p + 1));
        } else {
            assertEq(out, abi.encodeWithSelector(Operations.InvalidByteIndex.selector, index, data.length));
        }
    }

    // ============ Search ============

    /**
     * @dev With an empty needle every position 0 .. length matches:
     *      occurrence k >= 0 is position k, -k counts from the end, and
     *      anything out of range answers length. int256.min must not
     *      overflow on the way.
     */
    function check_indexOfEmptyNeedle(bytes memory s, int256 occurrence) public view {
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.indexOf, (s, "", occurrence)));
        assertTrue(ok, "indexOf reverted on an empty needle");
        int256 positions = int256(s.length) + 1;
        uint256 expected = s.length;
        if (occurrence >= 0 && occurrence < positions) expected = uint256(occurrence);
        if (occurrence < 0 && occurrence >= -positions) expected = uint256(positions + occurrence);
        assertEq(abi.decode(out, (uint256)), expected);
    }

    // ============ UTF-8 ============

    /**
     * @dev Over valid UTF-8 (ASCII, two-, three- and four-byte sequences),
     *      stringAt answers a lone ASCII byte, InvalidUtf8 inside a
     *      multibyte sequence, and InvalidByteIndex out of range, for every
     *      index
     */
    function check_stringAtOverValidText(uint8 textCase, uint8 indexCase, int256 indexSym) public view {
        bytes memory data = text(textCase);
        int256 index = pickSigned(indexCase, indexSym, data.length);
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.stringAt, (data, index)));
        int256 n = int256(data.length);
        if (index < -n || index >= n) {
            assertEq(out, abi.encodeWithSelector(Operations.InvalidByteIndex.selector, index, data.length));
            return;
        }
        uint256 p = index < 0 ? uint256(n + index) : uint256(index);
        if (uint8(data[p]) < 0x80) {
            assertTrue(ok, "stringAt refused an ASCII byte");
            assertEq(abi.decode(out, (bytes)), window(data, p, p + 1));
        } else {
            assertEq(out, abi.encodeWithSelector(Operations.InvalidUtf8.selector, p));
        }
    }

    /**
     * @dev Over valid UTF-8, stringSlice returns the clamped window when
     *      both ends sit on character boundaries, empty when inverted, and
     *      InvalidUtf8 at the first end that splits a character
     */
    function check_stringSliceOverValidText(uint8 textCase, uint8 aCase, int256 aSym, uint8 bCase, int256 bSym)
        public
        view
    {
        bytes memory data = text(textCase);
        int256 a = pickSigned(aCase, aSym, data.length);
        int256 b = pickSigned(bCase, bSym, data.length);
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.stringSlice, (data, a, b)));
        uint256 from = clamp(a, data.length);
        uint256 to = clamp(b, data.length);
        if (to <= from) {
            assertTrue(ok, "stringSlice refused an empty window");
            assertEq(abi.decode(out, (bytes)), bytes(""));
        } else if (splits(data, from)) {
            assertEq(out, abi.encodeWithSelector(Operations.InvalidUtf8.selector, from));
        } else if (splits(data, to)) {
            assertEq(out, abi.encodeWithSelector(Operations.InvalidUtf8.selector, to));
        } else {
            assertTrue(ok, "stringSlice refused a window on boundaries");
            assertEq(abi.decode(out, (bytes)), window(data, from, to));
        }
    }

    /**
     * @dev Up to four symbolic bytes, any content: the UTF-8 validator
     *      behind stringAt and stringSlice fails only with its declared
     *      errors, whatever the bytes are. The validator runs before any
     *      index is read, so the indices stay fixed here; the properties
     *      over valid text vary them (a symbolic pair on top cost 8,900
     *      paths and three minutes).
     */
    function check_utf8ValidatorNeverPanics(bytes4 raw, uint8 lengthCase) public view {
        // A literal length per case: returning lengthCase itself would stay symbolic.
        uint256 length;
        if (lengthCase == 1) {
            length = 1;
        } else if (lengthCase == 2) {
            length = 2;
        } else if (lengthCase == 3) {
            length = 3;
        } else {
            vm.assume(lengthCase == 4);
            length = 4;
        }
        bytes memory data = new bytes(length);
        for (uint256 i; i < length; i++) {
            data[i] = raw[i];
        }
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.stringAt, (data, int256(0))));
        if (!ok) assertDeclared(out);
        (ok, out) = address(ops).staticcall(abi.encodeCall(Operations.stringSlice, (data, int256(0), int256(length))));
        if (!ok) assertDeclared(out);
    }

    // ============ Helpers ============

    /**
     * @dev A symbolic index outside -length .. length, or a literal boundary
     */
    function pickSigned(uint8 c, int256 symbolic, uint256 length) internal pure returns (int256) {
        int256 n = int256(length);
        if (c == 0) {
            vm.assume(symbolic < -n || symbolic > n);
            return symbolic;
        }
        if (c == 1) return 0;
        if (c == 2) return 1;
        if (c == 3) return -1;
        if (c == 4) return n - 1;
        if (c == 5) return -n;
        vm.assume(c == 6);
        return n;
    }

    /**
     * @dev A symbolic offset past length, or a literal boundary
     */
    function pickUnsigned(uint8 c, uint256 symbolic, uint256 length) internal pure returns (uint256) {
        if (c == 0) {
            vm.assume(symbolic > length);
            return symbolic;
        }
        if (c == 1) return 0;
        if (c == 2) return 1;
        if (c == 3) return length == 0 ? 0 : length - 1;
        vm.assume(c == 4);
        return length;
    }

    function assertDeclared(bytes memory out) internal pure {
        assertGe(out.length, 4, "a failure carries no selector");
        bytes4 selector = bytes4(out);
        assertTrue(
            selector == Operations.InvalidUtf8.selector || selector == Operations.InvalidByteIndex.selector,
            "an undeclared failure"
        );
    }

    /**
     * @dev The NatSpec's clamp: negative counts from the end, both ends pinned to 0 .. length
     */
    function clamp(int256 index, uint256 length) internal pure returns (uint256) {
        int256 n = int256(length);
        if (index < 0) return index < -n ? 0 : uint256(n + index);
        return uint256(index) > length ? length : uint256(index);
    }

    /**
     * @dev Whether position `p` falls inside a character: a continuation byte
     */
    function splits(bytes memory data, uint256 p) internal pure returns (bool) {
        return p < data.length && uint8(data[p]) & 0xc0 == 0x80;
    }

    function window(bytes memory data, uint256 from, uint256 to) internal pure returns (bytes memory out) {
        out = new bytes(to - from);
        for (uint256 i; i < out.length; i++) {
            out[i] = data[from + i];
        }
    }

    /**
     * @dev ASCII, then two-, three- and four-byte characters, mixed
     */
    function text(uint8 c) internal pure returns (bytes memory) {
        if (c == 0) return "";
        if (c == 1) return "ab";
        if (c == 2) return hex"61c3a962"; // a é b
        if (c == 3) return hex"e282ac61"; // € a
        vm.assume(c == 4);
        return hex"61f09f988062"; // a 😀 b
    }
}

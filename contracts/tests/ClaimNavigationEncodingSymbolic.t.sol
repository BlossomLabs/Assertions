// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Assertions.sol";
import "../Operations.sol";

/**
 * @notice Selected C29/C33/C35-C37/C41/C44 and A21-A24/O70-O72 cases.
 *         solc supplies canonical encodings; sentinel fixtures locate faults.
 *         Copy lengths and valid indices are literal cases, not symbolic offsets.
 */
contract ClaimNavigationEncodingSymbolicTest is Test {
    Assertions core;
    Operations ops;
    int256 constant LEN = type(int256).min;
    int256 constant PAYLOAD = type(int256).min + 1;
    bytes32 constant A = 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
    bytes32 constant B = 0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb;
    bytes32 constant C = 0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc;
    bytes32 constant D = 0xdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd;

    struct StaticValue {
        uint8[2] pair;
        int16 signedWord;
        bytes3 tag;
    }

    struct WideStatic {
        uint256[2] pair;
        int256 signedWord;
        bytes32 tag;
    }

    struct Composite {
        uint8[] numbers;
        bytes[] blobs;
    }

    struct LengthTuple {
        bytes blob;
        bytes32 word;
    }

    function setUp() public {
        core = new Assertions();
        ops = new Operations();
    }

    function check_navStaticTerminals(uint8[2] memory pair, int16 signedWord, bytes3 tag, uint8 route) public view {
        vm.assume(route < 4);
        StaticValue memory s = StaticValue(pair, signedWord, tag);
        int256[] memory path = new int256[](route == 0 ? 1 : 2);
        path[0] = 1;
        if (route != 0) path[1] = route == 1 ? int256(0) : route == 2 ? int256(1) : int256(2);
        bytes memory expected = route == 0
            ? abi.encode(s)
            : route == 1 ? abi.encode(pair) : route == 2 ? abi.encode(signedWord) : abi.encode(tag);
        (bool ok, bytes memory out) = nav(abi.encode(uint256(93), s), "(uint256,(uint8[2],int16,bytes3))", path);
        assertTrue(ok);
        assertEq(out, expected);
    }

    function check_navStaticDirtyWords(bytes32 word, uint8 field) public view {
        vm.assume(field < 4);
        bool clean = field < 2
            ? uint256(word) < 256
            : field == 2
                ? word == bytes32(uint256(int256(int16(uint16(uint256(word))))))
                : uint256(word) & ((uint256(1) << 232) - 1) == 0;
        vm.assume(!clean);
        uint256[2] memory markers = [uint256(A), uint256(B)];
        bytes memory fixture = abi.encode(uint256(93), WideStatic(markers, int256(uint256(C)), D));
        uint256 offset = findWord(fixture, field == 0 ? A : field == 1 ? B : field == 2 ? C : D);
        uint8[2] memory pair = [uint8(7), uint8(9)];
        bytes memory data = abi.encode(uint256(93), StaticValue(pair, -3, hex"abcdef"));
        setWord(data, offset, word);
        (bool ok, bytes memory out) = nav(data, "(uint256,(uint8[2],int16,bytes3))", path1(1));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, offset));
    }

    function check_navDynamicTuple(uint8 a, uint8 b, bytes32 payload) public view {
        Composite memory c = composite(a, b, payload);
        (bool ok, bytes memory out) = nav(abi.encode(uint256(93), c), "(uint256,(uint8[],bytes[]))", path1(1));
        assertTrue(ok);
        assertEq(out, abi.encode(c));
    }

    function check_navDynamicArrays(uint8[4] memory words, uint8 route) public view {
        vm.assume(route < 4);
        uint8[][] memory a = arrays(words);
        int256[] memory path = new int256[](route == 0 ? 1 : route == 3 ? 3 : 2);
        path[0] = 1;
        if (route != 0) path[1] = route == 1 ? int256(0) : int256(-1);
        if (route == 3) path[2] = -1;
        bytes memory expected = route == 0
            ? abi.encode(a)
            : route == 1 ? abi.encode(a[0]) : route == 2 ? abi.encode(a[1]) : abi.encode(words[3]);
        (bool ok, bytes memory out) = nav(abi.encode(uint256(93), a), "(uint256,uint8[][])", path);
        assertTrue(ok);
        assertEq(out, expected);
    }

    function check_navDynamicDirtyWords(uint256 dirty, uint8 field) public view {
        vm.assume(dirty > 255 && field < 4);
        uint256[][] memory wide = new uint256[][](2);
        wide[0] = new uint256[](2);
        wide[1] = new uint256[](2);
        wide[0][0] = uint256(A);
        wide[0][1] = uint256(B);
        wide[1][0] = uint256(C);
        wide[1][1] = uint256(D);
        uint256 offset = findWord(abi.encode(uint256(93), wide), field == 0 ? A : field == 1 ? B : field == 2 ? C : D);
        uint8[4] memory words = [uint8(7), uint8(9), uint8(11), uint8(13)];
        bytes memory data = abi.encode(uint256(93), arrays(words));
        setWord(data, offset, bytes32(dirty));
        (bool ok, bytes memory out) = nav(data, "(uint256,uint8[][])", path1(1));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, offset));
    }

    function check_navSignedArraySelections(bytes32[3] memory words, uint8 indexCase, bool dynamic) public view {
        vm.assume(indexCase < 6);
        int256 index = indexCase == 0
            ? int256(0)
            : indexCase == 1
                ? int256(1)
                : indexCase == 2 ? int256(2) : indexCase == 3 ? int256(-1) : indexCase == 4 ? int256(-2) : int256(-3);
        bytes32 expected =
            indexCase == 0 || indexCase == 5 ? words[0] : indexCase == 1 || indexCase == 4 ? words[1] : words[2];
        (bool ok, bytes memory out) =
            nav(arrayData(words, dynamic), dynamic ? "(uint256,bytes32[])" : "(uint256,bytes32[3])", path2(1, index));
        assertTrue(ok);
        assertEq(out, abi.encode(expected));
    }

    function check_navArrayIndexRefusal(bytes32[3] memory words, int256 index, bool dynamic) public view {
        vm.assume((index < -3 || index >= 3) && index != LEN && index != PAYLOAD);
        (bool ok, bytes memory out) =
            nav(arrayData(words, dynamic), dynamic ? "(uint256,bytes32[])" : "(uint256,bytes32[3])", path2(1, index));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(ElementIndexOutOfBounds.selector, index, uint256(3)));
    }

    function check_navTupleIndexRefusal(bytes32 a, bytes32 b, int256 index) public view {
        vm.assume((index < 0 || index >= 2) && index != LEN && index != PAYLOAD);
        (bool ok, bytes memory out) = nav(abi.encode(a, b), "(bytes32,bytes32)", path1(index));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(ElementIndexOutOfBounds.selector, index, uint256(2)));
    }

    function check_navLengthRefusals(bytes32 word, uint8 shape, bool truncated) public view {
        vm.assume(shape < 6);
        string memory t = shape == 1
            ? "(uint256)"
            : shape == 2
                ? "(uint256[2])"
                : shape == 3 ? "((uint256,uint256))" : shape == 4 ? "((bytes,uint256))" : "(bytes[2])";
        bytes memory data;
        if (shape < 4) {
            data = truncated ? bytes("") : abi.encode(word, word);
        } else if (truncated) {
            data = abi.encode(uint256(32));
        } else if (shape == 4) {
            data = abi.encode(LengthTuple(hex"010203", word));
        } else {
            bytes[2] memory blobs = [bytes(hex"01"), bytes(hex"0203")];
            data = abi.encode(blobs);
        }
        (bool ok, bytes memory out) = nav(data, t, shape == 0 ? path1(LEN) : path2(0, LEN));
        assertFalse(ok);
        assertEq(
            out,
            shape >= 4 && truncated
                ? abi.encodeWithSelector(ReturnDataOutOfBounds.selector, int256(1), uint256(32))
                : abi.encodeWithSelector(Assertions.InvalidNavigation.selector, shape == 0 ? uint256(0) : uint256(1))
        );
    }

    function check_navPayloadRefusals(uint8 shape) public view {
        vm.assume(shape < 6);
        string memory t = shape == 1
            ? "(uint256)"
            : shape == 2 ? "(uint256[2])" : shape == 3 ? "(uint256[])" : shape == 4 ? "((bytes,uint256))" : "(bytes[2])";
        // For dynamic terminals, the parent offset fits but the selected body
        // is absent. Unsupported PAYLOAD types must reject before that read.
        (bool ok, bytes memory out) = nav(abi.encode(uint256(32)), t, shape == 0 ? path1(PAYLOAD) : path2(0, PAYLOAD));
        assertFalse(ok);
        assertEq(
            out, abi.encodeWithSelector(Assertions.InvalidNavigation.selector, shape == 0 ? uint256(0) : uint256(1))
        );
    }

    function check_navNonCompositeRefusal(bytes32 word, uint8 shape) public view {
        vm.assume(shape < 3);
        (bool ok, bytes memory out) = nav(
            shape == 0 ? abi.encode(word) : abi.encode(uint256(32)),
            shape == 0 ? "(uint256)" : shape == 1 ? "(bytes)" : "(string)",
            path2(0, 0)
        );
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(Assertions.InvalidNavigation.selector, uint256(1)));
    }

    function check_navTupleEncoding(uint8[4] memory words, bytes32 payload, bool envelope) public view {
        uint8[2] memory pair = [words[0], words[1]];
        uint8[][] memory nested = arrays(words);
        bytes memory blob = abi.encodePacked(payload, bytes1(0x7f));
        bytes[] memory values = new bytes[](3);
        values[0] = abi.encode(pair);
        values[1] = abi.encode(blob);
        values[2] = abi.encode(nested);
        bytes memory expected = abi.encode(pair, blob, nested);
        (bool ok, bytes memory out) = encoding("(uint8[2],bytes,uint8[][])", values, envelope);
        assertTrue(ok);
        assertEq(out, envelope ? abi.encode(expected) : expected);
    }

    function check_navComponentCount(bytes32 word, uint8 countCase, bool envelope) public view {
        vm.assume(countCase < 3);
        uint256 n = countCase == 0 ? 0 : countCase == 1 ? 1 : 3;
        bytes[] memory values = new bytes[](n);
        for (uint256 i; i < n; i++) {
            values[i] = abi.encode(word);
        }
        (bool ok, bytes memory out) = encoding("(uint256,bytes)", values, envelope);
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(AbiCodec.ComponentCountMismatch.selector, uint256(2), n));
    }

    function check_navStaticComponentWidth(bytes32[3] memory words, uint8 size, bool second, bool envelope)
        public
        view
    {
        vm.assume(size < 7);
        uint256 n =
            size == 0 ? 0 : size == 1 ? 1 : size == 2 ? 31 : size == 3 ? 32 : size == 4 ? 33 : size == 5 ? 63 : 65;
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(words[0], words[1]);
        values[1] = abi.encode(words[2]);
        bytes memory broken = new bytes(n);
        bytes memory source = abi.encodePacked(words);
        for (uint256 i; i < n; i++) {
            broken[i] = source[i];
        }
        values[second ? 1 : 0] = broken;
        (bool ok, bytes memory out) = encoding("(bytes32[2],uint256)", values, envelope);
        if (second && n == 32) {
            assertTrue(ok);
            bytes memory expected = abi.encode(words[0], words[1], words[0]);
            assertEq(out, envelope ? abi.encode(expected) : expected);
        } else {
            assertFalse(ok);
            assertEq(
                out,
                abi.encodeWithSelector(
                    AbiCodec.InvalidComponentLength.selector,
                    second ? uint256(1) : uint256(0),
                    second ? uint256(32) : uint256(64),
                    n
                )
            );
        }
    }

    function check_navDynamicComponentEnvelope(bytes32 content, bytes32 dirtyHead, uint8 shape, bool envelope)
        public
        view
    {
        vm.assume(shape < 8);
        uint256 n = shape == 0
            ? 0
            : shape == 1 ? 31 : shape == 2 ? 32 : shape == 3 ? 63 : shape == 4 ? 65 : shape == 7 ? 96 : 64;
        bytes32 head =
            shape == 5 ? bytes32(0) : shape == 6 ? bytes32(uint256(64)) : shape == 7 ? dirtyHead : bytes32(uint256(32));
        if (shape == 7) vm.assume(head != bytes32(uint256(32)));
        bytes memory bad = new bytes(n);
        bytes memory source = abi.encode(head, content, content);
        for (uint256 i; i < n; i++) {
            bad[i] = source[i];
        }
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(content);
        values[1] = bad;
        (bool ok, bytes memory out) = encoding("(uint256,bytes)", values, envelope);
        assertFalse(ok);
        assertEq(
            out,
            abi.encodeWithSelector(
                AbiCodec.InvalidComponentEnvelope.selector, uint256(1), n, n < 32 ? bytes32(0) : head
            )
        );
    }

    function nav(bytes memory data, string memory t, int256[] memory path) internal view returns (bool, bytes memory) {
        InputParam memory p =
            InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, data, new Constraint[](0));
        return address(core).staticcall(abi.encodeCall(Assertions.nav, (p, t, path)));
    }

    function encoding(string memory t, bytes[] memory values, bool envelope)
        internal
        view
        returns (bool, bytes memory)
    {
        return address(ops)
            .staticcall(
                envelope
                    ? abi.encodeCall(Operations.encodeBytes, (t, values))
                    : abi.encodeCall(Operations.encode, (t, values))
            );
    }

    function composite(uint8 a, uint8 b, bytes32 payload) internal pure returns (Composite memory c) {
        c.numbers = new uint8[](2);
        c.numbers[0] = a;
        c.numbers[1] = b;
        c.blobs = new bytes[](2);
        c.blobs[0] = hex"a5";
        c.blobs[1] = abi.encodePacked(payload, bytes1(0x7f));
    }

    function arrays(uint8[4] memory words) internal pure returns (uint8[][] memory a) {
        a = new uint8[][](2);
        a[0] = new uint8[](2);
        a[1] = new uint8[](2);
        a[0][0] = words[0];
        a[0][1] = words[1];
        a[1][0] = words[2];
        a[1][1] = words[3];
    }

    function arrayData(bytes32[3] memory words, bool dynamic) internal pure returns (bytes memory) {
        if (!dynamic) return abi.encode(uint256(93), words);
        bytes32[] memory a = new bytes32[](3);
        a[0] = words[0];
        a[1] = words[1];
        a[2] = words[2];
        return abi.encode(uint256(93), a);
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

    function findWord(bytes memory data, bytes32 sentinel) internal pure returns (uint256 found) {
        uint256 matches;
        for (uint256 i; i + 32 <= data.length; i += 32) {
            bytes32 word;
            assembly ("memory-safe") { word := mload(add(add(data, 32), i)) }
            if (word == sentinel) {
                found = i;
                matches++;
            }
        }
        assertEq(matches, 1);
    }

    function setWord(bytes memory data, uint256 offset, bytes32 word) internal pure {
        assertTrue(offset + 32 <= data.length);
        assembly ("memory-safe") { mstore(add(add(data, 32), offset), word) }
    }

    function test_navTerminalSamples() public view {
        uint8[2] memory pair = [uint8(7), uint8(93)];
        uint8[4] memory words = [uint8(7), uint8(9), uint8(11), uint8(13)];
        for (uint8 i; i < 4; i++) {
            check_navStaticTerminals(pair, -3, hex"abcdef", i);
            check_navStaticDirtyWords(i == 2 ? bytes32(uint256(0x8000)) : bytes32(type(uint256).max - 1), i);
            check_navDynamicArrays(words, i);
            check_navDynamicDirtyWords(256, i);
        }
        check_navDynamicTuple(7, 93, A);
        check_navTupleEncoding(words, A, false);
        check_navTupleEncoding(words, A, true);
    }

    function test_navIndexAndSentinelSamples() public view {
        bytes32[3] memory words = [A, B, C];
        for (uint8 i; i < 6; i++) {
            check_navSignedArraySelections(words, i, false);
            check_navSignedArraySelections(words, i, true);
            check_navLengthRefusals(A, i, false);
            check_navLengthRefusals(A, i, true);
            check_navPayloadRefusals(i);
        }
        check_navArrayIndexRefusal(words, -4, false);
        check_navArrayIndexRefusal(words, type(int256).max, true);
        check_navTupleIndexRefusal(A, B, -1);
        check_navTupleIndexRefusal(A, B, 2);
        for (uint8 i; i < 3; i++) {
            check_navNonCompositeRefusal(A, i);
        }
    }

    function test_navEncodingErrorSamples() public view {
        bytes32[3] memory words = [A, B, C];
        for (uint8 i; i < 3; i++) {
            check_navComponentCount(A, i, false);
            check_navComponentCount(A, i, true);
        }
        for (uint8 i; i < 7; i++) {
            check_navStaticComponentWidth(words, i, false, false);
            check_navStaticComponentWidth(words, i, true, true);
        }
        for (uint8 i; i < 8; i++) {
            check_navDynamicComponentEnvelope(A, B, i, false);
            check_navDynamicComponentEnvelope(A, B, i, true);
        }
    }
}

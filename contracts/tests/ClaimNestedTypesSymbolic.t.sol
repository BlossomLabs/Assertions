// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Collections.sol";
import "../Expressions.sol";
import "./ClaimTypeFamiliesSymbolic.t.sol";

/**
 * @notice L35/E8/L70/L75 through uint8[][] and (uint8[],bytes[]) values.
 *         The solc encoder supplies independent canonical references; error
 *         positions come from sentinel scans of independently encoded fixtures.
 */
contract ClaimNestedTypesSymbolicTest is Test {
    struct WideComposite {
        uint256[] numbers;
        bytes[] blobs;
    }

    struct NarrowComposite {
        uint8[] numbers;
        bytes[] blobs;
    }

    struct Value {
        string t;
        string wide;
        bytes data;
        bytes canonical;
        bytes tagged;
        bytes initial;
        bool valid;
        uint256 bad;
    }
    bytes32 constant A = 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
    bytes32 constant B = 0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb;
    bytes32 constant C = 0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc;
    bytes32 constant D = 0xdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd;
    Collections collections;
    Expressions expressions;
    ClaimTypesOracle oracle;

    function setUp() public {
        collections = new Collections();
        expressions = new Expressions();
        oracle = new ClaimTypesOracle();
    }

    function check_behaviorNestedPack(bytes32[4] memory words) public view {
        bytes[] memory values = new bytes[](2);
        uint256[] memory a = new uint256[](2);
        a[0] = uint256(words[0]);
        a[1] = uint256(words[1]);
        uint256[] memory b = new uint256[](2);
        b[0] = uint256(words[2]);
        b[1] = uint256(words[3]);
        values[0] = abi.encode(a);
        values[1] = abi.encode(b);
        uint256[] memory fixture = new uint256[](2);
        fixture[0] = uint256(A);
        fixture[1] = uint256(B);
        uint256 first = findWord(abi.encode(fixture), A);
        uint256 second = findWord(abi.encode(fixture), B);
        uint256 bad = uint256(words[0]) > 255 || uint256(words[2]) > 255 ? first : second;
        if (uint256(words[0]) <= 255 && uint256(words[1]) > 255) bad = second;
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.packArray, ("uint8[]", values)));
        bool valid = clean(words, false);
        assertEq(ok, valid);
        if (valid) assertEq(out, abi.encode(abi.encode(narrowArrays(words))));
        else assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, bad));
    }

    function check_behaviorNestedUnpack(bytes32[4] memory words) public view {
        Value memory c = value(words, false);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, ("uint8[]", c.data)));
        assertEq(ok, c.valid);
        if (c.valid) {
            bytes[] memory expected = new bytes[](2);
            uint8[][] memory arrays = narrowArrays(words);
            expected[0] = abi.encode(arrays[0]);
            expected[1] = abi.encode(arrays[1]);
            assertEq(out, abi.encode(expected));
        } else {
            assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, c.bad));
        }
    }

    function check_behaviorNestedUnpackEncodingFaults(bytes32 content, uint8 fault) public view {
        vm.assume(fault < 5);
        bytes32[4] memory markers = [A, B, C, D];
        bytes memory fixture = abi.encode(wideArrays(markers));
        uint256 firstHead = findWord(fixture, bytes32(uint256(64)));
        uint256 secondHead = findWord(fixture, bytes32(uint256(160)));
        uint256 firstCount = findWord(fixture, A) - 32;
        bytes32[4] memory words =
            [bytes32(uint256(uint8(uint256(content)))), bytes32(uint256(2)), bytes32(uint256(3)), bytes32(uint256(4))];
        bytes memory data = abi.encode(narrowArrays(words));
        uint256 bad;
        if (fault == 0) {
            setWord(data, 0, bytes32(0));
        } else if (fault == 1) {
            setWord(data, firstHead, bytes32(0));
            bad = firstHead;
        } else if (fault == 2) {
            setWord(data, secondHead, bytes32(0));
            bad = secondHead;
        } else if (fault == 3) {
            bad = data.length;
            data = bytes.concat(data, bytes1(content));
        } else {
            setWord(data, firstCount, bytes32(uint256(1)));
            bad = secondHead;
        }
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.unpackArray, ("uint8[]", data)));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, bad));
    }

    function check_behaviorNestedPackTrailingData(bytes1 tail) public view {
        uint8[] memory words = new uint8[](2);
        words[0] = 7;
        words[1] = 9;
        bytes memory encoded = abi.encode(words);
        uint256 bad = encoded.length;
        bytes[] memory values = new bytes[](1);
        values[0] = bytes.concat(encoded, tail);
        (bool ok, bytes memory out) =
            address(collections).staticcall(abi.encodeCall(Collections.packArray, ("uint8[]", values)));
        assertFalse(ok);
        assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, bad));
    }

    function check_behaviorNestedNodeValidation(bytes32[4] memory words, bool composite) public view {
        checkNode(value(words, composite));
    }

    function check_behaviorNestedCallbackSlots(bytes32[4] memory words, bool composite, bool constantSlot, bool empty)
        public
        view
    {
        checkSlot(value(words, composite), constantSlot, empty);
    }

    function check_behaviorNestedCallbackResults(bytes32[4] memory words, bool composite, bool fold, bool late)
        public
        view
    {
        checkResult(value(words, composite), fold, late);
    }

    function check_behaviorCompositePaddingErrors(uint8 a, uint8 b, bytes32 payload, bool secondBlob, uint8 route)
        public
        view
    {
        vm.assume(route < 4);
        bytes32[4] memory words = [bytes32(uint256(a)), bytes32(uint256(b)), payload, bytes32(0)];
        Value memory c = value(words, true);
        bytes memory fixture = compositeData([A, B, C, D], false);
        c.bad = secondBlob ? findWord(fixture, C) + 33 : findWord(fixture, bytes32(uint256(0xa5) << 248)) + 1;
        c.data[c.bad] = 0x01;
        c.valid = false;
        if (route == 0) {
            checkNode(c);
        } else if (route == 1) {
            bytes[] memory values = new bytes[](1);
            values[0] = c.data;
            (bool ok, bytes memory out) =
                address(collections).staticcall(abi.encodeCall(Collections.packArray, (c.t, values)));
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidValue.selector, c.bad));
        } else if (route == 2) {
            checkSlot(c, true, true);
        } else {
            checkResult(c, false, true);
        }
    }

    function checkNode(Value memory c) internal view {
        Expressions.Expression memory e;
        e.nodes = new Expressions.Node[](1);
        e.nodes[0].kind = Expressions.Kind.Literal;
        e.nodes[0].valueType = c.t;
        e.nodes[0].data = c.data;
        (bool ok, bytes memory out) =
            address(expressions).staticcall(abi.encodeCall(Expressions.evaluate, (e, new bytes[](0))));
        assertEq(ok, c.valid);
        assertEq(out, c.valid ? c.canonical : abi.encodeWithSelector(AbiCodec.InvalidValue.selector, c.bad));
    }

    function checkSlot(Value memory c, bool constantSlot, bool empty) internal view {
        Collections.Callback memory cb;
        cb.target = address(oracle);
        cb.selector = bytes4(0xcafef00d);
        cb.arguments = string.concat("(", c.t, constantSlot ? ",bytes32)" : ")");
        cb.constants = new bytes[](constantSlot ? 2 : 1);
        cb.constants[0] = c.data;
        if (constantSlot) cb.constants[1] = abi.encode(bytes32(uint256(9)));
        cb.first = constantSlot ? 1 : 0;
        bytes[] memory values = new bytes[](empty ? 0 : 1);
        if (!empty) values[0] = constantSlot ? abi.encode(bytes32(uint256(7))) : c.data;
        (bool ok, bytes memory out) = address(collections)
            .staticcall(abi.encodeCall(Collections.mapValues, (constantSlot ? "bytes32" : c.wide, "bytes", values, cb)));
        bool valid = c.valid || (!constantSlot && empty);
        assertEq(ok, valid);
        if (!valid) {
            assertEq(out, abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(0), c.bad));
        } else {
            bytes[] memory expected = new bytes[](empty ? 0 : 1);
            if (!empty) {
                // abi.encode(T) is already the one-argument calldata tuple.
                bytes memory args = c.canonical;
                if (constantSlot) args = c.tagged;
                expected[0] = abi.encode(bytes.concat(cb.selector, args));
            }
            assertEq(out, abi.encode(expected));
        }
    }

    function checkResult(Value memory c, bool fold, bool late) internal view {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(late ? c.initial : c.data);
        values[1] = abi.encode(late ? c.data : c.initial);
        Collections.Callback memory cb;
        cb.target = address(oracle);
        bytes memory data;
        if (fold) {
            cb.selector = bytes4(0xf00d0001);
            cb.arguments = string.concat("(", c.t, ",bytes)");
            cb.constants = new bytes[](2);
            cb.constants[0] = c.initial;
            cb.constants[1] = abi.encode(bytes(""));
            cb.second = 1;
            data = abi.encodeCall(Collections.foldValues, ("bytes", c.t, values, c.initial, cb));
        } else {
            cb.selector = ClaimTypesOracle.raw.selector;
            cb.arguments = "(bytes)";
            cb.constants = new bytes[](1);
            cb.constants[0] = abi.encode(bytes(""));
            data = abi.encodeCall(Collections.mapValues, ("bytes", c.t, values, cb));
        }
        (bool ok, bytes memory out) = address(collections).staticcall(data);
        assertEq(ok, c.valid);
        if (!c.valid) {
            assertEq(
                out,
                abi.encodeWithSelector(
                    AbiCodec.InvalidCallbackResult.selector,
                    fold ? Collections.foldValues.selector : Collections.mapValues.selector,
                    late ? uint256(1) : uint256(0),
                    uint256(0),
                    address(oracle)
                )
            );
        } else if (fold) {
            assertEq(out, abi.encode(late ? c.canonical : c.initial));
        } else {
            bytes[] memory expected = new bytes[](2);
            expected[0] = late ? c.initial : c.canonical;
            expected[1] = late ? c.canonical : c.initial;
            assertEq(out, abi.encode(expected));
        }
    }

    function value(bytes32[4] memory words, bool composite) internal pure returns (Value memory c) {
        bytes32[4] memory markers = [A, B, C, D];
        bytes32[4] memory zero;
        c.t = composite ? "(uint8[],bytes[])" : "uint8[][]";
        c.wide = composite ? "(uint256[],bytes[])" : "uint256[][]";
        c.data = composite ? compositeData(words, false) : abi.encode(wideArrays(words));
        c.canonical = composite ? compositeData(words, true) : abi.encode(narrowArrays(words));
        c.tagged = composite ? compositeArguments(words) : abi.encode(narrowArrays(words), bytes32(uint256(7)));
        c.initial = composite ? compositeData(zero, true) : abi.encode(narrowArrays(zero));
        c.valid = clean(words, composite);
        if (!c.valid) {
            bytes memory fixture = composite ? compositeData(markers, false) : abi.encode(wideArrays(markers));
            for (uint256 i; i < (composite ? 2 : 4); i++) {
                if (uint256(words[i]) > 255) {
                    c.bad = findWord(fixture, markers[i]);
                    break;
                }
            }
        }
    }

    function clean(bytes32[4] memory w, bool composite) internal pure returns (bool) {
        return
            uint256(w[0]) <= 255 && uint256(w[1]) <= 255
                && (composite || (uint256(w[2]) <= 255 && uint256(w[3]) <= 255));
    }

    function wideArrays(bytes32[4] memory w) internal pure returns (uint256[][] memory a) {
        a = new uint256[][](2);
        a[0] = new uint256[](2);
        a[1] = new uint256[](2);
        a[0][0] = uint256(w[0]);
        a[0][1] = uint256(w[1]);
        a[1][0] = uint256(w[2]);
        a[1][1] = uint256(w[3]);
    }

    function narrowArrays(bytes32[4] memory w) internal pure returns (uint8[][] memory a) {
        a = new uint8[][](2);
        a[0] = new uint8[](2);
        a[1] = new uint8[](2);
        a[0][0] = uint8(uint256(w[0]));
        a[0][1] = uint8(uint256(w[1]));
        a[1][0] = uint8(uint256(w[2]));
        a[1][1] = uint8(uint256(w[3]));
    }

    function compositeData(bytes32[4] memory w, bool narrow) internal pure returns (bytes memory) {
        bytes[] memory blobs = new bytes[](2);
        blobs[0] = hex"a5";
        blobs[1] = abi.encodePacked(w[2], bytes1(0x7f));
        if (narrow) {
            uint8[] memory numbers = new uint8[](2);
            numbers[0] = uint8(uint256(w[0]));
            numbers[1] = uint8(uint256(w[1]));
            return abi.encode(NarrowComposite(numbers, blobs));
        }
        uint256[] memory wide = new uint256[](2);
        wide[0] = uint256(w[0]);
        wide[1] = uint256(w[1]);
        return abi.encode(WideComposite(wide, blobs));
    }

    function compositeArguments(bytes32[4] memory w) internal pure returns (bytes memory) {
        uint8[] memory numbers = new uint8[](2);
        numbers[0] = uint8(uint256(w[0]));
        numbers[1] = uint8(uint256(w[1]));
        bytes[] memory blobs = new bytes[](2);
        blobs[0] = hex"a5";
        blobs[1] = abi.encodePacked(w[2], bytes1(0x7f));
        return abi.encode(NarrowComposite(numbers, blobs), bytes32(uint256(7)));
    }

    function findWord(bytes memory data, bytes32 marker) internal pure returns (uint256 found) {
        uint256 matches;
        for (uint256 i; i + 32 <= data.length; i += 32) {
            bytes32 word;
            assembly ("memory-safe") { word := mload(add(add(data, 32), i)) }
            if (word == marker) {
                found = i;
                matches++;
            }
        }
        assertEq(matches, 1, "fixture sentinel must be unique");
    }

    function setWord(bytes memory data, uint256 offset, bytes32 word) internal pure {
        assertTrue(offset + 32 <= data.length);
        assembly ("memory-safe") { mstore(add(add(data, 32), offset), word) }
    }

    function test_behaviorNestedCodecSamples() public view {
        bytes32[4] memory w = [bytes32(uint256(1)), bytes32(uint256(2)), bytes32(uint256(3)), bytes32(uint256(4))];
        check_behaviorNestedPack(w);
        check_behaviorNestedUnpack(w);
        for (uint8 fault; fault < 5; fault++) {
            check_behaviorNestedUnpackEncodingFaults(C, fault);
        }
        check_behaviorNestedPackTrailingData(0x00);
        check_behaviorNestedPackTrailingData(0xff);
        for (uint256 i; i < 4; i++) {
            bytes32 old = w[i];
            w[i] = bytes32(uint256(256));
            check_behaviorNestedPack(w);
            check_behaviorNestedUnpack(w);
            w[i] = old;
        }
    }

    function test_behaviorNestedNodeAndCallbackSamples() public view {
        bytes32[4] memory w = [bytes32(uint256(7)), bytes32(uint256(9)), bytes32(uint256(11)), bytes32(uint256(13))];
        for (uint256 shape; shape < 2; shape++) {
            check_behaviorNestedNodeValidation(w, shape == 1);
            check_behaviorNestedCallbackSlots(w, shape == 1, false, false);
            check_behaviorNestedCallbackSlots(w, shape == 1, true, false);
            check_behaviorNestedCallbackResults(w, shape == 1, false, false);
            check_behaviorNestedCallbackResults(w, shape == 1, true, true);
            bytes32 old = w[1];
            w[1] = bytes32(uint256(256));
            check_behaviorNestedNodeValidation(w, shape == 1);
            check_behaviorNestedCallbackSlots(w, shape == 1, true, true);
            check_behaviorNestedCallbackSlots(w, shape == 1, false, false);
            check_behaviorNestedCallbackResults(w, shape == 1, false, true);
            check_behaviorNestedCallbackResults(w, shape == 1, true, false);
            w[1] = old;
        }
    }

    function test_behaviorNestedPaddingSamples() public view {
        for (uint8 route; route < 4; route++) {
            check_behaviorCompositePaddingErrors(7, 9, C, false, route);
            check_behaviorCompositePaddingErrors(7, 9, C, true, route);
        }
    }
}

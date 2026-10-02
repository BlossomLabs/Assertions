// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Operations.sol";
import "../Collections.sol";
import "../lib/AbiCodec.sol";

contract AbiCodecTest is Test {
    Operations ops;
    Collections collections;

    function setUp() public {
        ops = new Operations();
        collections = new Collections();
    }

    function assertRejected(bytes memory value, string memory descriptor) private view {
        bytes[] memory args = new bytes[](1);
        args[0] = value;
        (bool rawOK, bytes memory rawError) = address(ops).staticcall(abi.encodeCall(Operations.encode, (descriptor, args)));
        (bool bytesOK, bytes memory bytesError) = address(ops).staticcall(abi.encodeCall(Operations.encodeBytes, (descriptor, args)));
        assertFalse(rawOK);
        assertFalse(bytesOK);
        assertEq(rawError, bytesError);
        assertEq(bytes4(rawError), AbiCodec.InvalidComponentValue.selector);
    }

    function testEncodingRejectsMalformedNestedValues() public view {
        string[] memory strings = new string[](1);
        strings[0] = "hello";
        bytes memory value = abi.encode(strings);
        assertRejected(bytes.concat(value, abi.encode(uint256(0))), "(string[])");
        // Find the nested string's canonical head offset independently.
        bytes memory badOffset = abi.encode(strings);
        uint256 matches;
        for (uint256 p = 32; p < badOffset.length; p += 32) {
            uint256 w;
            assembly { w := mload(add(add(badOffset, 32), p)) }
            if (w == 32) {
                assembly { mstore(add(add(badOffset, 32), p), 0) }
                matches++;
            }
        }
        assertEq(matches, 1);
        assertRejected(badOffset, "(string[])");
        value[value.length - 1] = 0x01;
        assertRejected(value, "(string[])");
    }

    function testEncodingRejectsOverflowingAndTruncatedLengths() public view {
        assertRejected(abi.encode(uint256(32), type(uint256).max), "(bytes)");
        assertRejected(abi.encode(uint256(32), type(uint256).max), "(uint256[])");
        assertRejected(abi.encode(uint256(32), uint256(33), uint256(0)), "(bytes)");
    }

    function testEncodingNamesMalformedComponent() public {
        bytes[] memory args = new bytes[](2);
        args[0] = abi.encode(uint256(7));
        args[1] = abi.encode(uint256(32), type(uint256).max);
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(1), uint256(32)));
        ops.encodeBytes("(uint256,bytes)", args);
    }

    function extremeResult(uint256 mode) external pure returns (bytes memory) {
        if (mode == 0) return "ok";
        assembly {
            mstore(0, 32)
            mstore(32, not(0))
            return(0, 64)
        }
    }

    function testMalformedResultKeepsCallbackContextWithoutSelfCall() public {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(uint256(0));
        values[1] = abi.encode(uint256(1));
        Collections.Callback memory cb = Collections.Callback(
            address(this), this.extremeResult.selector, "(uint256)", new bytes[](1), 0, 0, ""
        );
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidCallbackResult.selector,
            collections.mapValues.selector, uint256(1), uint256(0), address(this)));
        collections.mapValues("uint256", "bytes", values, cb);
    }

    function testEncodingAcceptsWordBoundaryPayloadsAndNestedFixedArrays() public view {
        for (uint256 n = 31; n <= 33; n++) {
            bytes memory payload = new bytes(n);
            for (uint256 i; i < n; i++) payload[i] = bytes1(uint8(i + 1));
            bytes[2] memory pair = [payload, bytes("")];
            bytes[] memory args = new bytes[](2);
            args[0] = abi.encode(uint256(9));
            args[1] = abi.encode(pair);
            bytes memory expected = abi.encode(uint256(9), pair);
            assertEq(ops.encodeBytes("(uint256,bytes[2])", args), expected);
            (bool ok, bytes memory raw) = address(ops).staticcall(abi.encodeCall(Operations.encode, ("(uint256,bytes[2])", args)));
            assertTrue(ok);
            assertEq(raw, expected);
        }
    }

    // ============ Canonical words for narrow static types ============

    function decodeUint8(bytes calldata e) external pure returns (uint8) { return abi.decode(e, (uint8)); }
    function decodeUint64(bytes calldata e) external pure returns (uint64) { return abi.decode(e, (uint64)); }
    function decodeUint248(bytes calldata e) external pure returns (uint248) { return abi.decode(e, (uint248)); }
    function decodeUint256(bytes calldata e) external pure returns (uint256) { return abi.decode(e, (uint256)); }
    function decodeInt8(bytes calldata e) external pure returns (int8) { return abi.decode(e, (int8)); }
    function decodeInt64(bytes calldata e) external pure returns (int64) { return abi.decode(e, (int64)); }
    function decodeInt248(bytes calldata e) external pure returns (int248) { return abi.decode(e, (int248)); }
    function decodeInt256(bytes calldata e) external pure returns (int256) { return abi.decode(e, (int256)); }
    function decodeAddress(bytes calldata e) external pure returns (address) { return abi.decode(e, (address)); }
    function decodeBool(bytes calldata e) external pure returns (bool) { return abi.decode(e, (bool)); }
    function decodeBytes1(bytes calldata e) external pure returns (bytes1) { return abi.decode(e, (bytes1)); }
    function decodeBytes20(bytes calldata e) external pure returns (bytes20) { return abi.decode(e, (bytes20)); }
    function decodeBytes31(bytes calldata e) external pure returns (bytes31) { return abi.decode(e, (bytes31)); }
    function decodeBytes32(bytes calldata e) external pure returns (bytes32) { return abi.decode(e, (bytes32)); }

    function packs(string memory descriptor, uint256 w) private view returns (bool ok) {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(w);
        (ok,) = address(collections).staticcall(abi.encodeCall(Collections.packArray, (descriptor, values)));
    }

    function solcDecodes(bytes4 decoder, uint256 w) private view returns (bool ok) {
        (ok,) = address(this).staticcall(abi.encodeWithSelector(decoder, abi.encode(w)));
    }

    /**
     * @dev Differential against solc's decoder: for every narrow type and
     *      every boundary word, the codec accepts exactly what abi.decode
     *      accepts
     */
    function testStaticWordsMatchSolcDecoder() public view {
        uint256[16] memory words = [
            uint256(0), 1, 2, 0x7f, 0x80, 0xff, 0x100, type(uint64).max, uint256(type(uint64).max) + 1,
            type(uint160).max, uint256(type(uint160).max) + 1, type(uint248).max, uint256(type(uint248).max) + 1,
            type(uint256).max, uint256(type(uint256).max) << 248, uint256(type(uint256).max) - 0x7f
        ];
        string[16] memory names = [
            "uint8", "uint64", "uint248", "uint256", "int8", "int64", "int248", "int256",
            "address", "bool", "bytes1", "bytes20", "bytes31", "bytes32", "uint", "int"
        ];
        bytes4[16] memory decoders = [
            this.decodeUint8.selector, this.decodeUint64.selector, this.decodeUint248.selector,
            this.decodeUint256.selector, this.decodeInt8.selector, this.decodeInt64.selector,
            this.decodeInt248.selector, this.decodeInt256.selector, this.decodeAddress.selector,
            this.decodeBool.selector, this.decodeBytes1.selector, this.decodeBytes20.selector,
            this.decodeBytes31.selector, this.decodeBytes32.selector, this.decodeUint256.selector,
            this.decodeInt256.selector
        ];
        uint256 rejections;
        for (uint256 t; t < names.length; t++) {
            for (uint256 i; i < words.length; i++) {
                bool expected = solcDecodes(decoders[t], words[i]);
                assertEq(packs(names[t], words[i]), expected, string.concat(names[t], " word ", vm.toString(i)));
                if (!expected) rejections++;
            }
        }
        // The oracle must actually reject something, or the comparison is vacuous.
        assertGt(rejections, 50);
    }

    function testFunctionWordsAreLeftAligned() public view {
        assertTrue(packs("function", uint256(type(uint192).max) << 64));
        assertFalse(packs("function", 1 << 63));
    }

    /** @dev Byte offset of the first word equal to `sentinel` at or after `from` */
    function find(bytes memory data, uint256 sentinel, uint256 from) private pure returns (uint256 p) {
        for (p = from; p + 32 <= data.length; p += 32) {
            uint256 w;
            assembly { w := mload(add(add(data, 32), p)) }
            if (w == sentinel) return p;
        }
        revert("sentinel not found");
    }

    function testDirtyWordsAreRejectedOnEveryPath() public {
        uint256 dirty = 0x100;
        bytes[] memory one = new bytes[](1);

        // unpack: a static element inside the array
        bytes memory array = abi.encodePacked(uint256(32), uint256(2), uint256(1), dirty);
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, find(array, dirty, 64)));
        collections.unpackArray("uint8", array);

        // body: a dynamic value's static elements
        one[0] = array;
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, find(array, dirty, 64)));
        collections.packArray("uint8[]", one);

        // body: a dynamic tuple's static component
        bytes memory pair = bytes.concat(abi.encode(uint256(32)), abi.encode(uint256(2), "a"));
        one[0] = pair;
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, find(pair, 2, 32)));
        collections.packArray("(bool,string)", one);

        // validate: a static tuple nested in a static tuple
        bytes memory nested = abi.encode(uint256(7), uint256(1), uint256(1) << 160);
        one[0] = nested;
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, find(nested, uint256(1) << 160, 0)));
        collections.packArray("(uint256,(bool,address))", one);

        // validate: a fixed array of signed words
        bytes memory fixedArray = abi.encode(type(uint256).max, uint256(0x80));
        one[0] = fixedArray;
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, find(fixedArray, 0x80, 0)));
        collections.packArray("int8[2]", one);

        // validateComponent: a static tuple component
        bytes[] memory args = new bytes[](2);
        args[0] = abi.encode(uint256(1));
        args[1] = abi.encode(uint256(1) << 160);
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(1), uint256(0)));
        ops.encodeBytes("(uint256,address)", args);

        // validateComponent: a static word inside a dynamic component
        one[0] = abi.encodePacked(uint256(32), uint256(1), dirty);
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidComponentValue.selector, uint256(0), find(one[0], dirty, 64)));
        ops.encodeBytes("(uint8[])", one);
    }

    function testFullWidthAndUnrecognisedNamesAcceptEveryWord() public view {
        string[8] memory names = ["uint256", "bytes32", "int", "uint7", "uint08", "uint512", "int1000", "bytes0"];
        for (uint256 t; t < names.length; t++) {
            assertTrue(packs(names[t], type(uint256).max));
            assertTrue(packs(names[t], uint256(1) << 255));
        }
    }

    function testEmptyArraysOfNarrowTypesAreAccepted() public view {
        bytes memory empty = abi.encode(new uint256[](0));
        string[3] memory elements = ["(int256,bool)", "uint8", "(uint8)[2]"];
        for (uint256 i; i < elements.length; i++) {
            assertEq(collections.unpackArray(elements[i], empty).length, 0);
            bytes[] memory one = new bytes[](1);
            one[0] = empty;
            // One empty inner array encodes the same whatever its element type.
            assertEq(collections.packArray(string.concat(elements[i], "[]"), one), abi.encode(new uint256[][](1)));
        }
        bytes[] memory args = new bytes[](1);
        args[0] = empty;
        assertEq(ops.encodeBytes("((uint8)[])", args), abi.encode(new uint256[](0)));
    }

    function testFixedArraysOfTuplesCheckEveryCopy() public {
        bytes[] memory one = new bytes[](1);
        one[0] = abi.encode(uint256(0x96), uint256(0x36), uint256(0));
        assertEq(collections.packArray("(uint8)[3]", one), abi.encodePacked(uint256(32), uint256(1), one[0]));
        one[0] = abi.encode(uint256(1), uint256(2), uint256(0x100));
        vm.expectRevert(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, find(one[0], 0x100, 0)));
        collections.packArray("(uint8)[3]", one);
    }

    function testHugeFixedLengthsRevertInvalidTypeDescriptor() public {
        bytes[] memory none = new bytes[](0);
        // The last length that parses: 2**32 - 1 words.
        collections.packArray("uint256[4294967295]", none);
        // One past it, rejected at the closing bracket.
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(18)));
        collections.packArray("uint256[4294967296]", none);
        // A length whose digits alone would overflow stops at the digit that crosses the bound.
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(18)));
        collections.packArray(
            "uint256[999999999999999999999999999999999999999999999999999999999999999999999999999999]", none
        );
        // In-bound lengths whose product is not.
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(21)));
        collections.packArray("uint256[4294967295][2]", none);
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(30)));
        collections.packArray("(uint256[65536],uint256)[65536]", none);
    }

    function testZeroLengthsRevertInvalidTypeDescriptor() public {
        bytes[] memory none = new bytes[](0);
        // solc refuses T[0], and so does the grammar, at the closing bracket.
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(7)));
        collections.packArray("uint8[0]", none);
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(8)));
        collections.packArray("uint8[00]", none);
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(10)));
        collections.unpackArray("(uint256[0])[2]", abi.encode(uint256(32), uint256(0)));
        vm.expectRevert(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(8)));
        collections.packArray("string[0]", none);
        // A leading zero is still a length.
        assertEq(collections.packArray("uint8[01]", none), abi.encode(uint256(32), uint256(0)));
    }
}

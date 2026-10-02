// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;
import {AbiCodec} from "../src/AbiCodec.sol";

contract DynamicHarness {
    function validate(bytes calldata t, bytes memory v) external pure returns (bool) {
        return AbiCodec.validate(t, v);
    }

    function body(bytes calldata t, bytes memory v, uint256 p) external pure returns (uint256) {
        (bool dynamic,) = AbiCodec.shape(t);
        require(dynamic);
        AbiCodec.Context memory context;
        return AbiCodec.body(t, 0, t.length, v, p, context);
    }

    function zero(bytes calldata t, uint256 p) external pure returns (uint256, uint256) {
        (bool dynamic,) = AbiCodec.shape(t);
        require(!dynamic);
        AbiCodec.Context memory context;
        return AbiCodec.checkWords(t, 0, t.length, 0, new bytes(0), p, context);
    }
}

contract DynamicOracleTest {
    DynamicHarness private target = new DynamicHarness();

    struct Mixed {
        uint8[2] counts;
        bytes[][] data;
        bool flag;
    }

    struct Item {
        bytes payload;
        uint8 n;
    }

    function valid(bytes memory t, bytes memory v, bool dynamic) private view {
        (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.validate, (t, v)));
        require(ok && keccak256(out) == keccak256(abi.encode(dynamic)), "canonical encoding rejected");
    }

    function invalid(bytes memory t, bytes memory v, uint256 at) private view {
        (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.validate, (t, v)));
        require(
            !ok && keccak256(out) == keccak256(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, at)),
            "wrong rejection"
        );
    }

    function extent(bytes memory t, bytes memory v, uint256 p, uint256 used) private view {
        (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.body, (t, v, p)));
        require(ok && keccak256(out) == keccak256(abi.encode(used)), "wrong extent");
    }

    function changed(bytes memory v, uint256 p, uint256 w) private pure returns (bytes memory copy) {
        copy = bytes.concat(v);
        assembly ("memory-safe") { mstore(add(add(copy, 32), p), w) }
    }

    function sentinel(bytes memory v, bytes memory marker) private pure returns (uint256) {
        for (uint256 i; i + marker.length <= v.length; i++) {
            bool matches = true;
            for (uint256 j; j < marker.length; j++) {
                if (v[i + j] != marker[j]) matches = false;
            }
            if (matches) return i;
        }
        revert("sentinel missing");
    }

    function sample() private pure returns (Mixed[] memory values) {
        values = new Mixed[](2);
        values[0].counts = [uint8(17), uint8(29)];
        values[0].data = new bytes[][](2);
        values[0].data[0] = new bytes[](0);
        values[0].data[1] = new bytes[](2);
        values[0].data[1][0] = hex"deadbeef42";
        values[0].data[1][1] = new bytes(33);
        values[1].counts = [uint8(151), uint8(239)];
        values[1].data = new bytes[][](0);
        values[1].flag = true;
    }

    function testRaggedArraysOfDynamicArrays() public view {
        uint8[][][] memory values = new uint8[][][](2);
        values[0] = new uint8[][](0);
        values[1] = new uint8[][](2);
        values[1][0] = new uint8[](0);
        values[1][1] = new uint8[](3);
        values[1][1][2] = 239;
        bytes memory v = abi.encode(values);
        valid("uint8[][][]", v, true);
        extent("uint8[][][]", v, 32, v.length - 32);
    }

    function testMixedRecursiveTupleArrays() public view {
        bytes memory v = abi.encode(sample());
        valid("(uint8[2],bytes[][],bool)[]", v, true);
        extent("(uint8[2],bytes[][],bool)[]", v, 32, v.length - 32);
    }

    function testDirtyStaticWordInsideDynamicRecursion() public view {
        bytes memory v = abi.encode(sample());
        uint256 at = sentinel(v, abi.encode(uint256(151), uint256(239)));
        invalid("(uint8[2],bytes[][],bool)[]", changed(v, at, 256), at);
    }

    function testDirtyNestedBytesPaddingNamesByte() public view {
        bytes memory v = abi.encode(sample());
        uint256 at = sentinel(v, hex"deadbeef42") + 5;
        v[at] = 0x01;
        invalid("(uint8[2],bytes[][],bool)[]", v, at);
    }

    function testTrailingByteAfterRecursiveBody() public view {
        bytes memory v = abi.encode(sample());
        invalid("(uint8[2],bytes[][],bool)[]", bytes.concat(v, hex"00"), v.length);
    }

    function testWrongDynamicEnvelopeIsRejectedFirst() public view {
        bytes memory v = abi.encode(sample());
        invalid("(uint8[2],bytes[][],bool)[]", changed(v, 0, 64), 0);
    }

    function testLooseArrayOffsetNamesItsWord() public view {
        bytes[] memory values = new bytes[](2);
        values[0] = hex"12";
        values[1] = hex"3456";
        bytes memory v = abi.encode(values);
        // The array header consists of its envelope, count and two offsets.
        invalid("bytes[]", changed(v, 64, 96), 64);
    }

    function testSecondTuplePassMixedStaticAndDynamic() public view {
        bytes memory v = abi.encode(hex"ab", uint8(239), true, "last");
        bytes memory canonical = bytes.concat(abi.encode(uint256(32)), v);
        valid("(bytes,uint8,bool,string)", canonical, true);
        extent("(bytes,uint8,bool,string)", v, 0, v.length);
    }

    function testDynamicFixedArrayOfTuples() public view {
        Item[3] memory values;
        values[0] = Item(hex"1234", 17);
        values[2] = Item(new bytes(65), 239);
        bytes memory v = abi.encode(values);
        valid("(bytes,uint8)[3]", v, true);
        extent("(bytes,uint8)[3]", v, 32, v.length - 32);
    }

    function testStaticElementArrayExtentIncludesCount() public view {
        uint8[2][] memory values = new uint8[2][](3);
        values[2] = [uint8(17), uint8(239)];
        bytes memory v = abi.encode(values);
        valid("uint8[2][]", v, true);
        extent("uint8[2][]", v, 32, v.length - 32);
    }

    function testEmptyDynamicAndStaticElementArrays() public view {
        bytes[][] memory dynamicValues = new bytes[][](0);
        uint8[2][] memory staticValues = new uint8[2][](0);
        valid("bytes[][]", abi.encode(dynamicValues), true);
        valid("uint8[2][]", abi.encode(staticValues), true);
    }

    function testRecursiveBodyAtUnalignedOriginWithFollowingBytes() public view {
        bytes memory v = abi.encode(sample());
        bytes memory body = new bytes(v.length - 32);
        for (uint256 i; i < body.length; i++) {
            body[i] = v[i + 32];
        }
        bytes memory shifted = bytes.concat(new bytes(13), body, hex"aabbcc");
        extent("(uint8[2],bytes[][],bool)[]", shifted, 13, body.length);
    }

    function testZeroCopyExactLastCursorBoundary() public view {
        bytes memory t = "(bool,uint8[2],bytes3)";
        uint256 p = type(uint256).max - 96;
        (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.zero, (t, p)));
        require(
            ok && keccak256(out) == keccak256(abi.encode(t.length, uint256(4))), "representable last cursor rejected"
        );
        (ok, out) = address(target).staticcall(abi.encodeCall(target.zero, (t, p + 1)));
        require(
            !ok && keccak256(out) == keccak256(abi.encodeWithSignature("Panic(uint256)", uint256(0x11))),
            "overflow not preserved"
        );
    }

    function testZeroCopyFixedSuffixDoesNotTraverseCopies() public view {
        bytes memory t = "(bool,uint8[2],bytes3)[100]";
        (bool ok, bytes memory out) =
            address(target).staticcall(abi.encodeCall(target.zero, (t, type(uint256).max - 96)));
        require(ok && keccak256(out) == keccak256(abi.encode(t.length, uint256(400))), "zero copies expanded");
    }

    function testZeroCopyOpaqueLeafAllowsMaximumOrigin() public view {
        bytes memory t = "foo[4294967295]";
        (bool ok, bytes memory out) = address(target).staticcall(abi.encodeCall(target.zero, (t, type(uint256).max)));
        require(ok && keccak256(out) == keccak256(abi.encode(t.length, uint256(4294967295))), "leaf read data");
    }

    function testEmptyOrShortDynamicValueRejectedAtEnvelope() public view {
        invalid("(bytes,uint8)", new bytes(0), 0);
        invalid("bytes[][]", new bytes(31), 0);
    }
}

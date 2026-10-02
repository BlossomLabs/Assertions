// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {AbiCodec, InvalidTypeDescriptor} from "../src/AbiCodec.sol";

contract TupleWordHarness {
    function checked(
        bytes calldata descriptor,
        uint256 start,
        uint256 limit,
        uint256 count,
        bytes memory value,
        uint256 p
    ) external pure returns (uint256 end, uint256 words) {
        (, bool dynamic, uint256 width) = AbiCodec.typeShape(descriptor, start, limit);
        require(!dynamic);
        if (count > 0) require(p <= value.length && count <= (value.length - p) / 32 / width);
        AbiCodec.Context memory context;
        return AbiCodec.checkWords(descriptor, start, limit, count, value, p, context);
    }
}

contract TupleOracleTest {
    TupleWordHarness private target = new TupleWordHarness();

    struct Pair {
        uint8 n;
        bool flag;
    }

    struct Tag {
        bytes3 label;
        int8 amount;
    }

    struct Composite {
        Pair[2] pairs;
        Tag tag;
    }

    function callCheck(bytes memory descriptor, uint256 count, bytes memory value, uint256 p)
        private
        view
        returns (bool, bytes memory)
    {
        return address(target)
            .staticcall(abi.encodeCall(target.checked, (descriptor, 0, descriptor.length, count, value, p)));
    }

    function valid(string memory descriptor, uint256 count, bytes memory value, uint256 p, uint256 width) private view {
        (bool ok, bytes memory data) = callCheck(bytes(descriptor), count, value, p);
        require(ok && keccak256(data) == keccak256(abi.encode(bytes(descriptor).length, width)), descriptor);
    }

    function dirty(string memory descriptor, uint256 count, bytes memory value, uint256 p, uint256 offset)
        private
        view
    {
        (bool ok, bytes memory data) = callCheck(bytes(descriptor), count, value, p);
        require(
            !ok && keccak256(data) == keccak256(abi.encodeWithSelector(AbiCodec.InvalidValue.selector, offset)),
            descriptor
        );
    }

    function testArrayOfTuplesMatchesSolidityEncoding() public view {
        Pair[3][2] memory pairs;
        pairs[0][0] = Pair(13, true);
        pairs[1][2] = Pair(255, false);
        bytes memory data = abi.encode(pairs);
        valid("(uint8,bool)[3][2]", 1, data, 0, data.length / 32);
    }

    function testNestedTupleCopiesMatchSolidityEncoding() public view {
        Composite[3] memory values;
        values[0].pairs[1] = Pair(29, true);
        values[1].tag = Tag("abc", -17);
        values[2].pairs[0] = Pair(42, true);
        bytes memory data = abi.encode(values);
        valid("((uint8,bool)[2],(bytes3,int8))[3]", 1, data, 0, data.length / 32);
        // Locate the bytes3 sentinel instead of duplicating layout arithmetic.
        uint256 marker;
        for (uint256 i; i + 32 <= data.length; i += 32) {
            if (data[i] == bytes1("a") && data[i + 1] == bytes1("b") && data[i + 2] == bytes1("c")) marker = i;
        }
        require(marker != 0, "sentinel");
        data[marker + 31] = 0x01;
        dirty("((uint8,bool)[2],(bytes3,int8))[3]", 1, data, 0, marker);
    }

    function testEveryTupleCopyChecksEveryWord() public view {
        bytes memory data = new bytes(13 + 32 * 12);
        valid("(uint8,bool)[3]", 2, data, 13, 6);
        for (uint256 i; i < 12; ++i) {
            uint256 offset = 13 + i * 32;
            data[offset] = 0xff;
            dirty("(uint8,bool)[3]", 2, data, 13, offset);
            data[offset] = 0x00;
        }
    }

    function testFirstFailurePrecedesLaterDirtyCopies() public view {
        bytes memory data = abi.encode(uint8(1), true, uint8(2), false, uint8(3), true);
        data[64] = 0xff;
        data[160] = 0xff;
        dirty("(uint8,bool)[3]", 1, data, 0, 64);
    }

    function testZeroCopiesIgnoreDirtyWordsAndOutOfAllocationOrigins() public view {
        bytes memory data = abi.encode(type(uint256).max);
        valid("(((bool,address)[2],bytes3)[3],uint8)[2]", 0, data, 0, 32);
        valid("(((bool,address)[2],bytes3)[3],uint8)[2]", 0, data, 17, 32);
        valid("(((bool,address)[2],bytes3)[3],uint8)[2]", 0, new bytes(0), 4096, 32);
        valid("(((bool,address)[2],bytes3)[3],uint8)[2]", 0, new bytes(0), type(uint256).max - 32 * 32 - 1, 32);
    }

    function testZeroCopiesStillRequireRepresentableTupleCursors() public view {
        (bool ok, bytes memory data) = callCheck(bytes("(bool,bool)"), 0, new bytes(0), type(uint256).max - 10);
        require(
            !ok && keccak256(data) == keccak256(abi.encodeWithSignature("Panic(uint256)", uint256(0x11))),
            "cursor overflow"
        );
    }

    function testZeroCopiesStillValidateDescriptorGrammar() public view {
        (bool ok, bytes memory data) = callCheck(bytes("()"), 0, new bytes(0), 0);
        require(!ok && keccak256(data) == keccak256(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1))));
        (ok, data) = callCheck(bytes("(bool)[0]"), 0, new bytes(0), 0);
        require(!ok && keccak256(data) == keccak256(abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(8))));
    }

    function testMaximumTupleFootprintWithZeroCopies() public view {
        valid("(bool)[4294967295]", 0, new bytes(0), 0, type(uint32).max);
        valid("((bool)[65535])[65537]", 0, new bytes(0), 0, type(uint32).max);
    }

    function testTupleCopiesRespectTheirDescriptorSubspan() public view {
        bytes memory descriptor = bytes("!!(uint8,bool)[3],bytes");
        Pair[3] memory pairs;
        pairs[2] = Pair(255, true);
        bytes memory value = abi.encode(pairs);
        uint256 end;
        for (uint256 i; i < descriptor.length; ++i) {
            if (descriptor[i] == "]") end = i + 1;
        }
        (bool ok, bytes memory data) =
            address(target).staticcall(abi.encodeCall(target.checked, (descriptor, 2, descriptor.length, 1, value, 0)));
        require(ok && keccak256(data) == keccak256(abi.encode(end, value.length / 32)), "subspan");
    }

    function testOpaqueNamesKeepTheirOwnWordsUnrestricted() public view {
        bytes memory value = abi.encode(type(uint256).max, uint8(3), type(uint256).max, uint8(4));
        valid("(foo,uint8)[2]", 1, value, 0, value.length / 32);
        value[96] = 0xff;
        dirty("(foo,uint8)[2]", 1, value, 0, 96);
    }
}

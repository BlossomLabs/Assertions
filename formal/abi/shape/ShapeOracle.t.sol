// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {AbiCodec, InvalidTypeDescriptor} from "../src/AbiCodec.sol";

contract ShapeHarness {
    function prefix(bytes calldata descriptor, uint256 start, uint256 limit)
        external
        pure
        returns (uint256 end, bool dynamic, uint256 words)
    {
        return AbiCodec.typeShape(descriptor, start, limit);
    }

    function whole(bytes calldata descriptor) external pure returns (bool dynamic, uint256 words) {
        return AbiCodec.shape(descriptor);
    }
}

contract ShapeOracleTest {
    ShapeHarness private target = new ShapeHarness();

    function valid(string memory descriptor, bool dynamic, uint256 words) private view {
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeCall(target.whole, (bytes(descriptor))));
        require(ok && keccak256(data) == keccak256(abi.encode(dynamic, words)), descriptor);
    }

    function invalid(string memory descriptor, uint256 offset) private view {
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeCall(target.whole, (bytes(descriptor))));
        require(
            !ok && keccak256(data) == keccak256(abi.encodeWithSelector(InvalidTypeDescriptor.selector, offset)),
            descriptor
        );
    }

    function testNamesAreShapesNotSolidityTypeValidation() public view {
        valid("uint8", false, 1);
        valid("foo", false, 1);
        valid("uint7", false, 1);
        valid("uint08", false, 1);
        valid("0", false, 1);
        valid("bytes3", false, 1);
        valid("bytes", true, 1);
        valid("string", true, 1);
        valid("bytes0", false, 1);
        valid("strings", false, 1);
        invalid("Bytes", 0);
        invalid("uint_8", 4);
        invalid("", 0);
    }

    function testStaticTupleAndArrayGeometryUsesSolidityEncoding() public view {
        uint8[2][3] memory array;
        bool[2] memory flags;
        valid("uint8[02][003]", false, abi.encode(array).length / 32);
        valid("(uint8[2][3],bool[2],bytes3)", false, abi.encode(array, flags, bytes3("abc")).length / 32);
        valid("((uint8,bool)[2],bytes3[3])[2]", false, 14);
    }

    function testDynamicPropagationThroughEveryConstructor() public view {
        valid("(uint8,bytes)", true, 1);
        valid("(string,uint8)", true, 1);
        valid("((uint8,string)[3],bool)[2]", true, 1);
        valid("(uint8,bool)[]", true, 1);
        valid("uint8[][2][3]", true, 1);
        valid("uint8[2][][3]", true, 1);
        valid("bytes[2][3]", true, 1);
        valid("bytes[][2][]", true, 1);
    }

    function testTupleFailuresPinFirstOffendingByte() public view {
        invalid("()", 1);
        invalid("(uint8,)", 7);
        invalid("(,uint8)", 1);
        invalid("(uint8", 6);
        invalid("(uint8 bool)", 6);
        invalid("((uint8),())", 10);
        invalid("(uint8))", 7);
    }

    function testArrayRejectionsPinConsumedDigitAndDelimiter() public view {
        invalid("uint8[0]", 7);
        invalid("uint8[00]", 8);
        invalid("bytes[0]", 7);
        invalid("uint8[", 6);
        invalid("uint8[12", 8);
        invalid("uint8[x]", 6);
        invalid("uint8[1x]", 7);
        invalid("uint8[-1]", 6);
        invalid("uint8[4294967296]", 16);
        invalid("uint8[42949672960]", 16);
        invalid("uint8[65536][65536]", 18);
        invalid("bytes[4294967296]", 16);
        invalid("uint8[][0]", 9);
    }

    function testBareTupleCanExceedArrayFootprintCap() public view {
        valid("uint8[4294967295]", false, type(uint32).max);
        valid("bytes[4294967295]", true, 1);
        valid("(uint8[4294967295],bool)", false, uint256(type(uint32).max) + 1);
        invalid("(uint8[4294967295],bool)[1]", 26);
        valid("(uint8[4294967295],bool)[]", true, 1);
        valid("(uint8[4294967295],bytes)[1]", true, 1);
    }

    function testPrefixBoundariesAndInvalidLimits() public view {
        bytes memory descriptor = bytes("!!(uint8,bytes)[02],bool");
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeCall(target.prefix, (descriptor, 2, 22)));
        require(ok && keccak256(data) == keccak256(abi.encode(uint256(19), true, uint256(1))), "prefix");
        (ok, data) = address(target).staticcall(abi.encodeCall(target.prefix, (bytes("bytes32"), 0, 5)));
        require(ok && keccak256(data) == keccak256(abi.encode(uint256(5), true, uint256(1))), "limited name");
        (ok, data) = address(target).staticcall(abi.encodeCall(target.prefix, (bytes("uint8"), 0, 6)));
        require(!ok && keccak256(data) == keccak256(abi.encodeWithSelector(InvalidTypeDescriptor.selector, 6)));
        (ok, data) = address(target).staticcall(abi.encodeCall(target.prefix, (bytes("uint8"), 5, 5)));
        require(!ok && keccak256(data) == keccak256(abi.encodeWithSelector(InvalidTypeDescriptor.selector, 5)));
    }

    function testLongDecimalLeadingZerosAndRecursiveNesting() public view {
        bytes memory descriptor = bytes("uint8[");
        for (uint256 i; i < 150; ++i) {
            descriptor = bytes.concat(descriptor, "0");
        }
        descriptor = bytes.concat(descriptor, "12]");
        for (uint256 i; i < 32; ++i) {
            descriptor = bytes.concat("(", descriptor, ")[1]");
        }
        valid(string(descriptor), false, 12);
    }
}

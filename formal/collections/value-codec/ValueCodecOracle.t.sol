// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";
import {AbiCodec, InvalidTypeDescriptor} from "../../../contracts/lib/AbiCodec.sol";

contract ValueCodecOracleTest {
    Collections private c = new Collections();

    function same(bytes memory actual, bytes memory expected) private pure {
        require(keccak256(actual) == keccak256(expected), "wrong codec bytes or error");
    }

    function fail(bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory ret) = address(c).staticcall(data);
        require(!ok, "expected codec rejection");
        same(ret, expected);
    }

    function invalid(uint256 offset) private pure returns (bytes memory) {
        return abi.encodeWithSelector(AbiCodec.InvalidValue.selector, offset);
    }

    function testEmptyCanonicalArray() public view {
        bytes[] memory values = new bytes[](0);
        bytes memory encoded = abi.encode(new uint8[](0));
        same(c.packArray("uint8", values), encoded);
        same(abi.encode(c.unpackArray("uint8", encoded)), abi.encode(values));
    }

    function testRawDescriptorPriorityInBothWrappers() public view {
        bytes[] memory values = new bytes[](1);
        values[0] = bytes("");
        bytes memory reason = abi.encodeWithSelector(InvalidTypeDescriptor.selector, uint256(1));
        fail(abi.encodeCall(c.packArray, ("()", values)), reason);
        fail(abi.encodeCall(c.unpackArray, ("()", bytes(""))), reason);
    }

    function testStaticFullWidthAndBothInverses() public view {
        uint256[] memory numbers = new uint256[](3);
        numbers[0] = 7;
        numbers[1] = type(uint256).max;
        numbers[2] = uint256(1) << 255;
        bytes[] memory values = new bytes[](3);
        for (uint256 i; i < 3; i++) {
            values[i] = abi.encode(numbers[i]);
        }
        bytes memory encoded = abi.encode(numbers);
        same(c.packArray("uint256", values), encoded);
        same(abi.encode(c.unpackArray("uint256", encoded)), abi.encode(values));
        same(c.packArray("uint256", c.unpackArray("uint256", encoded)), encoded);
    }

    function testPackValidatesEveryNarrowValue() public view {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(uint256(1));
        values[1] = abi.encode(uint256(256));
        fail(abi.encodeCall(c.packArray, ("uint8", values)), invalid(0));
    }

    function testPackFirstInvalidOffsetInOriginalOrder() public view {
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(uint256(1), uint256(2));
        values[1] = abi.encode(uint256(256), uint256(0));
        fail(abi.encodeCall(c.packArray, ("(uint8,bool)", values)), invalid(32));
    }

    function testDynamicBodiesAndBothInverses() public view {
        bytes[] memory payloads = new bytes[](2);
        payloads[0] = hex"abcdef";
        payloads[1] = bytes("");
        bytes[] memory values = new bytes[](2);
        values[0] = abi.encode(payloads[0]);
        values[1] = abi.encode(payloads[1]);
        bytes memory encoded = abi.encode(payloads);
        same(c.packArray("bytes", values), encoded);
        same(abi.encode(c.unpackArray("bytes", encoded)), abi.encode(values));
        same(c.packArray("bytes", c.unpackArray("bytes", encoded)), encoded);
    }

    function testUnpackEnvelopeCountAndTailOffsets() public view {
        fail(abi.encodeCall(c.unpackArray, ("uint8", abi.encode(uint256(31), uint256(0)))), invalid(0));
        fail(abi.encodeCall(c.unpackArray, ("uint8", abi.encode(uint256(32)))), invalid(32));
        fail(abi.encodeCall(c.unpackArray, ("uint8", abi.encode(uint256(32), uint256(1)))), invalid(64));
        bytes memory encoded = abi.encode(uint256(32), uint256(1), uint256(7));
        fail(abi.encodeCall(c.unpackArray, ("uint8", bytes.concat(encoded, abi.encode(uint256(9))))), invalid(96));
        bytes[] memory empty = new bytes[](0);
        same(abi.encode(c.unpackArray("uint8", abi.encode(uint256(32), uint256(0)))), abi.encode(empty));
    }

    function testUnpackNarrowValueAndDynamicOffset() public view {
        fail(abi.encodeCall(c.unpackArray, ("uint8", abi.encode(uint256(32), uint256(1), uint256(256)))), invalid(64));
        fail(
            abi.encodeCall(c.unpackArray, ("bytes", abi.encode(uint256(32), uint256(1), uint256(0), uint256(0)))),
            invalid(64)
        );
    }

    function testUnpackDirtyDynamicPaddingExactOffset() public view {
        bytes[] memory payloads = new bytes[](1);
        payloads[0] = hex"aa";
        bytes memory encoded = abi.encode(payloads);
        encoded[129] = 0x01;
        fail(abi.encodeCall(c.unpackArray, ("bytes", encoded)), invalid(129));
    }
}

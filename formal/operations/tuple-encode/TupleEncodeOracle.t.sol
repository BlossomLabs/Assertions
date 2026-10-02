// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsTupleEncodeOracleTest {
    Operations private ops = new Operations();

    struct Nested {
        uint256[] items;
        bytes data;
    }

    function testRawTupleAndBytesEnvelope() public view {
        bytes[] memory values = new bytes[](3);
        values[0] = abi.encode(uint256(7));
        values[1] = abi.encode(bytes("abc"));
        uint256[] memory items = new uint256[](2);
        items[0] = 11;
        items[1] = 13;
        values[2] = abi.encode(items);
        bytes memory expected = abi.encode(uint256(7), bytes("abc"), items);
        (bool rawSuccess, bytes memory raw) = address(ops)
            .staticcall(abi.encodeWithSignature("encode(string,bytes[])", "(uint256,bytes,uint256[])", values));
        require(rawSuccess && keccak256(raw) == keccak256(expected));
        require(keccak256(ops.encodeBytes("(uint256,bytes,uint256[])", values)) == keccak256(expected));
        (bool envelopedSuccess, bytes memory enveloped) = address(ops)
            .staticcall(abi.encodeWithSignature("encodeBytes(string,bytes[])", "(uint256,bytes,uint256[])", values));
        require(envelopedSuccess && keccak256(enveloped) == keccak256(abi.encode(expected)));
        bytes[] memory nested = new bytes[](1);
        nested[0] = abi.encode(Nested(items, bytes("nested")));
        require(
            keccak256(ops.encodeBytes("((uint256[],bytes))", nested))
                == keccak256(abi.encode(Nested(items, bytes("nested"))))
        );
    }

    function rejected(string memory types, bytes[] memory values, bytes memory expected) private view {
        for (uint256 i; i < 2; i++) {
            string memory signature = i == 0 ? "encode(string,bytes[])" : "encodeBytes(string,bytes[])";
            (bool success, bytes memory reason) =
                address(ops).staticcall(abi.encodeWithSignature(signature, types, values));
            require(!success && keccak256(reason) == keccak256(expected));
        }
    }

    function testExactDescriptorCountAndValueFailures() public view {
        bytes[] memory values = new bytes[](1);
        values[0] = abi.encode(uint256(7));
        rejected("()", values, abi.encodeWithSignature("InvalidTypeDescriptor(uint256)", 1));
        rejected("(uint256,uint256)", values, abi.encodeWithSignature("ComponentCountMismatch(uint256,uint256)", 2, 1));
        values[0] = hex"01";
        rejected(
            "(uint256)", values, abi.encodeWithSignature("InvalidComponentLength(uint256,uint256,uint256)", 0, 32, 1)
        );
        values[0] = abi.encode(uint256(2));
        rejected("(bool)", values, abi.encodeWithSignature("InvalidComponentValue(uint256,uint256)", 0, 0));
    }
}

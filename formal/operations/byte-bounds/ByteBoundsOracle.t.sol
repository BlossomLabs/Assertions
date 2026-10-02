// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsByteBoundsOracleTest {
    Operations private op = new Operations();

    function _error(bytes memory input, bytes memory expected) private view {
        (bool ok, bytes memory ret) = address(op).staticcall(input);
        require(!ok && keccak256(ret) == keccak256(expected));
    }

    function testSlice() public view {
        require(keccak256(op.slice(hex"123456", 1, 2)) == keccak256(hex"3456"));
        require(op.slice(hex"123456", 3, 0).length == 0);
        _error(
            abi.encodeWithSignature("slice(bytes,uint256,uint256)", hex"123456", 3, 1),
            abi.encodeWithSelector(Operations.SliceOutOfBounds.selector, 3, 1, 3)
        );
        _error(
            abi.encodeWithSignature("slice(bytes,uint256,uint256)", hex"123456", type(uint256).max, type(uint256).max),
            abi.encodeWithSelector(Operations.SliceOutOfBounds.selector, type(uint256).max, type(uint256).max, 3)
        );
    }

    function testSliceRange() public view {
        require(keccak256(op.sliceRange(hex"123456", -2, 99)) == keccak256(hex"3456"));
        require(keccak256(op.sliceRange(hex"123456", type(int256).min, type(int256).max)) == keccak256(hex"123456"));
        require(op.sliceRange(hex"123456", 2, 1).length == 0);
    }

    function testByteAt() public view {
        require(keccak256(op.byteAt(hex"123456", -1)) == keccak256(hex"56"));
        _error(
            abi.encodeWithSignature("byteAt(bytes,int256)", hex"123456", type(int256).min),
            abi.encodeWithSelector(Operations.InvalidByteIndex.selector, type(int256).min, 3)
        );
        _error(
            abi.encodeWithSignature("byteAt(bytes,int256)", hex"123456", 3),
            abi.encodeWithSelector(Operations.InvalidByteIndex.selector, 3, 3)
        );
    }

    function testByteLen() public view {
        require(op.byteLen(hex"123456") == 3 && op.byteLen(hex"") == 0);
    }

    function testHash() public view {
        require(op.hash(bytes("abc")) == 0x4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45);
    }

    function testHashPairSorted() public view {
        bytes32 expected = keccak256(abi.encodePacked(bytes32(uint256(3)), bytes32(uint256(5))));
        require(op.hashPairSorted(bytes32(uint256(3)), bytes32(uint256(5))) == expected);
        require(op.hashPairSorted(bytes32(uint256(5)), bytes32(uint256(3))) == expected);
    }
}

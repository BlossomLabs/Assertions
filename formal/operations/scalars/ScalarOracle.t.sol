// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsScalarOracleTest {
    Operations private op = new Operations();

    function _panic(bytes memory data, uint256 code) private view {
        (bool ok, bytes memory ret) = address(op).staticcall(data);
        require(!ok && keccak256(ret) == keccak256(abi.encodeWithSignature("Panic(uint256)", code)));
    }

    function testAddU() public view {
        require(op.add(uint256(3), uint256(7)) == 10);
        _panic(abi.encodeWithSignature("add(uint256,uint256)", type(uint256).max, 1), 0x11);
    }

    function testAddS() public view {
        require(op.add(int256(-7), int256(3)) == -4);
        _panic(abi.encodeWithSignature("add(int256,int256)", type(int256).max, 1), 0x11);
    }

    function testSubU() public view {
        require(op.sub(uint256(11), uint256(7)) == 4);
        _panic(abi.encodeWithSignature("sub(uint256,uint256)", 0, 1), 0x11);
    }

    function testSubS() public view {
        require(op.sub(int256(-7), int256(3)) == -10);
        _panic(abi.encodeWithSignature("sub(int256,int256)", type(int256).min, 1), 0x11);
    }

    function testMulU() public view {
        require(op.mul(uint256(3), uint256(7)) == 21);
        _panic(abi.encodeWithSignature("mul(uint256,uint256)", type(uint256).max, 2), 0x11);
    }

    function testMulS() public view {
        require(op.mul(int256(-3), int256(7)) == -21);
        _panic(abi.encodeWithSignature("mul(int256,int256)", type(int256).min, -1), 0x11);
    }

    function testDivU() public view {
        require(op.div(uint256(23), uint256(7)) == 3);
        _panic(abi.encodeWithSignature("div(uint256,uint256)", 1, 0), 0x12);
    }

    function testDivS() public view {
        require(op.div(int256(-23), int256(7)) == -3);
        _panic(abi.encodeWithSignature("div(int256,int256)", type(int256).min, -1), 0x11);
        _panic(abi.encodeWithSignature("div(int256,int256)", 1, 0), 0x12);
    }

    function testModU() public view {
        require(op.mod(uint256(23), uint256(7)) == 2);
        _panic(abi.encodeWithSignature("mod(uint256,uint256)", 1, 0), 0x12);
    }

    function testModS() public view {
        require(op.mod(int256(-23), int256(7)) == -2);
        require(op.mod(type(int256).min, int256(-1)) == 0);
        _panic(abi.encodeWithSignature("mod(int256,int256)", 1, 0), 0x12);
    }

    function testMinU() public view {
        require(op.min(uint256(3), uint256(7)) == 3);
    }

    function testMinS() public view {
        require(op.min(int256(-7), int256(3)) == -7);
    }

    function testMaxU() public view {
        require(op.max(uint256(3), uint256(7)) == 7);
    }

    function testMaxS() public view {
        require(op.max(int256(-7), int256(3)) == 3);
    }

    function testAbsDiffU() public view {
        require(op.absDiff(uint256(3), uint256(7)) == 4);
    }

    function testAbsDiffS() public view {
        require(op.absDiff(type(int256).min, type(int256).max) == type(uint256).max);
    }

    function testEqU() public view {
        require(op.eq(7, 7) && !op.eq(3, 7));
    }

    function testNeU() public view {
        require(!op.ne(7, 7) && op.ne(3, 7));
    }

    function testLtU() public view {
        require(op.lt(uint256(3), uint256(7)) && !op.lt(uint256(7), uint256(7)));
    }

    function testLtS() public view {
        require(op.lt(int256(-7), int256(3)) && !op.lt(int256(-7), int256(-7)));
    }

    function testGtU() public view {
        require(!op.gt(uint256(3), uint256(7)) && op.gt(uint256(7), uint256(3)));
    }

    function testGtS() public view {
        require(!op.gt(int256(-7), int256(3)) && op.gt(int256(3), int256(-7)));
    }

    function testLeU() public view {
        require(op.le(uint256(3), uint256(7)) && op.le(uint256(7), uint256(7)));
    }

    function testLeS() public view {
        require(op.le(int256(-7), int256(3)) && op.le(int256(-7), int256(-7)));
    }

    function testGeU() public view {
        require(!op.ge(uint256(3), uint256(7)) && op.ge(uint256(7), uint256(7)));
    }

    function testGeS() public view {
        require(!op.ge(int256(-7), int256(3)) && op.ge(int256(-7), int256(-7)));
    }

    function testBitAndU() public view {
        require(op.bitAnd(3, 5) == 1);
    }

    function testBitOrU() public view {
        require(op.bitOr(3, 5) == 7);
    }

    function testBitXorU() public view {
        require(op.bitXor(3, 5) == 6);
    }

    function testShlU() public view {
        require(op.shl(3, 4) == 48 && op.shl(type(uint256).max, 256) == 0);
    }

    function testShrU() public view {
        require(op.shr(uint256(48), 4) == 3 && op.shr(type(uint256).max, 256) == 0);
    }

    function testShrS() public view {
        require(op.shr(int256(-7), 1) == -4 && op.shr(int256(-7), 256) == -1);
    }

    function testBitSetU() public view {
        require(op.bitSet(5, 2) && !op.bitSet(5, 1) && !op.bitSet(type(uint256).max, 256));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsModularOracleTest {
    Operations private op = new Operations();

    function _zero(bytes memory input) private view {
        (bool ok, bytes memory ret) = address(op).staticcall(input);
        require(!ok && keccak256(ret) == keccak256(abi.encodeWithSignature("Panic(uint256)", uint256(0x12))));
    }

    function testAddU() public view {
        require(op.addMod(type(uint256).max, type(uint256).max, uint256(7)) == 2);
        require(op.addMod(uint256(3), uint256(5), uint256(11)) == 8);
        _zero(abi.encodeWithSignature("addMod(uint256,uint256,uint256)", 3, 5, 0));
    }

    function testMulU() public view {
        require(op.mulMod(type(uint256).max, type(uint256).max, uint256(7)) == 1);
        require(op.mulMod(uint256(3), uint256(5), uint256(11)) == 4);
        _zero(abi.encodeWithSignature("mulMod(uint256,uint256,uint256)", 3, 5, 0));
    }

    function testAddS() public view {
        require(op.addMod(type(int256).min, type(int256).min, int256(7)) == -2);
        require(op.addMod(type(int256).min, type(int256).max, type(int256).min) == -1);
        require(op.addMod(int256(-7), int256(3), int256(-5)) == -4);
        _zero(abi.encodeWithSignature("addMod(int256,int256,int256)", type(int256).min, type(int256).max, 0));
    }

    function testMulS() public view {
        require(op.mulMod(type(int256).min, type(int256).min, int256(7)) == 1);
        require(op.mulMod(int256(-7), int256(3), int256(-5)) == -1);
        _zero(abi.encodeWithSignature("mulMod(int256,int256,int256)", type(int256).min, type(int256).max, 0));
    }
}

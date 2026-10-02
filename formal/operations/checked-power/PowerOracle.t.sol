// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsCheckedPowerOracleTest {
    Operations private ops = new Operations();

    function testUnsignedPowerAndOverflow() public view {
        require(ops.exp(uint256(0), 0) == 1);
        require(ops.exp(uint256(0), type(uint256).max) == 0);
        require(ops.exp(uint256(1), type(uint256).max) == 1);
        require(ops.exp(uint256(2), 3) == 8);
        require(ops.exp(uint256(2), 255) == uint256(1) << 255);
        (bool success, bytes memory reason) =
            address(ops).staticcall(abi.encodeWithSignature("exp(uint256,uint256)", uint256(2), uint256(256)));
        require(!success && keccak256(reason) == keccak256(abi.encodeWithSignature("Panic(uint256)", uint256(17))));
    }

    function testSignedPowerAndCheckedTrace() public view {
        require(ops.exp(int256(0), 0) == 1);
        require(ops.exp(int256(-2), 3) == -8);
        require(ops.exp(int256(-2), 4) == 16);
        require(ops.exp(int256(-2), 255) == type(int256).min);
        require(ops.exp(type(int256).min, 1) == type(int256).min);
        require(ops.exp(int256(-1), type(uint256).max) == -1);
        (bool success, bytes memory reason) =
            address(ops).staticcall(abi.encodeWithSignature("exp(int256,uint256)", type(int256).min, uint256(2)));
        require(!success && keccak256(reason) == keccak256(abi.encodeWithSignature("Panic(uint256)", uint256(17))));
    }
}

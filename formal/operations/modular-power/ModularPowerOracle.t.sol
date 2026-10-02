// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsModularPowerOracleTest {
    Operations private ops = new Operations();

    function rejection(bytes memory input, bytes memory expected) private view {
        (bool success, bytes memory reason) = address(ops).staticcall(input);
        require(!success && keccak256(reason) == keccak256(expected));
    }

    function testUnsignedPowersInverseAndEdges() public view {
        require(ops.powMod(uint256(2), uint256(2), uint256(5)) == 4);
        require(ops.powMod(uint256(0), uint256(0), uint256(7)) == 1);
        require(ops.powMod(type(uint256).max, uint256(0), uint256(1)) == 0);
        require(ops.powMod(type(uint256).max, uint256(1), type(uint256).max - 1) == 1);
        require(ops.powMod(uint256(2), uint256(1) << 32, uint256(3)) == 1);
        require(ops.powMod(uint256(1), type(uint256).max, type(uint256).max) == 1);
        require(ops.powMod(uint256(2), int256(-1), uint256(5)) == 3);
        require(ops.powMod(uint256(2), int256(-2), uint256(5)) == 4);
        require(ops.powMod(uint256(0), int256(-1), uint256(1)) == 0);
        require(ops.powMod(uint256(1), type(int256).min, type(uint256).max) == 1);
        rejection(
            abi.encodeWithSignature("powMod(uint256,uint256,uint256)", 1, 0, 0),
            abi.encodeWithSignature("Panic(uint256)", 18)
        );
        rejection(
            abi.encodeWithSignature("powMod(uint256,int256,uint256)", 1, int256(-1), 0),
            abi.encodeWithSignature("Panic(uint256)", 18)
        );
        rejection(
            abi.encodeWithSignature("powMod(uint256,int256,uint256)", 6, int256(-1), 9),
            abi.encodeWithSelector(Operations.ModularInverseDoesNotExist.selector, 6, 9)
        );
    }

    function testSignedPowersInverseMinimumAndErrors() public view {
        require(ops.powMod(int256(-2), uint256(3), int256(-5)) == -3);
        require(ops.powMod(int256(-2), uint256(2), int256(-5)) == 4);
        require(ops.powMod(int256(-2), int256(-1), int256(-5)) == -3);
        require(ops.powMod(int256(-2), int256(-2), int256(-5)) == 4);
        require(ops.powMod(type(int256).min, uint256(1), type(int256).min) == 0);
        require(ops.powMod(type(int256).min, uint256(0), type(int256).min) == 1);
        require(ops.powMod(int256(-1), type(int256).min, type(int256).min) == 1);
        require(ops.powMod(int256(-2), uint256(1) << 32, int256(-3)) == 1);
        rejection(
            abi.encodeWithSignature("powMod(int256,uint256,int256)", int256(-1), 1, 0),
            abi.encodeWithSignature("Panic(uint256)", 18)
        );
        rejection(
            abi.encodeWithSignature("powMod(int256,int256,int256)", int256(-1), int256(-1), 0),
            abi.encodeWithSignature("Panic(uint256)", 18)
        );
        rejection(
            abi.encodeWithSignature("powMod(int256,int256,int256)", int256(-6), int256(-1), int256(-9)),
            abi.encodeWithSelector(Operations.ModularInverseDoesNotExist.selector, 6, 9)
        );
    }
}

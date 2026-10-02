// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsScaledPowerOracleTest {
    Operations private ops = new Operations();

    function panic(uint256 x, uint256 n, uint256 base, uint256 code) private view {
        (bool success, bytes memory reason) =
            address(ops).staticcall(abi.encodeWithSignature("rpow(uint256,uint256,uint256)", x, n, base));
        require(!success && keccak256(reason) == keccak256(abi.encodeWithSignature("Panic(uint256)", code)));
    }

    function testScaledPowerExactTraceAndEdges() public view {
        require(ops.rpow(0, 0, 3) == 3);
        require(ops.rpow(0, type(uint256).max, 3) == 0);
        require(ops.rpow(type(uint256).max, 0, 3) == 3);
        require(ops.rpow(1, type(uint256).max, 1) == 1);
        require(ops.rpow(2, 3, 1) == 8);
        require(ops.rpow(4, 2, 3) == 5);
        // Every intermediate is rounded, so 4^3 / 3^2 rounded once would be 7.
        require(ops.rpow(4, 3, 3) == 6);
        uint256 half = uint256(1) << 255;
        require(ops.rpow(half, 8, half) == half);
        require(ops.rpow(type(uint256).max, 1, 1) == type(uint256).max);
    }

    function testScaledPowerExactPanics() public view {
        panic(0, 0, 0, 18);
        panic(1, 0, 0, 18);
        panic(type(uint256).max, type(uint256).max, 0, 18);
        panic(type(uint256).max, 2, 1, 17);
        panic(2, 256, 1, 17);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsBinaryLogOracleTest {
    Operations private ops = new Operations();

    function testLogAllPowerBoundaries() public view {
        for (uint256 i; i < 256; i++) {
            uint256 p = uint256(1) << i;
            require(ops.log2(p) == i);
            if (i > 0) require(ops.log2(p - 1) == i - 1);
            if (i > 0) require(ops.log2(p + 1) == i);
        }
        require(ops.log2(type(uint256).max) == 255);
    }

    function testLogLookupAndUndefined() public view {
        for (uint256 i = 1; i < 16; i++) {
            uint256 expected = i < 2 ? 0 : i < 4 ? 1 : i < 8 ? 2 : 3;
            require(ops.log2(i) == expected);
        }
        (bool success, bytes memory reason) = address(ops).staticcall(abi.encodeCall(ops.log2, (0)));
        require(!success);
        require(
            keccak256(reason) == keccak256(abi.encodeWithSelector(Operations.LogarithmUndefined.selector, int256(0)))
        );
    }
}

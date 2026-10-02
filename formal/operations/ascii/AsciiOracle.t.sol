// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsAsciiOracleTest {
    Operations private op = new Operations();

    function testLower() public view {
        require(keccak256(op.toLower(hex"40415a5b617a7b80c381ff00")) == keccak256(hex"40617a5b617a7b80c381ff00"));
        require(op.toLower(hex"").length == 0);
    }

    function testUpper() public view {
        require(keccak256(op.toUpper(hex"40415a5b617a7b80c381ff00")) == keccak256(hex"40415a5b415a7b80c381ff00"));
        require(op.toUpper(hex"").length == 0);
    }

    function testCharset() public view {
        uint256 mask = 1 | (uint256(1) << 65) | (uint256(1) << 255);
        require(op.charset(hex"0041ff", mask));
        require(!op.charset(hex"0042ff", mask));
        require(op.charset(hex"", 0));
        require(!op.charset(hex"00", 0));
    }
}

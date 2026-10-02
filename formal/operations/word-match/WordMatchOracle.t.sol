// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsWordMatchOracleTest {
    Operations private ops = new Operations();

    function testContainsBoundaries() public view {
        require(ops.contains("", ""));
        require(ops.contains("abc", ""));
        require(!ops.contains("", "a"));
        require(ops.contains("abcd", "bcd"));
        require(!ops.contains("abcd", "abcde"));
        for (uint256 n = 31; n <= 65; n++) {
            bytes memory needle = new bytes(n);
            for (uint256 i; i < n; i++) {
                needle[i] = bytes1(uint8(i + 1));
            }
            bytes memory hay = bytes.concat(hex"feff", needle, hex"aabbcc");
            require(ops.contains(hay, needle));
            hay[2 + n - 1] = 0;
            require(!ops.contains(hay, needle));
        }
    }

    function testContainsPartialNearMiss() public view {
        require(!ops.contains(hex"112233", hex"112234"));
        require(ops.contains(hex"0011223300", hex"112233"));
        require(ops.contains(hex"000000", hex"0000"));
        require(!ops.contains(hex"000001", hex"000002"));
        require(!ops.contains(hex"11223300", hex"11223301"));
        require(ops.contains(hex"aabbcc", hex"aabbcc"));
    }
}

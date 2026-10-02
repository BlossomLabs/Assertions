// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsOccurrenceOracleTest {
    Operations private ops = new Operations();

    function testIndexNonOverlapping() public view {
        require(ops.indexOf("aaaa", "aa", 0) == 0);
        require(ops.indexOf("aaaa", "aa", 1) == 2);
        require(ops.indexOf("aaaa", "aa", 2) == 4);
        require(ops.indexOf("aaaa", "aa", -1) == 2);
        require(ops.indexOf("aaaa", "aa", -2) == 0);
        require(ops.indexOf("aaaa", "aa", -3) == 4);
        require(ops.indexOf("banana", "ana", -1) == 1);
        require(ops.indexOf("banana", "ana", 1) == 6);
        require(ops.indexOf(hex"0001000100", hex"0001", -1) == 2);
        require(ops.indexOf("abc", "z", 0) == 3);
        require(ops.indexOf("abc", "abcde", -1) == 3);
    }

    function testIndexOrdinalsAndEmpty() public view {
        require(ops.indexOf("", "", 0) == 0);
        require(ops.indexOf("abcd", "", 0) == 0);
        require(ops.indexOf("abcd", "", 4) == 4);
        require(ops.indexOf("abcd", "", 5) == 4);
        require(ops.indexOf("abcd", "", -1) == 4);
        require(ops.indexOf("abcd", "", -5) == 0);
        require(ops.indexOf("abcd", "", -6) == 4);
        require(ops.indexOf("abcd", "", type(int256).min) == 4);
        require(ops.indexOf("aaaa", "aa", type(int256).min) == 4);
        require(ops.indexOf("aaaa", "aa", type(int256).max) == 4);
        require(ops.indexOf("ababa", "a", -1) == 4);
        require(ops.indexOf("ababa", "a", -3) == 0);
    }
}

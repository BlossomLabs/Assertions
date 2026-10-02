// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsReplaceOracleTest {
    Operations private ops = new Operations();

    function testReplaceExpansionDeletionAndNonOverlap() public view {
        require(keccak256(ops.replace("aaaa", "aa", "x")) == keccak256("xx"));
        require(keccak256(ops.replace("aaaaa", "aa", "xyz")) == keccak256("xyzxyza"));
        require(keccak256(ops.replace("banana", "ana", "!")) == keccak256("b!na"));
        require(keccak256(ops.replace("abca", "a", "")) == keccak256("bc"));
        require(keccak256(ops.replace("abc", "z", "!")) == keccak256("abc"));
        require(keccak256(ops.replace("abc", "abcdef", "!")) == keccak256("abc"));
    }

    function testReplaceBinaryAndEmptyNeedle() public view {
        require(keccak256(ops.replace(hex"001122001122ff", hex"001122", hex"ff00")) == keccak256(hex"ff00ff00ff"));
        require(keccak256(ops.replace("", "a", "x")) == keccak256(""));
        require(keccak256(ops.replace("a", "a", "")) == keccak256(""));
        (bool success, bytes memory reason) =
            address(ops).staticcall(abi.encodeCall(ops.replace, (bytes("abc"), bytes(""), bytes("x"))));
        require(!success);
        require(keccak256(reason) == keccak256(abi.encodeWithSelector(Operations.EmptyNeedle.selector)));
    }
}

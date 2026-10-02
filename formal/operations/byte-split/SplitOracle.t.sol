// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsSplitOracleTest {
    Operations private ops = new Operations();

    function testSplitEmptySegments() public view {
        bytes[] memory parts = ops.split(",a,,b,", ",");
        require(parts.length == 5);
        require(parts[0].length == 0);
        require(keccak256(parts[1]) == keccak256("a"));
        require(parts[2].length == 0);
        require(keccak256(parts[3]) == keccak256("b"));
        require(parts[4].length == 0);
        parts = ops.split("", ",");
        require(parts.length == 1 && parts[0].length == 0);
        try ops.split("abc", "") {
            revert("accepted empty delimiter");
        } catch (bytes memory reason) {
            require(keccak256(reason) == keccak256(abi.encodeWithSelector(Operations.EmptyNeedle.selector)));
        }
    }

    function testSplitNonOverlappingAndBinary() public view {
        bytes[] memory parts = ops.split("aaaaa", "aa");
        require(parts.length == 3);
        require(parts[0].length == 0 && parts[1].length == 0);
        require(keccak256(parts[2]) == keccak256("a"));
        parts = ops.split(hex"001122001122ff", hex"001122");
        require(parts.length == 3);
        require(parts[0].length == 0 && parts[1].length == 0);
        require(keccak256(parts[2]) == keccak256(hex"ff"));
        parts = ops.split("abc", "abcdef");
        require(parts.length == 1 && keccak256(parts[0]) == keccak256("abc"));
    }
}

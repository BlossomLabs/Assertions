// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;
import {Operations} from "../../../contracts/Operations.sol";

contract OperationsConcatOracleTest {
    Operations private op = new Operations();

    function same(bytes memory a, bytes memory b) private pure {
        require(keccak256(a) == keccak256(b), "concat");
    }

    function testConcatEmptyAndDelimiters() public view {
        bytes[] memory parts = new bytes[](0);
        same(op.concat(parts, hex"ff"), hex"");
        parts = new bytes[](3);
        parts[0] = bytes("abc");
        parts[1] = hex"";
        parts[2] = bytes("def");
        same(op.concat(parts, bytes("|")), bytes("abc||def"));
        parts = new bytes[](4);
        parts[0] = hex"ab";
        parts[1] = hex"cd";
        parts[2] = hex"";
        parts[3] = hex"f0";
        same(op.concat(parts, hex"00ff"), hex"ab00ffcd00ff00fff0");
        same(op.concat(parts, hex""), hex"abcdf0");
    }

    function testConcatPreservesRawBytes() public view {
        bytes[] memory parts = new bytes[](1);
        parts[0] = new bytes(65);
        for (uint256 i; i < 65; i++) {
            parts[0][i] = bytes1(uint8(i * 3));
        }
        same(op.concat(parts, hex"aabbcc"), parts[0]);
        parts = new bytes[](2);
        parts[0] = hex"00ff80";
        parts[1] = hex"7f0100";
        same(op.concat(parts, hex"fe"), hex"00ff80fe7f0100");
    }
}

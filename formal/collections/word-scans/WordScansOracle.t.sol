// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";

contract WordScansOracleTest {
    Collections private c = new Collections();

    function reject(bytes memory data, bytes memory expected) private view {
        (bool ok, bytes memory result) = address(c).staticcall(data);
        require(!ok, "expected failure");
        require(keccak256(result) == keccak256(expected), "wrong error bytes");
    }

    function testBothRejectExactUnalignedLength() public view {
        bytes memory want = abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(33));
        reject(abi.encodeCall(c.wordIndexOf, (new bytes(33), bytes32(0))), want);
        reject(abi.encodeCall(c.sumWords, (new bytes(33))), want);
    }

    function testEmptyIndexAndSum() public view {
        require(c.wordIndexOf(bytes(""), bytes32(0)) == 0, "empty sentinel");
        require(c.sumWords(bytes("")) == 0, "empty sum");
    }

    function testIndexLeastOccurrenceAndFullWidth() public view {
        bytes memory input = abi.encode(uint256(7), type(uint256).max, uint256(7), uint256(0));
        require(c.wordIndexOf(input, bytes32(uint256(7))) == 0, "first occurrence");
        require(c.wordIndexOf(input, bytes32(type(uint256).max)) == 1, "full width");
        require(c.wordIndexOf(input, bytes32(0)) == 3, "zero word");
    }

    function testIndexNotFoundUsesCount() public view {
        require(
            c.wordIndexOf(abi.encode(uint256(2), uint256(4), uint256(8)), bytes32(uint256(9))) == 3, "count sentinel"
        );
    }

    function testSumExactBoundaryAndZero() public view {
        require(
            c.sumWords(abi.encode(uint256(0), type(uint256).max - 8, uint256(8), uint256(0))) == type(uint256).max,
            "max sum"
        );
        require(c.sumWords(abi.encode(uint256(13), uint256(19), uint256(27))) == 59, "exact total");
    }

    function testSumOverflowHasExactPanic() public view {
        bytes memory panic = abi.encodeWithSignature("Panic(uint256)", uint256(17));
        reject(abi.encodeCall(c.sumWords, (abi.encode(type(uint256).max, uint256(1)))), panic);
        reject(abi.encodeCall(c.sumWords, (abi.encode(uint256(1), type(uint256).max, uint256(0)))), panic);
    }
}

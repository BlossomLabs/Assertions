// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";

contract WordUniqueOracleTest {
    Collections private c = new Collections();

    function same(bytes memory actual, bytes memory expected) private pure {
        require(keccak256(actual) == keccak256(expected), "wrong retained words");
    }

    function testEmptyAndAlignmentInBothModes() public view {
        same(c.uniqueWords(bytes(""), false), bytes(""));
        same(c.uniqueWords(bytes(""), true), bytes(""));
        for (uint256 i; i < 2; i++) {
            (bool ok, bytes memory ret) = address(c).staticcall(abi.encodeCall(c.uniqueWords, (new bytes(33), i == 1)));
            require(!ok, "expected alignment rejection");
            same(ret, abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(33)));
        }
    }

    function testUnorderedKeepsStableFirstOccurrences() public view {
        bytes memory input = abi.encode(uint256(7), uint256(3), uint256(7), uint256(2), uint256(3), uint256(7));
        same(c.uniqueWords(input, false), abi.encode(uint256(7), uint256(3), uint256(2)));
    }

    function testOrderedCollapsesRunsAndPreservesUngroupedRepeats() public view {
        bytes memory input = abi.encode(uint256(7), uint256(7), uint256(3), uint256(3), uint256(7), uint256(7));
        same(c.uniqueWords(input, true), abi.encode(uint256(7), uint256(3), uint256(7)));
        same(c.uniqueWords(input, false), abi.encode(uint256(7), uint256(3)));
    }

    function testGroupedModesAgreeWithFullWidthWords() public view {
        bytes memory input = abi.encode(
            uint256(0), uint256(0), type(uint256).max, type(uint256).max, uint256(1) << 255, uint256(1) << 255
        );
        bytes memory expected = abi.encode(uint256(0), type(uint256).max, uint256(1) << 255);
        same(c.uniqueWords(input, false), expected);
        same(c.uniqueWords(input, true), expected);
    }

    function testAllDuplicatesAndAllDistinctShrinkExactly() public view {
        bytes memory input = abi.encode(uint256(5), uint256(5), uint256(5), uint256(5));
        same(c.uniqueWords(input, false), abi.encode(uint256(5)));
        same(c.uniqueWords(input, true), abi.encode(uint256(5)));
        input = abi.encode(uint256(5), uint256(13), uint256(19), uint256(27));
        same(c.uniqueWords(input, false), input);
        same(c.uniqueWords(input, true), input);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Collections} from "../../../contracts/Collections.sol";

contract WordSortOracleTest {
    Collections private collection = new Collections();

    function check(bytes memory input, bytes memory expected) private view {
        (bool ok, bytes memory encoded) = address(collection).staticcall(abi.encodeCall(Collections.sortWords, (input)));
        require(ok, "sort unexpectedly reverted");
        bytes memory actual = abi.decode(encoded, (bytes));
        require(actual.length == expected.length && keccak256(actual) == keccak256(expected), "wrong words");
    }

    function testEmptyAndSingleWord() public view {
        check(hex"", hex"");
        check(abi.encode(type(uint256).max), abi.encode(type(uint256).max));
    }

    function testFirstAndLastWord() public view {
        check(abi.encode(uint256(93), uint256(17)), abi.encode(uint256(17), uint256(93)));
    }

    function testOddLengthMiddleWord() public view {
        check(abi.encode(uint256(71), uint256(2), uint256(39)), abi.encode(uint256(2), uint256(39), uint256(71)));
    }

    function testUnsignedHighBitAndEveryByte() public view {
        uint256 patterned = 0x0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20;
        check(
            abi.encode(type(uint256).max, uint256(1) << 255, patterned, uint256(0)),
            abi.encode(uint256(0), patterned, uint256(1) << 255, type(uint256).max)
        );
    }

    function testMultiplePassesDuplicatesAndTail() public view {
        check(
            abi.encode(uint256(9), uint256(4), uint256(9), uint256(1), uint256(7)),
            abi.encode(uint256(1), uint256(4), uint256(7), uint256(9), uint256(9))
        );
    }

    function testUnalignedRejectedBeforeWordAccess() public view {
        bytes memory input = abi.encodePacked(uint256(51), bytes1(0xaa));
        (bool ok, bytes memory actual) = address(collection).staticcall(abi.encodeCall(Collections.sortWords, (input)));
        require(
            !ok
                && keccak256(actual)
                    == keccak256(abi.encodeWithSelector(Collections.UnalignedWords.selector, uint256(33))),
            "wrong rejection"
        );
    }

    function testPowerOfTwoBoundaryAndReversedInput() public view {
        check(
            abi.encode(uint256(8), uint256(7), uint256(6), uint256(5), uint256(4), uint256(3), uint256(2), uint256(1)),
            abi.encode(uint256(1), uint256(2), uint256(3), uint256(4), uint256(5), uint256(6), uint256(7), uint256(8))
        );
    }

    function testLeftAndRightRunDrain() public view {
        check(
            abi.encode(uint256(1), uint256(3), uint256(7), uint256(9)),
            abi.encode(uint256(1), uint256(3), uint256(7), uint256(9))
        );
        check(
            abi.encode(uint256(7), uint256(9), uint256(1), uint256(3)),
            abi.encode(uint256(1), uint256(3), uint256(7), uint256(9))
        );
    }
}

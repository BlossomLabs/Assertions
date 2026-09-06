// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Operators.sol";

contract OperatorsCollectionsTest is Test {
    Operators ops;

    function setUp() public { ops = new Operators(); }

    function testSplitPreservesEmptySegments() public view {
        bytes[] memory parts = ops.split(bytes(",a,,b,"), bytes(","));
        assertEq(parts.length, 5);
        assertEq(parts[0], bytes(""));
        assertEq(parts[1], bytes("a"));
        assertEq(parts[2], bytes(""));
        assertEq(parts[3], bytes("b"));
        assertEq(parts[4], bytes(""));
    }

    function testSplitEmptyAndOverlapping() public view {
        bytes[] memory empty = ops.split(bytes(""), bytes("xx"));
        assertEq(empty.length, 1);
        assertEq(empty[0], bytes(""));
        bytes[] memory parts = ops.split(bytes("aaaaa"), bytes("aa"));
        assertEq(parts.length, 3);
        assertEq(parts[0], bytes(""));
        assertEq(parts[1], bytes(""));
        assertEq(parts[2], bytes("a"));
    }

    function testSplitRejectsEmptyDelimiter() public {
        vm.expectRevert(Operators.EmptyNeedle.selector);
        ops.split(bytes("a"), bytes(""));
    }

    function testDistinctStable() public view {
        assertEq(ops.distinctWords(abi.encode(uint256(2), uint256(1), uint256(2), uint256(0), uint256(1))),
            abi.encode(uint256(2), uint256(1), uint256(0)));
        assertEq(ops.distinctWords(bytes("")), bytes(""));
        // Existing adjacent operation still keeps nonadjacent duplicates.
        assertEq(ops.uniqueWords(abi.encode(uint256(2), uint256(1), uint256(2))),
            abi.encode(uint256(2), uint256(1), uint256(2)));
    }

    function testDistinctRejectsPartialWord() public {
        vm.expectRevert(abi.encodeWithSelector(Operators.UnalignedWords.selector, 1));
        ops.distinctWords(hex"01");
    }

    function testEncodeBytesDynamicEnvelope() public view {
        bytes[] memory values = new bytes[](3);
        values[0] = abi.encode(uint256(19));
        values[1] = abi.encode("non-word-aligned");
        values[2] = abi.encode(hex"abcd");
        bytes memory result = ops.encodeBytes("(uint256,string,bytes)", values);
        assertEq(result, abi.encode(uint256(19), "non-word-aligned", hex"abcd"));
        (bool ok, bytes memory raw) = address(ops).staticcall(abi.encodeCall(ops.encode,
            ("(uint256,string,bytes)", values)));
        assertTrue(ok);
        assertEq(raw, result);
    }
}

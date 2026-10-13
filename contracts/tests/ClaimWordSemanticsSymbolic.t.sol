// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Operations.sol";

/**
 * @notice Full-word O6/O7/O29-O32/O34 obligations. Sign-biased unsigned
 *         coordinates specify signed order and distance; independent bit
 *         projections specify word operators and shifts, including huge shifts.
 */
contract ClaimWordSemanticsSymbolicTest is Test {
    Operations ops;
    uint256 constant SIGN = uint256(1) << 255;

    function setUp() public {
        ops = new Operations();
    }

    function check_wordsUnsignedMinMax(uint256 a, uint256 b) public view {
        uint256 lo = answer("min(uint256,uint256)", a, b);
        uint256 hi = answer("max(uint256,uint256)", a, b);
        assertTrue(lo == a || lo == b);
        assertTrue(hi == a || hi == b);
        assertTrue(lo <= a && lo <= b && hi >= a && hi >= b);
    }

    function check_wordsSignedMinMax(int256 a, int256 b) public view {
        uint256 x = uint256(a) ^ SIGN;
        uint256 y = uint256(b) ^ SIGN;
        uint256 lo = answer("min(int256,int256)", uint256(a), uint256(b));
        uint256 hi = answer("max(int256,int256)", uint256(a), uint256(b));
        assertTrue(lo == uint256(a) || lo == uint256(b));
        assertTrue(hi == uint256(a) || hi == uint256(b));
        assertTrue((lo ^ SIGN) <= x && (lo ^ SIGN) <= y);
        assertTrue((hi ^ SIGN) >= x && (hi ^ SIGN) >= y);
    }

    function check_wordsUnsignedDistance(uint256 a, uint256 b) public view {
        uint256 d = answer("absDiff(uint256,uint256)", a, b);
        uint256 lo = a <= b ? a : b;
        uint256 hi = a <= b ? b : a;
        assertTrue(d <= hi);
        unchecked {
            // A faulty distance must not revert inside the reference assertion.
            assertEq(d + lo, hi);
        }
    }

    function check_wordsSignedDistance(int256 a, int256 b) public view {
        uint256 x = uint256(a) ^ SIGN;
        uint256 y = uint256(b) ^ SIGN;
        uint256 d = answer("absDiff(int256,int256)", uint256(a), uint256(b));
        uint256 lo = x <= y ? x : y;
        uint256 hi = x <= y ? y : x;
        assertTrue(d <= hi);
        unchecked {
            assertEq(d + lo, hi);
        }
    }

    function check_wordsUnsignedRelations(uint256 a, uint256 b) public view {
        verdict("eq(uint256,uint256)", a, b, a == b);
        verdict("ne(uint256,uint256)", a, b, a != b);
        verdict("lt(uint256,uint256)", a, b, a < b);
        verdict("gt(uint256,uint256)", a, b, b < a);
        verdict("le(uint256,uint256)", a, b, !(b < a));
        verdict("ge(uint256,uint256)", a, b, !(a < b));
    }

    function check_wordsSignedRelations(int256 a, int256 b) public view {
        uint256 x = uint256(a) ^ SIGN;
        uint256 y = uint256(b) ^ SIGN;
        verdict("lt(int256,int256)", uint256(a), uint256(b), x < y);
        verdict("gt(int256,int256)", uint256(a), uint256(b), y < x);
        verdict("le(int256,int256)", uint256(a), uint256(b), !(y < x));
        verdict("ge(int256,int256)", uint256(a), uint256(b), !(x < y));
    }

    function check_wordsBitTruthTable(uint256 a, uint256 b, uint8 position) public view {
        bool x = bit(a, position);
        bool y = bit(b, position);
        assertEq(bit(answer("bitAnd(uint256,uint256)", a, b), position), x && y);
        assertEq(bit(answer("bitOr(uint256,uint256)", a, b), position), x || y);
        assertEq(bit(answer("bitXor(uint256,uint256)", a, b), position), x != y);
        assertEq(answer("bitXor(uint256,uint256)", a, type(uint256).max), ~a);
    }

    function check_wordsLeftShift(uint256 a, uint256 shift, uint8 position) public view {
        uint256 out = answer("shl(uint256,uint256)", a, shift);
        bool expected;
        if (shift <= position) expected = bit(a, uint256(position) - shift);
        assertEq(bit(out, position), expected);
    }

    function check_wordsRightShift(uint256 a, uint256 shift, uint8 position) public view {
        uint256 out = answer("shr(uint256,uint256)", a, shift);
        bool expected;
        if (shift <= 255 - uint256(position)) expected = bit(a, uint256(position) + shift);
        assertEq(bit(out, position), expected);
    }

    function check_wordsArithmeticRightShift(int256 a, uint256 shift, uint8 position) public view {
        uint256 out = answer("shr(int256,uint256)", uint256(a), shift);
        bool expected = bit(uint256(a), 255);
        if (shift <= 255 - uint256(position)) expected = bit(uint256(a), uint256(position) + shift);
        assertEq(bit(out, position), expected);
    }

    function check_wordsBitMembership(uint256 a, uint256 index) public view {
        bool expected;
        if (index < 256) expected = a & (uint256(1) << index) != 0;
        verdict("bitSet(uint256,uint256)", a, index, expected);
    }

    function bit(uint256 word, uint256 position) internal pure returns (bool) {
        return word & (uint256(1) << position) != 0;
    }

    function answer(string memory signature, uint256 a, uint256 b) internal view returns (uint256) {
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeWithSignature(signature, a, b));
        assertTrue(ok, "total word operation reverted");
        assertEq(out.length, 32);
        return abi.decode(out, (uint256));
    }

    function verdict(string memory signature, uint256 a, uint256 b, bool expected) internal view {
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeWithSignature(signature, a, b));
        assertTrue(ok, "total comparison reverted");
        assertEq(out, abi.encode(expected), "comparison must return canonical bool");
    }

    function test_wordsOrderAndDistanceSamples() public view {
        check_wordsUnsignedMinMax(7, type(uint256).max);
        check_wordsSignedMinMax(type(int256).min, type(int256).max);
        check_wordsUnsignedDistance(0, type(uint256).max);
        check_wordsSignedDistance(type(int256).min, type(int256).max);
        check_wordsSignedDistance(-7, 3);
        check_wordsUnsignedRelations(7, 7);
        check_wordsUnsignedRelations(3, 7);
        check_wordsSignedRelations(-7, 3);
        check_wordsSignedRelations(3, -7);
    }

    function test_wordsBitAndShiftSamples() public view {
        check_wordsBitTruthTable(0x37, 0xa5, 5);
        check_wordsBitTruthTable(SIGN, type(uint256).max, 255);
        check_wordsLeftShift(7, 1, 2);
        check_wordsLeftShift(7, 256, 0);
        check_wordsRightShift(SIGN, 255, 0);
        check_wordsRightShift(SIGN, type(uint256).max, 255);
        check_wordsArithmeticRightShift(-3, 1, 0);
        check_wordsArithmeticRightShift(-3, 256, 255);
        check_wordsArithmeticRightShift(3, type(uint256).max, 0);
        check_wordsBitMembership(SIGN, 255);
        check_wordsBitMembership(type(uint256).max, 256);
    }
}

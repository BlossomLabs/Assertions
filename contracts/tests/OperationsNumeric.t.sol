// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import {Operations} from "../Operations.sol";

contract OperationsNumericTest is Test {
    Operations ops;
    function setUp() public { ops = new Operations(); }

    function test_signedMulDivBoundaries() public {
        assertEq(ops.mulDiv(int256(-7), 1, 3, Operations.Rounding.Trunc), -2);
        assertEq(ops.mulDiv(int256(-7), 1, 3, Operations.Rounding.Floor), -3);
        assertEq(ops.mulDiv(int256(-7), 1, 3, Operations.Rounding.Ceil), -2);
        assertEq(ops.mulDiv(int256(7), 1, -3, Operations.Rounding.Floor), -3);
        assertEq(ops.mulDiv(type(int256).min, 1, 1, Operations.Rounding.Trunc), type(int256).min);
        assertEq(ops.mulDiv(type(int256).min, type(int256).min, type(int256).min, Operations.Rounding.Floor), type(int256).min);
        vm.expectRevert(stdError.arithmeticError);
        ops.mulDiv(type(int256).min, -1, 1, Operations.Rounding.Trunc);
        vm.expectRevert(stdError.divisionError);
        ops.mulDiv(int256(0), 1, 0, Operations.Rounding.Ceil);
        vm.expectRevert(stdError.arithmeticError);
        ops.mulDiv(uint256(type(uint256).max - 1), type(uint256).max - 1, type(uint256).max - 2, Operations.Rounding.Ceil);
    }

    function test_signedRoundingOverflowAfterTruncationFits() public {
        int256 maximum = type(int256).max;
        assertEq(ops.mulDiv(-maximum, maximum, maximum - 1, Operations.Rounding.Trunc), type(int256).min);
        vm.expectRevert(stdError.arithmeticError);
        ops.mulDiv(-maximum, maximum, maximum - 1, Operations.Rounding.Floor);
        assertEq(ops.mulDiv(maximum - 1, maximum - 1, maximum - 2, Operations.Rounding.Trunc), maximum);
        vm.expectRevert(stdError.arithmeticError);
        ops.mulDiv(maximum - 1, maximum - 1, maximum - 2, Operations.Rounding.Ceil);
    }

    function testFuzz_signedRounding(int128 a, int128 b, int128 denominator) public view {
        if (denominator == 0) return;
        int256 product = int256(a) * int256(b);
        int256 d = int256(denominator);
        int256 trunc = product / d;
        bool remainder = product % d != 0;
        bool negative = (product < 0) != (d < 0);
        assertEq(ops.mulDiv(int256(a), int256(b), d, Operations.Rounding.Trunc), trunc);
        assertEq(ops.mulDiv(int256(a), int256(b), d, Operations.Rounding.Floor), trunc - (remainder && negative ? int256(1) : int256(0)));
        assertEq(ops.mulDiv(int256(a), int256(b), d, Operations.Rounding.Ceil), trunc + (remainder && !negative ? int256(1) : int256(0)));
    }

    function test_signedPower() public {
        assertEq(ops.exp(int256(-2), 255), type(int256).min);
        assertEq(ops.exp(int256(-2), 4), 16);
        assertEq(ops.exp(int256(0), 0), 1);
        assertEq(ops.exp(type(int256).min, 1), type(int256).min);
        vm.expectRevert(stdError.arithmeticError);
        ops.exp(int256(2), 255);
    }

    function test_decimalParsing() public {
        assertEq(ops.parseUnits("-1.239", 2, Operations.Rounding.Trunc), -123);
        assertEq(ops.parseUnits("-1.239", 2, Operations.Rounding.Floor), -124);
        assertEq(ops.parseUnits("-1.239", 2, Operations.Rounding.Ceil), -123);
        assertEq(ops.parseUnitsUnsigned("+.001", 2, Operations.Rounding.Ceil), 1);
        assertEq(ops.parseUnitsUnsigned("12.", 2, Operations.Rounding.Floor), 1200);
        assertEq(ops.formatUnits(int256(-10020), 4), "-1.002");
        assertEq(ops.formatUnits(uint256(1), 77), "0.00000000000000000000000000000000000000000000000000000000000000000000000000001");
        vm.expectRevert();
        ops.parseUnitsUnsigned("-0", 0, Operations.Rounding.Trunc);
        vm.expectRevert();
        ops.parseUnits("1..2", 2, Operations.Rounding.Trunc);
        vm.expectRevert();
        ops.parseUnits("1e2", 2, Operations.Rounding.Trunc);
        vm.expectRevert();
        ops.parseUnits("+.", 2, Operations.Rounding.Trunc);
        vm.expectRevert();
        ops.parseUnits(" 1", 2, Operations.Rounding.Trunc);
        vm.expectRevert();
        ops.parseUnits("1", 78, Operations.Rounding.Trunc);
        vm.expectRevert(stdError.arithmeticError);
        ops.parseInt("57896044618658097711785492504343953926634992332820282019728792003956564819968");
    }

    function testFuzz_decimalRoundTrip(int256 value, uint8 decimals) public view {
        uint256 precision = uint256(decimals) % 78;
        assertEq(ops.parseInt(bytes(ops.toString(value))), value);
        assertEq(ops.parseUnits(bytes(ops.formatUnits(value, precision)), precision, Operations.Rounding.Trunc), value);
        uint256 unsigned = uint256(value);
        assertEq(ops.parseUnitsUnsigned(bytes(ops.formatUnits(unsigned, precision)), precision, Operations.Rounding.Trunc), unsigned);
    }
}

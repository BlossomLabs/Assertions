// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import {Operations} from "../Operations.sol";

contract OperationsModularTest is Test {
    Operations ops;
    function setUp() public { ops = new Operations(); }

    function test_powMod() public view {
        assertEq(ops.powMod(uint256(3), uint256(100), 11), 1);
        assertEq(ops.powMod(uint256(0), uint256(0), 7), 1);
        assertEq(ops.powMod(uint256(0), uint256(1), 7), 0);
        assertEq(ops.powMod(uint256(0), int256(-1), 1), 0);
        assertEq(ops.powMod(uint256(3), int256(-1), 11), 4);
        assertEq(ops.powMod(uint256(3), int256(-2), 11), 5);
        assertEq(ops.powMod(uint256(3), int256(-1), 10), 7);
        assertEq(ops.powMod(int256(-3), int256(-1), -11), -4);
        assertEq(ops.powMod(int256(-3), int256(-2), -11), 5);
        assertEq(ops.powMod(int256(-3), uint256(3), -11), -5);
        assertEq(ops.powMod(int256(-3), uint256(4), -11), 4);
        assertEq(ops.powMod(int256(3), int256(2), 11), 9);
    }

    function test_powModWordBoundaries() public view {
        uint256 high = type(uint256).max;
        int256 low = type(int256).min;
        assertEq(ops.powMod(uint256(2), int256(-1), high), uint256(1) << 255);
        assertEq(ops.powMod(high, int256(-1), high - 1), 1);
        assertEq(ops.powMod(int256(-1), low, low), 1);
        assertEq(ops.powMod(int256(-1), type(uint256).max, low), -1);
        assertEq(ops.powMod(low, int256(-1), -7), -1);
        assertEq(ops.powMod(low, uint256(2), -7), 1);
        assertEq(ops.powMod(uint256(2), high, 7), 1);
        assertEq(ops.powMod(int256(3), int256(-1), low), int256((uint256(1) << 255) / 3 + 1));
    }

    function test_powModFailures() public {
        vm.expectRevert(abi.encodeWithSelector(Operations.ModularInverseDoesNotExist.selector, 6, 9));
        ops.powMod(uint256(6), int256(-1), 9);
        vm.expectRevert(abi.encodeWithSelector(Operations.ModularInverseDoesNotExist.selector, 6, 9));
        ops.powMod(int256(-6), int256(-2), -9);
        vm.expectRevert(abi.encodeWithSelector(Operations.ModularInverseDoesNotExist.selector, 0, 7));
        ops.powMod(uint256(0), int256(-1), 7);
        vm.expectRevert(stdError.divisionError);
        ops.powMod(uint256(1), uint256(0), 0);
        vm.expectRevert(stdError.divisionError);
        ops.powMod(uint256(1), int256(-1), 0);
        vm.expectRevert(stdError.divisionError);
        ops.powMod(int256(-1), uint256(0), 0);
        vm.expectRevert(stdError.divisionError);
        ops.powMod(int256(-1), int256(-1), 0);
    }

    function testFuzz_inverseFullWidth(uint256 a, uint256 m) public {
        if (m == 0) return;
        uint256 x = a;
        uint256 y = m;
        while (y != 0) (x, y) = (y, x % y);
        if (x != 1) {
            vm.expectRevert(abi.encodeWithSelector(Operations.ModularInverseDoesNotExist.selector, a, m));
            ops.powMod(a, int256(-1), m);
        } else {
            uint256 inverse = ops.powMod(a, int256(-1), m);
            assertLt(inverse, m);
            assertEq(mulmod(a, inverse, m), 1 % m);
        }
    }

    function testFuzz_powModSmall(uint8 a, uint8 e, uint128 m) public view {
        if (m == 0) return;
        uint256 expected = 1 % uint256(m);
        for (uint256 i = 0; i < e; i++) expected = expected * a % m;
        assertEq(ops.powMod(uint256(a), uint256(e), m), expected);
        assertEq(ops.powMod(-int256(uint256(a)), uint256(e), -int256(uint256(m))),
            a != 0 && e & 1 != 0 ? -int256(expected) : int256(expected));
    }
}

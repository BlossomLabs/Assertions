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

    /**
     * Reference square-and-multiply, independent of the contract's own
     * loop, to pin the precompile path (exponents of 32 bits or more)
     * against the MULMOD path (below) at and around the threshold.
     */
    function _referencePowMod(uint256 base, uint256 exponent, uint256 modulus) private pure returns (uint256 r) {
        r = 1 % modulus;
        base %= modulus;
        while (exponent != 0) {
            if (exponent & 1 != 0) r = mulmod(r, base, modulus);
            base = mulmod(base, base, modulus);
            exponent >>= 1;
        }
    }

    function test_powModPrecompileThreshold() public view {
        uint256 threshold = 1 << 32;
        uint256 m = 1000000007;
        assertEq(ops.powMod(uint256(3), threshold - 1, m), _referencePowMod(3, threshold - 1, m));
        assertEq(ops.powMod(uint256(3), threshold, m), _referencePowMod(3, threshold, m));
        assertEq(ops.powMod(uint256(3), threshold + 1, m), _referencePowMod(3, threshold + 1, m));
        // The precompile must honor the loop's 1 % m and 0 ** e conventions
        assertEq(ops.powMod(uint256(5), threshold, 1), 0);
        assertEq(ops.powMod(uint256(0), threshold, 7), 0);
        assertEq(ops.powMod(uint256(1), threshold, 7), 1);
        assertEq(ops.powMod(int256(-3), threshold + 1, -11), -int256(_referencePowMod(3, threshold + 1, 11)));
        assertEq(ops.powMod(int256(-3), threshold, -11), int256(_referencePowMod(3, threshold, 11)));
        assertEq(ops.powMod(uint256(3), int256(-int256(threshold)), 11),
            _referencePowMod(ops.powMod(uint256(3), int256(-1), 11), threshold, 11));
    }

    function testFuzz_powModAroundThreshold(uint256 a, uint8 offset, bool above, uint256 m) public view {
        if (m == 0) return;
        uint256 e = above ? (1 << 32) + uint256(offset) : (1 << 32) - 1 - uint256(offset);
        assertEq(ops.powMod(a, e, m), _referencePowMod(a, e, m));
    }

    function testFuzz_powModFullWidth(uint256 a, uint256 e, uint256 m) public view {
        if (m == 0) return;
        assertEq(ops.powMod(a, e, m), _referencePowMod(a, e, m));
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

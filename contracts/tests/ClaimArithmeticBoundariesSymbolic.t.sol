// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../Operations.sol";

/**
 * @notice O1-O3/O75: full-word add/sub, division boundaries, selected binary
 *         divisors and manual panic encodings. No general multiplication or
 *         symbolic-divisor value claim is supplied by these properties.
 */
contract ClaimArithmeticBoundariesSymbolicTest is Test {
    Operations ops;
    uint256 constant SIGN = uint256(1) << 255;

    function setUp() public {
        ops = new Operations();
    }

    function check_arithmeticUnsignedAddSub(uint256 a, uint256 b, bool subtract) public view {
        uint256 expected;
        unchecked {
            expected = subtract ? a - b : a + b;
        }
        bool fits = subtract ? a >= b : expected >= a;
        (bool ok, bytes memory out) = address(ops)
            .staticcall(abi.encodeWithSignature(subtract ? "sub(uint256,uint256)" : "add(uint256,uint256)", a, b));
        assertEq(ok, fits);
        assertEq(out, fits ? abi.encode(expected) : panicBytes(0x11));
    }

    function check_arithmeticSignedAddSub(int256 a, int256 b, bool subtract) public view {
        uint256 expected;
        unchecked {
            expected = subtract ? uint256(a) - uint256(b) : uint256(a) + uint256(b);
        }
        bool aNeg = uint256(a) & SIGN != 0;
        bool bNeg = uint256(b) & SIGN != 0;
        bool rNeg = expected & SIGN != 0;
        bool overflow = (subtract ? aNeg != bNeg : aNeg == bNeg) && rNeg != aNeg;
        (bool ok, bytes memory out) = address(ops)
            .staticcall(abi.encodeWithSignature(subtract ? "sub(int256,int256)" : "add(int256,int256)", a, b));
        assertEq(ok, !overflow);
        assertEq(out, overflow ? panicBytes(0x11) : abi.encode(int256(expected)));
    }

    function check_arithmeticZeroDivisor(bytes32 word, uint8 operation) public view {
        vm.assume(operation < 4);
        string memory signature = operation == 0
            ? "div(uint256,uint256)"
            : operation == 1 ? "mod(uint256,uint256)" : operation == 2 ? "div(int256,int256)" : "mod(int256,int256)";
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeWithSignature(signature, word, uint256(0)));
        assertFalse(ok);
        assertEq(out, panicBytes(0x12));
    }

    function check_arithmeticUnsignedBinaryDivisors(uint256 a, uint8 exponentCase, bool remainder) public view {
        vm.assume(exponentCase < 5);
        uint256 shift =
            exponentCase == 0 ? 0 : exponentCase == 1 ? 1 : exponentCase == 2 ? 8 : exponentCase == 3 ? 128 : 255;
        uint256 divisor = uint256(1) << shift;
        uint256 expected = remainder ? a & (divisor - 1) : a >> shift;
        (bool ok, bytes memory out) = address(ops)
            .staticcall(
                abi.encodeWithSignature(remainder ? "mod(uint256,uint256)" : "div(uint256,uint256)", a, divisor)
            );
        assertTrue(ok);
        assertEq(out, abi.encode(expected));
    }

    function check_arithmeticSignedUnitDivisors(int256 a, bool negativeDivisor, bool remainder) public view {
        int256 divisor = negativeDivisor ? int256(-1) : int256(1);
        bool overflow = !remainder && negativeDivisor && a == type(int256).min;
        int256 expected;
        unchecked {
            expected = remainder ? int256(0) : negativeDivisor ? -a : a;
        }
        (bool ok, bytes memory out) = address(ops)
            .staticcall(abi.encodeWithSignature(remainder ? "mod(int256,int256)" : "div(int256,int256)", a, divisor));
        assertEq(ok, !overflow);
        assertEq(out, overflow ? panicBytes(0x11) : abi.encode(expected));
    }

    function check_arithmeticSignedBinaryDivisors(int256 a, uint8 exponentCase, bool negativeDivisor, bool remainder)
        public
        view
    {
        vm.assume(exponentCase < 3);
        uint256 shift = exponentCase == 0 ? 1 : exponentCase == 1 ? 8 : 128;
        int256 divisor = int256(uint256(1) << shift);
        if (negativeDivisor) divisor = -divisor;
        uint256 magnitude;
        uint256 expected;
        unchecked {
            magnitude = a < 0 ? 0 - uint256(a) : uint256(a);
            expected = remainder ? magnitude & ((uint256(1) << shift) - 1) : magnitude >> shift;
            if (remainder ? a < 0 : (a < 0) != negativeDivisor) expected = 0 - expected;
        }
        (bool ok, bytes memory out) = address(ops)
            .staticcall(abi.encodeWithSignature(remainder ? "mod(int256,int256)" : "div(int256,int256)", a, divisor));
        assertTrue(ok);
        assertEq(out, abi.encode(int256(expected)));
    }

    function check_arithmeticRpowZeroBase(uint256 x, uint256 exponent) public view {
        (bool ok, bytes memory out) =
            address(ops).staticcall(abi.encodeCall(Operations.rpow, (x, exponent, uint256(0))));
        assertFalse(ok);
        assertEq(out, compilerPanic(0x12));
    }

    function check_arithmeticExpWadOverflow(int256 x) public view {
        vm.assume(x >= 135305999368893231589);
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.expWad, (x)));
        assertFalse(ok);
        assertEq(out, compilerPanic(0x11));
    }

    function check_arithmeticSignedMagnitudeOverflow(uint8 mode) public view {
        vm.assume(mode < 3);
        (bool ok, bytes memory out) = address(ops)
            .staticcall(
                abi.encodeWithSignature(
                    "mulDiv(int256,int256,int256,uint8)", type(int256).min, int256(-1), int256(1), mode
                )
            );
        assertFalse(ok);
        assertEq(out, compilerPanic(0x11));
    }

    function compilerOverflow(uint256 a) external pure returns (uint256) {
        return a + 1;
    }

    function compilerDivide(uint256 denominator) external pure returns (uint256) {
        return 7 / denominator;
    }

    function compilerPanic(uint256 code) internal view returns (bytes memory out) {
        bool ok;
        (ok, out) = address(this)
            .staticcall(
                code == 0x11
                    ? abi.encodeCall(this.compilerOverflow, (type(uint256).max))
                    : abi.encodeCall(this.compilerDivide, (uint256(0)))
            );
        assertFalse(ok, "compiler oracle must fail explicitly");
        assertEq(out, panicBytes(code));
    }

    function panicBytes(uint256 code) internal pure returns (bytes memory) {
        return abi.encodeWithSignature("Panic(uint256)", code);
    }

    function test_arithmeticAddSubSamples() public view {
        check_arithmeticUnsignedAddSub(type(uint256).max, 1, false);
        check_arithmeticUnsignedAddSub(0, 1, true);
        check_arithmeticUnsignedAddSub(7, 3, true);
        check_arithmeticSignedAddSub(type(int256).max, 1, false);
        check_arithmeticSignedAddSub(type(int256).min, 1, true);
        check_arithmeticSignedAddSub(-7, 3, false);
    }

    function test_arithmeticDivisionSamples() public view {
        for (uint8 i; i < 4; i++) {
            check_arithmeticZeroDivisor(bytes32(type(uint256).max), i);
        }
        for (uint8 i; i < 5; i++) {
            check_arithmeticUnsignedBinaryDivisors(type(uint256).max, i, false);
            check_arithmeticUnsignedBinaryDivisors(type(uint256).max, i, true);
        }
        check_arithmeticSignedUnitDivisors(type(int256).min, true, false);
        check_arithmeticSignedUnitDivisors(type(int256).min, true, true);
        check_arithmeticSignedUnitDivisors(-7, false, false);
        for (uint8 i; i < 3; i++) {
            check_arithmeticSignedBinaryDivisors(-7, i, false, false);
            check_arithmeticSignedBinaryDivisors(-7, i, true, false);
            check_arithmeticSignedBinaryDivisors(-7, i, true, true);
        }
    }

    function test_arithmeticManualPanicSamples() public view {
        check_arithmeticRpowZeroBase(0, 0);
        check_arithmeticRpowZeroBase(type(uint256).max, type(uint256).max);
        check_arithmeticExpWadOverflow(135305999368893231589);
        check_arithmeticExpWadOverflow(type(int256).max);
        for (uint8 i; i < 3; i++) {
            check_arithmeticSignedMagnitudeOverflow(i);
        }
    }
}

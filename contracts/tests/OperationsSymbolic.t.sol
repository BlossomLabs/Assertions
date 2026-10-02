// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "forge-std/Test.sol";
import "../Operations.sol";

/**
 * @notice Halmos properties for Operations: the zero-denominator panic of
 *         mulDiv and int256.min support in signed addMod/mulMod. Run with
 *         `pnpm halmos`.
 * @dev What Halmos cannot decide is left to the differential fuzzers in
 *      test/math-fuzz.test.ts: value properties of mulDiv, signed
 *      addMod/mulMod, signed exp, sqrt and powMod all hit the solver limit
 *      (300s per query) even with int16/uint64 operands, because the code
 *      itself works in 256- and 512-bit multiply, divide and modulo. Every
 *      call expected to succeed checks its success explicitly: Halmos
 *      discards reverting paths.
 */
contract OperationsSymbolicTest is Test {
    Operations ops;

    function setUp() public {
        ops = new Operations();
    }

    // ============ mulDiv ============

    function check_mulDivZeroDenominatorPanics(uint256 a, uint256 b, uint8 rounding) public view {
        vm.assume(rounding < 3);
        (bool ok, bytes memory out) = address(ops).staticcall(
            abi.encodeWithSignature("mulDiv(uint256,uint256,uint256,uint8)", a, b, uint256(0), rounding)
        );
        assertFalse(ok);
        assertEq(out, abi.encodeWithSignature("Panic(uint256)", uint256(0x12)));
    }

    // ============ Signed modular arithmetic ============

    /** @dev int256.min operands are supported, per the NatSpec */
    function check_signedModAtIntMin(int256 other, uint8 which) public view {
        vm.assume(other != 0 && which < 2);
        int256 m = which == 0 ? type(int256).min : other;
        int256 a = which == 0 ? other : type(int256).min;
        (bool ok,) =
            address(ops).staticcall(abi.encodeWithSignature("mulMod(int256,int256,int256)", a, int256(1), m));
        assertTrue(ok, "signed mulMod reverted on int256.min");
        (ok,) = address(ops).staticcall(abi.encodeWithSignature("addMod(int256,int256,int256)", a, int256(0), m));
        assertTrue(ok, "signed addMod reverted on int256.min");
    }

    // ============ parseUnits rounding ============

    /**
     * @dev "±d0d1.f0f1f2" with every digit symbolic, at 0 to 4 decimals and
     *      in every mode, against the exact fraction N / 1000 rather than the
     *      implementation's digit dropping: the result's magnitude m brackets
     *      N * 10^decimals / 1000 from below when the mode rounds toward zero
     *      on that side and from above when it rounds away (Floor below zero,
     *      Ceil above it). Stated with constant multiplications: a symbolic
     *      division by 1000 kept one run past eleven minutes. Some queries
     *      still need more than the default solver limit (about 4 minutes in
     *      all), hence the annotation; the script sets no solver timeout, so
     *      nothing overrides it.
     * @custom:halmos --solver-timeout-assertion 300000
     */
    function check_parseUnitsRoundsAsItsMode(bool negative, uint8[5] memory d, uint8 decimalsCase, uint8 mode)
        public
        view
    {
        vm.assume(mode < 3);
        for (uint256 i; i < 5; i++) {
            vm.assume(d[i] < 10);
        }
        uint256 decimals;
        if (decimalsCase == 0) decimals = 0;
        else if (decimalsCase == 1) decimals = 1;
        else if (decimalsCase == 2) decimals = 2;
        else if (decimalsCase == 3) decimals = 3;
        else {
            vm.assume(decimalsCase == 4);
            decimals = 4;
        }
        bytes memory text = abi.encodePacked(
            negative ? bytes1("-") : bytes1("+"),
            bytes1(0x30 + d[0]),
            bytes1(0x30 + d[1]),
            ".",
            bytes1(0x30 + d[2]),
            bytes1(0x30 + d[3]),
            bytes1(0x30 + d[4])
        );
        uint256 n = uint256(d[0]) * 10000 + uint256(d[1]) * 1000 + uint256(d[2]) * 100 + uint256(d[3]) * 10 + d[4];
        uint256 scaled = n * 10 ** decimals;

        (bool ok, bytes memory out) = address(ops).staticcall(
            abi.encodeCall(Operations.parseUnits, (text, decimals, Operations.Rounding(mode)))
        );
        assertTrue(ok, "parseUnits refused a well-formed number");
        int256 result = abi.decode(out, (int256));
        // The sign follows the text; zero carries none.
        if (negative) assertLe(result, 0);
        else assertGe(result, 0);
        uint256 m = uint256(result < 0 ? -result : result);
        vm.assume(m < 1 << 64);
        if ((negative && mode == 1) || (!negative && mode == 2)) {
            // Away from zero: the smallest m with m * 1000 >= scaled.
            assertTrue(m * 1000 >= scaled && (m == 0 || (m - 1) * 1000 < scaled), "not rounded away from zero");
        } else {
            // Toward zero: the largest m with m * 1000 <= scaled.
            assertTrue(m * 1000 <= scaled && (m + 1) * 1000 > scaled, "not rounded toward zero");
        }
    }

    // ============ log2 ============

    /**
     * @dev log2 is the exact floor for every word: 2^r <= x < 2^(r+1), which
     *      is x >> r == 1, and zero is refused with LogarithmUndefined(0)
     */
    function check_log2IsTheExactFloor(uint256 x) public view {
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.log2, (x)));
        if (x == 0) {
            assertFalse(ok);
            assertEq(out, abi.encodeWithSelector(Operations.LogarithmUndefined.selector, int256(0)));
        } else {
            assertTrue(ok, "log2 refused a nonzero word");
            uint256 r = abi.decode(out, (uint256));
            assertEq(x >> r, 1, "log2 is not the floor");
        }
    }

    // ============ Sign extension ============

    /**
     * @dev The documented recipe shr(int256(shl(x, 256 - bits)), 256 - bits)
     *      re-widens the low `bits` of x as a two's-complement field, for every
     *      width from 8 to 248 bits, against an independent reference: the
     *      masked field, with every higher bit set when its top bit is
     */
    function check_signExtensionRecipe(uint256 x, uint8 byteWidth) public view {
        vm.assume(byteWidth >= 1 && byteWidth <= 31);
        uint256 bits = uint256(byteWidth) * 8;
        (bool ok, bytes memory out) = address(ops).staticcall(abi.encodeCall(Operations.shl, (x, 256 - bits)));
        assertTrue(ok);
        uint256 shifted = abi.decode(out, (uint256));
        (ok, out) = address(ops).staticcall(abi.encodeWithSignature("shr(int256,uint256)", int256(shifted), 256 - bits));
        assertTrue(ok);
        uint256 mask = (uint256(1) << bits) - 1;
        uint256 field = x & mask;
        uint256 expected = (field >> (bits - 1)) & 1 == 1 ? field | ~mask : field;
        assertEq(uint256(abi.decode(out, (int256))), expected, "the recipe does not sign-extend");
    }

    // ============ rawCall ============

    /**
     * @dev rawCall to a code-less, non-precompile address succeeds with empty
     *      returndata
     */
    function check_rawCallToCodelessAddressIsEmpty(bytes32 data) public view {
        (bool ok, bytes memory out) =
            address(ops).staticcall(abi.encodeCall(Operations.rawCall, (address(0xC0DE), abi.encode(data))));
        assertTrue(ok, "rawCall refused a code-less address");
        assertEq(abi.decode(out, (bytes)).length, 0);
    }
}

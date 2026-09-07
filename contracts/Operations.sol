// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AbiCodec} from "./lib/AbiCodec.sol";

/**
 * @title Operations
 * @author Sembrestels
 * @notice Plain-Solidity operator vocabulary for the Assertions core: word
 *         arithmetic and comparisons (with int256 overloads for signed
 *         semantics, 512-bit mulDiv for overflow-free mul-then-div and a
 *         modular family), bitwise operations, environment reads, bytes
 *         and string operations including decimal parsing and formatting,
 *         and runtime ABI encoding. Every function takes and returns plain
 *         ABI types: no ERC-8211 anywhere. Composition happens in the
 *         core, whose `read` primitive resolves its operands and splices
 *         the resolved values into this contract's calldata, so an
 *         operator call IS the composition. Any deployed view or pure
 *         contract extends the vocabulary through the same socket;
 *         Operations is just the canonical first extension.
 * @dev Named functions instead of op-code enums so decoded calldata reads
 *      on explorers: `ge(balance, 100e18)` needs no docs open. Signedness
 *      rides on the int256 overloads (decoders display negative operands
 *      correctly; int256 spans the full word, so raw spliced words pass
 *      through unchanged). Arithmetic uses Solidity 0.8 checked semantics
 *      (overflow reverts with Panic(0x11), division by zero with
 *      Panic(0x12)); shifts follow EVM semantics (256 or more yields 0).
 *      Admission is a demand test: a function earns a slot only when it
 *      is not a few-node recipe at practical cost AND a concrete assertion
 *      workload needs it; hot loops and calldata-exponential compositions
 *      (`rpow`, `log2`) pass, and iteration lives in Collections.
 *      Operations is reached by address, never by source import, so it
 *      versions on its own: old versions never break, new versions
 *      deploy at new addresses.
 * @custom:version 2.0
 */
contract Operations {
    // ============ Types ============

    /**
     * @notice Rounding modes for the division and parsing families
     * @dev ABI-encoded as uint8: Trunc = 0 rounds toward zero, Floor = 1
     *      toward negative infinity, Ceil = 2 toward positive infinity. For
     *      non-negative results Trunc and Floor agree. An out-of-range
     *      value reverts with Panic(0x21).
     */
    enum Rounding {
        Trunc,
        Floor,
        Ceil
    }

    // ============ Constants ============

    /**
     * @dev Exponents at or above this go to the modexp precompile in
     *      _powMod; below it the MULMOD loop is cheaper. See _powMod for
     *      the crossover arithmetic.
     */
    uint256 private constant POW_MOD_PRECOMPILE_THRESHOLD = 1 << 32;

    // ============ Custom Errors ============

    // The runtime encoder's errors are declared once in AbiCodec.

    /**
     * @notice Thrown when slice bounds fall outside the data
     * @param start The requested start byte
     * @param len The requested length in bytes
     * @param dataLength The data's actual byte length
     */
    error SliceOutOfBounds(uint256 start, uint256 len, uint256 dataLength);

    /**
     * @notice Thrown when a strict signed index lies outside
     *         -length .. length-1
     * @param index The requested index as given
     * @param length The data's byte length
     */
    error InvalidByteIndex(int256 index, uint256 length);

    /**
     * @notice Thrown when a string operation meets malformed UTF-8, or a
     *         slice boundary that would split a multi-byte code point
     * @param index The byte position of the offending byte
     */
    error InvalidUtf8(uint256 index);

    /**
     * @notice Thrown when replace or split receives an empty needle: it
     *         would match everywhere, and inserting the replacement (or a
     *         segment boundary) between every byte is certainly a mistake
     */
    error EmptyNeedle();

    /**
     * @notice Thrown when a parse function receives no digits: there is no
     *         number there, and 0 would be a silent wrong answer
     */
    error EmptyNumber();

    /**
     * @notice Thrown when a parse function meets a byte it does not accept
     *         (outside 0-9, a sign where none is allowed, a second decimal
     *         point)
     * @param position The byte position of the offending character
     * @param char The offending byte
     */
    error InvalidDecimalDigit(uint256 position, bytes1 char);

    /**
     * @notice Thrown when a decimals argument exceeds 77 (10^78 does not
     *         fit a word, so no scale beyond that is representable)
     * @param decimals The requested number of decimals
     */
    error InvalidPrecision(uint256 decimals);

    /**
     * @notice Thrown when a negative modular exponent needs an inverse that
     *         does not exist: the base and modulus magnitudes are not
     *         coprime
     * @param base The base magnitude, as reduced
     * @param modulus The modulus magnitude
     */
    error ModularInverseDoesNotExist(uint256 base, uint256 modulus);

    /**
     * @notice Thrown when a logarithm is taken outside its domain: log2 of
     *         zero, or lnWad of zero or a negative value
     * @param x The argument as given (zero for log2)
     */
    error LogarithmUndefined(int256 x);

    /**
     * @notice Thrown when a rawCall staticcall reverts
     * @param target The called address
     * @param data The calldata that was sent
     */
    error RawCallFailed(address target, bytes data);

    // ============ Arithmetic ============

    /**
     * @notice a + b, checked
     */
    function add(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;
    }

    /**
     * @notice a + b, signed, checked
     */
    function add(int256 a, int256 b) external pure returns (int256) {
        return a + b;
    }

    /**
     * @notice a - b, checked
     */
    function sub(uint256 a, uint256 b) external pure returns (uint256) {
        return a - b;
    }

    /**
     * @notice a - b, signed, checked
     */
    function sub(int256 a, int256 b) external pure returns (int256) {
        return a - b;
    }

    /**
     * @notice a * b, checked
     */
    function mul(uint256 a, uint256 b) external pure returns (uint256) {
        return a * b;
    }

    /**
     * @notice a * b, signed, checked
     */
    function mul(int256 a, int256 b) external pure returns (int256) {
        return a * b;
    }

    /**
     * @notice a / b (division by zero reverts with Panic(0x12))
     */
    function div(uint256 a, uint256 b) external pure returns (uint256) {
        return a / b;
    }

    /**
     * @notice a / b, signed, truncating toward zero (type(int256).min / -1
     *         reverts with Panic(0x11))
     */
    function div(int256 a, int256 b) external pure returns (int256) {
        return a / b;
    }

    /**
     * @notice a % b (modulo by zero reverts with Panic(0x12))
     */
    function mod(uint256 a, uint256 b) external pure returns (uint256) {
        return a % b;
    }

    /**
     * @notice a % b, signed, taking the sign of the dividend
     */
    function mod(int256 a, int256 b) external pure returns (int256) {
        return a % b;
    }

    /**
     * @notice a ** b, checked (0 ** 0 == 1): canonical use is live
     *         decimals scaling, e.g. mul(5, exp(10, token.decimals()))
     */
    function exp(uint256 a, uint256 b) external pure returns (uint256) {
        return a ** b;
    }

    /**
     * @notice a ** b, signed base, checked (0 ** 0 == 1)
     * @dev Binary exponentiation with checked multiplies, so any
     *      intermediate leaving int256 reverts with Panic(0x11)
     */
    function exp(int256 a, uint256 b) external pure returns (int256 result) {
        result = 1;
        while (b != 0) {
            if (b & 1 != 0) result *= a;
            b >>= 1;
            if (b != 0) a *= a;
        }
    }

    /**
     * @notice The smaller of a and b
     */
    function min(uint256 a, uint256 b) external pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @notice The smaller of a and b, signed
     */
    function min(int256 a, int256 b) external pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @notice The larger of a and b
     */
    function max(uint256 a, uint256 b) external pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @notice The larger of a and b, signed
     */
    function max(int256 a, int256 b) external pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @notice The magnitude |a - b|; total, never reverts
     */
    function absDiff(uint256 a, uint256 b) external pure returns (uint256) {
        return a > b ? a - b : b - a;
    }

    /**
     * @notice The magnitude |a - b| of two signed values as a uint256;
     *         total: a signed compare and a two's-complement wrapping
     *         subtract mean even the widest span (int256 min to max)
     *         yields its exact distance instead of reverting. Consume the
     *         result with unsigned comparisons
     */
    function absDiff(int256 a, int256 b) external pure returns (uint256) {
        unchecked {
            return a > b ? uint256(a) - uint256(b) : uint256(b) - uint256(a);
        }
    }

    /**
     * @notice a * b / denominator over the full 512-bit product, rounded
     *         once as `rounding` says (Trunc and Floor agree here): the
     *         overflow-free mul-then-div for token math
     * @dev A zero denominator reverts with Panic(0x12); a rounded result
     *      that does not fit uint256 with Panic(0x11)
     */
    function mulDiv(uint256 a, uint256 b, uint256 denominator, Rounding rounding)
        external
        pure
        returns (uint256 result)
    {
        result = _mulDiv(a, b, denominator);
        if (rounding == Rounding.Ceil && mulmod(a, b, denominator) != 0) result += 1;
    }

    /**
     * @notice a * b / denominator, signed, over the full 512-bit product of
     *         the magnitudes, rounded once as `rounding` says: Trunc toward
     *         zero, Floor toward negative infinity, Ceil toward positive
     *         infinity. Negative denominators are allowed
     * @dev All int256.min operands are supported. A zero denominator
     *      reverts with Panic(0x12); a rounded result outside int256 with
     *      Panic(0x11).
     */
    function mulDiv(int256 a, int256 b, int256 denominator, Rounding rounding) external pure returns (int256) {
        bool negative = (a < 0) != (b < 0) != (denominator < 0);
        uint256 x = _magnitude(a);
        uint256 y = _magnitude(b);
        uint256 d = _magnitude(denominator);
        uint256 result = _mulDiv(x, y, d);
        if (
            mulmod(x, y, d) != 0
                && ((negative && rounding == Rounding.Floor) || (!negative && rounding == Rounding.Ceil))
        ) {
            result += 1;
        }
        return _signedMagnitude(result, negative);
    }

    /**
     * @notice (a + b) % m over the full 512-bit sum (EVM ADDMOD: the
     *         addition does not wrap at 2^256)
     * @dev Modulo by zero reverts with Panic(0x12)
     */
    function addMod(uint256 a, uint256 b, uint256 m) external pure returns (uint256) {
        return addmod(a, b, m);
    }

    /**
     * @notice (a * b) % m over the full 512-bit product (EVM MULMOD: the
     *         multiplication does not wrap at 2^256)
     * @dev Modulo by zero reverts with Panic(0x12)
     */
    function mulMod(uint256 a, uint256 b, uint256 m) external pure returns (uint256) {
        return mulmod(a, b, m);
    }

    /**
     * @notice (a + b) % m, signed, with an overflow-free intermediate sum
     * @dev The remainder takes the sum's sign, independent of m's sign
     *      (Solidity's own convention for signed %). All int256.min operands
     *      are supported; modulo by zero reverts with Panic(0x12).
     */
    function addMod(int256 a, int256 b, int256 m) external pure returns (int256) {
        uint256 x = _magnitude(a);
        uint256 y = _magnitude(b);
        uint256 modulus = _magnitude(m);
        if ((a < 0) == (b < 0)) {
            return _signedMagnitude(addmod(x, y, modulus), a < 0);
        }
        // Opposite signs subtract magnitudes; the larger operand sets the sign.
        return x >= y ? _signedMagnitude((x - y) % modulus, a < 0) : _signedMagnitude((y - x) % modulus, b < 0);
    }

    /**
     * @notice (a * b) % m, signed, with an overflow-free intermediate
     *         product
     * @dev The remainder takes the product's sign, independent of m's sign.
     *      All int256.min operands are supported; modulo by zero reverts
     *      with Panic(0x12).
     */
    function mulMod(int256 a, int256 b, int256 m) external pure returns (int256) {
        return _signedMagnitude(mulmod(_magnitude(a), _magnitude(b), _magnitude(m)), (a < 0) != (b < 0));
    }

    /**
     * @notice a ** exponent % m without overflowing the intermediate power
     *         (0 ** 0 == 1, and a modulus of 1 yields 0)
     * @dev Square-and-multiply over MULMOD for small exponents, the
     *      modexp precompile for exponents of 32 bits or more (the loop
     *      remains the fallback if the precompile is unavailable). A zero
     *      modulus reverts with Panic(0x12).
     */
    function powMod(uint256 a, uint256 exponent, uint256 m) external view returns (uint256) {
        return _powMod(a, exponent, m);
    }

    /**
     * @notice a ** exponent % m, signed base: the power of |a| modulo |m|,
     *         negative when a is negative and the exponent odd
     * @dev The modulus's sign is ignored. All int256.min operands are
     *      supported; a zero modulus reverts with Panic(0x12).
     */
    function powMod(int256 a, uint256 exponent, int256 m) external view returns (int256) {
        return _signedMagnitude(_powMod(_magnitude(a), exponent, _magnitude(m)), a < 0 && exponent & 1 != 0);
    }

    /**
     * @notice a ** exponent % m with a signed exponent: a negative exponent
     *         raises the modular inverse of a to |exponent|
     * @dev Reverts with ModularInverseDoesNotExist unless gcd(a, m) == 1
     *      when the exponent is negative. A modulus of 1 yields 0; a zero
     *      modulus reverts with Panic(0x12).
     */
    function powMod(uint256 a, int256 exponent, uint256 m) external view returns (uint256) {
        return _powMod(exponent < 0 ? _inverseMod(a, m) : a, _magnitude(exponent), m);
    }

    /**
     * @notice a ** exponent % m, signed base and signed exponent: the
     *         magnitude rules of the unsigned overload over |a| and |m|,
     *         negative when a is negative and the exponent odd (in either
     *         direction)
     * @dev A negative exponent requires coprime base and modulus
     *      magnitudes (ModularInverseDoesNotExist otherwise). All
     *      int256.min operands are supported; a zero modulus reverts with
     *      Panic(0x12).
     */
    function powMod(int256 a, int256 exponent, int256 m) external view returns (int256) {
        uint256 base = _magnitude(a);
        uint256 modulus = _magnitude(m);
        if (exponent < 0) base = _inverseMod(base, modulus);
        return _signedMagnitude(_powMod(base, _magnitude(exponent), modulus), a < 0 && exponent & 1 != 0);
    }

    /**
     * @notice floor(sqrt(x)): canonical use is AMM invariant checks, e.g.
     *         sqrt(mulDiv(x, y, 1e18, Trunc))
     * @dev Babylonian method seeded by a bit scan: seven Newton
     *      iterations are exact for the full uint256 range
     */
    function sqrt(uint256 x) external pure returns (uint256) {
        if (x == 0) return 0;
        unchecked {
            uint256 r = 1 << (_log2(x) >> 1);
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            uint256 r1 = x / r;
            return r < r1 ? r : r1;
        }
    }

    /**
     * @notice x raised to the n-th power in fixed point, where `base` is
     *         one unit (1e27 for a ray, 1e18 for a wad): the compounding
     *         primitive, e.g. an APY from a per-second rate is
     *         rpow(1e27 + ratePerSecond, 31536000, 1e27)
     * @dev Binary exponentiation with the scale divided out after every
     *      multiply, so the intermediate never leaves fixed point. This
     *      cannot be composed from the rest of the vocabulary at any
     *      practical cost: a raw operand tree has no way to name a
     *      subterm, so squaring duplicates its operand's whole calldata
     *      subtree and the composed form is 2^k copies (about 33M for the
     *      exponent above). Rounds down at each step; earlier rounding
     *      losses can be amplified by later squarings, so the final error
     *      is not bounded by the number of multiplies. Choose the scale
     *      and tolerance for the input range and exponent. Reverts with
     *      Panic(0x11) if a scaled intermediate does not fit uint256, and
     *      with Panic(0x12) when `base` is zero: the scale is the divisor.
     */
    function rpow(uint256 x, uint256 n, uint256 base) external pure returns (uint256) {
        if (base == 0) _panic(0x12);
        // 0^0 is one unit, matching exp(0, 0) == 1 in the integer family.
        if (x == 0) return n == 0 ? base : 0;
        uint256 result = base;
        while (n > 0) {
            if (n & 1 == 1) {
                result = _mulDiv(result, x, base);
            }
            n >>= 1;
            if (n > 0) {
                x = _mulDiv(x, x, base);
            }
        }
        return result;
    }

    /**
     * @notice e^x in wad fixed point (1e18), for continuous compounding
     *         and the inverse of lnWad
     * @dev Remco Bloemen's algorithm: range-reduce by ln(2), evaluate a
     *      rational approximation, then scale by 2^k. Reverts with
     *      Panic(0x11) at or above 135305999368893231589 (where the result
     *      leaves int256) and returns 0 at or below -42139678854452767551
     *      (where it underflows wad).
     */
    function expWad(int256 x) external pure returns (int256 r) {
        unchecked {
            if (x <= -42139678854452767551) return 0;
            if (x >= 135305999368893231589) _panic(0x11);

            // Convert to a 2^96 base for the polynomial's precision.
            x = (x << 78) / 5 ** 18;

            // Reduce the range to [-ln2/2, ln2/2], remembering the power
            // of two to reapply at the end.
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;
            x = x - k * 54916777467707473351141471128;

            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            // q is never zero on this range, so plain division is safe.
            r = p / q;

            // Reapply the wad scale and the reduced power of two.
            r = int256((uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k));
        }
    }

    /**
     * @notice The natural log of x in wad fixed point (1e18): the inverse
     *         of expWad, and how a growth factor becomes a rate
     * @dev Remco Bloemen's algorithm. Reverts with LogarithmUndefined for
     *      x <= 0, where the log is undefined.
     */
    function lnWad(int256 x) external pure returns (int256 r) {
        unchecked {
            if (x <= 0) revert LogarithmUndefined(x);

            // Normalize to [1, 2) in a 2^96 base, remembering the shift.
            int256 k = int256(_log2(uint256(x))) - 96;
            x <<= uint256(159 - k);
            x = int256(uint256(x) >> 159);

            int256 p = x + 3273285459638523848632254066296;
            p = ((p * x) >> 96) + 24828157081833163892658089445524;
            p = ((p * x) >> 96) + 43456485725739037958740375743393;
            p = ((p * x) >> 96) - 11111509109440967052023855526967;
            p = ((p * x) >> 96) - 45023709667254063763336534515857;
            p = ((p * x) >> 96) - 14706773417378608786704636184526;
            p = p * x - (795164235651350426258249787498 << 96);

            int256 q = x + 5573035233440673466300451813936;
            q = ((q * x) >> 96) + 71694874799317883764090561454958;
            q = ((q * x) >> 96) + 283447036172924575727196451306956;
            q = ((q * x) >> 96) + 401686690394027663651624208769553;
            q = ((q * x) >> 96) + 204048457590392012362485061816622;
            q = ((q * x) >> 96) + 31853899698501571402653359427138;
            q = ((q * x) >> 96) + 909429971244387300277376558375;

            r = p / q;
            r *= 1677202110996718588342820967067443963516166;
            r += 16597577552685614221487285958193947469193820559219878177908093499208371 * k;
            r += 600920179829731861736702779321621459595472258049074101567377883020018308;
            r >>= 174;
        }
    }

    /**
     * @notice floor(log2(x)): the position of the highest set bit, and so
     *         the bit length of x minus one
     * @dev Earns its slot as a calldata-exponential composition: the
     *      composed form is eight nested conds that each duplicate their
     *      operand's calldata subtree. Reverts with LogarithmUndefined for
     *      x = 0, where the logarithm is undefined.
     */
    function log2(uint256 x) external pure returns (uint256) {
        if (x == 0) revert LogarithmUndefined(0);
        return _log2(x);
    }

    // ============ Comparisons ============

    /**
     * @notice a == b (bit-level, covers all word types)
     */
    function eq(uint256 a, uint256 b) external pure returns (bool) {
        return a == b;
    }

    /**
     * @notice a != b (bit-level, covers all word types)
     */
    function ne(uint256 a, uint256 b) external pure returns (bool) {
        return a != b;
    }

    /**
     * @notice a < b
     */
    function lt(uint256 a, uint256 b) external pure returns (bool) {
        return a < b;
    }

    /**
     * @notice a < b, signed
     */
    function lt(int256 a, int256 b) external pure returns (bool) {
        return a < b;
    }

    /**
     * @notice a > b
     */
    function gt(uint256 a, uint256 b) external pure returns (bool) {
        return a > b;
    }

    /**
     * @notice a > b, signed
     */
    function gt(int256 a, int256 b) external pure returns (bool) {
        return a > b;
    }

    /**
     * @notice a <= b
     */
    function le(uint256 a, uint256 b) external pure returns (bool) {
        return a <= b;
    }

    /**
     * @notice a <= b, signed
     */
    function le(int256 a, int256 b) external pure returns (bool) {
        return a <= b;
    }

    /**
     * @notice a >= b
     */
    function ge(uint256 a, uint256 b) external pure returns (bool) {
        return a >= b;
    }

    /**
     * @notice a >= b, signed
     */
    function ge(int256 a, int256 b) external pure returns (bool) {
        return a >= b;
    }

    // ============ Bitwise ============

    /**
     * @notice a & b: also conjoins comparison results, which splice as
     *         0/1 words
     */
    function bitAnd(uint256 a, uint256 b) external pure returns (uint256) {
        return a & b;
    }

    /**
     * @notice a | b: also disjoins comparison results
     */
    function bitOr(uint256 a, uint256 b) external pure returns (uint256) {
        return a | b;
    }

    /**
     * @notice a ^ b: bitXor(x, ~0) is bitwise NOT
     */
    function bitXor(uint256 a, uint256 b) external pure returns (uint256) {
        return a ^ b;
    }

    /**
     * @notice a << bits, EVM semantics (shifts of 256 or more yield 0)
     */
    function shl(uint256 a, uint256 bits) external pure returns (uint256) {
        return a << bits;
    }

    /**
     * @notice a >> bits, EVM semantics (shifts of 256 or more yield 0)
     */
    function shr(uint256 a, uint256 bits) external pure returns (uint256) {
        return a >> bits;
    }

    /**
     * @notice a >> bits, signed, arithmetic (EVM SAR): the sign fills in
     *         from the left, rounding toward negative infinity; shifts of
     *         256 or more yield 0 for non-negative a and -1 for negative
     * @dev With shl this is also the sign-extension recipe for narrow
     *      two's-complement fields sliced out of packed bytes:
     *      shr(int256(shl(x, 256 - bits)), 256 - bits) re-widens the low
     *      `bits` bits
     */
    function shr(int256 a, uint256 bits) external pure returns (int256) {
        return a >> bits;
    }

    /**
     * @notice Whether bit `index` of `mask` is set (indices past 255 are
     *         never set): the character-class test, since with a charset
     *         bitmap mask, bitSet(mask, byteValue) is a one-call fold lambda
     */
    function bitSet(uint256 mask, uint256 index) external pure returns (bool) {
        return (mask >> index) & 1 == 1;
    }

    // ============ Environment ============

    /**
     * @notice The native balance of `account` in wei, at judge time
     */
    function balance(address account) external view returns (uint256) {
        return account.balance;
    }

    /**
     * @notice The code hash of `account`, EXTCODEHASH semantics
     *         (nonexistent account: 0; existing code-less account:
     *         keccak256(""))
     */
    function codeHash(address account) external view returns (bytes32) {
        return account.codehash;
    }

    /**
     * @notice The block timestamp at judge time: how an ERC-8211 predicate
     *         gates on time
     */
    function timestamp() external view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @notice The block number at judge time
     */
    function blockNumber() external view returns (uint256) {
        return block.number;
    }

    /**
     * @notice The chain id
     */
    function chainId() external view returns (uint256) {
        return block.chainid;
    }

    /**
     * @notice The block base fee in wei at judge time: how a predicate
     *         gates on fee conditions
     */
    function baseFee() external view returns (uint256) {
        return block.basefee;
    }

    /**
     * @notice The previous RANDAO mix of the block at judge time
     */
    function prevRandao() external view returns (uint256) {
        return block.prevrandao;
    }

    /**
     * @notice The block proposer's fee recipient at judge time
     */
    function coinbase() external view returns (address) {
        return block.coinbase;
    }

    /**
     * @notice The block gas limit at judge time
     */
    function gasLimit() external view returns (uint256) {
        return block.gaslimit;
    }

    /**
     * @notice The blob base fee in wei at judge time
     */
    function blobBaseFee() external view returns (uint256) {
        return block.blobbasefee;
    }

    /**
     * @notice The hash of block `n`, BLOCKHASH semantics: 0 for blocks
     *         older than 256 blocks, the current block, or the future
     */
    function blockHash(uint256 n) external view returns (bytes32) {
        return blockhash(n);
    }

    /**
     * @notice The transaction origin: lets an assertion gate on who is
     *         executing the batch it guards
     */
    function origin() external view returns (address) {
        return tx.origin;
    }

    /**
     * @notice The gas price of the transaction executing the batch, in wei
     *         (tx.gasprice): gate a batch on the fee it is actually paying,
     *         e.g. le(gasPrice(), maxWei)
     */
    function gasPrice() external view returns (uint256) {
        return tx.gasprice;
    }

    /**
     * @notice The versioned hash of the executing transaction's index-th
     *         blob (BLOBHASH), or zero when the transaction carries no blob
     *         at that index: pins blob-carrying batches to the data they
     *         were built for (ne(blobHash(0), 0) asserts a blob is present
     *         at all)
     */
    function blobHash(uint256 index) external view returns (bytes32) {
        return blobhash(index);
    }

    // ============ Calls ============

    /**
     * @notice Executes a staticcall with raw calldata and returns the
     *         returndata as a bytes value
     * @dev The precompile reach-through: unlike the core's constructed
     *      calls, no selector is prepended and NO code-length check is
     *      performed, because precompiles (sha256 at 0x02, ecrecover at
     *      0x01, modexp at 0x05, ...) have no code and raw calldata is
     *      their entire input. The caveat is the flip side: a staticcall
     *      to a code-less non-precompile address "succeeds" with empty
     *      returndata, so pin the result with byteLen or a constraint when
     *      that matters. A revert is wrapped as RawCallFailed carrying the
     *      calldata (the target's reason is lost; Expressions' ProbeCall
     *      and the core's revertData are the reason-carrying probes).
     * @param target The address to staticcall (precompiles included)
     * @param data The raw calldata
     * @return The raw returndata as a bytes value
     */
    function rawCall(address target, bytes calldata data) external view returns (bytes memory) {
        (bool success, bytes memory result) = target.staticcall(data);
        if (!success) revert RawCallFailed(target, data);
        return result;
    }

    /**
     * @notice The full runtime code of `account` as a bytes value:
     *         codeHash's sibling for prefix, suffix and segment assertions
     *         (a code-less account yields empty bytes)
     */
    function code(address account) external view returns (bytes memory) {
        return account.code;
    }

    // ============ Bytes ============

    /**
     * @notice The parts concatenated in order, with `delimiter` inserted
     *         between consecutive parts (join is this over a split)
     * @dev Returned as a normal bytes value (ABI envelope): the canonical
     *      form every consumer of a single bytes argument expects,
     *      including encode's values[]
     */
    function concat(bytes[] calldata parts, bytes calldata delimiter) external pure returns (bytes memory out) {
        uint256 length;
        for (uint256 i; i < parts.length; i++) {
            length += parts[i].length;
        }
        if (parts.length > 1) length += (parts.length - 1) * delimiter.length;
        out = new bytes(length);
        uint256 offset;
        for (uint256 i; i < parts.length; i++) {
            if (i != 0) {
                _copy(out, offset, delimiter);
                offset += delimiter.length;
            }
            _copy(out, offset, parts[i]);
            offset += parts[i].length;
        }
    }

    /**
     * @notice data[start .. start + len), reverting with SliceOutOfBounds
     *         when the range leaves the data
     */
    function slice(bytes calldata data, uint256 start, uint256 len) external pure returns (bytes memory) {
        if (start > data.length || len > data.length - start) {
            revert SliceOutOfBounds(start, len, data.length);
        }
        return data[start:start + len];
    }

    /**
     * @notice data[start .. end) with JavaScript Array.slice semantics:
     *         signed indices, negative counting from the end, both clamped
     *         to the data bounds, end exclusive, and empty bytes when end
     *         does not exceed start. Never reverts
     */
    function sliceRange(bytes calldata data, int256 start, int256 end) external pure returns (bytes memory) {
        uint256 a = _rangeIndex(start, data.length);
        uint256 b = _rangeIndex(end, data.length);
        return b > a ? data[a:b] : data[0:0];
    }

    /**
     * @notice The single byte at a signed index (negative from the end,
     *         -1 = last) as a one-byte bytes value
     * @dev Strict: an index outside -length .. length-1 reverts with
     *      InvalidByteIndex, where sliceRange would clamp
     */
    function byteAt(bytes calldata data, int256 index) external pure returns (bytes memory) {
        uint256 position = _strictIndex(index, data.length);
        return data[position:position + 1];
    }

    /**
     * @notice sliceRange over a UTF-8 string: the same clamped signed
     *         range over BYTE positions, refusing to cut a code point in
     *         half
     * @dev The whole input is validated as UTF-8 first (InvalidUtf8 at the
     *      offending byte); a non-empty range whose start or end lands on
     *      a continuation byte reverts with InvalidUtf8 at that boundary.
     *      Indices are still bytes, not characters: a character-level slice
     *      is a composition over indexOf.
     */
    function stringSlice(bytes calldata data, int256 start, int256 end) external pure returns (bytes memory) {
        _checkUtf8(data);
        uint256 a = _rangeIndex(start, data.length);
        uint256 b = _rangeIndex(end, data.length);
        if (b <= a) return data[0:0];
        if (a < data.length && uint8(data[a]) & 0xc0 == 0x80) revert InvalidUtf8(a);
        if (b < data.length && uint8(data[b]) & 0xc0 == 0x80) revert InvalidUtf8(b);
        return data[a:b];
    }

    /**
     * @notice byteAt over a UTF-8 string: the single ASCII character at a
     *         signed byte index, as a one-character string
     * @dev The whole input is validated as UTF-8 first; an index outside
     *      the data reverts with InvalidByteIndex, and a position holding
     *      any byte of a multi-byte code point with InvalidUtf8, since one
     *      byte of it is not a character
     */
    function stringAt(bytes calldata data, int256 index) external pure returns (bytes memory) {
        _checkUtf8(data);
        uint256 position = _strictIndex(index, data.length);
        if (uint8(data[position]) >= 0x80) revert InvalidUtf8(position);
        return data[position:position + 1];
    }

    /**
     * @notice The raw byte length of `data`
     */
    function byteLen(bytes calldata data) external pure returns (uint256) {
        return data.length;
    }

    /**
     * @notice keccak256 of `data`: lets an EQ constraint pin complex or
     *         hard-to-decode values (keccak is an opcode, not a precompile,
     *         so it must be a function here)
     */
    function hash(bytes calldata data) external pure returns (bytes32) {
        return keccak256(data);
    }

    /**
     * @notice keccak256 of the two words concatenated in ascending order,
     *         byte-identical to OpenZeppelin MerkleProof's node combiner:
     *         a foldWords over a proof payload with this as the lambda and
     *         the leaf as the initial accumulator reproduces the root
     *         (order-preserving pair hashing composes as hash over concat)
     */
    function hashPairSorted(bytes32 a, bytes32 b) external pure returns (bytes32) {
        if (a > b) (a, b) = (b, a);
        return keccak256(abi.encodePacked(a, b));
    }

    // ============ Search ============

    /**
     * @notice Whether `needle` occurs in `s`; an empty needle always
     *         matches, even in an empty `s`
     */
    function contains(bytes calldata s, bytes calldata needle) external pure returns (bool) {
        if (needle.length == 0) return true;
        if (needle.length > s.length) return false;
        for (uint256 i; i <= s.length - needle.length; i++) {
            if (_matchesAt(s, needle, i)) return true;
        }
        return false;
    }

    /**
     * @notice Position of the occurrence-th occurrence of `needle` in `s`,
     *         counted from the start (0, 1, 2, ...) or from the end
     *         (-1 = last, -2 = second-last, ...)
     * @dev The signed occurrence ordinal matches the repo-wide
     *      negative-index idiom (pick, nav). Occurrences are enumerated
     *      left to right and NON-overlapping: after a match the scan
     *      resumes past it, so in `aaaa` the needle `aa` occurs at 0 and
     *      2. That is delimiter semantics, so splitting and occurrence
     *      counting agree. Requesting an occurrence that does not exist
     *      (in either direction) returns the sentinel `s.length` (it
     *      composes: includes = lt(indexOf(s, n, 0), byteLen(s))).
     *      Split segments are two indexOf reads and a slice: segment
     *      k >= 0 spans [indexOf(s, d, k-1) + dlen, indexOf(s, d, k))
     *      (0 for k == 0; the sentinel ends the trailing segment for
     *      free), and segment -k spans
     *      [indexOf(s, d, -k) + dlen, indexOf(s, d, -k+1))
     *      (byteLen(s) for k == 1). Total by design: an empty needle
     *      vacuously matches at every position 0 .. s.length, and nothing
     *      here ever reverts.
     * @param s The haystack
     * @param needle The exact byte sequence to find
     * @param occurrence The signed occurrence ordinal (see above)
     * @return The match position, or s.length when there is none
     */
    function indexOf(bytes calldata s, bytes calldata needle, int256 occurrence) external pure returns (uint256) {
        if (needle.length == 0) {
            // Vacuous matches at every position 0 .. s.length.
            uint256 positions = s.length + 1;
            if (occurrence >= 0) {
                return uint256(occurrence) < positions ? uint256(occurrence) : s.length;
            }
            // occurrence == type(int256).min is caught here before
            // -occurrence could overflow.
            if (occurrence < -int256(positions)) return s.length;
            return positions - uint256(-occurrence);
        }
        uint256 wanted;
        if (occurrence < 0) {
            uint256 count = _countOccurrences(s, needle);
            // occurrence == type(int256).min is caught here before
            // -occurrence could overflow.
            if (occurrence < -int256(count)) return s.length;
            wanted = count - uint256(-occurrence);
        } else {
            wanted = uint256(occurrence);
        }
        uint256 seen;
        uint256 p;
        while (p + needle.length <= s.length) {
            if (_matchesAt(s, needle, p)) {
                if (seen == wanted) return p;
                seen++;
                p += needle.length;
            } else {
                p++;
            }
        }
        return s.length;
    }

    /**
     * @notice `data` split on every non-overlapping occurrence of
     *         `delimiter`, as a bytes[] of segments: the same enumeration
     *         indexOf uses, so there are always count + 1 segments and
     *         empty segments (leading, trailing, between adjacent
     *         delimiters) are preserved
     * @dev An empty delimiter reverts with EmptyNeedle (it would match
     *      everywhere). No delimiter in the data yields the data as its
     *      single segment.
     */
    function split(bytes calldata data, bytes calldata delimiter) external pure returns (bytes[] memory parts) {
        if (delimiter.length == 0) revert EmptyNeedle();
        parts = new bytes[](_countOccurrences(data, delimiter) + 1);
        uint256 start;
        uint256 position;
        uint256 index;
        while (position + delimiter.length <= data.length) {
            if (_matchesAt(data, delimiter, position)) {
                parts[index++] = data[start:position];
                position += delimiter.length;
                start = position;
            } else {
                position++;
            }
        }
        parts[index] = data[start:];
    }

    // ============ Strings ============

    /**
     * @notice `s` with every occurrence of `needle` replaced by `repl`
     * @dev Non-overlapping left-to-right scan, the same enumeration
     *      indexOf and occurrence counting use (in `aaaa` the needle `aa`
     *      is replaced at positions 0 and 2). An empty `repl` deletes;
     *      an empty needle reverts with EmptyNeedle (it would vacuously
     *      match everywhere)
     */
    function replace(bytes calldata s, bytes calldata needle, bytes calldata repl)
        external
        pure
        returns (bytes memory out)
    {
        if (needle.length == 0) revert EmptyNeedle();
        // Record each match once, then size and fill the output without rescanning.
        uint256[] memory matches = new uint256[](s.length / needle.length);
        uint256 count;
        uint256 p;
        while (p + needle.length <= s.length) {
            if (_matchesAt(s, needle, p)) {
                matches[count++] = p;
                p += needle.length;
            } else {
                p++;
            }
        }
        if (count == 0) return s;
        out = new bytes(s.length - count * needle.length + count * repl.length);
        uint256 start;
        uint256 dest;
        for (uint256 i; i < count; i++) {
            p = matches[i];
            _copy(out, dest, s[start:p]);
            dest += p - start;
            _copy(out, dest, repl);
            dest += repl.length;
            start = p + needle.length;
        }
        _copy(out, dest, s[start:]);
    }

    /**
     * @notice `s` with ASCII A-Z folded to a-z; every other byte passes
     *         through verbatim (multi-byte UTF-8 units have the high bit
     *         set, so they are untouched: the fold is ASCII-only)
     */
    function toLower(bytes calldata s) external pure returns (bytes memory) {
        return _foldCase(s, "A", "Z");
    }

    /**
     * @notice `s` with ASCII a-z folded to A-Z; every other byte passes
     *         through verbatim (ASCII-only, like toLower)
     */
    function toUpper(bytes calldata s) external pure returns (bytes memory) {
        return _foldCase(s, "a", "z");
    }

    /**
     * @notice Whether every byte of `s` is a member of the 256-bit
     *         character-class `mask` (bit i set means byte value i is
     *         allowed): a native single-call loop, the fixed-operation
     *         form of the foldBytes(bitSet, All) recipe. An empty string
     *         is vacuously in every set
     */
    function charset(bytes calldata s, uint256 mask) external pure returns (bool) {
        for (uint256 i = 0; i < s.length; i++) {
            if (mask & (uint256(1) << uint8(s[i])) == 0) return false;
        }
        return true;
    }

    // ============ Parse ============

    /**
     * @notice The uint256 a decimal ASCII string encodes: the bridge from
     *         string returns into arithmetic, e.g. comparing a version
     *         segment numerically, gt(parseUint(split-segment), 2)
     * @dev Strict by design: reverts with EmptyNumber on empty input and
     *      InvalidDecimalDigit on any byte outside 0-9 (no signs, no
     *      whitespace, no decimal points); a value past 2^256 - 1
     *      reverts with Panic(0x11) via the checked accumulator.
     *      Leading zeros are accepted ("007" is 7).
     */
    function parseUint(bytes calldata s) external pure returns (uint256) {
        return _parseDigits(s, 0);
    }

    /**
     * @notice The int256 a decimal ASCII string encodes, with an optional
     *         leading + or - sign: parseUint's signed sibling
     * @dev Strict like parseUint: EmptyNumber on empty input or a bare
     *      sign, InvalidDecimalDigit on any other byte outside 0-9, and
     *      Panic(0x11) when the value leaves int256 ("-" followed by 2^255
     *      is the most negative accepted input). Leading zeros are
     *      accepted.
     */
    function parseInt(bytes calldata value) external pure returns (int256) {
        if (value.length == 0) revert EmptyNumber();
        bool negative = value[0] == "-";
        return _signedMagnitude(_parseDigits(value, negative || value[0] == "+" ? 1 : 0), negative);
    }

    /**
     * @notice The signed integer units a decimal ASCII string denotes at
     *         `decimals` places: viem's parseUnits, e.g. "1.5" at 18
     *         decimals is 1500000000000000000
     * @dev Accepts an optional leading + or -, digits with at most one
     *      decimal point anywhere (".5" and "5." are fine) and at least
     *      one digit in total (EmptyNumber otherwise). Fractional digits
     *      beyond `decimals` are dropped as `rounding` says: Trunc toward
     *      zero, Floor toward negative infinity, Ceil toward positive
     *      infinity. Reverts with InvalidPrecision above 77 decimals,
     *      InvalidDecimalDigit on any other byte, and Panic(0x11) when the
     *      result leaves int256.
     */
    function parseUnits(bytes calldata value, uint256 decimals, Rounding rounding) external pure returns (int256) {
        (uint256 magnitude, bool negative) = _parseUnits(value, decimals, rounding, true);
        return _signedMagnitude(magnitude, negative);
    }

    /**
     * @notice parseUnits for a non-negative decimal, returning uint256
     * @dev Same grammar and rounding as parseUnits (Trunc and Floor agree
     *      here); a leading + is accepted and a leading - rejected with
     *      InvalidDecimalDigit at position 0, negative zero included.
     *      Reverts with Panic(0x11) when the result leaves uint256.
     */
    function parseUnitsUnsigned(bytes calldata value, uint256 decimals, Rounding rounding)
        external
        pure
        returns (uint256)
    {
        (uint256 magnitude,) = _parseUnits(value, decimals, rounding, false);
        return magnitude;
    }

    /**
     * @notice The decimal ASCII rendering of `v`: parseUint's inverse (no
     *         leading zeros, so toString(parseUint(s)) normalizes)
     */
    function toString(uint256 v) public pure returns (string memory) {
        if (v == 0) return "0";
        uint256 digits;
        for (uint256 t = v; t > 0; t /= 10) {
            digits++;
        }
        bytes memory buf = new bytes(digits);
        for (uint256 t = v; t > 0; t /= 10) {
            digits--;
            buf[digits] = bytes1(uint8(48 + (t % 10)));
        }
        return string(buf);
    }

    /**
     * @notice The decimal ASCII rendering of `value`, signed: a leading
     *         minus for negative values, no plus, no leading zeros
     * @dev int256.min renders correctly (its magnitude is computed
     *      unchecked)
     */
    function toString(int256 value) external pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(_magnitude(value)));
    }

    /**
     * @notice The decimal ASCII rendering of integer units at `decimals`
     *         places, trailing fractional zeros trimmed: viem's
     *         formatUnits, and parseUnitsUnsigned's inverse (1500000 at 6
     *         decimals is "1.5", 1000000 is "1")
     * @dev Zero decimals renders the integer without a decimal point.
     *      Reverts with InvalidPrecision above 77 decimals.
     */
    function formatUnits(uint256 value, uint256 decimals) public pure returns (string memory) {
        if (decimals > 77) revert InvalidPrecision(decimals);
        if (decimals == 0) return toString(value);
        uint256 scale = 10 ** decimals;
        string memory integer = toString(value / scale);
        uint256 remainder = value % scale;
        if (remainder == 0) return integer;
        bytes memory fraction = new bytes(decimals);
        for (uint256 i = decimals; i != 0;) {
            fraction[--i] = bytes1(uint8(48 + remainder % 10));
            remainder /= 10;
        }
        uint256 length = decimals;
        while (fraction[length - 1] == "0") length--;
        assembly ("memory-safe") {
            mstore(fraction, length)
        }
        return string.concat(integer, ".", string(fraction));
    }

    /**
     * @notice formatUnits for signed integer units: a leading minus for
     *         negative values, parseUnits' inverse
     * @dev int256.min renders correctly. Reverts with InvalidPrecision
     *      above 77 decimals.
     */
    function formatUnits(int256 value, uint256 decimals) external pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", formatUnits(_magnitude(value), decimals));
    }

    // ============ Encode ============

    /**
     * @notice Runtime abi.encode: assembles the canonical ABI encoding of
     *         a tuple from pre-encoded component values, nav's inverse
     * @dev `types` is the tuple's type as a parenthesized descriptor
     *      (nav's grammar, only the SHAPE is parsed). `values[i]` is the
     *      canonical single-value encoding of component i:
     *      - static component with head footprint w words: exactly w * 32
     *        bytes (one word for uint256/address/bool/bytes32, the
     *        flattened words for static tuples and fixed arrays), copied
     *        verbatim into the head;
     *      - dynamic component (bytes, string, T[], dynamic tuples): the
     *        canonical envelope [0x20][tail...], exactly what a
     *        bytes-returning call, nav's dynamic terminal, or abi.encode
     *        of the single value produces. The leading offset word is
     *        stripped, the true top-level offset written into the head,
     *        and the tail appended verbatim. Because ABI offsets are
     *        frame-relative, verbatim tail splicing is correct at any
     *        nesting depth, so nested dynamics (string[], (uint,bytes)[])
     *        need no special handling.
     *      The output is returned via a raw assembly return with NO bytes
     *      envelope, deliberately the one raw-returning function here,
     *      because the output is a calldata SEGMENT for the core's read
     *      to splice, not a value to decode (encodeBytes is the enveloped
     *      form). Nested offsets, bounds, padding and complete consumption
     *      are validated by AbiCodec. Reverts with InvalidTypeDescriptor
     *      on a malformed descriptor, ComponentCountMismatch when
     *      values.length differs from the component count,
     *      InvalidComponentLength for a static component of the wrong
     *      size, InvalidComponentEnvelope for a dynamic component that is
     *      not an envelope, and InvalidComponentValue identifying the
     *      component and byte offset of a malformed nested value.
     * @param types The tuple type descriptor, e.g. "(address,uint256[])"
     * @param values One canonical single-value encoding per component
     */
    function encode(string calldata types, bytes[] calldata values) external pure {
        bytes memory out = AbiCodec.tuple(bytes(types), values);
        assembly ("memory-safe") {
            return(add(out, 32), mload(out))
        }
    }

    /**
     * @notice encode's output inside a normal bytes envelope: a VALUE
     *         rather than a segment, for consumers that decode a single
     *         bytes argument (hash, byteLen, a Collections values array)
     * @param types The tuple type descriptor
     * @param values One canonical single-value encoding per component
     */
    function encodeBytes(string calldata types, bytes[] calldata values) external pure returns (bytes memory) {
        return AbiCodec.tuple(bytes(types), values);
    }

    // ============ Internal Numeric Helpers ============

    /**
     * @dev |value| as a uint256; total, int256.min yields 2^255
     */
    function _magnitude(int256 value) private pure returns (uint256) {
        unchecked {
            return value < 0 ? uint256(-(value + 1)) + 1 : uint256(value);
        }
    }

    /**
     * @dev The int256 with magnitude `value` and the given sign, reverting
     *      with Panic(0x11) when it does not fit (2^255 fits only negative)
     */
    function _signedMagnitude(uint256 value, bool negative) private pure returns (int256) {
        if (value > (negative ? uint256(1) << 255 : uint256(type(int256).max))) _panic(0x11);
        unchecked {
            return negative ? -int256(value) : int256(value);
        }
    }

    /**
     * @dev Reverts with the Solidity panic `code` (0x11 arithmetic
     *      overflow, 0x12 division by zero), byte-identical to the
     *      compiler's own checked-arithmetic reverts
     */
    function _panic(uint256 panicCode) private pure {
        assembly ("memory-safe") {
            mstore(0, 0x4e487b7100000000000000000000000000000000000000000000000000000000)
            mstore(4, panicCode)
            revert(0, 36)
        }
    }

    /**
     * @dev floor(a * b / denominator) over the 512-bit product
     *      [prod1 prod0], the classic Remco Bloemen construction: subtract
     *      the remainder, factor powers of two out of the denominator,
     *      then multiply by its inverse mod 2^256 (Newton doubles the
     *      correct low bits each step: 6 steps from a 4-bit seed cover
     *      all 256). Reverts with Panic(0x12) when denominator == 0 and
     *      Panic(0x11) when the result needs more than 256 bits.
     */
    function _mulDiv(uint256 a, uint256 b, uint256 denominator) private pure returns (uint256 result) {
        unchecked {
            uint256 prod0;
            uint256 prod1;
            assembly ("memory-safe") {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                // Plain division: Panic(0x12) on a zero denominator.
                return prod0 / denominator;
            }
            if (denominator <= prod1) {
                _panic(denominator == 0 ? 0x12 : 0x11);
            }
            uint256 remainder;
            assembly ("memory-safe") {
                remainder := mulmod(a, b, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = denominator & (0 - denominator);
            assembly ("memory-safe") {
                denominator := div(denominator, twos)
                prod0 := div(prod0, twos)
                // 2^256 / twos: flip the divided-out factor to the high side
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;
            uint256 inverse = (3 * denominator) ^ 2;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            result = prod0 * inverse;
        }
    }

    /**
     * @dev base ** exponent % modulus. Reverts with Panic(0x12) when the
     *      modulus is zero. Exponents below POW_MOD_PRECOMPILE_THRESHOLD
     *      run square-and-multiply over MULMOD (about 45 gas per exponent
     *      bit); larger ones go to the modexp precompile at 0x05, whose
     *      cost is flat (500 gas since EIP-7883, plus the call) and beats
     *      the loop from roughly 30 bits up. The loop is also the fallback
     *      when the precompile call fails or returns nothing, so a chain
     *      without modexp still computes the right answer, only slower.
     */
    function _powMod(uint256 base, uint256 exponent, uint256 modulus) private view returns (uint256 result) {
        result = 1 % modulus;
        base %= modulus;
        if (exponent >= POW_MOD_PRECOMPILE_THRESHOLD) {
            bool done;
            assembly ("memory-safe") {
                let p := mload(0x40)
                mstore(p, 32)
                mstore(add(p, 0x20), 32)
                mstore(add(p, 0x40), 32)
                mstore(add(p, 0x60), base)
                mstore(add(p, 0x80), exponent)
                mstore(add(p, 0xa0), modulus)
                if and(staticcall(gas(), 0x05, p, 0xc0, p, 0x20), eq(returndatasize(), 32)) {
                    result := mload(p)
                    done := 1
                }
            }
            if (done) return result;
        }
        while (exponent != 0) {
            if (exponent & 1 != 0) result = mulmod(result, base, modulus);
            exponent >>= 1;
            if (exponent != 0) base = mulmod(base, base, modulus);
        }
    }

    /**
     * @dev The inverse of `base` modulo `modulus` by the extended Euclidean
     *      algorithm with coefficients kept reduced modulo `modulus`
     *      (MULMOD keeps q * t from overflowing even for a full-word
     *      modulus). Reverts with ModularInverseDoesNotExist unless the two
     *      are coprime, and with Panic(0x12) when the modulus is zero.
     */
    function _inverseMod(uint256 base, uint256 modulus) private pure returns (uint256) {
        uint256 r = modulus;
        uint256 nextR = base % modulus;
        uint256 t;
        uint256 nextT = 1 % modulus;
        while (nextR != 0) {
            uint256 q = r / nextR;
            (r, nextR) = (nextR, r % nextR);
            uint256 product = mulmod(q, nextT, modulus);
            uint256 next = t >= product ? t - product : modulus - (product - t);
            (t, nextT) = (nextT, next);
        }
        if (r != 1) revert ModularInverseDoesNotExist(base, modulus);
        return t;
    }

    /**
     * @dev floor(log2(x)) by a binary bit scan; returns 0 for x = 0 (the
     *      public entry rejects that input)
     */
    function _log2(uint256 x) private pure returns (uint256 r) {
        unchecked {
            r = x >= 1 << 128 ? 128 : 0;
            x >>= r;
            uint256 s = x >= 1 << 64 ? 64 : 0;
            x >>= s;
            r |= s;
            s = x >= 1 << 32 ? 32 : 0;
            x >>= s;
            r |= s;
            s = x >= 1 << 16 ? 16 : 0;
            x >>= s;
            r |= s;
            s = x >= 1 << 8 ? 8 : 0;
            x >>= s;
            r |= s;
            s = x >= 1 << 4 ? 4 : 0;
            x >>= s;
            r |= s;
            s = x >= 1 << 2 ? 2 : 0;
            x >>= s;
            r |= s;
            r |= x >= 1 << 1 ? 1 : 0;
        }
    }

    // ============ Internal Bytes Helpers ============

    /**
     * @dev Clamps a signed slice index into 0 .. length (negative counts
     *      from the end; out-of-range indices clamp to the nearest bound)
     */
    function _rangeIndex(int256 index, uint256 length) private pure returns (uint256) {
        if (index < 0) return index < -int256(length) ? 0 : uint256(int256(length) + index);
        return uint256(index) > length ? length : uint256(index);
    }

    /**
     * @dev Normalizes a signed element index into 0 .. length-1, reverting
     *      with InvalidByteIndex outside -length .. length-1
     */
    function _strictIndex(int256 index, uint256 length) private pure returns (uint256) {
        if (index >= int256(length) || index < -int256(length)) revert InvalidByteIndex(index, length);
        return index < 0 ? uint256(int256(length) + index) : uint256(index);
    }

    /**
     * @dev Requires `data` to be well-formed UTF-8 per the Unicode table of
     *      valid byte sequences: lead bytes C2-F4 with the right number of
     *      continuation bytes, the second-byte ranges that exclude overlong
     *      forms, surrogates and code points past U+10FFFF. Reverts with
     *      InvalidUtf8 at the first offending byte.
     */
    function _checkUtf8(bytes calldata data) private pure {
        for (uint256 i; i < data.length;) {
            uint8 first = uint8(data[i]);
            if (first < 0x80) {
                i++;
                continue;
            }
            uint256 count;
            if (first >= 0xc2 && first <= 0xdf) count = 1;
            else if (first >= 0xe0 && first <= 0xef) count = 2;
            else if (first >= 0xf0 && first <= 0xf4) count = 3;
            else revert InvalidUtf8(i);
            if (data.length - i <= count) revert InvalidUtf8(i);
            uint8 second = uint8(data[i + 1]);
            if (
                (first == 0xe0 && second < 0xa0) || (first == 0xed && second >= 0xa0)
                    || (first == 0xf0 && second < 0x90) || (first == 0xf4 && second >= 0x90)
            ) revert InvalidUtf8(i + 1);
            for (uint256 j = 1; j <= count; j++) {
                if (uint8(data[i + j]) & 0xc0 != 0x80) revert InvalidUtf8(i + j);
            }
            i += count + 1;
        }
    }

    /**
     * @dev Number of non-overlapping occurrences of `needle` in `s`, left
     *      to right: the same scan the selection loop uses (caller
     *      guarantees a non-empty needle)
     */
    function _countOccurrences(bytes calldata s, bytes calldata needle) private pure returns (uint256 count) {
        uint256 p;
        while (p + needle.length <= s.length) {
            if (_matchesAt(s, needle, p)) {
                count++;
                p += needle.length;
            } else {
                p++;
            }
        }
    }

    /**
     * @dev Whether `needle` occurs in `s` at byte position `pos` (caller
     *      bounds-checks)
     */
    function _matchesAt(bytes calldata s, bytes calldata needle, uint256 pos) private pure returns (bool) {
        for (uint256 j = 0; j < needle.length; j++) {
            if (s[pos + j] != needle[j]) return false;
        }
        return true;
    }

    /**
     * @dev Flips the ASCII case bit of every byte in the letter range
     *      `low` .. `high`, leaving the rest untouched
     */
    function _foldCase(bytes calldata s, bytes1 low, bytes1 high) private pure returns (bytes memory out) {
        out = s;
        for (uint256 i = 0; i < out.length; i++) {
            bytes1 c = out[i];
            if (c >= low && c <= high) out[i] = c ^ 0x20;
        }
    }

    /**
     * @dev Copies `src` into `dst` starting at byte `dstOffset` (caller
     *      sizes dst)
     */
    function _copy(bytes memory dst, uint256 dstOffset, bytes calldata src) private pure {
        uint256 len = src.length;
        assembly ("memory-safe") {
            calldatacopy(add(add(dst, 32), dstOffset), src.offset, len)
        }
    }

    // ============ Internal Parse Helpers ============

    /**
     * @dev The digits s[start ..] as a checked uint256: at least one digit
     *      (EmptyNumber), all in 0-9 (InvalidDecimalDigit at the offending
     *      position). The signed entry point consumes the sign first.
     */
    function _parseDigits(bytes calldata s, uint256 start) private pure returns (uint256 result) {
        if (start == s.length) revert EmptyNumber();
        for (uint256 i = start; i < s.length; i++) {
            bytes1 c = s[i];
            if (c < "0" || c > "9") revert InvalidDecimalDigit(i, c);
            result = result * 10 + (uint8(c) - 48);
        }
    }

    /**
     * @dev The shared parseUnits engine: the magnitude scaled to
     *      `decimals` places and the sign, with the dropped fraction folded
     *      in per `rounding` (a non-zero remainder rounds away from zero
     *      for Ceil on a positive value and Floor on a negative one). With
     *      `signed` false a minus sign is an InvalidDecimalDigit.
     */
    function _parseUnits(bytes calldata value, uint256 decimals, Rounding rounding, bool signed)
        private
        pure
        returns (uint256 magnitude, bool negative)
    {
        if (decimals > 77) revert InvalidPrecision(decimals);
        if (value.length == 0) revert EmptyNumber();
        negative = value[0] == "-";
        if (negative && !signed) revert InvalidDecimalDigit(0, value[0]);
        uint256 start = negative || value[0] == "+" ? 1 : 0;
        bool point;
        bool digit;
        bool remainder;
        uint256 fractional;
        for (uint256 i = start; i < value.length; i++) {
            bytes1 c = value[i];
            if (c == "." && !point) {
                point = true;
                continue;
            }
            if (c < "0" || c > "9") revert InvalidDecimalDigit(i, c);
            digit = true;
            if (point && fractional >= decimals) {
                if (c != "0") remainder = true;
            } else {
                magnitude = magnitude * 10 + uint256(uint8(c) - 48);
                if (point) fractional++;
            }
        }
        if (!digit) revert EmptyNumber();
        magnitude *= 10 ** (decimals - fractional);
        if (remainder && ((negative && rounding == Rounding.Floor) || (!negative && rounding == Rounding.Ceil))) {
            magnitude++;
        }
    }
}

---
title: Operations
description: "The scalar computation contract: named arithmetic, comparisons, bytes, strings, parsing and an ABI encoder, spliced over live operands by the core's read."
---

`Operations` is the most used expansion pack for Assertions. It computes over values the core has already read: arithmetic, comparisons such as `!=`, bytes and strings, hashing and block fields. Every function takes and returns plain ABI types, with no ERC-8211 types anywhere: `ge(balance, 100e18)` is an ordinary call, and a decoded batch shows it by name. You meet it in a decoded batch as the target of a `read` call on the Assertions contract (the core splices live operands into Operations calldata), or as the target of a `STATIC_CALL` fetcher for argument-free reads such as `timestamp()`. Its address is on the [Deployments](/docs/contracts/deployments) page.

Plain-value computation lives here. Assertion constraints judge (revert or pass); iteration over arrays lives on [Collections](/docs/contracts/collections); and shared subterms and lazy branches live on [Expressions](/docs/contracts/expressions). The judge and the core primitives that call into this contract are on the [Assertions](/docs/contracts/assertions) page.

## Functions by task

EVML spellings are helpers of the `assert` command (see the [EVML guide](/docs/evml)); "none" means call it from Solidity or an SDK. Signed overloads exist for the names marked (u/s), see [signedness](#signedness-rides-on-overloads).

| Task | Functions | EVML |
|------|-----------|------|
| [Arithmetic](#arithmetic) | `add`, `sub`, `mul`, `div`, `mod`, `min`, `max` (u/s); `exp` (uint or int base, uint exponent); `absDiff` (u/s operands, uint256 magnitude, total) | `@calc!`, `@min!`, `@max!`, `@absDiff!` |
| [512-bit math](#512-bit-math-muldiv-the-mod-pair-powmod-and-sqrt) | `mulDiv(a, b, denominator, rounding)` (u/s, `Trunc`/`Floor`/`Ceil`); `addMod`, `mulMod` (u/s, full-width remainder); `powMod` (four overloads, modular powers and inverses); `sqrt` (floor) | `@calc!`, `@calcFloor!`, `@calcCeil!`, `@sqrt!` |
| [Fixed point](#fixed-point-rpow-expwad-lnwad-and-log2) | `rpow(x, n, base)`; `expWad(int256)`, `lnWad(int256)`; `log2` (floor, reverts on 0) | `@pow!`, `@exp!`, `@ln!`, `@log2!` |
| [Comparisons](#signed-comparisons-and-logic) | `eq`, `ne` (bit-level); `lt`, `gt`, `le`, `ge` (u/s); all return `bool` | `==` `!=` `<` `>` `<=` `>=` in `assert` and `@bool!` |
| [Bitwise](#bitmasks) | `bitAnd`, `bitOr`, `bitXor`, `shl`, `shr` (u/s), `bitSet(mask, index)` | `@bytes!(a "&" b)`, `@bool!` |
| [Environment](#environment-reads) | `balance`, `codeHash`, `timestamp`, `blockNumber`, `chainId`, `baseFee`, `prevRandao`, `coinbase`, `gasLimit`, `blobBaseFee`, `blockHash(n)`, `origin`, `gasPrice`, `blobHash(i)` | `@balance!`, `@codeHash!`, the `@block.*!`, `@tx.*!` and `@chainId!` helpers |
| [Raw calls and code](#calls-rawcall-and-code) | `rawCall(address, bytes)` (raw staticcall, the precompile reach-through); `code(address)` | `@hash!(call "sha256")` (through `rawCall`), `@codeAt!` |
| [Hashing](#hashing-the-payload-semantic) | `hash(bytes)`; `hashPairSorted(bytes32, bytes32)` (the sorted Merkle node combiner) | `@hash!`, `@crypto:merkle.verify!` |
| [Length, slice, concat](#byte-length) | `byteLen`; `slice(bytes, start, len)`; `sliceRange(bytes, int256, int256)` (clamped); `byteAt(bytes, int256)` (strict); `concat(bytes[], delimiter)` | `@bytes.len!`, `@bytes.slice!`, `@bytes.at!`, `@bytes.concat!`, `@str.concat!`, `@str.join!` |
| [Search](#search-indexof-and-contains) | `indexOf(bytes, bytes, int256 occurrence)`; `contains(bytes, bytes)`; `split(bytes, bytes)` | `@str.includes!`, `@str.split!` |
| [Strings](#strings) | `replace`; `toLower`, `toUpper` (ASCII-only); `charset(bytes, uint256)`; `stringSlice`, `stringAt` (UTF-8 aware) | `@str.replace!`, `@str.lower!`, `@str.upper!`, `@str.charset!`, `@str.slice!`, `@str.at!` |
| [Parse and format](#parse-and-format) | `parseUint`, `parseInt`; `parseUnits`, `parseUnitsUnsigned`; `toString` (u/s); `formatUnits` (u/s) | `parseUint` through a live string inside `@calc!`; `@num.parse!`; `@num.format!`; `parseInt`, `toString`: none |
| [Encode](#encode-runtime-abiencode) | `encode` (raw runtime `abi.encode`), `encodeBytes` (bytes envelope) | `@abi.encode!` (through `encodeBytes`) |

Operations has no mutable state, so every function is `pure` or `view`. The `view` ones are the environment reads, `balance`, `codeHash`, `code`, `rawCall` and `powMod` (which may call the modexp precompile).

## Signedness rides on overloads

Word operations ship in pairs: `add(uint256,uint256)` next to `add(int256,int256)`. The int256 overloads carry signed semantics (ordering, truncation, sign display in decoders). Since `int256` spans the full word, raw spliced words pass through unchanged: pick the overload, not a cast.

The overloaded names are `add`, `sub`, `mul`, `div`, `mod`, `exp`, `min`, `max`, `absDiff`, `mulDiv`, `addMod`, `mulMod`, `powMod`, `lt`, `gt`, `le`, `ge`, `shr`, `toString` and `formatUnits`. Everything else (`eq`, `ne`, `sqrt`, `rpow`, `expWad`, `lnWad`, `log2`, the other bitwise operations, the environment reads, and the calls, bytes, search, string, parse and encode families) is not overloaded and works with plain member access such as `Operations.bitAnd.selector`.

Two pairs are asymmetric. `shr`'s signed overload takes `(int256, uint256)` because the shift amount stays unsigned, and `exp`'s takes `(int256, uint256)` because the exponent does, so their selectors are `shr(int256,uint256)` and `exp(int256,uint256)`. `powMod` has four overloads: base and modulus are both `uint256` or both `int256`, and the exponent is `uint256` or `int256` independently.

### Selector constants

`abi.encodeCall` cannot disambiguate overloads, so Solidity callers pass explicit selectors for overloaded operations. The examples on these pages share this set:

```solidity
bytes4 constant ADD_U = bytes4(keccak256("add(uint256,uint256)"));
bytes4 constant MUL_U = bytes4(keccak256("mul(uint256,uint256)"));
bytes4 constant EXP_U = bytes4(keccak256("exp(uint256,uint256)"));
bytes4 constant GT_U  = bytes4(keccak256("gt(uint256,uint256)"));
bytes4 constant GE_U  = bytes4(keccak256("ge(uint256,uint256)"));
bytes4 constant GT_S  = bytes4(keccak256("gt(int256,int256)"));
bytes4 constant ABS_S = bytes4(keccak256("absDiff(int256,int256)"));
```

## The composition model

The core's `read` primitive resolves `InputParam` operand expressions and splices the resolved values into plain calldata. An Operations call IS the composed expression: `ge(token.balanceOf(treasury), 100e18)` with a live first argument is one `read` whose segments are the balance call and the literal. The judge then consumes the result through a `STATIC_CALL` fetcher pointed at the core, so the constraint sees the comparison's 0/1 word. Operands are full `InputParam`s, so they nest (an operand may be another `read`, a `pick`, a `nav` or a `cond`) and carry inline constraints that are validated as they resolve. Operations functions themselves take plain values; `read` is the one place operand expressions get resolved.

Any deployed view or pure contract extends the vocabulary through the same socket; Operations is the canonical first extension. Because a `read` names its target by address, versioning is a deployment: old deployments never break, and a new version ships at a new address as an opt-in.

The Solidity examples on these pages use the helpers `callParam`, `balanceParam`, `eq`, `gte` and `noConstraints` from the [Assertions](/docs/contracts/assertions) page, plus three small helpers for splicing:

```solidity
/** A literal word operand. */
function lit(uint256 x) pure returns (InputParam memory) {
    return InputParam(
        InputParamType.CALL_DATA,
        InputParamFetcherType.RAW_BYTES,
        abi.encode(x),
        new Constraint[](0)
    );
}

/** Core `read` calldata splicing two operands into a binary Operations call. */
function read2(address operations, bytes4 sel, InputParam memory a, InputParam memory b)
    pure returns (bytes memory)
{
    InputParam[] memory args = new InputParam[](2);
    args[0] = a;
    args[1] = b;
    return abi.encodeCall(Assertions.read, (lit(uint256(uint160(operations))), sel, args));
}

/** Same, for unary operations. */
function read1(address operations, bytes4 sel, InputParam memory a)
    pure returns (bytes memory)
{
    InputParam[] memory args = new InputParam[](1);
    args[0] = a;
    return abi.encodeCall(Assertions.read, (lit(uint256(uint160(operations))), sel, args));
}
```

"The treasury holds at least 100 whole tokens" is then one judged parameter:

```evml
assert $token::!{balanceOf(address)(uint256) $treasury} >= 100e18
```

```solidity
bytes memory holds = read2(operations, GE_U,
    callParam(token, abi.encodeCall(IERC20.balanceOf, (treasury)), noConstraints()),
    lit(100e18)
);
assertions.assertParam(callParam(address(assertions), holds, eq(bytes32(uint256(1)))));
```

(The EVML form above compiles to a direct `GTE` constraint; a comparison between two live values, or `!=`, compiles to the read-spliced `ge`/`ne` form shown in Solidity.)

## Math

These are the Operations functions that work on 32-byte words. They are `pure` except for the environment reads and `powMod`. Live operands reach them through the core's `read` splicing, described on the [Operations overview](#the-composition-model). The Solidity examples below use `lit`, `read1`, `read2` and the selector constants defined there, and the `callParam`, `balanceParam`, `eq`, `gte` and `noConstraints` helpers from the [Assertions](/docs/contracts/assertions) page. Bytes, strings and parsing are on [the other page](#bytes).

Comparisons return `bool`, which splices onward as a 0/1 word: it feeds straight into boolean composition (`bitAnd`, `bitOr`, `bitXor` on 0/1 words) and into an `EQ 1` constraint.

### Arithmetic

```solidity
function add(uint256 a, uint256 b) external pure returns (uint256);   // int256 overload too
function sub(uint256 a, uint256 b) external pure returns (uint256);   // int256 overload too
function mul(uint256 a, uint256 b) external pure returns (uint256);   // int256 overload too
function div(uint256 a, uint256 b) external pure returns (uint256);   // int256 overload too
function mod(uint256 a, uint256 b) external pure returns (uint256);   // int256 overload too
function exp(uint256 a, uint256 b) external pure returns (uint256);   // exp(int256, uint256) too
function min(uint256 a, uint256 b) external pure returns (uint256);   // int256 overload too
function max(uint256 a, uint256 b) external pure returns (uint256);   // int256 overload too
function absDiff(uint256 a, uint256 b) external pure returns (uint256); // absDiff(int256, int256) too
```

"`addr1`'s ETH balance plus its WETH balance is positive":

```evml
assert @calc!(@balance!(ETH $addr1) + $weth::!{balanceOf(address)(uint256) $addr1}) > 0
```

```solidity
bytes memory sum = read2(operations, ADD_U,
    balanceParam(address(0), addr1, noConstraints()),   // native balance operand
    callParam(weth, abi.encodeCall(IERC20.balanceOf, (addr1)), noConstraints())
);
assertions.assertParam(callParam(address(assertions), sum, gte(1)));
```

Rules:

- **Checked.** Overflow and underflow revert with `Panic(0x11)`, division and modulo by zero with `Panic(0x12)`.
- **Signed division and remainder.** `div(int256,int256)` truncates toward zero (`-42 / 5 == -8`), `mod` takes the sign of the dividend (`-42 % 5 == -2`), and `type(int256).min / -1` reverts with `Panic(0x11)`.
- **`exp`.** Checked `**`: overflow reverts with `Panic(0x11)`, and `0 ** 0 == 1`. The signed overload uses binary exponentiation with checked multiplies, so any intermediate that leaves `int256` reverts. The exponent is always unsigned, so `exp` is overloaded and takes an explicit selector (`EXP_U`).
- **`absDiff`.** Returns the magnitude `|a - b|` as a `uint256` and is total: no underflow, and no overflow revert on wide spans, in both overloads. The signed overload handles operands that cross zero, and even the span from `int256.min` to `int256.max` yields its exact distance. Judged `LTE d`, it is live-vs-live approximate equality; the signed overload keeps the constraint unsigned, so signed tolerance is also `absDiff(int256,int256)` judged `LTE`.
- **`min`, `max`.** Plain ordering, unsigned or signed.

Scaling a threshold by a live `decimals()` is the canonical use of `exp`. "`a` holds at least 5 whole tokens":

```evml
assert $token::!{balanceOf(address)(uint256) $a} >= @calc!(5 * 10 ^ $token::!{decimals()(uint8)})
```

```solidity
bytes memory scale = read2(operations, EXP_U,                        // 10 ** decimals()
    lit(10),
    callParam(token, abi.encodeCall(IERC20.decimals, ()), noConstraints())
);
bytes memory threshold = read2(operations, MUL_U,                    // 5 * 10 ** decimals()
    lit(5),
    callParam(address(assertions), scale, noConstraints())
);
bytes memory holds = read2(operations, GE_U,
    callParam(token, abi.encodeCall(IERC20.balanceOf, (a)), noConstraints()),
    callParam(address(assertions), threshold, noConstraints())
);
assertions.assertParam(callParam(address(assertions), holds, eq(bytes32(uint256(1)))));
```

### 512-bit math: mulDiv, the mod pair, powMod and sqrt

```solidity
enum Rounding { Trunc, Floor, Ceil }   // ABI uint8: 0, 1, 2
function mulDiv(uint256 a, uint256 b, uint256 denominator, Rounding rounding) external pure returns (uint256);
function mulDiv(int256 a, int256 b, int256 denominator, Rounding rounding) external pure returns (int256);
function addMod(uint256 a, uint256 b, uint256 m) external pure returns (uint256);   // int256 overload too
function mulMod(uint256 a, uint256 b, uint256 m) external pure returns (uint256);   // int256 overload too
function powMod(uint256 a, uint256 exponent, uint256 m) external view returns (uint256); // four overloads
function sqrt(uint256 x) external pure returns (uint256);
```

**`mulDiv`** takes a full 512-bit intermediate product and rounds the quotient once. `Trunc` (0) rounds toward zero, `Floor` (1) toward negative infinity and `Ceil` (2) toward positive infinity; for non-negative results, truncation and floor coincide. Signed operands may include negative denominators and `int256.min`. A zero denominator reverts with `Panic(0x12)`; a rounded result that does not fit reverts with `Panic(0x11)`. For rounded division alone, use `mulDiv(a, 1, b, rounding)`.

In EVML, inside `@calc!` an unsigned `a * b // c` fuses into one `mulDiv(a, b, c, Trunc)`, so the intermediate product never overflows and the result is exactly what `div(mul(a, b), c)` would have been; a rational factor such as `* 2 // 3` lowers the same way. `@calc!` does not fuse signed products. The rounded forms are `@calcFloor!` and `@calcCeil!`, which emit `Floor` and `Ceil` (signed or unsigned operands):

```evml
assert @calc!($pool::!{reserve0()(uint256)} * $price::!{rate()(uint256)} // 1e18) >= 1e18
assert @calcCeil!($vault::!{totalAssets()(uint256)} * $shares / $vault::!{totalSupply()(uint256)}) <= $cap
```

**`addMod` and `mulMod`** take a full-width sum or product before the remainder (EVM `ADDMOD` and `MULMOD` for the unsigned overloads). The signed remainder follows the sign of the mathematical sum or product, independent of the modulus's sign, and `int256.min` is supported in every operand. Modulo by zero reverts with `Panic(0x12)`. In EVML they are `(a + b) % m` and `(a * b) % m` inside `@calc!`; only the operation immediately before `%` is fused, and `%` binds more tightly than `+`, so parenthesise a sum:

```evml
assert @calc!(($a::!{x()(uint256)} + $b::!{y()(uint256)}) % $m::!{z()(uint256)}) == 0
```

**`powMod(a, exponent, m)`** computes `a ** exponent % m` without materializing the power, in four overloads: base and modulus are both `uint256` or both `int256`, and the exponent is `uint256` or `int256` independently.

- A negative exponent raises the modular inverse of the base, and reverts with `ModularInverseDoesNotExist(baseMagnitude, modulusMagnitude)` when the magnitudes are not coprime.
- Odd exponents preserve a negative base's sign (in either direction); the modulus's sign is ignored.
- A zero modulus reverts with `Panic(0x12)`, a modulus of magnitude 1 returns 0, and an exponent of zero returns `1 % m` (so `0 ** 0` is 1 for any modulus above 1).
- Exponents of 2^32 or more are delegated to the modexp precompile (`0x05`); smaller ones run a `MULMOD` loop. This is a fixed routing policy, not a measured gas crossover. The loop is also the fallback when the precompile call fails or returns anything but exactly 32 bytes, so a chain without modexp computes the right answer, only slower. (The contract does not use OpenZeppelin's `Math.modExp`, which trusts a successful call without checking the return size.)

In EVML, a power immediately followed by `%` is the modular form, and a negative exponent uses the inverse (`3 ^ -1 % 11` is `4`):

```evml
assert @calc!($a::!{x()(uint256)} ^ $e::!{y()(uint256)} % $m::!{z()(uint256)}) == 1
```

**`sqrt(x)`** is the floor square root, the AMM invariant form. A bare product still reverts past 2^256 (checked `mul`), so scale wide reserves down through `mulDiv` first; in `@calc!`, writing the division right after the product does that automatically.

```evml
load math

assert @sqrt!($pool::!{reserve0()(uint256)} * $pool::!{reserve1()(uint256)}) >= $minLiquidity
```

### Fixed point: rpow, expWad, lnWad and log2

```solidity
function rpow(uint256 x, uint256 n, uint256 base) external pure returns (uint256);
function expWad(int256 x) external pure returns (int256);
function lnWad(int256 x) external pure returns (int256);
function log2(uint256 x) external pure returns (uint256);
```

**`rpow(x, n, base)`** is the compounding primitive: a scaled power where `base` is one unit (1e27 for a ray, 1e18 for a wad). An APY from a per-second rate is `rpow(1e27 + ratePerSecond, 31536000, 1e27)`. It uses binary exponentiation with the scale divided out after every multiply, so the intermediate never leaves fixed point.

- A scaled intermediate that does not fit `uint256` reverts with `Panic(0x11)`; a zero `base` reverts with `Panic(0x12)`, the scale being the divisor. `rpow(0, 0, base)` is one unit, matching `0 ** 0 == 1`.
- It rounds down at each step, so the result can be lower than a single final rounding of `base * (x / base)^n`, and earlier rounding errors are amplified by later squarings: there is no general `2 * log2(n)` bound on the final error in units of the output. For example, `rpow(19, 16, 10)` returns `276889`, while rounding the exact rational power once gives `288441`. Choose the scale and assertion tolerance for the input range and exponent; wad or ray precision does not establish a universal absolute error bound.
- It earns its slot because the composed form is exponential in calldata: the NatSpec puts it at about 33 million copies for the exponent 31536000 (a source comment, not a measurement recorded in a test).

```evml
load math

assert @pow!(@calc!(1e27 + $pool::!{ratePerSecond()(uint256)}) 31536000 1e27) < 2e27
```

`@pow!(value exponent base?)` compiles to `rpow` with unsigned operands; `base` defaults to 1e18.

**`expWad(x)`** is e^x and **`lnWad(x)`** the natural logarithm, both in wad (1e18) fixed point over `int256`. `expWad` returns 0 at or below -42139678854452767551 (where the result underflows a wad) and reverts with `Panic(0x11)` at or above 135305999368893231589 (where it leaves `int256`). `lnWad` reverts with `LogarithmUndefined(x)` for `x <= 0`. Both use Remco Bloemen's rational approximation; the source proof covers the quantized finite-word calculation, and global real-function accuracy, monotonicity and inverse-error bounds are not established.

**`log2(x)`** is the floor binary logarithm: the position of the highest set bit, the bit length minus one. It reverts with `LogarithmUndefined(0)` at 0. Its composed form is eight nested `cond`s that each duplicate their operand's calldata, which is why it has a slot.

```evml
load math

assert @exp!($rates::!{continuousRate()(int256)}) > 1e18
assert @ln!($rates::!{growthFactor()(int256)}) > 0
assert @log2!($pool::!{totalSupply()(uint256)}) >= 40
```

`@exp!` and `@ln!` carry the wad scale in their result so that surrounding arithmetic aligns to it. Neither the modular family nor `powMod` has a dedicated helper; they are reached through `@calc!` as shown above.

## Logic

### Signed comparisons and logic

```solidity
function eq(uint256 a, uint256 b) external pure returns (bool);
function ne(uint256 a, uint256 b) external pure returns (bool);
function lt(uint256 a, uint256 b) external pure returns (bool);   // int256 overload too
function gt(uint256 a, uint256 b) external pure returns (bool);   // int256 overload too
function le(uint256 a, uint256 b) external pure returns (bool);   // int256 overload too
function ge(uint256 a, uint256 b) external pure returns (bool);   // int256 overload too
```

`eq` and `ne` compare at the bit level, which covers every word type (uint, int, address, bool, bytes32) at once. `lt`, `gt`, `le` and `ge` have unsigned and signed overloads.

Signed ERC-8211 constraints can compare a word directly with a constant. The int256 overloads also support strict and live-vs-live comparisons, and remain the SDK's lowering for signed predicates. "The rate is above -10" (an unsigned comparison would read -10 as astronomically large):

```evml
assert $oracle::!{rate()(int256)} > -10
```

```solidity
bytes memory aboveFloor = read2(operations, GT_S,
    callParam(oracle, abi.encodeCall(IOracle.rate, ()), noConstraints()),
    lit(uint256(int256(-10)))   // the raw two's-complement word
);
assertions.assertParam(callParam(address(assertions), aboveFloor, eq(bytes32(uint256(1)))));
```

**Logic.** An inline `OR` constraint combines alternative checks on the same resolved word against encoded references. To combine predicates over different live values, comparisons return their outcomes as 0/1 words, and `bitAnd`, `bitOr` and `bitXor` combine those outcomes (on 0/1 words the bitwise and logical operations coincide). Nested expressions become operands by pointing a `STATIC_CALL` at the core. "`addr1` has ETH or holds more than 10 tokens":

```evml
assert @bool!((@balance!(ETH $addr1) > 0) or ($token::!{balanceOf(address)(uint256) $addr1} > 10))
```

```solidity
bytes memory hasEth = read2(operations, GT_U,
    balanceParam(address(0), addr1, noConstraints()),
    lit(0)
);
bytes memory hasTokens = read2(operations, GT_U,
    callParam(token, abi.encodeCall(IERC20.balanceOf, (addr1)), noConstraints()),
    lit(10)
);
bytes memory either = read2(operations, Operations.bitOr.selector,
    callParam(address(assertions), hasEth, noConstraints()),
    callParam(address(assertions), hasTokens, noConstraints())
);
assertions.assertParam(callParam(address(assertions), either, eq(bytes32(uint256(1)))));
```

Boolean negation is `eq(x, 0)`; the bitwise complement is `bitXor(x, type(uint256).max)`.

Nesting is unlimited: an operand can be a `pick`, another `read`, a comparison feeding a `bitOr`, and so on. `(pool.token().decimals() + x.value() == 60) && !protocol.paused()` is one judged parameter. Operands also carry their own constraints, validated as they resolve: a `GTE` on the balance operand inside a larger expression asserts it and uses it in one call.

**Conditional select.** The core's `cond` branches lazily on any 0/1 word a comparison produces and never resolves the losing branch. Prefer it to the arithmetic trick `c * a + (1 - c) * b`, which evaluates both.

### Bitmasks

```solidity
function bitAnd(uint256 a, uint256 b) external pure returns (uint256);
function bitOr(uint256 a, uint256 b) external pure returns (uint256);
function bitXor(uint256 a, uint256 b) external pure returns (uint256);
function shl(uint256 a, uint256 bits) external pure returns (uint256);
function shr(uint256 a, uint256 bits) external pure returns (uint256);   // shr(int256, uint256) too
function bitSet(uint256 mask, uint256 index) external pure returns (bool);
```

For `shl` and `shr` the second operand is the shift amount; shifts of 256 or more yield 0 (EVM semantics, no revert). The signed `shr(int256, uint256)` is the arithmetic shift (EVM `SAR`): the sign fills in from the left, rounding toward negative infinity, and shifts of 256 or more yield 0 for non-negative values and -1 for negative ones.

Flag checks on a packed config word use a literal operand as the mask. "`config & MASK != 0`" is a `bitAnd` judged `GTE 1`:

```evml
assert @bytes!($config::!{packedConfig()(uint256)} "&" 65280) != 0
assert @bytes!($reg::!{packedPool()(uint256)} ">>" 96) <= 3000
```

```solidity
bytes memory masked = read2(operations, Operations.bitAnd.selector,
    callParam(configSource, abi.encodeCall(IConfig.packedConfig, ()), noConstraints()),
    lit(MASK)
);
assertions.assertParam(callParam(address(assertions), masked, gte(1)));
```

In EVML, bitwise expressions are `@bytes!(a "&" b)` (also `"|"`, `"xor"`, `"<<"`, `">>"`, the operator quoted); `@lang:bytes.not!(x)` is the complement, and the single-argument `@bytes!(x)` is the raw-word cast. `>>` on a signed value picks the arithmetic-shift overload automatically.

**`bitSet(mask, index)`** returns whether bit `index` of `mask` is set (indices past 255 are never set). "Bit `N` of the config is set" is `bitSet(config, N)` judged `EQ 1`, with no shift composition. It is also the character-class lambda for the byte folds on [Collections](/docs/contracts/collections), since with a charset bitmap as the mask, `bitSet(mask, byteValue)` is a one-call fold lambda.

**Sign extension** is a two-operation recipe over the shift pair: a narrow two's-complement field sliced out of packed bytes re-widens as `shr(int256(shl(x, 256 - bits)), 256 - bits)`, using the signed `shr` overload so the sign propagates.

## Environment reads

```solidity
function balance(address account) external view returns (uint256);
function codeHash(address account) external view returns (bytes32);
function timestamp() external view returns (uint256);
function blockNumber() external view returns (uint256);
function chainId() external view returns (uint256);
function baseFee() external view returns (uint256);
function prevRandao() external view returns (uint256);
function coinbase() external view returns (address);
function gasLimit() external view returns (uint256);
function blobBaseFee() external view returns (uint256);
function blockHash(uint256 n) external view returns (bytes32);
function origin() external view returns (address);
function gasPrice() external view returns (uint256);
function blobHash(uint256 index) external view returns (bytes32);
```

The environment functions turn non-call quantities into ordinary staticcalls. For argument-free reads no splicing is involved: the fetcher targets Operations directly.

```evml
load receipts

assert @block.timestamp! > 1780000000 "unlock time not reached"
assert @chainId! == 1 "wrong chain"
```

```solidity
// block timestamp past the unlock time
assertions.assertParam(
    callParam(address(operations), abi.encodeCall(Operations.timestamp, ()), gte(unlockTime + 1))
);
// on mainnet
assertions.assertParam(
    callParam(address(operations), abi.encodeCall(Operations.chainId, ()), eq(bytes32(uint256(1))))
);
```

- `baseFee()` and `blobBaseFee()` gate a batch on fee conditions ("only execute while basefee <= X").
- `prevRandao()`, `coinbase()` and `gasLimit()` read the block header.
- `blockHash(n)` follows `BLOCKHASH` semantics: 0 for the current block, the future, and blocks older than 256.
- `origin()` reads the transaction origin, so an assertion can gate on who is executing the batch it guards.
- `gasPrice()` bounds what the batch is willing to pay ("only execute while gas <= X wei").
- `blobHash(index)` reads the versioned hash of a blob carried by the executing transaction (0 when the index is out of range), so a batch can assert it ships with the blobs it was built for. `ne(blobHash(0), 0)` asserts that a blob is present at all.

In EVML each is a bang helper in the `receipts` module (`load receipts`). The `@block.*` family also has plain off-chain faces addressed by block number or tag, such as `@block.baseFee(block? chain?)`, which read sealed headers at build time.

| Helper | Operations function | Description |
|--------|---------------------|-------------|
| `@block.number!` | `blockNumber()` | The block number at assertion time (plain `@block.number(block? chain?)` reads a sealed block off-chain, default latest) |
| `@block.timestamp!` | `timestamp()` | The block timestamp at assertion time (plain `@block.timestamp(block? chain?)` reads a sealed block off-chain, default latest) |
| `@block.baseFee!` / `@block.blobBaseFee!` | `baseFee()` / `blobBaseFee()` | The block base fee / blob base fee in wei at assertion time (the plain blob-fee face with no block argument reads the live `eth_blobBaseFee` value) |
| `@block.hash!(n)` | `blockHash(n)` | The hash of block `n` (0 outside the last 256 blocks); the number composes live, e.g. `@block.hash!(@block.number! - 1)`; plain `@block.hash(block? chain?)` reads any sealed block off-chain, unbounded by the 256-block window |
| `@block.coinbase!` | `coinbase()` | The block proposer fee recipient at assertion time |
| `@block.gasLimit!` | `gasLimit()` | The block gas limit at assertion time |
| `@block.prevrandao!` | `prevRandao()` | The previous RANDAO mix at assertion time (the plain face reads a sealed block's mixHash; pre-merge blocks carry difficulty semantics there) |
| `@chainId!` | `chainId()` | The chain id, read on-chain at assertion time |
| `@tx.from!` | `origin()` | The sender (origin) of the executing transaction; a different identity from `@sender` and `@me` (plain `@tx.from(hash chain?)` reads sealed data off-chain) |
| `@tx.gasPrice!` | `gasPrice()` | The gas price of the executing transaction in wei |
| `@tx.blobHash!(i)` | `blobHash(i)` | The versioned hash of blob `i` carried by the executing transaction (0 when out of range) |
| `@balance!(ETH addr)` | `balance(addr)` | Native balance of an address (an ERC-20 token symbol or address makes it a `balanceOf` read instead) |
| `@codeHash!(addr)` | `codeHash(addr)` | Live `EXTCODEHASH`; the argument may be a `::!` call that resolves to an address |

**`balance(account)`** reads the native balance and **`codeHash(account)`** the `EXTCODEHASH` (`bytes32(0)` for a nonexistent account, `keccak256("")` for an existing code-less one). The core's `BALANCE` fetcher already covers native and ERC-20 balances of known addresses without any Operations call; these two earn their keep when the address is computed, such as the balance of `registry.treasury()`, or "the proxy's current implementation is the audited contract":

```evml
load contracts

assert @codeHash!($proxy::!{implementation()(address)}) == $auditedCodeHash
```

```solidity
bytes memory implHash = read1(operations, Operations.codeHash.selector,
    callParam(proxy, abi.encodeCall(IProxy.implementation, ()), noConstraints())
);
assertions.assertParam(callParam(address(assertions), implHash, eq(auditedCodeHash)));
```

## Bytes

These are the Operations functions that work on `bytes` and `string` values. Live data reaches them through the core's `read` splicing, described on the [Operations overview](#the-composition-model). The Solidity examples use `lit`, `read1` and `read2` from there and `callParam`, `eq` and `noConstraints` from the [Assertions](/docs/contracts/assertions) page. Arithmetic, comparisons and the environment reads are on [the math page](#math).

The fact that makes the splicing work: a resolved dynamic operand (a string or bytes return, a `nav` dynamic terminal, a `chain` result) arrives as the canonical single-value envelope `[0x20][length][payload]`, which is byte-for-byte the ABI encoding of one `bytes` argument. So for the single-argument functions (`hash`, `byteLen`, `toLower`, `toUpper`) the envelope splices directly after the selector, and the function sees the decoded payload.

```solidity
function rawCall    (address target, bytes data) external view returns (bytes);
function code       (address account) external view returns (bytes);
function concat     (bytes[] parts, bytes delimiter) external pure returns (bytes);
function slice      (bytes data, uint256 start, uint256 len) external pure returns (bytes);
function sliceRange (bytes data, int256 start, int256 end) external pure returns (bytes);
function byteAt     (bytes data, int256 index) external pure returns (bytes);
function byteLen    (bytes data) external pure returns (uint256);
function hash       (bytes data) external pure returns (bytes32);
function hashPairSorted(bytes32 a, bytes32 b) external pure returns (bytes32);
function indexOf    (bytes s, bytes needle, int256 occurrence) external pure returns (uint256);
function contains   (bytes s, bytes needle) external pure returns (bool);
function split      (bytes s, bytes delimiter) external pure returns (bytes[]);
function replace    (bytes s, bytes needle, bytes repl) external pure returns (bytes);
function toLower    (bytes s) external pure returns (bytes);
function toUpper    (bytes s) external pure returns (bytes);
function charset    (bytes s, uint256 mask) external pure returns (bool);
function stringSlice(bytes s, int256 start, int256 end) external pure returns (bytes);
function stringAt   (bytes s, int256 index) external pure returns (bytes);
function parseUint  (bytes s) external pure returns (uint256);
function parseInt   (bytes s) external pure returns (int256);
function toString   (uint256 v) public pure returns (string);               // int256 overload too
function parseUnits (bytes s, uint256 decimals, Rounding r) external pure returns (int256);
function parseUnitsUnsigned(bytes s, uint256 decimals, Rounding r) external pure returns (uint256);
function formatUnits(uint256 v, uint256 decimals) public pure returns (string); // int256 overload too
function encode     (string types, bytes[] values) external pure;           // raw return
function encodeBytes(string types, bytes[] values) external pure returns (bytes);
```

### Calls: rawCall and code

`rawCall(target, data)` executes a staticcall with raw calldata and returns the returndata as a bytes value: the precompile reach-through. Unlike the core's constructed calls, no selector is prepended and no code-length check is performed, because precompiles (sha256 at `0x02`, ecrecover at `0x01`, modexp at `0x05`, ...) have no code and raw calldata is their entire input.

- **Code-less targets.** A staticcall to a code-less non-precompile address succeeds with empty returndata, so pin the result with `byteLen` or a constraint when that matters.
- **Failure.** Gas exhaustion and an exact `SubcallOutOfGas()` signal propagate unchanged (a near-exhausting ordinary revert can also be refused as exhaustion). Other reverts wrap as `RawCallFailed(target, data)`, carrying the calldata; the target's own reason is lost. The core's `revertData` and Expressions' `ProbeCall` are the reason-carrying probes.
- **Envelope wrapper.** Because the returndata comes back as a bytes value, `rawCall` bridges any call's raw return, whatever its shape or runtime length, into every bytes-consuming operation. The [whole-returndata recipe](#whole-returndata-hash-over-rawcall) builds on this.

In EVML there is no direct `rawCall` helper; `@hash!(call "sha256")` routes its digest through a `rawCall` to the SHA-256 precompile.

`code(account)` returns the full runtime code of an account as a bytes value: `codeHash`'s sibling for prefix, suffix and segment assertions (slice out the ERC-1167 target of a minimal proxy, pin a code segment). A code-less account yields empty bytes. EVML's `@codeAt!` compiles to it, and sees code a batch deployed in an earlier step.

```evml
load lang
load contracts

assert @bytes.len!(@codeAt!($target)) > 0 "not a contract"
```

### Hashing: the payload semantic

`hash(data)` returns `keccak256` of its `bytes` argument, so an `EQ` constraint can pin complex or hard-to-decode values against a precomputed hash (keccak is an opcode, not a precompile, so it has to be a function here). Through `read` splicing, a string operand's resolved envelope IS `hash`'s calldata encoding, so the digest covers the decoded payload: pinning a `name()` return compares against `keccak256("Curve LP Token")`, the string itself.

```evml
assert @hash!($pool::!{name()(string)}) == @hash("Curve LP Token")
```

```solidity
bytes memory nameHash = read1(operations, Operations.hash.selector,
    callParam(pool, abi.encodeCall(IPool.name, ()), noConstraints())
);
assertions.assertParam(
    callParam(address(assertions), nameHash, eq(keccak256("Curve LP Token")))
);
```

**The envelope framing holds for `string` and `bytes` returns only.** An array return also arrives as an envelope, so the splice compiles and executes, but its length word counts elements, not bytes: `hash` over a spliced `address[3]` return digests the first 3 bytes of a 96-byte payload and returns a plausible word for a value nobody computed. Never splice an array return directly into `hash` (or `byteLen`, which would report the element count as a byte length). Use the whole-returndata form below, or extract a field with the core's `pick` or `nav` and compare words directly. The EVML helpers `@hash!` and `@bytes.len!` refuse non-string, non-bytes operands for this reason; use `@len!` for an array's element count.

#### Whole returndata: hash over rawCall

For everything the envelope framing does not cover (multi-value returns, structs with dynamic members, array returns, revert payloads, empty returndata), `rawCall` returns the target call's raw returndata as a bytes value at its true byte length. Composing `hash` over it pins a call's entire return with a standard `EQ` constraint:

```text
hash(rawCall(target, callData))        keccak256 of the whole returndata
hash(rawCall(core, resolveCalldata))   keccak256 of any resolved operand
```

The second form routes through the core's `resolve`, so constraint-guarded operands, `BALANCE` fetchers and nested core expressions are all reachable. Snapshot equality falls out: "the signer set and owner have not changed" is one hash judged `EQ` against the precomputed value, with no per-element navigation and no build-time length knowledge. Empty returndata works too: a call returning nothing hashes as `keccak256("")`, which is the one way to assert emptiness (a direct constraint on an empty value has no word to judge).

Two care points: the digest covers the raw bytes, envelope words included, so precompute the expected hash from the full ABI encoding rather than the payload alone; and `rawCall`'s code-less caveat carries over, so pair it with `codeHash` when "returned nothing" must not be satisfied by "was nothing". When you need the conventional digest of a single string or bytes value (stored name hashes, Merkle leaves), keep the direct splice above.

#### hashPairSorted

`hashPairSorted(a, b)` hashes the ascending-sorted pair of two words, byte-identical to OpenZeppelin MerkleProof's node combiner. A `foldWords` over a proof payload with `hashPairSorted` as the lambda and the leaf as the initial accumulator reproduces the root; the crypto module's `@crypto:merkle.verify!` compiles exactly this fold. Order-preserving pair hashing needs no dedicated function: it composes as `hash` over `concat`.

### Byte length

`byteLen(data)` is the raw byte length of its argument. Spliced over a string or bytes return it measures the decoded payload (`"Curve LP Token"` measures 14), matching `nav`'s `LEN` sentinel for those types; the empty string measures 0. Composed over `rawCall`, `byteLen(rawCall(target, callData))` measures a call's raw returndata length, whatever its shape. EVML: `@bytes.len!` and `@str.len!`.

```evml
load lang

assert @bytes.len!($pool::!{name()(string)}) == 14
```

### Slice, ranges and concat

`slice(data, start, len)` returns `data[start .. start + len)`, reverting with `SliceOutOfBounds(start, len, dataLength)` when the range leaves the data (zero-length slices at any in-range position are fine).

`sliceRange(data, start, end)` is the clamped signed form, with JavaScript `Array.slice` semantics. `start` and `end` are byte positions counted from the start, or from the end when negative (`-1` is the last byte), each clamped into `[0, length]`, with `end` exclusive; a reversed or empty range returns empty bytes. It never reverts.

`byteAt(data, index)` returns the single byte at a signed index as a one-byte bytes value, and is strict instead: an index outside `-length .. length-1` reverts with `InvalidByteIndex(index, length)`.

In EVML, `@bytes.slice!` and `@bytes.at!` compile to `sliceRange` and `byteAt`:

```evml
load lang

assert @bytes.slice!($oracle::!{blob()(bytes)} 0 4) == 0x12345678
assert @bytes.at!($oracle::!{blob()(bytes)} -1) == 0x12
```

`concat(parts, delimiter)` concatenates the parts in order with the delimiter between consecutive elements. It returns a normal bytes value, the canonical form every consumer of a single bytes argument expects, including `encode`'s `values[]`. It allocates once, preserves empty elements, and an empty `parts` array yields empty bytes. Pass empty bytes as the delimiter for plain concatenation (what `@str.concat!`, `@concat!` and `@bytes.concat!` do); a constant delimiter turns it into a join (`@str.join!`).

### Search: indexOf and contains

`indexOf(s, needle, occurrence)` returns the position of the occurrence-th occurrence of `needle` in `s`, counted from either end:

- `occurrence >= 0`: the (occurrence+1)-th match from the start (0 is the first, 1 the second, ...).
- `occurrence < 0`: counted from the end (-1 is the last, -2 the second-last, ...).

Occurrences are enumerated left to right and non-overlapping: after a match the scan resumes past it, so in `"aaaa"` the needle `"aa"` occurs at 0 and 2. That is delimiter semantics, and it makes occurrence counting and splitting agree. Requesting an occurrence that does not exist returns the sentinel `s.length` in both directions. The function is total by design: an empty needle vacuously matches at every position `0 .. s.length`, out-of-range ordinals return the sentinel, and nothing reverts (execution still needs enough gas). For an empty needle the final valid match shares the sentinel position, so use `contains` there. On `"Curve LP Token"` (length 14, spaces at 5 and 8):

```solidity
indexOf(name, "LP", 0)    // 6
indexOf(name, " ", 0)     // 5   (first space)
indexOf(name, " ", 1)     // 8   (second space)
indexOf(name, "xyz", 0)   // 14  (sentinel: not found)
indexOf(name, " ", -1)    // 8   (last space)
indexOf(name, " ", -2)    // 5   (second-to-last space)
```

`contains(s, needle)` is the boolean form of the same question, one call with the loop inside: true when `needle` occurs anywhere in `s`, and an empty needle always matches, including in an empty `s`. It is total. EVML's `@str.includes!` compiles to it:

```evml
load lang

assert @str.includes!($pool::!{name()(string)} "LP") == true
```

The sentinel also composes. **Includes** is `lt(indexOf(s, part, 0), byteLen(s))` judged `EQ 1` (for a nonempty needle), and its negation asserts absence.

**Split segments** are two `indexOf` reads and a `slice`. For a nonempty delimiter `d` with `m` matches, segment `j` in `0 .. m` starts at 0 when `j == 0`, otherwise at `indexOf(s, d, j-1) + dlen`; it ends at `indexOf(s, d, j)` when `j < m`, otherwise at `byteLen(s)` (which is exactly what the not-found sentinel returns for the missing next boundary). Negative segment indices normalise against `m + 1` first. The first and last segments work when no delimiter occurs. So "the name ends with LP" needs no composition-time segment counting. Version-string checks work the same way: split `"2.1.0"` by `"."` and pin segment 0, or parse a segment to compare it numerically.

Anchored checks compose from `slice` and `hash`: "starts with Curve" is `eq(hash(slice(name, 0, 5)), keccak256("Curve"))`, and "ends with" anchors the slice at `byteLen(s) - n`.

**`split(s, delimiter)`** returns every segment as a `bytes[]`, including empty leading, trailing and consecutive segments. Matches are non-overlapping, so there are always `count + 1` segments, no delimiter yields the data as its single segment, and an empty delimiter reverts with `EmptyNeedle`. When a single segment is all that is needed, the `indexOf`/`slice` pair is cheaper. EVML's `@str.split!` returns the whole array without an index and selects one segment with one (negative indexes count from the end, `-1` is the last):

```evml
load lang

assert @str.split!($pool::!{name()(string)} " " -1) == "Token"
```

## Strings

**`replace(s, needle, repl)`** returns `s` with every occurrence of `needle` replaced by `repl`. The scan is non-overlapping and left to right, the same enumeration `indexOf` uses (in `"aaaa"` the needle `"aa"` is replaced at positions 0 and 2). An empty `repl` deletes; an empty needle reverts with `EmptyNeedle`. EVML: `@str.replace!`.

```evml
load lang

assert @str.replace!($pool::!{name()(string)} "LP" "Pool") == "Curve Pool Token"
```

**`toLower(s)` and `toUpper(s)`** fold ASCII letters and pass every other byte through verbatim. Multi-byte UTF-8 units have the high bit set, so they are untouched: the folds are ASCII-only and UTF-8 safe. A case-insensitive comparison is a two-node recipe: fold both sides, then `eq` on their hashes. EVML: `@str.lower!` and `@str.upper!`.

**`charset(s, mask)`** returns true when every byte of `s` is a member of the 256-bit character class `mask` (bit `i` set means byte value `i` is allowed). It is the native single-call form of the `foldBytes(bitSet, All)` recipe on [Collections](/docs/contracts/collections). The empty string is vacuously in every set, and the check is byte-level, so multi-byte UTF-8 characters fail any ASCII-only class. EVML's `@str.charset!` builds the mask from a class spec at composition time:

```evml
load lang

assert @str.charset!($registry::!{label()(string)} "a-z0-9-")
```

**`stringSlice(s, start, end)` and `stringAt(s, index)`** are the UTF-8-aware siblings of `sliceRange` and `byteAt`. Both validate the whole input as UTF-8 first and revert with `InvalidUtf8(position)` at the first malformed byte (lead bytes C2 to F4 with the right continuation bytes; overlong forms, surrogates and code points past U+10FFFF are rejected).

- `stringSlice` takes the same clamped signed byte range as `sliceRange`, and additionally rejects a nonempty range whose start or end falls inside a multibyte code point (`InvalidUtf8` at that boundary). An empty range returns empty bytes. Indices are still bytes, not characters: a character-level slice is a composition over `indexOf`.
- `stringAt` returns the single ASCII character at a strict signed byte index (`InvalidByteIndex` outside the data) and rejects a byte that belongs to a multibyte code point (`InvalidUtf8`), since one byte of it is not a character.

Both return bytes values that transport as `string`. EVML: `@str.slice!` and `@str.at!`.

```evml
load lang

assert @str.slice!($pool::!{name()(string)} 0 5) == "Curve"
assert @str.at!($pool::!{name()(string)} 0) == "C"
```

### Parse and format

**`parseUint(s)`** decodes a decimal ASCII string as a `uint256`: the bridge from string returns into arithmetic, so a split version segment composes straight into a numeric comparison (`gt(parseUint(segment), 2)`). It is strict:

- empty input reverts with `EmptyNumber`;
- any byte outside `0-9` reverts with `InvalidDecimalDigit(position, char)` (no signs, whitespace or decimal points);
- a value past `2^256 - 1` reverts with `Panic(0x11)`;
- leading zeros are accepted (`"007"` is 7).

**`toString(v)`** is its inverse, the decimal rendering with no leading zeros, so `toString(parseUint(s))` normalizes. The `int256` overload adds a leading minus for negative values (no plus), and renders `int256.min` correctly. In EVML, a live string operand inside `@calc!` arithmetic coerces through `parseUint` automatically; `toString` has no EVML spelling.

**`parseInt(s)`** accepts an optional `+` or `-` followed by at least one decimal digit, including the full signed minimum. A bare sign or empty input reverts with `EmptyNumber`, and a value that leaves `int256` reverts with `Panic(0x11)`. It has no EVML spelling.

**`parseUnits(value, decimals, rounding)`** returns an `int256`; **`parseUnitsUnsigned`** returns a `uint256`. For example, `"1.5"` at 18 decimals is `1500000000000000000`.

- `decimals` runs from 0 to 77 (`InvalidPrecision(decimals)` above).
- The input accepts one optional sign and at most one decimal point anywhere (`".5"` and `"5."` are fine), and needs at least one digit in total (`EmptyNumber` otherwise). It rejects whitespace, exponent notation, separators and additional points with `InvalidDecimalDigit`.
- The unsigned variant accepts a leading `+` and rejects a leading `-`, negative zero included, with `InvalidDecimalDigit` at position 0.
- Fractional digits past `decimals` are dropped as `rounding` says: `Trunc` (0) toward zero, `Floor` (1) toward negative infinity, `Ceil` (2) toward positive infinity (`Trunc` and `Floor` agree for the unsigned variant). A result that leaves its type reverts with `Panic(0x11)`, after rounding.

**`formatUnits(value, decimals)`** is viem's `formatUnits` and the inverse of `parseUnits`: it trims trailing fractional zeros and omits the point for integral values (1500000 at 6 decimals is `"1.5"`, 1000000 is `"1"`). Zero decimals renders the integer alone. It has unsigned and signed overloads, the signed one rendering `int256.min` correctly, and both revert with `InvalidPrecision` above 77 decimals.

In EVML, `@num.parse!(value decimals rounding? signedness?)` compiles to `parseUnits` or `parseUnitsUnsigned` (rounding `trunc`, `floor` or `ceil`; precision 0 to 77), and `@num.format!(value decimals)` compiles to `formatUnits`:

```evml
load lang

assert @num.format!($token::!{totalSupply()(uint256)} 6) == "1.5"
assert @num.parse!($feed::!{price()(string)} 18) >= 1e18
```

## Encoding and calldata layout

### Calldata layout for multi-argument calls

`read` appends each segment's full resolved bytes in order, so functions taking a dynamic argument plus other arguments need the encoder to lay out heads and tails, exactly as ABI encoding requires. `RAW_BYTES` segments carry the head words (offsets, static arguments) and any pre-encoded tails. A live envelope splices as a tail, with one trick: its leading `0x20` word rides along as dead calldata bytes, and the head offset points one word past it. `slice(liveData, start, len)` built by hand:

```text
selector
0x00: 0x80          <- RAW head word: offset of data's [length][payload]
0x20: start         <- RAW head word
0x40: len           <- RAW head word
0x60: [0x20][length][payload...]   <- the live envelope; its length word sits at 0x80
```

That is four segments: three literal words and the operand. Hand-writing this is rare; the EVML compiler produces these layouts for the string and bytes helpers, and single-dynamic-argument calls (`hash`, `byteLen`) need none of it.

### Encode: runtime abi.encode

`encode(types, values)` assembles the canonical ABI encoding of a tuple from pre-encoded component values: `nav`'s inverse. `types` is the tuple's type as a parenthesized descriptor (`"(address,uint256[])"`, the same grammar as `nav`), and `values[i]` is the canonical single-value encoding of component `i`:

- A static component with a head footprint of `w` words is exactly `w * 32` bytes (one word for `uint256`, `address`, `bool` or `bytes32`; the flattened words for static tuples and fixed arrays), copied verbatim into the head.
- A dynamic component (`bytes`, `string`, `T[]`, dynamic tuples) is the canonical envelope `[0x20][tail...]`, exactly what a bytes-returning call, `nav`'s dynamic terminal, or `abi.encode` of the single value produces. The leading offset word is stripped, the true top-level offset written into the head, and the tail appended verbatim. ABI offsets are frame-relative, so verbatim tail splicing is correct at any nesting depth: nested dynamics (`string[]`, `(uint256,bytes)[]`) need no special handling.

`encode` returns its output via a raw assembly return with no bytes envelope, deliberately the one raw-returning function in the contract: its output is a calldata segment for the core's `read` to splice, not a value to decode. That is its role in composition: resolve pieces live (a `nav` selection here, a `pick` word there), `encode` them into one multi-value span, and splice that span into a constructed call's arguments. `encodeBytes(types, values)` returns the same tuple payload inside a normal bytes envelope, for consumers that want a value rather than a segment (`hash`, `byteLen`, a Collections values array). EVML's `@abi.encode!` builds its bytes value through `encodeBytes`.

```evml
assert @hash!(@abi.encode!("uint256,uint256" $pool::!{reserve0()(uint256)} $pool::!{reserve1()(uint256)})) == $expectedDigest
```

Both functions use the shared `AbiCodec` to validate complete canonical encodings: nested offsets, lengths, bounds, zero padding and the absence of trailing data. Every static word is range-checked for its type the way solc's decoder does (narrow integers, address upper bits, `intN` sign extension, `bytesN` padding). What stays the caller's claim is which type the data really has.

**Packed encoding** (`abi.encodePacked`) needs no runtime encoder: it is pure composition over `concat` and `slice`. Full-width words (`uint256`, `int256`, `bytes32`) and dynamic payloads go straight into `concat`'s parts (a compiler synthesizes the constant envelopes around spliced words), and each narrowed part costs one `slice` over its word-as-bytes value: `address` is `slice(w, 12, 20)`, `bool` and `uintN` are `slice(w, 32 - N/8, N/8)`, and `bytesN` is `slice(w, 0, N)`. So `hash(concat(...))` over sliced parts reproduces a Solidity `keccak256(abi.encodePacked(...))` commitment over live operands. EVML's `@abi.encodePacked!` compiles to exactly that.

## Failure modes and limits

### Every call

- **Checked arithmetic.** Solidity 0.8 semantics: overflow or underflow reverts with `Panic(0x11)`, division or modulo by zero with `Panic(0x12)`. Shifts follow EVM semantics (256 or more yields 0).
- **Raw words.** Spliced operands are raw 32-byte words with no per-word validation, and bools are their 0/1 words.
- **Out-of-range enum.** An out-of-range `Rounding` value is refused by the ABI decoder, which reverts without data.
- **Operand failures** are reported by the core: an operand that reverts or targets a code-less address reverts with `CallFailed` identifying it, and an operand constraint violation reverts with `ConstraintFailed`. In a `read`, the target is operand 0 and the arguments follow at index + 1. A word spliced into a typed parameter it cannot decode as (for example a dirty address word) fails the callee's ABI decoding and surfaces as `CallFailed` on the constructed call.
- **No short-circuit.** `read` resolves every segment before the call happens, so `bitAnd` and `bitOr` always evaluate both sides. When an operand may revert, use the core's lazy `cond`, `orElse` and `isValid` instead.

The named errors of this contract (`SliceOutOfBounds`, `InvalidByteIndex`, `InvalidUtf8`, `EmptyNeedle`, `EmptyNumber`, `InvalidDecimalDigit`, `InvalidPrecision`, `ModularInverseDoesNotExist`, `LogarithmUndefined`, `RawCallFailed`, `SubcallOutOfGas`) are explained where their function is. The errors shared by every contract are on the [Errors](/docs/contracts/errors) page.

### Math and environment reads

| Error or panic | Raised by | When |
|----------------|-----------|------|
| `Panic(0x11)` | `add`, `sub`, `mul`, `exp`, signed `div` (`int256.min / -1`), `mulDiv`, `rpow`, `expWad` | Overflow or underflow, a `mulDiv` result that does not fit, a scaled `rpow` intermediate that does not fit, `expWad` at or above 135305999368893231589 |
| `Panic(0x12)` | `div`, `mod`, `mulDiv`, `addMod`, `mulMod`, `powMod`, `rpow` | Division or modulo by zero; a zero `rpow` base |
| `ModularInverseDoesNotExist(base, modulus)` | `powMod` | A negative exponent whose base and modulus magnitudes are not coprime |
| `LogarithmUndefined(x)` | `log2`, `lnWad` | `log2(0)` (reported as 0), `lnWad` with `x <= 0` |
| revert without data | every function taking `Rounding` | A `Rounding` value above 2, refused by the ABI decoder |

Descriptions of operand-resolution errors (`CallFailed`, `ConstraintFailed`) are on the [Operations overview](#every-call).

### Bytes and strings

| Error | Raised by | When |
|-------|-----------|------|
| `SliceOutOfBounds(start, len, dataLength)` | `slice` | The range leaves the data |
| `InvalidByteIndex(index, length)` | `byteAt`, `stringAt` | A strict index outside `-length .. length-1` |
| `InvalidUtf8(index)` | `stringSlice`, `stringAt` | Malformed UTF-8 anywhere in the input (reported at the first bad byte), or a slice boundary or index that falls inside a multibyte code point |
| `EmptyNeedle()` | `replace`, `split` | An empty needle or delimiter (`indexOf` and `contains` are total instead) |
| `EmptyNumber()` | `parseUint`, `parseInt`, `parseUnits`, `parseUnitsUnsigned` | No digits: empty input, a bare sign, or only a decimal point |
| `InvalidDecimalDigit(position, char)` | the parse functions | A byte outside `0-9` (and outside a sign or one point where allowed), a second point, or `-` in `parseUnitsUnsigned` |
| `InvalidPrecision(decimals)` | `parseUnits`, `parseUnitsUnsigned`, `formatUnits` | `decimals` above 77 |
| `RawCallFailed(target, data)` | `rawCall` | The staticcall reverted without exhausting gas |
| `SubcallOutOfGas()` | `rawCall` | The subcall exhausted its gas, or propagated the signal |
| `InvalidTypeDescriptor(position)` | `encode`, `encodeBytes` | A malformed type descriptor |
| `ComponentCountMismatch(expected, actual)` | `encode`, `encodeBytes` | `values.length` differs from the component count |
| `InvalidComponentLength(index, expectedBytes, actualBytes)` | `encode`, `encodeBytes` | A static component of the wrong size |
| `InvalidComponentEnvelope(index, length, head)` | `encode`, `encodeBytes` | A dynamic component that is not an envelope |
| `InvalidComponentValue(index, offset)` | `encode`, `encodeBytes` | A malformed nested value; for trailing data, `offset` is the first byte after the canonical value, measured within that component's single-value encoding |
| `Panic(0x11)` | `parseUint`, `parseInt`, `parseUnits` | The parsed value leaves its type |

The errors shared by every contract are on the [Errors](/docs/contracts/errors) page.

## What earns a slot

Admission is a demand test. A function earns a slot only when both hold:

1. It is not expressible as a few-node recipe at practical cost.
2. A concrete assertion workload needs it: a script in the docs or tests, or an SDK helper that calls it.

What passes the first half is hot loops that would otherwise cost one external call per element (`charset`, the lambda-shaped `bitSet` and `hashPairSorted`, and `sumWords` on Collections) and calldata-exponential compositions (`rpow`, `log2`): a raw operand tree cannot name a subterm, so squaring duplicates its whole operand. Everything else composes and stays out:

- `join` is `concat` with a delimiter.
- Unsorted pair hashing is `hash` over an encoder-built two-word payload.
- Packed encoding is `concat` over `slice`-narrowed words (see [encode](#encode-runtime-abiencode)).
- Signed `sortWords` is refused (flip the sign bit with `mapWords`, sort, flip back).
- Specialist families go to optional contracts.

These measurements move with the compiler.

## Why it lives here

Operations works on values that have already been read, so it never has to decide anything about reads and does not belong on the core. Keeping it a separate contract lets it version by deployment without moving the judge.

Some functions are here for cost, not necessity:

- `rpow` and `log2` could be composed from other functions, but a raw operand tree cannot name a subterm, so the composed form grows exponentially in calldata.
- The loops inside `charset`, `indexOf`, `replace`, `split` and the UTF-8 walk would otherwise cost one external call per byte.
- `encode` and `rawCall` are the only way a composed expression can build a multi-value span or reach a precompile.

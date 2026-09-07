---
title: "Words: arithmetic, comparisons, bitwise & environment"
description: Named word operations with int256 overloads, 512-bit and fixed-point math, and the environment reads, spliced over live operands by the core's read.
---

Expressions over call results follow the same composition philosophy as everything else: every operand is an ERC-8211 `InputParam` (a raw literal, a staticcall, a balance read, or a nested core expression), the core's [`read`](/docs/core/reads) resolves them and splices the values into plain Operations calldata, and the judge consumes the result through a `STATIC_CALL` fetcher pointed at the core.

The examples reuse the `callParam`/`balanceParam`/`eq`/`gte`/`noConstraints` helpers and the [selector constants](/docs/solidity#selector-constants) (`ADD_U`, `MUL_U`, `EXP_U`, `GT_U`, `GE_U`, `GT_S`, `ABS_S`) from [the Solidity guide](/docs/solidity), plus `lit`/`read2`/`read1` from [the Operations overview](/docs/operators).

Comparisons return `bool`, which splices onward as a 0/1 word: they feed straight into boolean composition (`bitAnd`/`bitOr`/`bitXor` on 0/1 words) and an `EQ 1` judged constraint. `absDiff` returns the `|a - b|` magnitude as a `uint256` and is total: no underflow, no overflow revert on wide spans, so `absDiff(a, b)` judged `LTE d` expresses live-vs-live approximate equality (the int256 overload handles operands that cross zero, and even the widest span yields its exact distance). For `shl`/`shr` the second operand is the shift amount; shifts of 256 or more yield 0 (EVM shift semantics, no revert). `shr` also has a signed overload, `shr(int256, uint256)`: the arithmetic shift (EVM SAR), where the sign fills in from the left, rounding toward negative infinity (shifts of 256 or more yield 0 for non-negative values and -1 for negative ones).

## Arithmetic

"`addr1`'s ETH balance plus its WETH balance is positive":

```solidity
bytes memory sum = read2(operations, ADD_U,
    balanceParam(address(0), addr1, noConstraints()),   // native balance operand
    callParam(weth, abi.encodeCall(IERC20.balanceOf, (addr1)), noConstraints())
);
assertions.assertParam(callParam(address(assertions), sum, gte(1)));
```

In EVMcrispr the same expression is written directly and compiles to the same read-spliced calldata:

```evml
assert @calc!(@balance!(ETH $addr1) + $weth::balanceOf($addr1)) > 0
```

## 512-bit math: mulDiv, the mod pair, powMod & sqrt

`mulDiv(a, b, denominator, rounding)` uses a full 512-bit intermediate product and rounds the quotient once. Both `uint256` and `int256` overloads exist. `Rounding.Trunc` (ABI value 0) rounds toward zero, `Floor` (1) toward negative infinity and `Ceil` (2) toward positive infinity; unsigned truncation and floor coincide. Signed operands may include negative denominators and `int256.min`. A zero denominator reverts with `Panic(0x12)`; a rounded result that does not fit reverts with `Panic(0x11)`. For rounded division alone, use `mulDiv(a, 1, b, rounding)`.

The EVMcrispr compiler emits the unsigned overload only, always with `Trunc`: inside `@calc!`, an unsigned `a * b / c` fuses into one `mulDiv(a, b, c, Trunc)`, so the intermediate product never overflows and the result is exactly what `div(mul(a, b), c)` would have been, and a rational factor such as `* 0.5` or `* 2 / 3` lowers the same way. `Floor` and `Ceil` are reachable from Solidity encoders; the compiler never emits them, and it does not fuse signed products.

`addMod(a, b, m)` and `mulMod(a, b, m)` take a full-width sum or product before the remainder (EVM `ADDMOD`/`MULMOD` for the unsigned overloads). Both `uint256` and `int256` overloads exist. The signed remainder follows the sign of the mathematical sum or product, independent of the modulus's sign; `int256.min` is supported in every operand. Modulo by zero reverts with `Panic(0x12)`.

`powMod(a, exponent, m)` computes `a ** exponent % m` without materializing the power, in four overloads: the base and modulus are both `uint256` or both `int256`, and the exponent is `uint256` or `int256` independently. A negative exponent raises the modular inverse of the base and reverts with `ModularInverseDoesNotExist(baseMagnitude, modulusMagnitude)` when the magnitudes are not coprime. Odd exponents preserve a negative base's sign; the modulus's sign is ignored. A zero modulus reverts with `Panic(0x12)`, a modulus of magnitude 1 returns 0, and an exponent of zero returns `1 % m` (so `0 ** 0` is 1 for any modulus above 1). Exponents of 32 bits or more are delegated to the modexp precompile (flat cost); smaller ones run a MULMOD loop, which is also the fallback on a chain without modexp.

Neither the modular pair nor `powMod` has an EVMcrispr helper face; reach them from Solidity encoders with explicit selectors.

`sqrt(x)` is the floor square root, the AMM invariant form: `sqrt(mulDiv(x, y, 1e18, Rounding.Floor))` style checks, or EVMcrispr's `@sqrt!($pool::reserve0() * $pool::reserve1())`. A bare product still reverts past `2^256` (checked `mul`), so scale wide reserves down through `mulDiv` first; in `@calc!`, writing the division right after the product does that automatically.

## Fixed point: rpow, expWad and lnWad

`rpow(x, n, base)` computes a scaled power where `base` is one unit (1e27 for a ray, 1e18 for a wad), the compounding primitive: an APY from a per-second rate is `rpow(1e27 + ratePerSecond, 31536000, 1e27)`. It uses binary exponentiation with the scale divided out after every multiply, so the intermediate never leaves fixed point, and a scaled intermediate that does not fit `uint256` reverts with `Panic(0x11)`; a zero `base` reverts with `Panic(0x12)`, the scale being the divisor. It rounds down at each step, so its result can be lower than a single final rounding of `base * (x / base)^n`, and earlier rounding errors are amplified by later squarings: there is no general `2 * log2(n)` bound on the final error in units of the output. For example, `rpow(19, 16, 10)` returns `276889`, while rounding the exact rational power once gives `288441`. Choose the scale and assertion tolerance for the input range and exponent; wad/ray precision does not establish a universal absolute error bound. EVMcrispr's `@pow!(value exponent base?)` compiles to it with unsigned operands (`base` defaults to 1e18).

`expWad(x)` is e^x and `lnWad(x)` the natural logarithm, both in wad (1e18) fixed point over `int256`. `expWad` returns 0 at or below -42139678854452767551 (where the result underflows a wad) and reverts with `Panic(0x11)` at or above 135305999368893231589 (where it leaves `int256`); `lnWad` reverts with `LogarithmUndefined(x)` for `x <= 0`. They are `@exp!` and `@ln!` in the math module, whose results carry the wad scale so surrounding arithmetic aligns to it. `log2(x)` is the floor binary logarithm, the bit length of `x` minus one; it reverts with `LogarithmUndefined(0)` at 0 and is `@log2!`.

## Signed comparisons

Constraints compare unsigned words, so anything signed routes through the int256 overloads. "The rate is above -10" (where an unsigned comparison would see -10 as astronomically large):

```solidity
bytes memory aboveFloor = read2(operations, GT_S,
    callParam(oracle, abi.encodeCall(IOracle.rate, ()), noConstraints()),
    InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(int256(-10)), new Constraint[](0))
);
assertions.assertParam(callParam(address(assertions), aboveFloor, eq(bytes32(uint256(1)))));
```

Signed tolerance is the `absDiff(int256,int256)` overload judged `LTE`: the magnitude comes back as a `uint256`, so the constraint stays unsigned.

## Logic

Assertion constraints revert on failure, so they cannot be OR-ed; a comparison *returns* the outcome as a 0/1 word instead, and `bitAnd`/`bitOr`/`bitXor` combine outcomes (on 0/1 words the bitwise and logical ops coincide). Nested expressions become operands by pointing a `STATIC_CALL` at the core. "`addr1` has ETH OR holds more than 10 tokens":

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

```evml
assert @bool!((@balance!(ETH $addr1) > 0) or ($token::balanceOf($addr1) > 10))
```

Boolean negation is `eq(x, 0)`; the bitwise complement is `bitXor(x, type(uint256).max)`.

## Bitmasks

Flag checks on a packed config word, with a literal operand supplying the mask. "`config & MASK != 0`" is a `bitAnd` judged `GTE 1`:

```solidity
bytes memory masked = read2(operations, Operations.bitAnd.selector,
    callParam(configSource, abi.encodeCall(IConfig.packedConfig, ()), noConstraints()),
    lit(MASK)
);
assertions.assertParam(callParam(address(assertions), masked, gte(1)));
```

"Bit `N` of the config is set" is direct, no shift composition needed: `bitSet(config, N)` returns whether bit `N` of the first operand is set (indices past 255 are never set), judged `EQ 1`. `bitSet` is also the character-class lambda of [the folds](/docs/operators/fold). In EVMcrispr bitwise expressions are `@bytes!(a "&" b)` (also `"|"`, `"xor"`, `"<<"`, `">>"`, the operator quoted), `@lang:bytes.not!(x)` is the complement, and single-arg `@bytes!(x)` is the raw-word cast; `>>` on a signed value picks the arithmetic-shift overload automatically.

Sign extension is a two-op recipe over the shift pair: a narrow two's-complement field sliced out of packed bytes re-widens as `shr(int256(shl(x, 256 - bits)), 256 - bits)`, using the signed `shr` overload so the sign propagates.

## Environment reads

The environment functions turn non-call quantities into ordinary staticcalls, so for *known* addresses and argument-free reads no splicing is involved: the fetcher targets Operations directly.

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

Beyond `timestamp`, `blockNumber` and `chainId`, the block environment is fully readable: `baseFee()` and `blobBaseFee()` gate a batch on fee conditions ("only execute while basefee <= X"), `prevRandao()`, `coinbase()` and `gasLimit()` read the block header, `blockHash(n)` follows BLOCKHASH semantics (0 for the current block, the future, and blocks older than 256), and `origin()` reads the transaction origin, letting an assertion gate on who is executing the batch it guards. The transaction context is readable too: `gasPrice()` bounds what the batch is willing to pay ("only execute while gas <= X wei"), and `blobHash(uint256)` reads the versioned hash of a blob carried by the executing transaction (0 when the index is out of range), so a batch can assert it ships with the blobs it was built for.

In EVMcrispr each is a bang helper in the receipts module (`load receipts`). The `@block.*` family also has plain off-chain faces addressed by block number or tag, `@block.baseFee(block? chain?)` and friends, which read sealed headers at build time:

| Helper | Operations function | Description |
|--------|---------------------|-------------|
| `@block.number!` | `blockNumber()` | The block number at assertion time (plain `@block.number(block? chain?)` reads a sealed block off-chain, default latest) |
| `@block.timestamp!` | `timestamp()` | The block timestamp at assertion time (plain `@block.timestamp(block? chain?)` reads a sealed block off-chain, default latest) |
| `@block.baseFee!` / `@block.blobBaseFee!` | `baseFee()` / `blobBaseFee()` | The block base fee / blob base fee in wei at assertion time (the plain blob-fee face with no block argument reads the live `eth_blobBaseFee` value) |
| `@block.hash!(n)` | `blockHash(n)` | The hash of block `n` (0 outside the last 256 blocks); the number composes live, e.g. `@block.hash!(@block.number! - 1)`; plain `@block.hash(block? chain?)` reads ANY sealed block off-chain, unbounded by the 256-block window |
| `@block.coinbase!` | `coinbase()` | The block proposer fee recipient at assertion time |
| `@block.gasLimit!` | `gasLimit()` | The block gas limit at assertion time |
| `@block.prevrandao!` | `prevRandao()` | The previous RANDAO mix at assertion time (the plain face reads a sealed block's mixHash; pre-merge blocks carry difficulty semantics there) |
| `@chainId!` | `chainId()` | The chain id, read on-chain at assertion time |
| `@tx.from!` | `origin()` | The sender (origin) of the executing transaction; a different identity from `@sender` and `@me` (plain `@tx.from(hash chain?)` reads sealed data off-chain) |
| `@tx.gasPrice!` | `gasPrice()` | The gas price of the executing transaction in wei |
| `@tx.blobHash!(i)` | `blobHash(i)` | The versioned hash of blob `i` carried by the executing transaction (0 when out of range) |

`balance(account)` reads the native balance and `codeHash(account)` the EXTCODEHASH (`bytes32(0)` for a nonexistent account, `keccak256("")` for an existing code-less one). Note the `BALANCE` fetcher already covers native and ERC-20 balances of known addresses without any Operations call; these earn their keep when the address is *computed*. The balance of `registry.treasury()`, or "the proxy's current implementation is the audited contract":

```solidity
bytes memory implHash = read1(operations, Operations.codeHash.selector,
    callParam(proxy, abi.encodeCall(IProxy.implementation, ()), noConstraints())
);
assertions.assertParam(callParam(address(assertions), implHash, eq(auditedCodeHash)));
```

## More composition patterns

**Exponentiation & live decimals scaling.** `exp` gives checked `**` (overflow reverts with `Panic(0x11)`, `0 ** 0 == 1` per EVM semantics). Both signed and unsigned bases are supported; the exponent is always unsigned, which makes `exp` overloaded, so it takes an explicit selector (`EXP_U`). The canonical use is scaling thresholds by a live `decimals()` (EVMcrispr's `@calc!` with `^`): "`a` holds at least 5 whole tokens":

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

```evml
assert $token::balanceOf($a) >= @calc!(5 * 10 ^ $token::decimals())
```

**Conditional select.** The core's [`cond`](/docs/core/control) branches lazily on any 0/1 word a comparison produces, and never resolves the losing branch; prefer it to the arithmetic trick `c * a + (1 - c) * b`, which evaluates both.

**Inline asserts.** Operands carry their own constraints, validated as they resolve: a `GTE` on the balance operand inside a larger expression asserts it *and* uses it, in one call.

Nesting is unlimited: an operand can be a `pick`, another `read`, a comparison feeding a `bitOr`, and so on. `(pool.token().decimals() + x.value() == 60) && !protocol.paused()` is one judged parameter.

## Semantics to know

- **Checked arithmetic.** Solidity 0.8 semantics: overflow/underflow reverts with `Panic(0x11)` (including `exp` overflow), division or modulo by zero with `Panic(0x12)`.
- **Signed semantics.** `div(int256,int256)` truncates toward zero (`-42 / 5 == -8`), `mod` takes the sign of the dividend (`-42 % 5 == -2`), and `type(int256).min / -1` reverts with `Panic(0x11)`. `absDiff` is total in both overloads: it returns the `uint256` magnitude and never reverts on wide spans.
- **Raw words, overload-carried signedness.** Spliced operands are raw 32-byte words: there is no per-word validation, and bools are their 0/1 words. `eq`/`ne` compare at the bit level, which covers every word type (uint, int, address, bool, bytes32) at once.
- **Overloads need explicit selectors.** `abi.encodeCall` cannot pick between `add(uint256,uint256)` and `add(int256,int256)`; use `bytes4(keccak256("add(uint256,uint256)"))` ([the shared constants](/docs/solidity#selector-constants)).
- **No short-circuit.** `read` resolves every segment before the call happens, so `bitAnd`/`bitOr` always evaluate both sides. When an operand may revert, reach for the core's lazy [`cond`/`orElse`/`isValid`](/docs/core/control) instead.
- **Operand failures.** An operand that reverts or targets a code-less address reverts with `CallFailed` identifying it; operand constraint violations revert with `ConstraintFailed` (in a `read`, the target is operand 0 and args follow at index + 1). A word spliced into a typed Solidity parameter it cannot decode as (e.g. a dirty address word) fails the callee's ABI decoding and surfaces as `CallFailed` on the constructed call.

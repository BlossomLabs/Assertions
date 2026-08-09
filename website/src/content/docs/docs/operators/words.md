---
title: "Words: arithmetic, comparisons, bitwise & environment"
description: Named word operations with int256 overloads, spliced over live operands by the core's read.
---

Expressions over call results follow the same composition philosophy as everything else: every operand is an ERC-8211 `InputParam` (a raw literal, a staticcall, a balance read, or a nested core expression), the core's [`read`](/docs/core/reads) resolves them and splices the values into plain Operators calldata, and the judge consumes the result through a `STATIC_CALL` fetcher pointed at the core.

The examples reuse the `callParam`/`balanceParam`/`eq`/`gte`/`noConstraints` helpers from [the Solidity guide](/docs/solidity) and `lit`/`read2`/`read1` from [the Operators overview](/docs/operators), plus the explicit selectors overloads require:

```solidity
bytes4 constant ADD_U = bytes4(keccak256("add(uint256,uint256)"));
bytes4 constant MUL_U = bytes4(keccak256("mul(uint256,uint256)"));
bytes4 constant GT_U  = bytes4(keccak256("gt(uint256,uint256)"));
bytes4 constant GE_U  = bytes4(keccak256("ge(uint256,uint256)"));
bytes4 constant GT_S  = bytes4(keccak256("gt(int256,int256)"));
bytes4 constant ABS_S = bytes4(keccak256("absDiff(int256,int256)"));
```

Comparisons return `bool`, which splices onward as a 0/1 word: they feed straight into boolean composition (`bitAnd`/`bitOr`/`bitXor` on 0/1 words) and an `EQ 1` judged constraint. `absDiff` returns the `|a - b|` magnitude as a `uint256` and is total: no underflow, no overflow revert on wide spans, so `absDiff(a, b)` judged `LTE d` expresses live-vs-live approximate equality (the int256 overload handles operands that cross zero, and even the widest span yields its exact distance). For `shl`/`shr` the second operand is the shift amount; shifts of 256 or more yield 0 (EVM shift semantics, no revert). `shr` also has a signed overload, `shr(int256, uint256)`: the arithmetic shift (EVM SAR), where the sign fills in from the left, rounding toward negative infinity (shifts of 256 or more yield 0 for non-negative values and -1 for negative ones).

## Arithmetic

"`addr1`'s ETH balance plus its WETH balance is positive":

```solidity
bytes memory sum = read2(operators, ADD_U,
    balanceParam(address(0), addr1, noConstraints()),   // native balance operand
    callParam(weth, abi.encodeCall(IERC20.balanceOf, (addr1)), noConstraints())
);
assertions.assertParam(callParam(address(assertions), sum, gte(1)));
```

In EVMcrispr the same expression is written directly and compiles to the same read-spliced calldata:

```evml
assertions:assert @num!(@balance!(ETH $addr1) + $weth::balanceOf($addr1)) > 0
```

## 512-bit math: mulDiv, the mod pair & sqrt

`mulDiv(a, b, denominator)` is `floor(a * b / denominator)` with a full 512-bit intermediate product: the mul-then-div for price, share and bps math where the plain composition `div(mul(a, b), d)` would revert on an intermediate past `2^256` (think `balance * price / 1e18`). It keeps the checked semantics of the plain operators: a zero denominator reverts with `Panic(0x12)`, a result that does not fit 256 bits with `Panic(0x11)`. `mulDivUp` is the ceiling variant for round-up share math. In EVMcrispr no special form is needed: `@num!(a * b / c)` over unsigned operands **fuses into one mulDiv read automatically** (signed operands keep the nested lowering, since there is no signed mulDiv).

`addMod(a, b, m)` and `mulMod(a, b, m)` are the EVM ADDMOD/MULMOD builtins: the sum or product is taken over 512 bits before the modulo, so nothing wraps at `2^256` (modulo by zero reverts with `Panic(0x12)`).

`sqrt(x)` is the floor square root, the AMM invariant form: `sqrt(mulDiv(x, y, 1e18))` style checks, or EVMcrispr's `@sqrt!($pool::reserve0() * $pool::reserve1())`. The raw product still reverts past `2^256` (checked `mul`), so scale wide reserves down through `mulDiv` first.

## Signed comparisons

Constraints compare unsigned words, so anything signed routes through the int256 overloads. "The rate is above -10" (where an unsigned comparison would see -10 as astronomically large):

```solidity
bytes memory aboveFloor = read2(operators, GT_S,
    callParam(oracle, abi.encodeCall(IOracle.rate, ()), noConstraints()),
    InputParam(InputParamType.CALL_DATA, InputParamFetcherType.RAW_BYTES, abi.encode(int256(-10)), new Constraint[](0))
);
assertions.assertParam(callParam(address(assertions), aboveFloor, eq(bytes32(uint256(1)))));
```

Signed tolerance is the `absDiff(int256,int256)` overload judged `LTE`: the magnitude comes back as a `uint256`, so the constraint stays unsigned.

## Logic

Assertion constraints revert on failure, so they cannot be OR-ed; a comparison *returns* the outcome as a 0/1 word instead, and `bitAnd`/`bitOr`/`bitXor` combine outcomes (on 0/1 words the bitwise and logical ops coincide). Nested expressions become operands by pointing a `STATIC_CALL` at the core. "`addr1` has ETH OR holds more than 10 tokens":

```solidity
bytes memory hasEth = read2(operators, GT_U,
    balanceParam(address(0), addr1, noConstraints()),
    lit(0)
);
bytes memory hasTokens = read2(operators, GT_U,
    callParam(token, abi.encodeCall(IERC20.balanceOf, (addr1)), noConstraints()),
    lit(10)
);
bytes memory either = read2(operators, Operators.bitOr.selector,
    callParam(address(assertions), hasEth, noConstraints()),
    callParam(address(assertions), hasTokens, noConstraints())
);
assertions.assertParam(callParam(address(assertions), either, eq(bytes32(uint256(1)))));
```

```evml
assertions:assert @bool!((@balance!(ETH $addr1) > 0) or ($token::balanceOf($addr1) > 10))
```

Boolean negation is `eq(x, 0)`; the bitwise complement is `bitXor(x, type(uint256).max)`.

## Bitmasks

Flag checks on a packed config word, with a literal operand supplying the mask. "`config & MASK != 0`" is a `bitAnd` judged `GTE 1`:

```solidity
bytes memory masked = read2(operators, Operators.bitAnd.selector,
    callParam(configSource, abi.encodeCall(IConfig.packedConfig, ()), noConstraints()),
    lit(MASK)
);
assertions.assertParam(callParam(address(assertions), masked, gte(1)));
```

"Bit `N` of the config is set" is direct, no shift composition needed: `bitSet(config, N)` returns whether bit `N` of the first operand is set (indices past 255 are never set), judged `EQ 1`. `bitSet` is also the character-class lambda of [the folds](/docs/operators/fold). In EVMcrispr bitwise expressions are `@bytes!(a "&" b)` (also `|`, `^`, `<<`, `>>`), `@not!(x)` is the complement, and single-arg `@bytes!(x)` is the raw-word cast; `>>` on a signed value picks the arithmetic-shift overload automatically.

Sign extension is a two-op recipe over the shift pair: a narrow two's-complement field sliced out of packed bytes re-widens as `shr(int256(shl(x, 256 - bits)), 256 - bits)`, using the signed `shr` overload so the sign propagates.

## Environment reads

The environment functions turn non-call quantities into ordinary staticcalls, so for *known* addresses and argument-free reads no splicing is involved: the fetcher targets Operators directly.

```solidity
// block timestamp past the unlock time
assertions.assertParam(
    callParam(address(operators), abi.encodeCall(Operators.timestamp, ()), gte(unlockTime + 1))
);
// on mainnet
assertions.assertParam(
    callParam(address(operators), abi.encodeCall(Operators.chainId, ()), eq(bytes32(uint256(1))))
);
```

Beyond `timestamp`, `blockNumber` and `chainId`, the block environment is fully readable: `baseFee()` and `blobBaseFee()` gate a batch on fee conditions ("only execute while basefee <= X"), `prevRandao()`, `coinbase()` and `gasLimit()` read the block header, `blockHash(n)` follows BLOCKHASH semantics (0 for the current block, the future, and blocks older than 256), and `origin()` reads the transaction origin, letting an assertion gate on who is executing the batch it guards. The transaction context is readable too: `gasPrice()` bounds what the batch is willing to pay ("only execute while gas <= X wei"), and `blobHash(uint256)` reads the versioned hash of a blob carried by the executing transaction (0 when the index is out of range), so a batch can assert it ships with the blobs it was built for. In EVMcrispr each is a bang helper in the receipts module (`load receipts`): `@block.basefee!`, `@block.blobbasefee!`, `@block.prevrandao!`, `@block.coinbase!`, `@block.gaslimit!`, `@block.hash!(n)` (the block number composes live, e.g. `@block.hash!(@block.number! - 1)`), `@tx.from!` (the origin: the from field the receipt will seal), `@tx.gasprice!` and `@tx.blobhash!(i)`. The `@block.*` family also has plain off-chain faces addressed by block number or tag, `@block.basefee(block? chain?)` and friends, which read sealed headers at build time; plain `@block.hash` reads any sealed block, unbounded by the opcode's 256-block window.

`balance(account)` reads the native balance and `codehash(account)` the EXTCODEHASH (`bytes32(0)` for a nonexistent account, `keccak256("")` for an existing code-less one). Note the `BALANCE` fetcher already covers native and ERC-20 balances of known addresses without any Operators call; these earn their keep when the address is *computed*. The balance of `registry.treasury()`, or "the proxy's current implementation is the audited contract":

```solidity
bytes memory implHash = read1(operators, Operators.codehash.selector,
    callParam(proxy, abi.encodeCall(IProxy.implementation, ()), noConstraints())
);
assertions.assertParam(callParam(address(assertions), implHash, eq(auditedCodeHash)));
```

## More composition patterns

**Exponentiation & live decimals scaling.** `exp` gives checked `**` (overflow reverts with `Panic(0x11)`, `0 ** 0 == 1` per EVM semantics). It is unsigned-only: Solidity defines `**` for unsigned operands, so signed exponentiation is ill-defined. The canonical use is scaling thresholds by a live `decimals()` (EVMcrispr's `@num!` with `^`): "`a` holds at least 5 whole tokens":

```solidity
bytes memory scale = read2(operators, Operators.exp.selector,       // 10 ** decimals()
    lit(10),
    callParam(token, abi.encodeCall(IERC20.decimals, ()), noConstraints())
);
bytes memory threshold = read2(operators, MUL_U,                    // 5 * 10 ** decimals()
    lit(5),
    callParam(address(assertions), scale, noConstraints())
);
bytes memory holds = read2(operators, GE_U,
    callParam(token, abi.encodeCall(IERC20.balanceOf, (a)), noConstraints()),
    callParam(address(assertions), threshold, noConstraints())
);
assertions.assertParam(callParam(address(assertions), holds, eq(bytes32(uint256(1)))));
```

```evml
assertions:assert $token::balanceOf($a) >= @num!(5 * 10 ^ $token::decimals())
```

**Conditional select.** The core's [`cond`](/docs/core/control) branches lazily on any 0/1 word a comparison produces; the arithmetic trick (`c * a + (1 - c) * b`) is no longer needed, and unlike it, `cond` never resolves the losing branch.

**Inline asserts.** Operands carry their own constraints, validated as they resolve: a `GTE` on the balance operand inside a larger expression asserts it *and* uses it, in one call.

Nesting is unlimited: an operand can be a `pick`, another `read`, a comparison feeding a `bitOr`, and so on. `(pool.token().decimals() + x.value() == 60) && !protocol.paused()` is one judged parameter.

## Semantics to know

- **Checked arithmetic.** Solidity 0.8 semantics: overflow/underflow reverts with `Panic(0x11)` (including `exp` overflow), division or modulo by zero with `Panic(0x12)`.
- **Signed semantics.** `div(int256,int256)` truncates toward zero (`-42 / 5 == -8`), `mod` takes the sign of the dividend (`-42 % 5 == -2`), and `type(int256).min / -1` reverts with `Panic(0x11)`. `absDiff` is total in both overloads: it returns the `uint256` magnitude and never reverts on wide spans.
- **Raw words, overload-carried signedness.** Spliced operands are raw 32-byte words: there is no per-word validation, and bools are their 0/1 words. `eq`/`ne` compare at the bit level, which covers every word type (uint, int, address, bool, bytes32) at once.
- **Overloads need explicit selectors.** `abi.encodeCall` cannot pick between `add(uint256,uint256)` and `add(int256,int256)`; use `bytes4(keccak256("add(uint256,uint256)"))`.
- **No short-circuit.** `read` resolves every segment before the call happens, so `bitAnd`/`bitOr` always evaluate both sides. When an operand may revert, reach for the core's lazy [`cond`/`orElse`/`ok`](/docs/core/control) instead.
- **Operand failures.** An operand that reverts or targets a code-less address reverts with `CallFailed` identifying it; operand constraint violations revert with `ConstraintFailed` (in a `read`, the target is operand 0 and args follow at index + 1). A word spliced into a typed Solidity parameter it cannot decode as (e.g. a dirty address word) fails the callee's ABI decoding and surfaces as `CallFailed` on the constructed call.

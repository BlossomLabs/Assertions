---
title: "calc, unary & env: expressions"
description: Arithmetic, comparison, logic and value getters over live on-chain operands.
---

Expressions over call results follow the same composition philosophy as everything else: every operand is an ERC-8211 `InputParam`, and an operand may itself be a call to the Combinators contract (a `nav`, another `calc`, `data`, `env`, …), so expressions nest recursively.

```solidity
function calc (CalcOp op, InputParam a, InputParam b) external view returns (uint256);
function unary(UnaryOp op, InputParam a) external view returns (uint256);
function env  (EnvOp op, uint256 arg) external view returns (uint256);
```

One opcode enum covers arithmetic, bitwise and comparison: unsigned ops sit next to their `S`-prefixed signed variants (pick the signed opcode when either operand is an int), and comparisons return 0/1 so they feed straight into boolean composition (`And`/`Or`/`Xor` on 0/1 words) and an `EQ 1` judged constraint.

`AbsDiff`/`SAbsDiff` return the `|a - b|` magnitude as a `uint256` and are total: no underflow, no overflow revert on wide spans, so `AbsDiff(a, b)` judged `LTE d` expresses live-vs-live approximate equality. For `Shl`/`Shr` the second operand is the shift amount; shifts of 256 or more yield 0 (EVM shift semantics, no revert).

## Operands

The examples reuse the helpers from [the Solidity guide](/docs/solidity), plus two more:

```solidity
/// A constant operand: the RAW_BYTES fetcher echoes the literal word.
function constParam(uint256 x) pure returns (InputParam memory) {
    return InputParam(
        InputParamType.CALL_DATA,
        InputParamFetcherType.RAW_BYTES,
        abi.encode(x),
        new Constraint[](0)
    );
}

/// A nested combinator expression as an operand.
function comboParam(address combinators, bytes memory call) pure returns (InputParam memory) {
    return InputParam(
        InputParamType.CALL_DATA,
        InputParamFetcherType.STATIC_CALL,
        abi.encode(combinators, call),
        new Constraint[](0)
    );
}
```

(`env(Constant, x)` echoes a literal too, for encoders that want every operand to be a call; the `RAW_BYTES` fetcher is the direct form.)

## Value getters

`env` turns non-call quantities into operands: `env(Balance, addr)` (native balance), `env(Timestamp, 0)`, `env(BlockNumber, 0)`, `env(ChainId, 0)`, `env(CodeHash, addr)` (EXTCODEHASH: `bytes32(0)` for a nonexistent account, `keccak256("")` for an existing code-less one). Note the `BALANCE` fetcher covers native and ERC-20 balances of *known* addresses without any combinator call.

When the account is not known at encoding time, `unary(Balance, a)` / `unary(CodeHash, a)` return the native balance / code hash of the address the operand resolves to, e.g. the balance of `registry.treasury()`, or the code hash of `proxy.implementation()`:

```solidity
// "The proxy's current implementation is the audited contract"
assertions.assertParam(
    callParam(
        address(combinators),
        abi.encodeCall(Combinators.unary, (
            Combinators.UnaryOp.CodeHash,
            callParam(proxy, abi.encodeCall(IProxy.implementation, ()), noConstraints())
        )),
        eq(auditedCodeHash)
    )
);
```

## Arithmetic

"`addr1`'s ETH balance plus its WETH balance is positive":

```solidity
assertions.assertParam(
    callParam(
        address(combinators),
        abi.encodeCall(Combinators.calc, (
            Combinators.CalcOp.Add,
            balanceParam(address(0), addr1, noConstraints()),   // native balance operand
            callParam(weth, abi.encodeCall(IERC20.balanceOf, (addr1)), noConstraints())
        )),
        gte(1)
    )
);
```

In EVMcrispr the same expression is written directly and compiles to nested `calc` calldata:

```evml
assertions:assert @num!(@balance!(ETH $addr1) + $weth::balanceOf($addr1)) > 0
```

## Logic

Assertion constraints revert on failure, so they cannot be OR-ed; a comparison opcode *returns* the outcome as a 0/1 word instead, and `And`/`Or`/`Xor` combine outcomes (on 0/1 words the bitwise and logical ops coincide). "`addr1` has ETH OR holds more than 10 tokens":

```solidity
bytes memory hasEth = abi.encodeCall(Combinators.calc, (
    Combinators.CalcOp.Gt,
    balanceParam(address(0), addr1, noConstraints()),
    constParam(0)
));
bytes memory hasTokens = abi.encodeCall(Combinators.calc, (
    Combinators.CalcOp.Gt,
    callParam(token, abi.encodeCall(IERC20.balanceOf, (addr1)), noConstraints()),
    constParam(10)
));
assertions.assertParam(
    callParam(
        address(combinators),
        abi.encodeCall(Combinators.calc, (
            Combinators.CalcOp.Or,
            comboParam(address(combinators), hasEth),
            comboParam(address(combinators), hasTokens)
        )),
        eq(bytes32(uint256(1)))
    )
);
```

```evml
assertions:assert @bool!((@balance!(ETH $addr1) > 0) or ($token::balanceOf($addr1) > 10))
```

Boolean negation is `unary(IsZero, a)`; the bitwise complement is `unary(Not, a)`.

## Bitmasks

Flag checks on a packed config word, with a constant operand supplying the mask or shift. "`config & MASK != 0`" is an `And` fed into a `Gt 0` (or judged `GTE 1` directly):

```solidity
assertions.assertParam(
    callParam(
        address(combinators),
        abi.encodeCall(Combinators.calc, (
            Combinators.CalcOp.And,
            callParam(configSource, abi.encodeCall(IConfig.packedConfig, ()), noConstraints()),
            constParam(MASK)
        )),
        gte(1)
    )
);
```

"Bit `N` of the config is set" (`(config >> N) & 1 == 1`) nests a `Shr` inside an `And` the same way. In EVMcrispr bitwise expressions are `@bytes!(a "&" b)` (also `|`, `^`, `<<`, `>>`), `@not!(x)` is the complement, and single-arg `@bytes!(x)` is the raw-word cast (e.g. bool to 0/1).

## More composition patterns

**Exponentiation & live decimals scaling.** `Exp = 10` in `CalcOp` gives checked `**` (overflow reverts with `Panic(0x11)`, `0 ** 0 == 1` per EVM semantics). There is no `SExp`: Solidity defines `**` for unsigned operands only. The canonical use is scaling thresholds by a live `decimals()` (EVMcrispr's `@num!` with `^`): "`a` holds at least 5 whole tokens":

```solidity
bytes memory scale = abi.encodeCall(Combinators.calc, (        // 10 ** decimals()
    Combinators.CalcOp.Exp,
    constParam(10),
    callParam(token, abi.encodeCall(IERC20.decimals, ()), noConstraints())
));
bytes memory threshold = abi.encodeCall(Combinators.calc, (   // 5 * 10 ** decimals()
    Combinators.CalcOp.Mul,
    constParam(5),
    comboParam(address(combinators), scale)
));
assertions.assertParam(
    callParam(
        address(combinators),
        abi.encodeCall(Combinators.calc, (
            Combinators.CalcOp.Ge,
            callParam(token, abi.encodeCall(IERC20.balanceOf, (a)), noConstraints()),
            comboParam(address(combinators), threshold)
        )),
        eq(bytes32(uint256(1)))
    )
);
```

```evml
assertions:assert $token::balanceOf($a) >= @num!(5 * 10 ^ $token::decimals())
```

**Conditional select.** Bool returns are 0/1 words that feed straight into arithmetic (no bridging call), enabling an expression-level `if`: `cond * a + (1 - cond) * b` picks `a` when the condition holds and `b` otherwise, composed from three nested `calc` calls.

**Inline asserts.** Operands carry their own constraints, validated as they resolve — a `GTE` on the balance operand inside a larger expression asserts it *and* uses it, in one call.

Nesting is unlimited: an operand can be a `nav`, another `calc`, a comparison feeding an `Or`, and so on. `(pool.token().decimals() + x.value() == 60) && !protocol.paused()` is one judged parameter.

**Expressing other things.** Several patterns need no dedicated functions:

- **Address equality inside expressions**: address returns occupy a single word, so `calc(Eq, ownerCallParam, constParam(uint256(uint160(expectedAddr))))` compares them (a top-level `EQ` constraint remains the direct form).
- **Bool constants**: a constant `true` operand is simply `constParam(1)`; bools are 0/1 words.
- **String operations**: splitting is covered by `data(Split)`, substring search by `data(Includes)`, and only-these-characters checks by `data(Charset)`; concatenation and regex matching are deliberately not included. Instead of building strings on-chain, compare the final value against a constant hash (`data(Hash)` judged `EQ`).

## Semantics to know

- **Checked arithmetic.** `calc` uses Solidity 0.8 semantics: overflow/underflow reverts with `Panic(0x11)` (including `Exp` overflow), division or modulo by zero with `Panic(0x12)`.
- **Signed semantics.** `SDiv` truncates toward zero (`45 / -7 == -6`), `SMod` takes the sign of the dividend (`45 % -7 == 3`, `-45 % 7 == -3`), and `type(int256).min / -1` reverts with `Panic(0x11)`. `AbsDiff`/`SAbsDiff` are total: they return the `uint256` magnitude and never revert on wide spans.
- **Raw words, opcode-carried signedness.** Operands are raw 32-byte words: there is no per-word validation, and bools are their 0/1 words. Use the `S`-prefixed opcode when an operand is signed.
- **No short-circuit.** Logic composition always evaluates both operands (they are resolved before the op is applied); don't rely on `And`/`Or` to skip a reverting operand.
- **Operand failures.** An operand that reverts or targets a code-less address reverts with `CallFailed` identifying it; operands resolving to fewer than 32 bytes revert with `ReturnDataOutOfBounds`; operand constraint violations revert with `ConstraintFailed` (the parameter index names the operand).

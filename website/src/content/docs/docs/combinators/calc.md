---
title: "calc, unary & env: expressions"
description: Arithmetic, comparison, logic and value getters over live on-chain operands.
---

Expressions over call results follow the same composition philosophy as everything else: every operand is a `(target, data)` pair, and operands may themselves be calls to the Combinators contract (`read`, another `calc`, `unary`, `data`, `env`), so expressions nest recursively.

```solidity
function calc (CalcOp op, address target1, bytes data1, address target2, bytes data2) external view returns (uint256);
function unary(UnaryOp op, address target, bytes callData) external view returns (uint256);
function env  (EnvOp op, uint256 arg) external view returns (uint256);
```

One opcode enum covers arithmetic, bitwise and comparison: unsigned ops sit next to their `S`-prefixed signed variants (pick the signed opcode when either operand is an int), and comparisons return 0/1 so they feed straight into boolean composition (`And`/`Or`/`Xor` on 0/1 words) and `assertTrue`.

`AbsDiff`/`SAbsDiff` return the `|a - b|` magnitude as a `uint256` and are total: no underflow, no overflow revert on wide spans, so `AbsDiff(a, b) <= d` with a `Le` assertion expresses live-vs-live approximate equality. For `Shl`/`Shr` the second operand is the shift amount; shifts of 256 or more yield 0 (EVM shift semantics, no revert).

## Value getters

`env` turns non-call quantities into operands: `env(Balance, addr)` (native balance), `env(Timestamp, 0)`, `env(BlockNumber, 0)`, `env(ChainId, 0)`, `env(CodeHash, addr)` (EXTCODEHASH: `bytes32(0)` for a nonexistent account, `keccak256("")` for an existing code-less one), and the literal echo `env(Constant, x)` for comparing a call result against a constant (signed literals pass as their two's-complement word).

When the account is not known at encoding time, `unary(Balance, target, callData)` / `unary(CodeHash, target, callData)` return the native balance / code hash of the address the operand call returns, e.g. the balance of `registry.treasury()`, or the code hash of `proxy.implementation()`:

```solidity
// "The proxy's current implementation is the audited contract"
assertions.assertEqCallBytes32(
    address(combinators),
    abi.encodeCall(Combinators.unary, (
        Combinators.UnaryOp.CodeHash,
        proxy, abi.encodeCall(IProxy.implementation, ())
    )),
    auditedCodeHash
);
```

## Arithmetic

"`addr1`'s ETH balance plus its WETH balance is positive":

```solidity
assertions.assertGtCallUint(
    address(combinators),
    abi.encodeCall(Combinators.calc, (
        Combinators.CalcOp.Add,
        address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Balance, uint256(uint160(addr1)))),
        weth,                abi.encodeCall(IERC20.balanceOf, (addr1))
    )),
    0
);
```

In EVMcrispr the same expression is written directly and compiles to nested `calc` calldata:

```evml
assertions:assert @num!(@balance!(ETH $addr1) + $weth::balanceOf($addr1)) > 0
```

## Logic

Assertions revert on failure, so they cannot be OR-ed; a comparison opcode *returns* the outcome as a 0/1 word instead, and `And`/`Or`/`Xor` combine outcomes (on 0/1 words the bitwise and logical ops coincide). "`addr1` has ETH OR holds more than 10 tokens":

```solidity
bytes memory hasEth = abi.encodeCall(Combinators.calc, (
    Combinators.CalcOp.Gt,
    address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Balance, uint256(uint160(addr1)))),
    address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, 0))
));
bytes memory hasTokens = abi.encodeCall(Combinators.calc, (
    Combinators.CalcOp.Gt,
    token,               abi.encodeCall(IERC20.balanceOf, (addr1)),
    address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, 10))
));
assertions.assertEqCallBool(
    address(combinators),
    abi.encodeCall(Combinators.calc, (
        Combinators.CalcOp.Or,
        address(combinators), hasEth,
        address(combinators), hasTokens
    )),
    true
);
```

```evml
assertions:assert @bool!((@balance!(ETH $addr1) > 0) or ($token::balanceOf($addr1) > 10))
```

Boolean negation is `unary(IsZero, target, data)`; the bitwise complement is `unary(Not, target, data)`.

## Bitmasks

Flag checks on a packed config word, with `env(Constant, ...)` supplying the mask or shift. "`config & MASK != 0`":

```solidity
assertions.assertNeCallUint(
    address(combinators),
    abi.encodeCall(Combinators.calc, (
        Combinators.CalcOp.And,
        configSource,        abi.encodeCall(IConfig.packedConfig, ()),
        address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, MASK))
    )),
    0
);
```

"Bit `N` of the config is set" (`(config >> N) & 1 == 1`) nests a `Shr` inside an `And` the same way. In EVMcrispr bitwise expressions are `@bytes!(a "&" b)` (also `|`, `^`, `<<`, `>>`), `@not!(x)` is the complement, and single-arg `@bytes!(x)` is the raw-word cast (e.g. bool to 0/1).

## More composition patterns

**Exponentiation & live decimals scaling.** `Exp = 10` in `CalcOp` gives checked `**` (overflow reverts with `Panic(0x11)`, `0 ** 0 == 1` per EVM semantics). There is no `SExp`: Solidity defines `**` for unsigned operands only. The canonical use is scaling thresholds by a live `decimals()` (EVMcrispr's `@num!` with `^`): "`a` holds at least 5 whole tokens":

```solidity
bytes memory scale = abi.encodeCall(Combinators.calc, (        // 10 ** decimals()
    Combinators.CalcOp.Exp,
    address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, 10)),
    token,                abi.encodeCall(IERC20.decimals, ())
));
bytes memory threshold = abi.encodeCall(Combinators.calc, (   // 5 * 10 ** decimals()
    Combinators.CalcOp.Mul,
    address(combinators), abi.encodeCall(Combinators.env, (Combinators.EnvOp.Constant, 5)),
    address(combinators), scale
));
assertions.assertEqCallBool(
    address(combinators),
    abi.encodeCall(Combinators.calc, (
        Combinators.CalcOp.Ge,
        token,                abi.encodeCall(IERC20.balanceOf, (a)),
        address(combinators), threshold
    )),
    true
);
```

```evml
assertions:assert $token::balanceOf($a) >= @num!(5 * 10 ^ $token::decimals())
```

**Conditional select.** Bool returns are 0/1 words that feed straight into arithmetic (no bridging call), enabling an expression-level `if`: `cond * a + (1 - cond) * b` picks `a` when the condition holds and `b` otherwise, composed from three nested `calc` calls.

Nesting is unlimited: an operand can be a `read`, another `calc`, a comparison feeding an `Or`, and so on. `(pool.token().decimals() + x.value() == 60) && !protocol.paused()` is one `assertTrue` call.

**Expressing other things.** Several patterns need no dedicated functions:

- **Address equality inside expressions**: address returns occupy a single word, so `calc(Eq, target, ownerCall, combinators, env(Constant, uint256(uint160(expectedAddr))))` compares them (the top-level `assertEqCallAddress` remains the direct form).
- **Bool constants**: a constant `true` operand is simply `env(Constant, 1)`; bools are 0/1 words.
- **String operations**: splitting is covered by `data(Split)`, substring search by `data(Includes)`, and only-these-characters checks by `data(Charset)`; concatenation and regex matching are deliberately not included. Instead of building strings on-chain, compare the final value against a constant (`assertEqCallStringN`) or its hash (`data(Hash)`).

## Semantics to know

- **Checked arithmetic.** `calc` uses Solidity 0.8 semantics: overflow/underflow reverts with `Panic(0x11)` (including `Exp` overflow), division or modulo by zero with `Panic(0x12)`.
- **Signed semantics.** `SDiv` truncates toward zero (`45 / -7 == -6`), `SMod` takes the sign of the dividend (`45 % -7 == 3`, `-45 % 7 == -3`), and `type(int256).min / -1` reverts with `Panic(0x11)`. `AbsDiff`/`SAbsDiff` are total: they return the `uint256` magnitude and never revert on wide spans.
- **Raw words, opcode-carried signedness.** Operands are raw 32-byte words: there is no per-word validation, and bools are their 0/1 words. Use the `S`-prefixed opcode when an operand is signed.
- **No short-circuit.** Logic composition always evaluates both operands (they are view calls executed before the op is applied); don't rely on `And`/`Or` to skip a reverting operand.
- **Operand failures.** An operand that reverts or targets a code-less address reverts with `CallFailed` identifying it; operands returning fewer than 32 bytes revert with `ReturnDataOutOfBounds`.

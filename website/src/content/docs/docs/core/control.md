---
title: "cond, orElse & ok: resolution control"
description: Lazy branching, composable try/catch and failure probes over unresolved ERC-8211 operands.
---

Constraints revert or pass; the [read primitives](/docs/core/reads) select and construct. The third family decides *whether* operands resolve at all. These are the clearest case of the core's admission test: a branch that must not execute can only be held by code that speaks the ERC-8211 `InputParam` format, because an unresolved operand is data, not a call. Ordinary Solidity arguments are evaluated before the call; `InputParam` operands are not.

```solidity
function cond  (InputParam c, InputParam then_, InputParam else_) external view; // raw return
function orElse(InputParam a, InputParam b) external view;                       // raw return
function ok    (InputParam a) external view returns (uint256);
```

All three return like the other primitives: the selected value comes back via a raw assembly return (`ok` as a normal word), so they nest inside any operand and feed any constrained fetcher.

The examples reuse the `callParam`/`eq`/`gte`/`noConstraints` helpers from [the Solidity guide](/docs/solidity), plus a literal operand:

```solidity
/// A literal operand: the RAW_BYTES fetcher echoes the bytes.
function rawParam(bytes memory v) pure returns (InputParam memory) {
    return InputParam(
        InputParamType.CALL_DATA,
        InputParamFetcherType.RAW_BYTES,
        v,
        new Constraint[](0)
    );
}
```

## cond: branch on a value

`cond(c, then_, else_)` resolves the condition, then resolves and returns ONLY the winning branch. The losing branch is never resolved, so its calls never happen: a branch may target a contract that reverts, or that does not exist yet, and the expression still evaluates.

Truth is EVM truthiness: the first 32-byte word of the resolved condition, nonzero = true. [Operators](/docs/operators/words) comparisons return 0/1 words, so they compose directly as conditions; a condition resolving to fewer than 32 bytes reverts with `ReturnDataOutOfBounds`.

```solidity
// "the vault's spendable amount is at least min": staked() while locked,
// balance() otherwise, and the losing call never happens
bytes memory spendable = abi.encodeCall(Assertions.cond, (
    callParam(vault, abi.encodeCall(IVault.locked, ()), noConstraints()),
    callParam(vault, abi.encodeCall(IVault.staked, ()), noConstraints()),
    callParam(vault, abi.encodeCall(IVault.balance, ()), noConstraints())
));
assertions.assertParam(callParam(address(assertions), spendable, gte(minSpendable)));
```

The condition resolves normally, fetcher plus full constraint validation: a violated condition constraint reverts the whole `cond`. Branching on a *failure* is `orElse`'s job; branching on a *value* is `cond`'s. The winning branch is resolved (constraints included) and returned byte-identically, indistinguishable from resolving that branch directly. In resolution errors the condition is operand 0, the then-branch operand 1, the else-branch operand 2.

## orElse: branch on a failure

`orElse(a, b)` resolves `a`; if that reverts for ANY reason, it resolves and returns `b` instead. It is the composable try/catch:

```solidity
// name() on a token that may not implement it: any revert selects the literal
bytes memory name = abi.encodeCall(Assertions.orElse, (
    callParam(token, abi.encodeCall(IERC20.name, ()), noConstraints()),
    rawParam(abi.encode("unknown"))
));
```

ALL failures of the attempt select the fallback: a reverting or code-less call target, malformed data, a violated constraint. That last one is the **constraint-as-guard pattern**: an operand's inline constraints, which normally turn expression nodes into asserts, double as admission tests when the operand sits in an `orElse` attempt. "Use the oracle price only when it is positive, otherwise the TWAP" is one guarded operand:

```solidity
InputParam memory guarded = callParam(oracle, abi.encodeCall(IOracle.price, ()), gte(1));
bytes memory price = abi.encodeCall(Assertions.orElse, (
    guarded,
    callParam(twap, abi.encodeCall(ITwap.price, ()), noConstraints())
));
```

On success the attempt's bytes pass through byte-identically. The fallback resolves in-frame: its failures propagate (in resolution errors `b` is operand 1). For more than one fallback, chain `orElse` operands: `orElse(a, orElse(b, c))` tries three sources in order.

## ok: probe a resolution

`ok(a)` collapses the same question to a word: 1 when `a` resolves without reverting (constraints included), 0 otherwise. Point a constrained fetcher at it to assert that a call *succeeds* (`EQ 1`) or, just as usefully, that it *fails* (`EQ 0`):

```solidity
// "the legacy oracle no longer answers": the probe must come back 0
bytes memory probe = abi.encodeCall(Assertions.ok, (
    callParam(legacyOracle, abi.encodeCall(IOracle.latestAnswer, ()), noConstraints())
));
assertions.assertParam(callParam(address(assertions), probe, eq(bytes32(0))));
```

Because the result is a 0/1 word, `ok` also feeds `cond` directly, branching on resolvability instead of on a value.

## The staticcall boundary (and the OOG caveat)

`orElse` and `ok` run the attempt behind an external self-staticcall boundary, `address(this).staticcall(abi.encodeCall(this.resolve, (a)))`: the EVM's only catch primitive. That boundary is what makes "any revert" catchable, and it has one documented edge: out-of-gas inside the subframe is also caught. The 63/64 rule (the outer frame keeps at least 1/64 of the gas) means a genuine OOG usually re-reverts in the outer frame anyway, but with a large gas limit and a cheap fallback, an OOG deep inside the attempt can masquerade as "the attempt failed". Treat `orElse` and `ok` as answering "did it resolve", never "why did it fail", and do not lean on them to distinguish failure causes under adversarial gas.

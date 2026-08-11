---
title: "cond, orElse, isValid & revertData: resolution control"
description: Lazy branching, composable try/catch and failure probes over unresolved ERC-8211 operands.
---

Constraints revert or pass; the [read primitives](/docs/core/reads) select and construct. The third family decides *whether* operands resolve at all. These are the clearest case of the core's admission test: a branch that must not execute can only be held by code that speaks the ERC-8211 `InputParam` format, because an unresolved operand is data, not a call. Ordinary Solidity arguments are evaluated before the call; `InputParam` operands are not.

```solidity
function cond      (InputParam c, InputParam then_, InputParam else_) external view; // raw return
function orElse    (InputParam a, InputParam b) external view;                       // raw return
function isValid   (InputParam a) external view returns (uint256);
function revertData(InputParam a, bytes4 expectedSelector) external view;            // raw return
```

All four return like the other primitives: the selected value comes back via a raw assembly return (`isValid` as a normal word), so they nest inside any operand and feed any constrained fetcher.

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

The EVML surface for this primitive is std's `@ifElse!(cond ? then : else)`.

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

## isValid: probe a resolution

`isValid(a)` collapses the same question to a word: 1 when `a` resolves *and passes its constraints*, 0 otherwise. Point a constrained fetcher at it to assert that a call *succeeds* (`EQ 1`) or, just as usefully, that it *fails* (`EQ 0`):

```solidity
// "the legacy oracle no longer answers": the probe must come back 0
bytes memory probe = abi.encodeCall(Assertions.isValid, (
    callParam(legacyOracle, abi.encodeCall(IOracle.latestAnswer, ()), noConstraints())
));
assertions.assertParam(callParam(address(assertions), probe, eq(bytes32(0))));
```

Because the result is a 0/1 word, `isValid` also feeds `cond` directly, branching on resolvability instead of on a value (in EVML: `@ifElse!(@bool!(not @reverts!(…)) ? a : b)`).

## revertData: the reason a call fails

`isValid` answers *whether*; `revertData(a, expectedSelector)` answers *why*. It takes a `STATIC_CALL` operand (unconstrained — the call itself is the subject) and performs its staticcall **in its own frame**, so the target's revert data survives; the routes the other probes take convert a revert into the core's own `CallFailed` and the reason is lost. A call that *succeeds* reverts with `DidNotRevert` — an assertion that a call fails is not satisfied by it working.

With a non-zero `expectedSelector` the first four bytes of the revert data must match — a mismatch reverts with `UnexpectedRevertData(expected, actual)` — and the selector is **stripped** from the result: what returns is the error's ABI-encoded arguments, word-aligned, so `pick` and `nav` navigate them exactly as they navigate a call's return. A zero selector accepts any revert and passes the data through whole.

```solidity
// "withdraw(100) still fails with InsufficientBalance, and the shortfall
// it reports is at least 100": nav selects argument 1 of the stripped
// payload, and the constraint judges it like any other read.
bytes memory probe = abi.encodeCall(Assertions.revertData, (
    callParam(vault, abi.encodeCall(IVault.withdraw, (100)), noConstraints()),
    IVault.InsufficientBalance.selector
));
int256[] memory path = new int256[](1);
path[0] = 1;
bytes memory nav = abi.encodeCall(Assertions.nav, (
    callParam(address(assertions), probe, noConstraints()), "(uint256,uint256)", path
));
assertions.assertParam(callParam(address(assertions), nav, gte(100)));
```

Compose the two for "reverted with this reason" as a word: `isValid(revertData(a, sel))` is 1 exactly when `a` reverts with the expected error. And note what the in-frame call implies: the reason `revertData` observes belongs to whatever the operand calls *directly*. A nested core expression is itself a staticcall into the core, so probing one reports the core's own error — reason matching only makes sense on a direct target call.

## The staticcall boundary (and the OOG caveat)

`orElse` and `isValid` run the attempt behind an external self-staticcall boundary, `address(this).staticcall(abi.encodeCall(this.resolve, (a)))`: the EVM's only catch primitive (`revertData` staticcalls the target in-frame, but catches the same way). That boundary is what makes "any revert" catchable, and it has one documented edge: out-of-gas inside the subframe is also caught. The 63/64 rule (the outer frame keeps at least 1/64 of the gas) means a genuine OOG usually re-reverts in the outer frame anyway, but with a large gas limit and a cheap fallback, an OOG deep inside the attempt can masquerade as "the attempt failed". Treat `orElse` and `isValid` as answering "did it resolve", never "why did it fail" — that is `revertData`'s job, and even it cannot tell an OOG from a bare revert — and do not lean on any of them to distinguish failure causes under adversarial gas.

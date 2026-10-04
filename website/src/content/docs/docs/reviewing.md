---
title: Reviewing an assertion
description: How to read an assertion in a transaction you are about to sign or vote on, and what to check before you do.
---

You are a Safe signer, a voter or an auditor, and the batch in front of you contains calls to the Assertions contract. You did not write them. This page explains what those calls say, what they cannot say, and what to check before you approve.

If the batch came from an EVML script, read the script first: it is shorter and says the same thing. This page is for when you have only the calldata, or want to confirm that the calldata matches the script.

## One assertion, decoded

Every assertion is a call to the Assertions contract, usually `assertParam(param, message)`. The `param` is a predicate in the [ERC-8211 (Smart Batching)](https://eips.ethereum.org/EIPS/eip-8211) format, so any tool that reads that standard can read it: the field names below (`InputParam`, fetcher, constraints) are the standard's. Here is one, as an explorer or a Safe interface shows it once it has the contract's ABI. It asserts that a token's balance for the treasury is at least 100 tokens.

```text
assertParam(
  param = (
    paramType   = 2                       CALL_DATA
    fetcherType = 1                       STATIC_CALL
    paramData   = (
      target    = 0x2222…2222             the token
      callData  = balanceOf(0x1111…1111)  the treasury
    )
    constraints = [
      (GTE, 0x…56bc75e2d63100000)         100e18
    ]
  )
  message = "treasury below floor"
)
```

Read it in three parts:

1. **The fetcher** says how the value is obtained. `STATIC_CALL` means: call `target` with `callData` and take what it returns. This one reads `balanceOf(treasury)` on the token.
2. **The constraints** say what the value must satisfy. `GTE` with `100e18` means the returned number must be greater than or equal to 100 tokens (in 18-decimal units).
3. **The message** is what the revert carries if a constraint fails.

The `paramType` is routing information for batches that construct calls. For a plain assertion you can ignore it.

In EVML, the same assertion is:

```evml
assert $token::!{balanceOf(address)(uint256) $treasury} >= 100e18 "treasury below floor"
```

## Fetchers and constraints

A fetcher is one of three kinds: `RAW_BYTES` is a literal stored in the calldata, `STATIC_CALL` is the return data of a read-only call, and `BALANCE` is a native or ERC-20 balance.

Constraint `i` judges word `i` of the fetched value. A one-word value, which is most of them, has one constraint: `EQ`, `GTE`, `LTE`, a range (`IN`), one of several alternatives (`OR`), or `SKIP`, which judges nothing. The Assertions page describes [each fetcher](/docs/contracts/assertions#the-three-fetchers) and [each constraint](/docs/contracts/assertions#wire-format-and-constraints) in full.

Look at the signedness. `GTE`, `LTE` and `IN` compare unsigned numbers, and `GTE_SIGNED`, `LTE_SIGNED` and `IN_SIGNED` compare signed ones. A signed value judged with an unsigned constraint reads negative numbers as huge positive ones.

## Assertions built from other reads

Most assertions are not one read. When the `target` of a `STATIC_CALL` is the Assertions contract itself, the fetcher is calling one of its own primitives, and the value is built from other operands. You will see these:

| In the calldata | It means |
|-----------------|----------|
| `chain` | Read an address from one call and use it as the target of the next. |
| `pick`, `nav` | Select one value out of a call that returns several, or out of an array or struct. |
| `read`, `get` | Build a call whose arguments come from other reads, at execution time. |
| `cond`, `orElse`, `isValid` | Choose between operands, try one and fall back, or ask "does this read succeed". |
| `gather` | Collect several reads into one list. |

When the target is the Operations contract, the call is arithmetic or a comparison on values already read: `add`, `mulDiv`, `gt`, `hash`, `indexOf`, and so on. When it is Collections, the call runs over a list: `allValues`, `anyValues`, `filterValues`, `sumWords`. Expressions evaluates a named graph of operands.

You do not need the details to review. Read nested assertions from the inside out: the innermost call is a plain read, and each layer above it takes that value and does one thing to it. The [contract pages](/docs/contracts) list every primitive if you want to look one up.

## What to check before approving

1. **Is the Assertions address the canonical one?** An assertion that calls a different contract proves nothing. Compare the address with [Deployments](/docs/contracts/deployments) for your chain.
2. **Does a failure revert the whole batch?** An executor that tolerates failed calls can keep the earlier actions. [Executors](/docs/guides/executors) says what a Safe, a Governor, an Aragon OSx DAO and a wallet each do.
3. **Is the assertion before or after the action it protects?** An outcome check placed before the action checks nothing about the outcome. See [placement](/docs/guides/executors#placement).
4. **Does the value read match what the message claims?** "Ownership compromised" on a check of `totalSupply()` is a bad sign. Match the contract, function and arguments to the claim.
5. **Could the condition pass whatever happens?** A `GTE 0` is true for every unsigned number. A range of `0` to `type(uint256).max` is the same. A check on the wrong word of a multi-value return can also pass trivially.
6. **Is the type right?** A return declared as `uint256` that is really an address reads a number. The contract checks that the encoding is valid for the declared type, not that the declaration is true.
7. **Does it have constraints at all?** An assertion with an empty constraint list only checks that the read succeeds. It does not judge the value.

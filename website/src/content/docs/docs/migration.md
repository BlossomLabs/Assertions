---
title: Migrating from Argos (v1)
description: "What changes between Assertions 1.0 (Argos) and v2 (Byakko), what keeps working at the old address, and how to move your assertions."
---

You already have assertions that call Argos (v1), the original contract. This page tells you what keeps working, what is different in Byakko (v2), and what to redo to move. For the releases themselves, see [Argos (v1)](/releases/argos) and [Byakko (v2)](/releases/byakko).

## Nothing breaks at the old address

Argos (v1) is deployed at `0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F`. It has no owner, no admin functions and no storage, and Byakko (v2) does not touch it. A batch, a queued proposal or a Safe transaction that calls Argos (v1) behaves as it did. You never have to migrate; you migrate to get what Argos (v1) cannot do.

One thing to check: `assertions.eth` used to resolve to Argos (v1) and now resolves to Byakko (v2). Argos (v1) is `argos.assertions.eth`. If a script resolves `assertions.eth` by name and you want Argos (v1), use `argos.assertions.eth` or the address above.

## What is new

- **Four contracts.** Assertions is the main contract. Operations, Collections and Expressions are expansion packs for calculations, lists and reused values (see [The four contracts](/docs/contracts)).
- **Live values on both sides.** Argos (v1) compared a call's result with a value fixed in the calldata. Byakko (v2) can compare a live read with another live read, do arithmetic, follow an address returned by one contract into another, fall back when a read reverts, and check every item in a list.
- **EVML.** You write `assert` lines and the [builder](/builder) compiles them. See [Writing assertions in EVML](/docs/evml).
- **Signed comparisons and ranges** are part of the constraint set (see [Assertions](/docs/contracts/assertions)).

## What changed

Argos (v1) had 98 functions: 49 checks, each with a variant that takes a message. The names were `assertEqCallUint`, `assertGeCallUint`, `assertEqCallAddress`, `assertTrue`, `assertEqCallBytes`, `assertEqCallUintN`, `assertEqCallArrayLength`, `assertApproxEqCallUint`, `assertEqBalance`, `assertGtBlockTimestamp`, `assertEqChainId`, `assertEqCodeHash`, `assertHasCode` and so on.

Assertions in Byakko (v2) has none of them. Its judge is four functions:

```solidity
function assertParam(InputParam calldata param) external view;
function assertParam(InputParam calldata param, string calldata message) external view;
function assertBatch(ComposableExecution[] calldata executions) external view;
function assertBatch(ComposableExecution[] calldata executions, string calldata message) external view;
```

Each check is now an `InputParam`: a way to get a value (a staticcall, a native or token balance, or a literal) plus constraints on it. Around the judge sit the primitives `resolve`, `gather`, `pick`, `nav`, `chain`, `read`, `get`, `cond`, `orElse`, `isValid` and `revertData`. Calldata built for an Argos (v1) function does not work on the new address.

The failure error changed too. Argos (v1) reverted with a typed error per value kind, for example `AssertionFailedUint(string assertion, uint256 actual, uint256 expected)`. Byakko (v2) reverts with one error, `ConstraintFailed(string, uint256, uint256, uint256, ConstraintType, bytes32, bytes)`, carrying your message, the entry and parameter index, the constraint index and kind, the value it saw and the reference. `CallFailed(address, bytes)` exists in both. If something parses revert data, update it. The default message also differs: with none given, Argos (v1) functions reported short tags such as `NE`, and Byakko (v2) reports `PARAM` (`assertParam`) or `COMPOSABLE` (`assertBatch`).

## In Argos (v1), in Byakko (v2)

| In Argos (v1) | In Byakko (v2) |
|----------|-----------|
| `assertGeCallUint(target, data, n, msg)` | `assert <call>::!{fn(args)(uint256)} >= n "msg"` |
| `assertEqCallAddress`, `assertEqCallBool`, `assertEqCallBytes32` | `assert <call> == value "msg"` |
| `assertTrue`, `assertFalse` | `assert <call>` (requires true), or `== false` |
| `assertNeCall…` | `!=` |
| `assertEqCallUintN(target, data, index, n)` | a lens that picks the value: `<call>[_ $ _] == n` |
| `assertEqCallStringN`, `assertEqCallBytes` | `==` on a string, or `@hash!(call bytes)` for `bytes` |
| `assertEqCallArrayLength`, `assertGtCallArrayLength`, `assertGeCallArrayLength` | `@len!(call)` with a comparison (needs `load lang`) |
| `assertApproxEqCallUint`, `assertApproxEqBalance` | `~=` with `--delta` |
| `assertEqBalance` and the other balance checks | `@balance!(ETH account)` or `@balance!(token account)` |
| `assertEqBlockNumber`, `assertEqBlockTimestamp` | `@block.number!`, `@block.timestamp!` (needs `load receipts`) |
| `assertEqChainId` | `@chainId!` (needs `load receipts`) |
| `assertEqCodeHash` | `@codeHash!(address)` (needs `load contracts`) |
| One Argos (v1) call, one value | one `assert` line; lines can nest, branch and run over lists |

The first rows as EVML:

```evml
load token
load lang

assert @token(WETH)::!{balanceOf(address)(uint256) $treasury} >= 100e18 "treasury below floor"
assert @balance!(ETH $recipient) >= 10e18 "recipient not paid"
assert $pool::!{getReserves()(uint112,uint112,uint32)}[_ $ _] >= 1000 "low reserve"
```

## How to move

1. **Use the new addresses.** Assertions is at `0xa55e47A8F0701e231a9c0ac916776074e5c561d5`, and the expansion packs have their own addresses. Copy them from [Deployments](/docs/contracts/deployments). The contracts must exist on the chain you execute on.
2. **Rewrite each Argos (v1) call as an `assert` line**, using the table. Do it in the [builder](/builder), which writes the EVML and the calldata, rather than encoding calls by hand.
3. **Keep placement.** An Argos (v1) call placed before or after an action meant a precondition or a postcondition. Keep each check on the same side of the action it guarded.
4. **Simulate.** The builder simulates the batch on a fork with the assertions in place. Change a threshold so it must fail and confirm that it reverts with your message.
5. **Hand-written calldata.** If you built calldata outside the builder, regenerate it. Nothing encoded for Argos (v1) is valid on the new address.

## What to re-check

- **Tuple indexes.** The tuple-indexed checks in Argos (v1) (`assertEqCallUintN` and the other `N` variants) read the word at your index straight from the returned data, without checking that it exists. An index past the end reads unrelated memory, so such an assertion could pass or fail for the wrong reason. Byakko (v2) reverts with `ReturnDataOutOfBounds` when the data is too short for a read. If a rewritten assertion starts failing, check its index first.
- **Types are your claim.** In Argos (v1) the function name fixed the type (`…Uint`, `…Address`). In EVML you write the return type in the line, and a wrong one reads the wrong value. Byakko (v2) rejects a word that is out of range for the type you declared, but it cannot tell an address from a number of the same shape.
- **Executor behavior.** A failed assertion rolls back the batch only when the executor lets a failing call fail the whole batch. This was true for Argos (v1) too. See [Executors](/docs/guides/executors).
- **Gas.** Each read in a Byakko (v2) assertion is an external call, so a rewritten check can cost more than the Argos (v1) call it replaces. Simulate the whole batch and check its gas.

## Versions and addresses

The contracts are not upgradeable. They have no owner, no proxy, no storage and no delegatecall, so deployed code never changes. A new version is a new deployment at a new address, because any change to the source changes the address the contract deploys to. Each of the four contracts versions on its own.

The current addresses are on [Deployments](/docs/contracts/deployments), together with the chains where they are deployed. The same page lists Argos (v1) as the earlier release. An old deployment keeps working at its address after a new one ships, and nothing is redirected. A script that pins an address keeps its behavior; one that follows a bare ENS name, such as `assertions.eth`, moves with the latest release.

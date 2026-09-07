---
title: Overview
description: What Assertions is, how the four contracts split responsibilities, and where they live.
---

Assertions is an on-chain assertion system for verifying view function return values and blockchain state. Assertion calls are batched alongside the transactions they guard: if any assertion fails, the entire transaction reverts, atomically.

It ships as **four contracts** with one tagline: **the core reads and judges; the periphery computes.**

- **`Assertions` (the frozen core)** is the judge, designed around [ERC-8211 (Smart Batching)](https://eips.ethereum.org/EIPS/eip-8211), plus every primitive that speaks the ERC-8211 wire format. An assertion IS an ERC-8211 predicate: an `InputParam` describes how to fetch a live value (a raw literal, a `staticcall`, or a balance read) and carries inline constraints (`EQ`, `GTE`, `LTE`, `IN`) the value must satisfy. `assertParam` judges one parameter (the 90% case) and `assertBatch` judges whole batches; a failing constraint reverts with a descriptive `ConstraintFailed` error. Around the judge sit nine primitives in three families: selection ([`resolve`, `pick`, `nav`](/docs/core/reads)), call construction ([`chain`, `read`](/docs/core/reads)) and resolution control ([`cond`, `orElse`, `isValid`, `revertData`](/docs/core/control)).
- **`Operations` (the versionable periphery)** is the scalar computation vocabulary: named word arithmetic and comparisons (with int256 overloads for signed semantics), 512-bit and fixed-point math, bitwise operations, environment reads, bytes and string operations, decimal parsing and a runtime ABI encoder. Every function takes and returns plain ABI types, with zero ERC-8211 anywhere. Composition happens in the core: its `read` primitive resolves operand expressions and splices the values into plain Operations calldata, so expressions nest recursively and the judge consumes the final value through a `STATIC_CALL` fetcher pointed at the core. Any deployed view or pure contract extends the vocabulary the same way; Operations is the canonical first extension.
- **`Collections`** owns iteration: the bounded folds and the word-array family (map, filter, sort, deduplicate, zip, sum over aligned 32-byte payloads), plus the generic ABI-valued family that maps, filters, folds, sorts and traverses arrays of whole canonical values through typed callbacks. Both sorting paths are stable bottom-up merge sorts.
- **`Expressions`** adds typed expression graphs and resolve-once call construction. A raw `InputParam` is a tree that cannot name a subterm, so a repeated expression is duplicated in calldata and resolved again each time; a graph references earlier nodes, evaluates each once per evaluation, binds whole canonical ABI values, branches lazily with a `Select` judged like the core's `cond`, and evaluates guarded attempts. The SDK emits graphs for generic collection callbacks and for recipes that share a resolved value, and `Collections.Callback.expression` runs them per element. See [Expressions](/docs/operators/expressions).

The core's admission test decides what lives where: only what needs operands to arrive *unresolved* (ERC-8211 `InputParam`s) lives on the frozen core; scalar computation over resolved values belongs to Operations, iteration to Collections and expression graphs to Expressions. Because the periphery contracts are stateless view targets reached through `read`, they can evolve: old deployments never break (anything referencing them keeps working), and new versions ship at new addresses as pure opt-ins, without touching the frozen core. The design rules behind this split are recorded in the repository's [`AGENTS.md`](https://github.com/blossomlabs/Assertions/blob/master/AGENTS.md).

## Where the contracts live

Every contract has the same CREATE2 address on every chain. The current addresses, the retired candidates and the earlier releases are listed once, on the [Deployments](/docs/reference/deployments) page, rendered from the deployment manifest; listing an address implies no public-chain deployment.

## Why assertions?

**Secure DAO proposals.** Governance proposals often execute complex multi-step transactions. A malicious or buggy proposal could drain the treasury, change critical permissions, or break protocol invariants. By including assertion calls in your proposals, you guarantee that certain conditions hold before and after execution, or the entire transaction reverts.

**Safe transaction guards.** When using multisig wallets like [Safe](https://safe.global/), batch assertion calls alongside your actual transactions to verify pre-conditions, post-conditions and protocol invariants, and to catch unexpected state changes.

**On-chain invariant enforcement.** Unlike off-chain simulations that can be fooled by MEV or state changes between submission and execution, on-chain assertions execute atomically with your transaction. No partial execution, no unexpected outcomes.

| Scenario | Example |
|----------|---------|
| **Treasury protection** | Assert treasury balance doesn't drop below threshold |
| **Permission safety** | Assert admin roles haven't been changed unexpectedly |
| **Price manipulation guards** | Assert oracle price is within expected bounds |
| **Upgrade verification** | Assert proxy implementation matches expected code hash |
| **Timelock validation** | Assert current timestamp is after unlock period |
| **Liquidity checks** | Assert pool reserves meet minimum requirements |
| **Ownership verification** | Assert critical contracts still owned by DAO |
| **Deep reads** | Assert a struct field inside a returned array, at any nesting depth |
| **String guards** | Assert a name ends with "LP", contains a substring, or stays within a charset |
| **Live arguments** | Call a view function with arguments read on-chain at assertion time |
| **Graceful fallbacks** | Try one source, fall back to another when it reverts, and branch lazily |

## Features

- **ERC-8211 native**: assertions are standard Smart Batching predicate entries; batches built by any ERC-8211 SDK judge here unchanged
- **Inline constraints**: `EQ`, `GTE`, `LTE` and `IN` (inclusive range) validate any fetched value ([how constraints judge](/docs/core/reads#constraints))
- **Three fetchers**: raw literals, arbitrary `staticcall`s, and balance reads (native or ERC-20); one `assertParam` call covers balances, view returns and constants alike
- **Core reads**: raw word selection (`pick`), typed navigation into tuples and dynamic arrays (`nav`), runtime-address chains (`chain`) and runtime-argument calls (`read`), all composable from recursive `InputParam` operands
- **Resolution control**: lazy branching (`cond`), composable try/catch with constraints doubling as guards (`orElse`), and did-it-resolve probes (`isValid`) and the reason-carrying failure probe (`revertData`)
- **Operations vocabulary**: named arithmetic, comparisons, bitwise, environment, bytes, search, a runtime ABI encoder, readable directly in decoded explorer calldata
- **Collections**: bounded folds, word-array shape operations and generic ABI-valued traversals with typed callbacks
- **Nested live call arguments**: use the result of one view call as an argument of another, resolved at assertion time via the core's `read`
- **Approximate equality**: the `IN` constraint asserts a value within inclusive bounds; `absDiff(a, b)` judged `LTE d` covers live-vs-live tolerance
- **Custom error messages**: every judge function has an overload accepting a custom message

## Where to go next

- [Using assertions from Solidity](/docs/solidity): complete examples for DAO proposals, Safe batches and upgrades
- [Core reads](/docs/core/reads) and [resolution control](/docs/core/control): the frozen core's nine primitives
- [Operations](/docs/operators), [Collections](/docs/operators/collections) and [Expressions](/docs/operators/expressions): the computation vocabulary and how `read` splicing composes it
- [EVMcrispr integration](/docs/evml): writing assertions as one-line EVML scripts, and the [visual builder](/builder)
- [Core reference](/docs/reference/core) and [error reference](/docs/reference/errors)
- [Deployments](/docs/reference/deployments): canonical addresses, CREATE2 mechanics and deploying to new chains

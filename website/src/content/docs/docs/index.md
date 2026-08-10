---
title: Overview
description: What Assertions is, how the two contracts split responsibilities, and where they live.
---

Assertions is an on-chain assertion system for verifying view function return values and blockchain state. Assertion calls are batched alongside the transactions they guard: if any assertion fails, the entire transaction reverts, atomically.

It ships as **two contracts** with one tagline: **the core reads and judges; Operators compute.**

- **`Assertions` (the frozen core)** is the judge, designed around [ERC-8211 (Smart Batching)](https://eips.ethereum.org/EIPS/eip-8211), plus every primitive that speaks the ERC-8211 wire format. An assertion IS an ERC-8211 predicate: an `InputParam` describes how to fetch a live value (a raw literal, a `staticcall`, or a balance read) and carries inline constraints (`EQ`, `GTE`, `LTE`, `IN`) the value must satisfy. `assertParam` judges one parameter (the 90% case) and `assertComposable` judges whole batches; a failing constraint reverts with a descriptive `ConstraintFailed` error. Around the judge sit eight primitives in three families: selection ([`resolve`, `pick`, `nav`](/docs/core/reads)), call construction ([`chain`, `read`](/docs/core/reads)) and resolution control ([`cond`, `orElse`, `ok`](/docs/core/control)). The admission test for the core: only what needs operands to arrive *unresolved* lives there.
- **`Operators` (the versionable periphery)** is the computation vocabulary: named word arithmetic and comparisons (with int256 overloads for signed semantics), bitwise operations, environment reads, bytes and string operations, a runtime ABI encoder and bounded folds. Every function takes and returns plain ABI types, with zero ERC-8211 anywhere. Composition happens in the core: its `read` primitive resolves operand expressions and splices the values into plain Operators calldata, so expressions nest recursively and the judge consumes the final value through a `STATIC_CALL` fetcher pointed at the core. Any deployed view or pure contract extends the vocabulary the same way; Operators is the canonical first extension.

Because Operators is a stateless view target reached only through `read`, the periphery can evolve: old deployments never break (anything referencing them keeps working), and new versions ship at new addresses as pure opt-ins, without touching the frozen core.

## Current addresses (interim)

The current deployments are **interim, non-vanity addresses**: the bytecode is still in flux, and the vanity `0xa55E...` addresses will be re-mined before the canonical roll (see [Deployments](/docs/reference/deployments)):

```
Assertions v2.0  0x637d99Ff8bcB919e5203b0B96Ad0520A9943a32C   (frozen core: judge + primitives)
Operators  v1.0  0x8a9E5b20C8d2Eb57aA69bCF4C5E8eF5715a63876   (versionable periphery)
```

Earlier versions remain deployed and working forever at their own canonical addresses: the v2.0-rc core at [`0xa55E47F37088b6D0212BdfD56b175ec08744DB19`](https://etherscan.io/address/0xa55E47F37088b6D0212BdfD56b175ec08744DB19) with Combinators v2.0-rc at [`0xA55Ec0935FB5aaf95CAC1F48DD822005d91b64b9`](https://etherscan.io/address/0xA55Ec0935FB5aaf95CAC1F48DD822005d91b64b9), the v1.1 typed-assert core at [`0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0`](https://etherscan.io/address/0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0), and the original v1.0 core at [`assertions.eth`](https://etherscan.io/address/0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F). V2 replaces v1.1's 140 typed assertion functions (`assertEqCallUint`, ...) with the ERC-8211 model: `assertEqCallUint(target, data, expected)` is now `assertParam` over a `STATIC_CALL` fetcher with an `EQ` constraint.

## Why assertions?

**Secure DAO proposals.** Governance proposals often execute complex multi-step transactions. A malicious or buggy proposal could drain the treasury, change critical permissions, or break protocol invariants. By including assertion calls in your proposals, you guarantee that certain conditions hold before and after execution, or the entire transaction reverts.

**Safe transaction guards.** When using multisig wallets like [Safe](https://safe.global/), batch assertion calls alongside your actual transactions to verify pre-conditions, post-conditions and protocol invariants, and to catch unexpected state changes.

**On-chain invariant enforcement.** Unlike off-chain simulations that can be fooled by MEV or state changes between submission and execution, on-chain assertions execute atomically with your transaction. No partial execution, no unexpected outcomes.

| Scenario | Example |
|----------|---------|
| **Treasury protection** | Assert treasury balance doesn't drop below threshold |
| **Permission safety** | Assert admin roles haven't been changed unexpectedly |
| **Price manipulation guards** | Assert oracle price is within expected bounds |
| **Upgrade verification** | Assert proxy implementation matches expected codehash |
| **Timelock validation** | Assert current timestamp is after unlock period |
| **Liquidity checks** | Assert pool reserves meet minimum requirements |
| **Ownership verification** | Assert critical contracts still owned by DAO |
| **Deep reads** | Assert a struct field inside a returned array, at any nesting depth |
| **String guards** | Assert a name ends with "LP", contains a substring, or stays within a charset |
| **Live arguments** | Call a view function with arguments read on-chain at assertion time |
| **Graceful fallbacks** | Try one source, fall back to another when it reverts, and branch lazily |

## Features

- **ERC-8211 native**: assertions are standard Smart Batching predicate entries; batches built by any ERC-8211 SDK judge here unchanged
- **Inline constraints**: `EQ`, `GTE`, `LTE` and `IN` (inclusive range) validate any fetched value; everything richer routes through a read-spliced Operators comparison judged `EQ 1`
- **Three fetchers**: raw literals, arbitrary `staticcall`s, and balance reads (native or ERC-20); one `assertParam` call covers balances, view returns and constants alike
- **Core reads**: raw word selection (`pick`), typed navigation into tuples and dynamic arrays (`nav`), runtime-address chains (`chain`) and runtime-argument calls (`read`), all composable from recursive `InputParam` operands
- **Resolution control**: lazy branching (`cond`), composable try/catch with constraints doubling as guards (`orElse`), and did-it-resolve probes (`ok`)
- **Operators vocabulary**: named arithmetic, comparisons, bitwise, environment, bytes, search, a runtime ABI encoder and bounded folds, readable directly in decoded explorer calldata
- **Nested live call arguments**: use the result of one view call as an argument of another, resolved at assertion time via the core's `read`
- **Approximate equality**: the `IN` constraint asserts a value within inclusive bounds; `absDiff(a, b)` judged `LTE d` covers live-vs-live tolerance
- **Custom error messages**: every judge function has an overload accepting a custom message

## Where to go next

- [Using assertions from Solidity](/docs/solidity): complete examples for DAO proposals, Safe batches and upgrades
- [Core reads](/docs/core/reads) and [resolution control](/docs/core/control): the frozen core's eight primitives
- [Operators](/docs/operators): the computation vocabulary and how `read` splicing composes it
- [EVMcrispr integration](/docs/evml): writing assertions as one-line EVML scripts, and the [visual builder](/builder)
- [Core reference](/docs/reference/core) and [error reference](/docs/reference/errors)
- [Deployments](/docs/reference/deployments): interim addresses, CREATE2 mechanics and deploying to new chains

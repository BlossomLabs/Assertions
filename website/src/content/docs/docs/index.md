---
title: Overview
description: What Assertions is, how the two contracts split responsibilities, and where they live.
---

Assertions is an on-chain assertion system for verifying view function return values and blockchain state. Assertion calls are batched alongside the transactions they guard: if any assertion fails, the entire transaction reverts, atomically.

It ships as **two contracts** with one tagline: **Assertions judge, Combinators compute.**

- **`Assertions` (the core)** is the judge, redesigned around [ERC-8211 (Smart Batching)](https://eips.ethereum.org/EIPS/eip-8211). An assertion IS an ERC-8211 predicate: an `InputParam` describes how to fetch a live value (a raw literal, a `staticcall`, or a balance read) and carries inline constraints (`EQ`, `GTE`, `LTE`, `IN`) the value must satisfy. `assertParam` judges one parameter — the 90% case — and `assertComposable` judges whole batches, including entries that *construct* calls by splicing runtime-resolved values into calldata (which is how nested live call arguments work). A failing constraint reverts with a descriptive `ConstraintFailed` error.
- **`Combinators` (the periphery)** provides nine composable building blocks: operand resolution with inline constraints (`resolve`), raw word selection (`pick`), typed navigation into tuples and dynamic arrays ([`nav`](/docs/combinators/reads)), runtime-address chains (`chain`), runtime-argument calls ([`invoke`](/docs/combinators/reads)), binary word operations ([`calc`](/docs/combinators/calc)), unary word operations (`unary`), raw-bytes operations ([`data`](/docs/combinators/data)) and constants/environment values (`env`). Every operand is itself an `InputParam`, so expressions nest recursively. The core judges the final value: an assertion's fetcher points a `STATIC_CALL` at the Combinators address with the encoded expression as calldata.

Because combinators are stateless view targets, the periphery can evolve: old `Combinators` deployments never break (anything referencing them keeps working), and new versions ship at new addresses as pure opt-ins, without touching the core.

## Canonical addresses

Both contracts live at the same address on every chain (see [Deployments](/docs/reference/deployments)):

```
Assertions  v2.0  0xa55E47F37088b6D0212BdfD56b175ec08744DB19   (ERC-8211 judge)
Combinators v2.0  0xA55Ec0935FB5aaf95CAC1F48DD822005d91b64b9   (versionable periphery)
```

Earlier versions remain deployed and working forever at their own canonical addresses: the v1.1 typed-assert core at [`0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0`](https://etherscan.io/address/0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0) with Combinators v1.0 at `0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC`, and the original v1.0 core at [`assertions.eth`](https://etherscan.io/address/0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F). V2 replaces v1.1's 140 typed assertion functions (`assertEqCallUint`, …) with the ERC-8211 model: `assertEqCallUint(target, data, expected)` is now `assertParam` over a `STATIC_CALL` fetcher with an `EQ` constraint.

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

## Features

- **ERC-8211 native**: assertions are standard Smart Batching predicate entries — batches built by any ERC-8211 SDK judge here unchanged
- **Inline constraints**: `EQ`, `GTE`, `LTE` and `IN` (inclusive range) validate any fetched value; everything richer routes through a combinator comparison judged `EQ 1`
- **Three fetchers**: raw literals, arbitrary `staticcall`s, and balance reads (native or ERC-20) — one `assertParam` call covers balances, view returns and constants alike
- **Combinators**: chained reads, typed navigation, arithmetic, logic, bitwise, hashing and string operations composed from recursive `InputParam` operands
- **Nested live call arguments**: use the result of one view call as an argument of another, resolved at assertion time via `assertComposable` construction batches
- **Approximate equality**: the `IN` constraint asserts a value within inclusive bounds; `calc(AbsDiff) <= d` covers live-vs-live tolerance
- **Environment values**: block number, timestamp, chain id, balances and code hashes as composable operands
- **Custom error messages**: every judge function has an overload accepting a custom message

## Where to go next

- [Using assertions from Solidity](/docs/solidity): complete examples for DAO proposals, Safe batches and upgrades
- [Combinators](/docs/combinators): computing values on-chain with nine functions
- [EVMcrispr integration](/docs/evml): writing assertions as one-line EVML scripts, and the [visual builder](/builder)
- [Core reference](/docs/reference/core) and [error reference](/docs/reference/errors)
- [Deployments](/docs/reference/deployments): canonical CREATE2 addresses and deploying to new chains

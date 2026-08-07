---
title: Overview
description: What Assertions is, how the two contracts split responsibilities, and where they live.
---

Assertions is an on-chain assertion system for verifying view function return values and blockchain state. Assertion calls are batched alongside the transactions they guard: if any assertion fails, the entire transaction reverts, atomically.

It ships as **two contracts** with one tagline: **Assertions judge, Combinators compute.**

- **`Assertions` (the core)** provides a comprehensive suite of assertion functions that validate on-chain state. It uses `staticcall` to execute view functions on target contracts and compares results against expected values, reverting with descriptive custom errors on failure. The core is the trust anchor: it is **frozen forever**. No future version will change its behavior at its canonical address.
- **`Combinators` (the periphery)** provides five composable building blocks: navigated call chains ([`read`](/docs/combinators/read)), binary word operations ([`calc`](/docs/combinators/calc)), unary word operations (`unary`), returndata operations ([`data`](/docs/combinators/data)) and constants/environment values (`env`). Each combinator computes and returns a value, and nested `(target, data)` operands in calldata compose them into arbitrary expressions. The core judges the final value: point any call assertion at the Combinators address with the encoded expression as data.

Because combinators are stateless view targets, the periphery can evolve: old `Combinators` deployments never break (anything referencing them keeps working), and new versions ship at new addresses as pure opt-ins, all without ever touching the frozen core.

## Canonical addresses

Both contracts live at the same address on every chain (see [Deployments](/docs/reference/deployments)):

```
Assertions  v1.1  0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0   (frozen core)
Combinators v1.0  0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC   (versionable periphery)
```

Version 1.0 of the core remains deployed at [`assertions.eth`](https://etherscan.io/address/0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F) (`0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F`). Core v1.1 is a strict superset of the 1.0 ABI: it adds int256 assertions (including approximate equality), tuple index bounds checking, `CallFailed` on code-less targets, and the `Ne`/`Lt`/`Le` variants listed in the [core reference](/docs/reference/core).

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

## Features

- **Call-based assertions**: execute view functions on any contract and assert return values
- **Combinators**: navigated chained reads, arithmetic, logic, bitwise, hashing and string splitting composed via the separate `Combinators` contract's five functions
- **Multiple type support**: `uint256`, `int256`, `address`, `bool`, `bytes32`, `bytes`, `string`
- **Tuple indexing**: assert specific elements from functions returning multiple values
- **Comparison operators**: equal, not equal, greater than, less than, greater/less than or equal
- **Approximate equality**: assert values within a tolerance (absolute delta)
- **Array length assertions**: validate dynamic array lengths
- **Balance assertions**: check native token balances
- **Block assertions**: verify block number and timestamp
- **Chain ID assertions**: ensure correct network
- **Contract existence**: check if an address has code, verify code hashes
- **Custom error messages**: all assertions have overloaded versions accepting custom messages

## Where to go next

- [Using assertions from Solidity](/docs/solidity): complete examples for DAO proposals, Safe batches and upgrades
- [Combinators](/docs/combinators): computing values on-chain with five functions
- [EVMcrispr integration](/docs/evml): writing assertions as one-line EVML scripts, and the [visual builder](/builder)
- [Core reference](/docs/reference/core) and [error reference](/docs/reference/errors)
- [Deployments](/docs/reference/deployments): canonical CREATE2 addresses and deploying to new chains

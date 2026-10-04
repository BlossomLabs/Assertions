---
title: Glossary
description: Short definitions of the terms used across the assertions docs, with a link to the page that explains each one.
---

Terms are in alphabetical order.

| Term | Meaning |
|------|---------|
| **ABI descriptor** | A string such as `uint256`, `address[]` or `(address,uint256)` that says how to read a value a contract returned. You write one whenever you write a signature inline, for example `balanceOf(address)(uint256)`. The contracts check that the data is valid for the descriptor, not that the descriptor is true. See [Reviewing an assertion](/docs/reviewing). |
| **Argos (v1)** | The release name for Assertions 1.0, the original single contract. It stays at its own address. See [Argos (v1)](/releases/argos). |
| **Assertion** | A condition written into a transaction and checked where you place it. If it is false, the guarded batch reverts. See the [Overview](/docs). |
| **Batch** | Several calls sent and executed together as one transaction, for example a Safe transaction, a wallet batch or the actions of a proposal. An assertion in a batch can make the whole batch revert. |
| **Build-time value** | A value fixed when the script is built, such as a literal like `100e18`, a `$variable` or an ordinary helper. It does not change if the batch executes later. Compare with live value. See [Writing assertions in EVML](/docs/evml). |
| **Byakko (v2)** | The release name for Assertions v2 (version 2.0): Assertions, Operations, Collections and Expressions. See [Byakko (v2)](/releases/byakko). |
| **Canonical address** | The address a contract has on every chain, produced by deploying through the CREATE2 proxy with a fixed salt. An assertion that calls any other address proves nothing about the canonical contracts. See [Deployments](/docs/contracts/deployments). |
| **Constraint** | A test a fetched value must pass, such as `EQ`, `GTE`, `LTE`, `IN`, their signed forms, `OR` or `SKIP`. Constraint `i` judges word `i` of the value. See [Reviewing an assertion](/docs/reviewing). |
| **CREATE2** | The deployment method that fixes a contract's address from the deployer, a salt and the contract's code. It is why the four contracts have the same address on every chain. See [Deployments](/docs/contracts/deployments). |
| **ERC-8211** | The standard (Smart Batching) whose `InputParam` format assertions use, so that other tools can read them. See [ERC-8211](https://eips.ethereum.org/EIPS/eip-8211). |
| **EVML** | The small scripting language for transaction batches, from EVMcrispr, in which assertions are written. See [Writing assertions in EVML](/docs/evml). |
| **Executor** | Whatever runs the batch: your wallet, a Safe, a Governor or an Aragon OSx DAO. An assertion only rolls the batch back if the executor lets a failing call fail the whole batch. See [Executors](/docs/guides/executors). |
| **Expansion pack** | One of the three contracts that extend the main Assertions contract: Operations, Collections and Expressions. Assertions calls into them when a line needs more than a read and a comparison. See [The four contracts](/docs/contracts). |
| **Fetcher** | The part of an `InputParam` that says how a value is obtained: `RAW_BYTES` (a literal), `STATIC_CALL` (the return data of a read-only call) or `BALANCE` (a native or ERC-20 balance). See [Reviewing an assertion](/docs/reviewing). |
| **Fork** | A simulated copy of a chain's current state. The builder runs your batch on a fork so you can see it succeed or fail before anything is signed. See the [quickstart](/docs/quickstart). |
| **Helper** | A name in EVML that starts with `@`, such as `@balance!` or `@all!`. Helpers come from modules, and a helper ending in `!` reads the chain when the batch executes. The [EVML assertion reference](/docs/reference#helpers) lists them. |
| **InputParam** | The ERC-8211 structure that describes one value: where it routes, how it is fetched, its fetcher data and its constraints. Every assertion is built from one. See [Reviewing an assertion](/docs/reviewing). |
| **Lens** | A pattern in square brackets after a read that selects part of the result. `$` marks the part you want and `_` skips one, as in `[_ $ _]`. See [Writing assertions in EVML](/docs/evml). |
| **Live value** | A value read when the batch executes, written with a `::!` call or a helper ending in `!`. Compare with build-time value. See [Writing assertions in EVML](/docs/evml). |
| **Postcondition** | An assertion placed after the actions it checks, about the outcome. See [Executors](/docs/guides/executors#placement). |
| **Precondition** | An assertion placed before the actions it protects, about the state they rely on. See [Executors](/docs/guides/executors#placement). |
| **Predicate** | A condition on a value. In ERC-8211 form, an assertion is a predicate: a fetched value plus the constraints it must satisfy. See [Reviewing an assertion](/docs/reviewing). |
| **Primitive** | One of the functions on the Assertions contract that works on reads before they run, such as `nav`, `chain`, `cond` and `orElse`. See [Assertions](/docs/contracts/assertions). |
| **Proxy** | In deployment, the deterministic-deployment proxy that every chain's CREATE2 deployments go through. The contracts are deployed through it, which is why their addresses match across chains. In an assertion, "proxy" can also mean an upgradeable contract whose implementation an assertion checks. See [Deployments](/docs/contracts/deployments). |
| **Signed vs unsigned** | An unsigned number cannot be negative. A signed number can. Compared as unsigned, a negative number reads as a huge positive one, so signed values need signed constraints. See [Reviewing an assertion](/docs/reviewing). |
| **Simulation** | Running a batch against a copy of the chain to see what it would do. A simulation describes the chain as it was when it ran, which is why assertions check again at execution. See the [Overview](/docs). |
| **Word** | 32 bytes, the unit of the EVM and of ABI encoding. Constraint `i` judges word `i` of a fetched value. See [Reviewing an assertion](/docs/reviewing). |

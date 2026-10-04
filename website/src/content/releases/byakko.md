---
codename: Byakko
version: "2.0"
status: released
summary: Four contracts and a documentation rewrite built around EVML. Assertions is the main contract; Operations, Collections and Expressions are its expansion packs.
banner: byakko
order: 2
---

Byakko is the v2 release of **Assertions**, **Operations**, **Collections** and **Expressions**. All four are stateless and view-only, each at the same address on every chain, and each versions on its own.

## Assertions, the main contract

Assertions judges a live value against constraints in the [ERC-8211](https://eips.ethereum.org/EIPS/eip-8211) wire format and reads values out of other contracts. It carries eleven primitives that work on reads before they are resolved:

- **Select:** `resolve`, `gather`, `pick` and `nav`, which walks tuples and arrays by type and can return a string's length or its raw payload.
- **Build calls:** `chain` follows addresses read at execution time, `read` splices live values into a call, and `get` builds a call from whole values, resolving each argument once.
- **Branch:** `cond` takes the branch that holds, `orElse` falls back when a read fails, `isValid` asks whether a read succeeds, and `revertData` reads why a call reverts.

Constraints cover equality, unsigned and signed comparisons, ranges, `OR` and `SKIP`.

## The expansion packs

- **Operations** is the most used pack: arithmetic, 512-bit and fixed-point math, comparisons such as `!=`, bytes and strings, hashing, parsing and formatting numbers, and block and transaction fields.
- **Collections** manages arrays: check every or any element, find, filter, sort, deduplicate and total the lists that contracts return, in one call.
- **Expressions** deduplicates calculations: define a read or a calculation once and reuse the result, with lazy branches and guarded fallbacks.

## Names

Each contract has two kinds of ENS name. A release name sits under `byakko.assertions.eth`, is permanent and always resolves to the contract this release uses; a bare name follows the latest release and moves when a new one ships.

- **Assertions:** `byakko.assertions.eth`, latest at `assertions.eth`
- **Operations:** `operations.byakko.assertions.eth`, latest at `operations.assertions.eth`
- **Collections:** `collections.byakko.assertions.eth`, latest at `collections.assertions.eth`
- **Expressions:** `expressions.byakko.assertions.eth`, latest at `expressions.assertions.eth`

`assertions.eth` used to resolve to Argos, which is now `argos.assertions.eth`. A later release takes names under its own codename and leaves these untouched. Where it reuses a contract unchanged, its name for that contract resolves to the same address as the one here.

## Documentation

The docs are rewritten around the reader. An overview and a quickstart lead in, [Reviewing an assertion](/docs/reviewing) explains how to read one in a batch you are about to sign, and the [EVML guide](/docs/evml) is organized by what you want to check. The contract pages are now one per contract, with Assertions as the main one.

## Requirements

Compiling assertions for Byakko needs EVMcrispr 0.12.0, which is not released yet. The builder on this site already includes it.

## Status

Byakko is released, and `assertions.eth` points to it. The contracts have not been externally audited or formally verified. They hold no funds and write no state, so a bug produces a wrong answer, not a theft. Addresses and per-chain availability are on [Deployments](/docs/contracts/deployments).

---
title: The four contracts
description: "Assertions is the main contract; Operations, Collections and Expressions are its expansion packs. What each does and why the work is split this way."
---

There are four contracts, and **Assertions is the main one**. An EVML `assert` line compiles to a call on Assertions, which judges a live value against constraints and reads values out of other contracts. That is enough for a balance, a state variable or an owner compared with `>=` or `==`.

When a line needs more than that, Assertions calls into its **expansion packs**: the other three contracts, which add extra functions and are reached by address. Each adds something different:

- **Operations** works on single values: arithmetic and comparisons (including `!=`), bytes and string handling, hashing, and reading block and transaction fields. Use it when a claim needs a calculation or a string test.
- **Collections** works on arrays. When a contract returns a list (a Safe's owners, a vault's caps, a token's holders), Collections checks that every or any element passes a test, finds one, filters, maps, sorts, removes duplicates, pairs two lists and totals them, in one call instead of one read per element.
- **Expressions** removes repeated work. When a claim uses the same read or calculation in several places (an oracle price compared three times, a pool ratio used in two formulas), a plain assertion repeats it and pays for it each time. Expressions defines it once, gives it a name, and reuses the result. It pays off when the repeated part is expensive.

You do not need to know any of this to write or approve assertions. The [Overview](/docs), the [EVML guide](/docs/evml) and [Reviewing an assertion](/docs/reviewing) do not assume it. These pages are for integrators building calldata directly, auditors reading a decoded batch closely, and anyone who wants to know where a behaviour comes from.

All four contracts are stateless: every function is `view` or `pure`. They hold no funds, own no permissions and write no storage. Each has the same address on every chain, listed on [Deployments](/docs/contracts/deployments).

| Contract | It is for | You meet it as |
|----------|-----------|----------------|
| [**Assertions**](/docs/contracts/assertions) | Judging a live value against constraints, and reading values out of other contracts: select, navigate, follow addresses, build calls, branch | The target of every assertion (`assertParam`, `assertBatch`) and of nested reads (`nav`, `chain`, `read`, `cond`, `orElse`) |
| [**Operations**](/docs/contracts/operations) | Computing over values that are already resolved | A call inside an expression: `add`, `mulDiv`, `gt`, `hash`, `contains` |
| [**Collections**](/docs/contracts/collections) | Array management: testing, searching, filtering, sorting and totalling the lists that contracts return | A call that carries a callback: `allValues`, `filterValues`, `sumWords`, `foldWords` |
| [**Expressions**](/docs/contracts/expressions) | Deduplicating calculations: define a read or a calculation once and reuse its result | An `evaluate` call over a typed graph of nodes |

## One assertion, all four

This EVML line from the [Overview](/docs) checks that every owner of a Safe is on an approved list:

```evml
def @onCouncil! "$o: address -> bool" @includes!($council $o)
assert @all!(@safe:owners!($councilSafe) @onCouncil!) == true "unknown signer"
```

On-chain, `Assertions` judges the final result and reads the Safe's owner list. `Collections` runs the `@all!` test over the list, one element at a time. The test itself, `@includes!` on each owner, is a computation, which `Operations` or a graph from `Expressions` carries out, depending on how the compiler lowers it. The pieces reach each other by address, so a decoded batch shows several different targets.

## Why a core and expansion packs

**Assertions decides which reads happen. The expansion packs work on the results.**

Assertions is handed an instruction for getting a value, not the value itself, so it can choose whether to carry the instruction out. Take "use the oracle price, or the TWAP if the oracle reverts". Assertions has to try the oracle itself and catch the failure; no price exists yet to hand over. The same goes for a branch that must not run unless its condition holds, and for a call whose arguments are other reads. Only code that receives the instruction can do these, and that code is the core.

Adding two balances, comparing two strings or testing every element of a list is different. By the time it runs, every input is already a number, a string or a list. It does not need to decide anything about reads, so it lives in an expansion pack: calculations in Operations, lists in Collections, reuse in Expressions.

**Each contract versions on its own.** The core and the packs reach each other only through addresses and interfaces, never through a source import, so a change to one does not move the address of another. The one shared source is `AbiCodec`, the ABI type grammar and canonical-value checker that all four compile in. Any source edit, comments included, changes a contract's address, so a new version is a new deployment and an opt-in. Old deployments never break.

## Where to go next

- [Assertions](/docs/contracts/assertions): the judge, the wire format and the eleven primitives.
- The expansion packs: [Operations](/docs/contracts/operations), [Collections](/docs/contracts/collections) and [Expressions](/docs/contracts/expressions).
- [Errors](/docs/contracts/errors): the errors more than one contract raises.
- [Deployments](/docs/contracts/deployments).

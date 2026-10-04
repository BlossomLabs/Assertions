---
title: Overview
description: What assertions are for, how they compose, and how you write them.
---

Between the moment you sign a transaction and the moment it executes, the chain moves. A price shifts, a signer is swapped, a proxy is upgraded by an earlier proposal in the same queue. A simulation tells you what was true when you ran it. It does not tell you what is true when the transaction lands.

An **assertion** is a condition written into the transaction itself, checked at the point where you place it, in the same transaction that executes everything else. If the condition is false, the guarded batch reverts and nothing happens.

You write assertions in **EVML**, a small scripting language for transaction batches, from [EVMcrispr](https://evmcrispr.blossom.software). If you know Solidity you can read it: it is a list of lines, one per action or check, and the `assert` command is the check.

```evml
assert $vault::!{owner()(address)} == $councilSafe "handover didn't land"
```

An `assert` line has the same parts as a `require`: a value, a comparison and a message.

- `$vault::!{owner()(address)}` is the value. It calls `owner()` on the contract named by the variable `$vault` and reads back an `address`. The first parentheses hold the function's inputs and the second its return type, so the signature is written out in the line itself. The `!` after `::` means the call runs when the batch executes, not when you write the script.
- `== $councilSafe` is the comparison, against another variable. Variables start with `$` and are set earlier in the script.
- `"handover didn't land"` is the message the revert carries if the check fails.

So the line reads the vault's owner when the batch executes and compares it to the council Safe. If they differ, the batch reverts with that message. You do not deploy anything: each `assert` compiles to a call on the **Assertions** contract, which already exists at the same address on every chain. When a line needs more than a read and a comparison, Assertions calls into **expansion packs**, separate contracts of extra functions: arithmetic and string handling (Operations), handling lists that a contract returns (Collections) and calculations reused across a claim (Expressions).

## What you use them for

- **DAO proposals.** A proposal can run many actions seven days after the vote. Assertions state what the vote meant: who owns what afterwards, which code runs, what the treasury still holds.
- **Safe batches.** Signers approve a batch against the state they saw. Assertions make the batch fail if that state moved.
- **Wallet batches.** An EIP-7702 wallet that sends several calls at once can wrap them in checks on the outcome.

Typical claims: a treasury balance stays above a floor, an admin role did not change, an oracle price is inside a band, a proxy still points at the audited implementation, a timelock has expired, a pool holds enough reserves.

## Claims compose

Every claim has the same shape, so claims combine: read a live value, then compare it.

One read can feed the next. This line reads the proxy's implementation address, then hashes the code at that address:

```evml
assert @codeHash!($vault::!{implementation()(address)}) == 0xdfff0c54be05b5df7dc8f015f8c813825344770fee1ba1202130a4652b529ca9 "unaudited code"
```

A claim can run over a whole list, however long it is at execution time. This one reads the Safe's owners and requires every one to be on an approved list:

```evml
def @onCouncil! "$o: address -> bool" @includes!($council $o)
assert @all!(@safe:owners!($councilSafe) @onCouncil!) == true "unknown signer"
```

A claim can try one source and fall back to another, compare strings, do arithmetic, or check chain state such as balances, timestamps and code hashes. The [EVML guide](/docs/evml) shows how, and the [reference](/docs/reference) lists every helper.

## A proposal, end to end

A DAO votes to upgrade a vault and hand its admin role to a council Safe. The proposal executes a week later. These are the claims that say what the vote meant, placed right after the two actions:

```evml
load contracts
load lang
load safe

assert $vault::!{owner()(address)} == $councilSafe "handover didn't land"
assert @codeHash!($vault::!{implementation()(address)}) == 0xdfff0c54be05b5df7dc8f015f8c813825344770fee1ba1202130a4652b529ca9 "unaudited code"
def @onCouncil! "$o: address -> bool" @includes!($council $o)
assert @all!(@safe:owners!($councilSafe) @onCouncil!) == true "unknown signer"
assert @safe:threshold!($councilSafe) >= 3 "threshold too low"
```

If the owner is wrong, the code is not the audited build, an unknown signer holds a key, or fewer than three signatures are required, the whole proposal reverts. The same proposal without these lines would have executed and been wrong.

## Where you write them

The [builder](/builder) is the easiest way in, because it writes the EVML for you. It composes a batch, simulates it on a fork, suggests assertions that protect it, previews their live values, and ships the result as a wallet batch, a Safe transaction, a Governor proposal or an Aragon OSx proposal. The [quickstart](/docs/quickstart) walks through it. You can also write EVML by hand in any EVMcrispr script.

## What assertions do not do

- **An assertion checks what you wrote, and nothing else.** A vague condition passes. An assertion is a precise check on a stated claim, not a safety net over the whole batch.
- **Placement is meaning.** The same assertion before an action and after it asks two different questions. See [placement](/docs/guides/executors#placement).
- **Reverting needs an executor that propagates the failure.** The revert only rolls back the batch if the executor lets a failing call fail the whole batch. [Executors](/docs/guides/executors) says which do.
- **A type you write is a claim.** If you declare a return as `uint256` and it is actually an address, the assertion reads a number and passes or fails on that.
- **Assertions cost gas.** Each read is an external call, and a check over a list pays once per element. They are meant for transactions you prepare, where the stakes justify the cost. A contract that needs a check at run time should write it in Solidity, which is far cheaper.
- **The contracts must exist on the chain where you execute.** If they are missing, a call to their address can succeed without checking anything, so the assertion protects nothing. Check [Deployments](/docs/contracts/deployments).
- **No audit yet.** The contracts have not been externally audited, and formal verification covers only part of their behaviour: see [Towards formal verification](/docs/contracts/verification). They are `view` or `pure`: they hold no funds and write no storage, so the failure mode is a wrong answer, not a theft. A wrong answer from a guard still matters.

## Next

- [Quickstart](/docs/quickstart): guard a transfer in the builder.
- [Executors](/docs/guides/executors): the condition that decides whether an assertion protects you, then guides for [Safe batches](/docs/guides/safe), [DAO proposals](/docs/guides/dao-proposals) and [wallet batches](/docs/guides/wallet-batches).
- [Recipes](/docs/recipes): copy-pasteable assertions for funds, permissions, upgrades, prices, time and lists.
- [Writing assertions in EVML](/docs/evml): reads, comparisons, lists, strings and fallbacks, with the [reference](/docs/reference) for every operator and helper.
- [Reviewing an assertion](/docs/reviewing): read the assertions in a batch you are about to sign or vote on.
- [Troubleshooting](/docs/troubleshooting), [FAQ](/docs/faq) and [Glossary](/docs/glossary).
- [The four contracts](/docs/contracts): Assertions, the main contract, and its three expansion packs.

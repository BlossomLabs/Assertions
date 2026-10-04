---
title: FAQ
description: Short answers to the questions people ask before they use assertions in a batch.
---

## What does an assertion cost?

Each read in an assertion is an external call, and a check over a list pays once per element, so cost grows with what you check. There is no fixed price per assertion. The simulation in the builder runs the batch with the assertions in place, so you can read the gas it used. For measured figures on calls built from several live values, see [get](/docs/contracts/assertions#get).

## Which chains does it work on?

The builder offers Ethereum, Gnosis, Base, Optimism, Arbitrum, Polygon and Sepolia. Assertions work on any chain where the four contracts are deployed, and the [Deployments](/docs/contracts/deployments) page checks each chain live. A chain also needs the Cancun upgrade (`MCOPY` and `PUSH0`).

## Which wallets and executors work?

The builder ships a batch four ways: from your connected wallet as one atomic batch (EIP-5792 `wallet_sendCalls`, using your wallet's EIP-7702 delegation when available), as a Safe transaction, as an OpenZeppelin Governor proposal, or as an Aragon OSx proposal. Whatever executes the batch must let a failing call fail the whole batch. See [Executors](/docs/guides/executors).

## Is it audited?

The contracts have not been externally audited. Part of their behaviour is formally verified within stated bounds, and the rest is covered by tests. See [Security and trust](/docs/security) and [Towards formal verification](/docs/contracts/verification).

## Can an assertion move funds or change state?

No. Every function in the four contracts is `view` or `pure`. They hold no funds and write no storage, and the judge rejects output parameters and `VALUE` parameters. A bug in them produces a wrong answer, not a theft. See [The four contracts](/docs/contracts).

## Does a passing assertion mean my transaction is safe?

No. An assertion checks only what you wrote, at the point where you placed it. A vague condition passes, and a type you declare incorrectly makes the assertion read the wrong value. See [What assertions do not do](/docs#what-assertions-do-not-do) and [Reviewing an assertion](/docs/reviewing).

## What happens to my assertions if there is a new version?

Nothing. A new version is deployed at a new address, and a batch that references the old address keeps working. New batches use the new address only when you choose it. The bare ENS names (for example `assertions.eth`) follow the latest release; the release names (for example `byakko.assertions.eth`) always resolve to one release. See [Deployments](/docs/contracts/deployments) and [Byakko (v2)](/releases/byakko).

## Do I need to deploy anything?

Not if your chain already has the four contracts. Your batch only calls them. If your chain is missing, see the next question.

## What if my chain is missing?

Anyone can deploy the contracts there, from the [Deployments](/docs/contracts/deployments#add-your-chain) page. They go out through the deterministic-deployment proxy, so they end up at the same addresses as everywhere else. Deploying through any other factory produces different addresses that the builder will not find.

## Should my own contract call Assertions?

No. Assertions are for transactions and batches that someone prepares, where the stakes justify the extra cost: a treasury payment, an upgrade, a proposal. A contract that needs a check while it runs should write that check in Solidity, which costs far less than an external call. See [Integrating](/docs/integrate).

## Where can I get help?

Use the Support button on this site.

## Can I use it without the builder?

Yes. The builder writes EVML for you, but you can write EVML by hand in any EVMcrispr script (see [Writing assertions in EVML](/docs/evml)). You can also build the calldata yourself with `assertParam` as the entry point (see [Integrating](/docs/integrate)). Assertions v2 compiles with EVMcrispr 0.12.0, which is not released yet, so until then the builder is the way to produce them.

---
title: Security and trust
description: What the contracts can and cannot do, what an assertion guarantees, what you must trust, and how to check the deployed code.
---

This page is for auditors and cautious users. It states what the four contracts do, what an assertion does and does not promise, what you have to trust, and how to check the code on your chain.

## What the contracts can and cannot do

Assertions, Operations, Collections and Expressions are stateless. Every function is `view` or `pure`. They hold no funds, write no storage, own no permissions and are not upgradeable: each is deployed once at a fixed address, and a new version is a new deployment at a new address. You can confirm this in the source on any explorer where it is verified (see below).

The judge also refuses what a view contract cannot do: it rejects output parameters and `VALUE` parameters. So the failure mode is a wrong answer from a guard, not a loss of funds. A wrong answer still matters, because you may sign or vote on the strength of it.

## What an assertion guarantees

- If a condition is false at the point where it runs, the call reverts with the assertion's message.
- If the executor lets that failure fail the whole batch, nothing in the batch happens.
- The same assertion before and after an action asks two different questions. See [placement](/docs/guides/executors#placement).

## What it does not guarantee

- It checks what you wrote and nothing else. A vague condition passes.
- A type or signature you write is a claim. If it is wrong but has the same shape, the contract reads the wrong value. The contracts check that the data is valid for the declared type, not that the declaration is true.
- An external contract you read from can answer differently depending on its caller, the gas it receives or the chain's history.
- The contracts must exist on the chain where you execute. If they are missing, a call to their address can succeed without checking anything, so the assertion protects nothing.

See [Reviewing an assertion](/docs/reviewing) for how to read these in a batch.

## What you have to trust

1. **The executor propagates failure.** A failed assertion rolls the batch back only if the executor lets a failing call fail the whole batch. [Executors](/docs/guides/executors) says which do.
2. **The addresses are the canonical ones.** An assertion that calls another contract proves nothing. Compare the address in a batch with [Deployments](/docs/contracts/deployments).
3. **Your descriptors and types are right.** See above.
4. **Your chain behaves like Ethereum where it matters.** The chain needs the Cancun upgrade, and values such as `block.number` mean different things on some L2s (see [Assertions](/docs/contracts/assertions)).

## Audit status

The contracts have not been externally audited, and formal verification covers only part of their behaviour. [Towards formal verification](/docs/contracts/verification) lists each claim, the evidence behind it and what is not proved.

## Verify the code on your chain

The contracts are deployed through a deterministic-deployment proxy, so each has the same address on every chain. To check that the code at an address matches the published source:

1. Open the address on your chain's block explorer and look for verified source. The builder's deployment flow can submit the source to explorers supported by the Etherscan multichain API, so on those chains it is verified automatically after you deploy.
2. If the source is not verified, submit it from the [Deployments](/docs/contracts/deployments#networks) page: under the table, pick your chain and add an Etherscan API key.
3. Compare the address you see in a batch with the address in the table there.

The explorer's check compares compiled source with the deployed bytecode. It shows that the code is the published source, not that the source is correct. For that, see the verification page above.

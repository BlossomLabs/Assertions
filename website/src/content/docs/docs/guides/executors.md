---
title: Executors
description: "What an executor is, and the one condition that decides whether an assertion protects you: a failing assertion must fail the whole batch."
---

The executor is the account that sends your batch: your wallet, a Safe, a Governor or an Aragon OSx DAO. The [builder](/builder) asks for it first, under "Executor and network", and wraps your calls for it when you submit.

An assertion protects you only if a failing assertion makes the whole batch fail. If the executor can carry on after a failed call, the assertion is a comment. Before you rely on a batch, check how its executor treats a failed call.

## Placement

An assertion is an ordinary call in the batch, and the calls run in order.

- An assertion **before** the actions is a precondition. It judges the state the batch relies on.
- An assertion **after** the actions is a postcondition. It judges the outcome.

A postcondition placed before the action checks nothing about the outcome, and a precondition placed after it judges a state the action has already changed. If a precondition fails, nothing has happened yet. The [builder](/builder) asks "When should it run?" for each assertion and places it for you. See [Writing assertions in EVML](/docs/evml) for the lines themselves.

## What each executor does with a failure

| Executor | How the batch is submitted | What a failed assertion does |
|----------|----------------------------|------------------------------|
| Your wallet | The builder wraps the calls in `batch ( ... )`. The wallet sends them as one atomic batch with EIP-5792 `wallet_sendCalls`, using its EIP-7702 delegation when it has one. | The whole batch reverts. If any call in it fails, none of its calls take effect. |
| Safe | `safe:propose` queues one Safe transaction on the Safe Transaction Service. With several calls, they are packed into one MultiSendCallOnly call (MultiSend only if a call needs a delegatecall). | The calls form one Safe transaction. A failing call reverts the whole multisend, so none of the calls take effect. With the usual gas setting of zero, executing the transaction reverts and the nonce is not used. If a gas amount is set for the inner transaction, the Safe does not revert: it records a failed execution and uses the nonce, still with none of the calls applied. |
| Governor | `governor:propose` creates a proposal where each call in the block becomes one entry of the proposal, in order. | On an OpenZeppelin Governor, executing the proposal reverts with the assertion's error and none of its calls take effect. The proposal stays executable (Succeeded, or Queued with a timelock). Other Governor implementations may differ: check yours. |
| Aragon OSx DAO | `aragonosx:propose` creates a proposal on a governance plugin you name, with the calls as its actions. | Tolerated only for actions in the `--allow-failure-map` bitmap. The default is none, so no action may fail. |

For a Safe, the builder can also export the calls as a Transaction Builder JSON file instead of proposing them. That file lists the calls one by one (assertions included) for the Safe app to import. See [Safe batches](/docs/guides/safe).

## What has been tested

The Safe and Governor rows above were checked by running a failing and a passing assertion, in both orders, through the real contracts: Safe 1.3.0 and 1.4.1 with MultiSend and MultiSendCallOnly, and OpenZeppelin Governor 5.6.1 with and without a timelock. No executor kept the earlier action after a failed assertion. Wallet batches depend on the wallet, and Aragon OSx follows the allow-failure setting described below. Other chains, Safe modules and guards, and other Governor implementations were not tested.

## When an executor tolerates failed calls

Some executors can be told to let particular calls fail while the rest go through. Aragon OSx has that setting in the proposal: the allow-failure map is a bitmap of the actions that may fail. If an assertion's position is set in that map, a failing assertion no longer stops anything. The builder's wrapper does not set it, and the default is none.

If you submit through anything else, such as a custom module or a script that sends calls one by one, find out what happens to the calls after a failed one. A batch that keeps its earlier actions after a failed assertion has run those actions unprotected.

When you review a batch someone else wrote, ask the same question. [Reviewing an assertion](/docs/reviewing) lists it among the checks.

## Proposals run later than you wrote them

A Safe, Governor or DAO proposal executes after it is approved, not when you build it. State can move in between, so write assertions on the outcome you need (a balance floor, an unchanged owner set), not on values you saw while drafting. The builder's simulation shows the batch passing on a fork at that moment, which is not a promise about execution day.

## Wallets with EIP-7702

The builder's wallet option sends the batch with `wallet_sendCalls` and says the wallet uses its EIP-7702 delegation when available. Whether a particular wallet makes the batch atomic is the wallet's behavior, not something the builder can check. See [Wallet batches](/docs/guides/wallet-batches).

## Next

- [Safe batches](/docs/guides/safe): an end-to-end Safe flow.
- [Reviewing an assertion](/docs/reviewing): what to check as a signer or voter.

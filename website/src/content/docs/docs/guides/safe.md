---
title: Safe batches
description: "Build a Safe transaction with assertions in the builder, simulate it, propose it, and what the other signers see."
---

This guide follows one job from start to finish: your Safe pays a contributor 5 ETH, and the batch must fail unless the Safe still holds its 10 ETH floor, the threshold is still 2 and the owner set still has three members. You are an owner or delegate of the Safe. For how failures behave on each executor, see [Executors](/docs/guides/executors).

## 1. Compose

Open the [builder](/builder). Step 1 is **Compose**.

1. Pick the network.
2. Under "Executor and network", choose **Safe** and enter the Safe address or ENS name. The builder reads the address and shows its version, threshold and owner count, or tells you it is not a Safe.
3. Add the payment as an action: a transfer to the contributor of 5 ETH. You can use the contract form, the EVML editor, or the **Transaction Builder JSON** tab, which only appears when the executor is a Safe and imports a batch exported from the Safe app.
4. Press "Simulate batch". The simulation runs as the Safe, so you see the payment succeed or fail before anyone signs.

## 2. Add assertions

Step 2 is **Assertions**. Each check has a placement: before the actions for what the batch relies on, after for the outcome. The step also has an assistant that can suggest checks from the batch.

For this payment you want:

- Before: the Safe can cover the payment and the floor.
- After: the Safe is above its floor, the threshold is unchanged, the owner set has not shrunk and a signer you care about is still in it.

Written out in EVML, with the payment between the checks:

```evml
load safe
load lang

set $safe 0x44fA8E6f47987339850636F88629646662444217
set $contributor 0x4F2083f5fBede34C2714aFfb3105539775f7FE64
set $signer1 0xc125218F4Df091eE40624784caF7F47B9738086f

assert @balance!(ETH $safe) >= 15e18 "Safe cannot cover the payment and the floor"
send $contributor --value 5e18
assert @balance!(ETH $safe) >= 10e18 "Safe below its 10 ETH floor"
assert @safe:threshold!($safe) == 2 "threshold changed"
assert @len!(@safe:owners!($safe)) == 3 "owner count changed"
assert @includes!(@safe:owners!($safe) $signer1) == true "signer removed"
```

`@safe:threshold!` and `@safe:owners!` read the Safe when the batch executes, not when you build it. `@len!` and `@includes!` come from the `lang` module.

Press "Simulate protected batch". A pass means every check holds on the fork. If it fails, simulate the batch from step 1 to tell a failing action from a failing assertion. Step 3 warns you if the protected batch has not passed a simulation in its current form.

## 3. Submit

Step 3 is **Submit**. It shows the final script, which wraps your calls in `safe:propose` for your Safe, and gives you two ways to continue.

**Propose to Safe** has your wallet sign and queue the batch on the Safe Transaction Service. Your signature counts as the first confirmation when you are an owner. When you are a delegate, the Safe app shows the proposal but the service does not count it as a confirmation. After proposing, the run follows the proposal and reports its confirmations, and whether it was executed or replaced by another transaction at the same nonce.

**Download Transaction Builder JSON** saves the batch as a file you can import into the Safe app's Transaction Builder. The file lists every call, assertions included, as plain `to`, `value` and `data`. The builder refuses to export a batch that contains a contract deployment or a delegatecall.

The proposal uses the next free nonce unless you set one. Several calls in one proposal are packed into a single MultiSendCallOnly call.

## If an assertion fails at execution

When the transaction is executed and an assertion fails, the whole multisend reverts and none of the calls take effect. With the usual gas setting, executing reverts, so the transaction is not marked executed and the nonce stays free. Fix the batch and propose it again, or reject it.

## What the other signers see

The Safe app shows one transaction with several calls. The assertions are calls to the Assertions contract, placed before and after the payment, each with its message. The signers can read them next to the payment. Send them [Reviewing an assertion](/docs/reviewing), which explains how to read the calls, and tell them to compare the Assertions address with [Deployments](/docs/contracts/deployments) for your chain.

If you are the one signing a proposal from the command line, `safe:confirm` fetches the transaction, rebuilds it and refuses it unless it hashes back to the requested hash. It also stops on findings such as new owners, a changed threshold or a delegatecall to an unknown contract, until you name what you reviewed with an `--allow-*` option. A batch whose assertions say the owners and threshold stay the same does not need those options.

## Next

- [Writing assertions in EVML](/docs/evml): more checks you can add.
- [Executors](/docs/guides/executors): how each executor handles a failed call.

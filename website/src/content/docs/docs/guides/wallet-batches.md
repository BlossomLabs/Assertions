---
title: Wallet batches
description: "Build a protected batch for your own wallet in the builder, simulate it, send it as one atomic group, and what happens when an assertion fails."
---

This guide sends a protected batch from your own account, without a Safe or a DAO: you pay a recipient 1 ETH, and the batch must fail unless you had 2 ETH to begin with and keep at least 1 ETH afterwards. You need a wallet that can send several calls at once (EIP-5792 `wallet_sendCalls`). For how failures behave on each executor, see [Executors](/docs/guides/executors).

## 1. Compose

Open the [builder](/builder). Step 1 is **Compose**.

1. Pick the network. The batch must target a single chain.
2. Under "Executor and network", choose **This wallet**.
3. Add the payment as an action: a transfer of 1 ETH to the recipient. A contract deployment cannot go in a wallet batch.
4. Press "Simulate batch" to see the payment succeed or fail on a fork.

## 2. Add assertions

Step 2 is **Assertions**. Add one check before the payment and one after it. Written out in EVML, with the wrapping the builder adds for a wallet:

```evml
set $recipient 0x2222222222222222222222222222222222222222

batch (
  assert @balance!(ETH @me) >= 2e18 "not enough ETH"
  send $recipient --value 1e18
  assert @balance!(ETH @me) >= 1e18 "would leave less than 1 ETH"
)
```

`@me` is your connected account. The builder writes the `batch ( ... )` wrapping for you, so you only write the lines inside the parentheses. The assertions are ordinary calls in the group, in the order you wrote them.

Press "Simulate protected batch". A failing assertion shows up here first, with the line that failed. You cannot continue until a simulation of the current script has passed.

## 3. Submit

Step 3 is **Submit**. The builder asks the wallet to send the calls as one atomic group, with atomicity forced on: a wallet that cannot execute the calls atomically does not get a looser variant. The wallet uses its EIP-7702 delegation when it has one.

## If an assertion fails at execution

Because the group is atomic, a failing assertion fails the whole group and the earlier calls do not take effect. If the wallet reports anything other than success for the group, the run stops with "Transaction batch failed" and the chain name.

## How the simulation treats a batch

The builder's simulation imitates what a delegating wallet does: if your account has no delegation, it installs MetaMask's EIP-7702 delegator on the fork copy of your account, then runs all calls as one atomic call through it. If your account has other contract code that is not a 7702 delegation, the simulation refuses to run. The delegator the simulation uses is MetaMask's, version 1.3.0. Your wallet may use a different one, so the simulation mirrors the behaviour, not your wallet's exact contract.

## What is not covered

- **Setting up 7702.** The builder does not delegate your account. Whether the wallet batches atomically, and with which contract, is the wallet's decision.
- **Smart accounts other than through the wallet.** The wallet path only uses `wallet_sendCalls`. Other smart-account types and their bundlers are not described here.
- **Receipts.** The run needs the wallet to return receipts for the batch, and fails with an explicit error if it does not.
- **Failure inside a wallet.** What your wallet shows the user when a call fails is up to the wallet.

## Next

- [Executors](/docs/guides/executors)
- [Quickstart](/docs/quickstart)
- [Reviewing an assertion](/docs/reviewing)

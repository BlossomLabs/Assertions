---
title: Quickstart
description: Guard a small payment from your own wallet with three assertions in the builder, and watch one of them stop the batch, in about five minutes.
---

You will build a batch that pays 0.001 ETH from your wallet and reverts unless the recipient got it and your wallet kept a minimum. Everything up to the last step runs on a simulated copy of the chain, so nothing is sent until you choose to.

You need a browser wallet holding at least 0.002 ETH on a network the [builder](/builder) lists, and a second address to pay.

## 1. Compose the batch

1. Open the [builder](/builder) and press "Connect wallet".
2. Under "Executor and network", pick the network your ETH is on under "Network", and choose **This wallet** under "From".
3. Under "Actions", open the "EVML editor" tab and enter these two lines, with your second address in place of the one shown:

```evml
set $recipient 0x2222222222222222222222222222222222222222
send $recipient --value 1e15
```

`set` gives the address a name. `send` pays it, and `1e15` is 0.001 ETH written in wei.

4. Press "Simulate batch".

The result reads "Simulation passed (1 action)". It ran on a fork, a copy of the chain, so no ETH has moved.

## 2. Add a check before the payment

Go to the second step, **Assertions**. Add a check that your wallet can afford the payment:

1. Under "Start from", choose "Native balance". The form fills in the token `ETH`, the account `@me` and the operator `>=`.
2. In "Expected value", enter `2e15`.
3. In "Revert message", enter `not enough ETH to pay`.
4. Under "When should it run?", choose "Before actions".
5. Check the line under "Generated assertion", which is marked "compiles", and press "Add assertion".

The builder adds this line to the batch, ahead of the payment:

```evml
assert @balance!(ETH @me) >= 2e15 "not enough ETH to pay"
```

An `assert` line has a value, a comparison and a message, like a Solidity `require`:

- `@balance!(ETH @me)` is the value: the ETH balance of `@me`, your connected account. Names that start with `@` are helpers, and the `!` at the end means the helper reads the chain when the batch executes, not when the script is written.
- `>= 2e15` is the comparison.
- `"not enough ETH to pay"` is the message the revert carries if the check fails.

## 3. Add two checks after the payment

Add two more the same way, both with "After actions". For the first, replace `@me` in the account field with `$recipient`:

```evml
assert @balance!(ETH $recipient) >= 1e15 "recipient not paid"
assert @balance!(ETH @me) >= 5e14 "wallet below its floor"
```

The first says the recipient holds at least what you sent. The second says your wallet still holds 0.0005 ETH once the payment is made.

## 4. Simulate with the assertions

Press "Simulate protected batch". The builder runs the payment again with the three checks around it, and the result reads "Simulation passed (1 action, 3 assertions)". The three claims hold on the fork, and the third step now says "Verified".

## 5. Make an assertion fail

A check that cannot fail protects nothing, so make one fail. Go back to the "EVML editor" in the first step, which now shows the assertions too. On the last line, change the limit from `5e14` to `1000e18`, more than your wallet holds, and press "Simulate protected batch" again.

This time the simulation fails, and the error carries your message: `wallet below its floor`. The payment did not happen either: when an assertion fails, the whole batch reverts.

Set the limit back to `5e14` and simulate once more, so the batch passes again.

## What you built

This is the whole batch as an EVML script. The builder adds the `batch ( ... )` wrapping for a wallet:

```evml
set $recipient 0x2222222222222222222222222222222222222222

batch (
  assert @balance!(ETH @me) >= 2e15 "not enough ETH to pay"
  send $recipient --value 1e15
  assert @balance!(ETH $recipient) >= 1e15 "recipient not paid"
  assert @balance!(ETH @me) >= 5e14 "wallet below its floor"
)
```

Lines run in order, so placement is part of the meaning: the first assertion asks about the state before the payment, and the last two ask about the state after it.

You can stop here. If you want to send the batch for real, go to the third step, **Submit**, and press "Execute batch". Your wallet sends the payment and the three checks as one group, and 0.001 ETH leaves your account.

## Next

- [Executors](/docs/guides/executors): why a failed assertion stops the whole batch, and when it does not.
- Guides for [Safe batches](/docs/guides/safe), [DAO proposals](/docs/guides/dao-proposals) and [wallet batches](/docs/guides/wallet-batches).
- [Recipes](/docs/recipes): assertions for the situations you are most likely to face.
- [Writing assertions in EVML](/docs/evml): reading other contracts, lists, strings and fallbacks.
- [Overview](/docs): a larger example, and what assertions do not cover.

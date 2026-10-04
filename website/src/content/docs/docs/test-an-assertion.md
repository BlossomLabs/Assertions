---
title: Test an assertion
description: "Make an assertion fail on purpose in the builder's simulation, so you know it can judge the value before you rely on it."
---

An assertion that cannot fail protects nothing. Before you rely on one, make it fail on purpose.

## What the two simulations run

In the [builder](/builder), the first two steps each have a simulate button.

- "Simulate batch" runs the actions alone, with assertions ignored.
- "Simulate protected batch" runs the actions with your assertions in place.

Both run on a fork of the chain, as the executor you chose. The result shows which command failed, the revert text and the logs. If the protected batch fails, the actions-only run tells you whether an action or an assertion is at fault.

## Make the condition fail

1. Run the protected simulation and note that it passes.
2. Change the condition so it is false right now. For a floor, set the limit far above the current balance:

```evml
assert $token::!{balanceOf(address)(uint256) $treasury} >= 1000000000e18 "treasury below floor"
```

3. Simulate again. It must fail, naming that assertion and showing the `actual` value you expect. [Troubleshooting](/docs/troubleshooting#reading-a-failed-assertion) explains the fields of the failure.
4. Restore the real limit and simulate once more.

## Check the placement

Move the assertion to the other side of the action and simulate again. The result should change. If it passes on both sides, the assertion does not depend on the action, so it says nothing about the action's outcome.

## What a passing simulation does not show

A passing simulation shows the batch passes on a fork of the chain as it is now. The chain can change before execution, a delayed proposal runs later, and a condition that is always true also passes. Only a deliberate failure shows that the check can judge the value.

## Next

- [Troubleshooting](/docs/troubleshooting): read a failure you did not expect.
- [Reviewing an assertion](/docs/reviewing): the checks a signer makes on an assertion someone else wrote.

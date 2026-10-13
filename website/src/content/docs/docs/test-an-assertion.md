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

## Suggested checks

When the protected simulation passes, the builder may list "Suggested checks" under the result: assertions drawn from what the run did, such as a new owner, a granted role, a proxy or beacon upgraded to a new implementation, an ENS name given a new owner or resolver, an allowance, or a balance after a transfer. Each row is a sentence, such as "0x28C6…1d60 keeps at least 51,950.2982 USDC", with an "Add" button. Every account, contract and token in it links to the chain's block explorer, and hovering one shows its full address. A token symbol stands alone only when the chain's token list gives that address that symbol; otherwise the address is shown beside it. "Show code" under the sentence reveals the EVML the row would add. Nothing is added until you press "Add", and an added check goes after the actions like any other, so simulate again afterwards.

Adding a check writes three things into the batch:

- a `set` line for each address the check mentions, such as `set $usdc 0xA0b8…eB48`, once per address. A variable the batch already has for that address is reused (the ones your actions use included), and a name the batch already uses for something else is left alone (the new one becomes `$spender2`);
- the `load` line of any module the check needs, once;
- the check itself, written with those variables and with amounts in the token's own units: `assert @balance!($usdc $safe) >= @token:amount($usdc 51950.2982)`. The chain's own currency is written the same way, `@token:amount(ETH 1.5)`. An amount too small to read in those units is given in base units, and the line says so in a comment: `assert @token:allowance!($weth $safe $spender) == 5  # base units of $weth`.

A token is a variable set to an address, not a bare symbol, on purpose. A symbol is looked up in the token list each time the script is compiled, and the list can change; the variable pins the token the check was drawn from. Removing a check also removes a variable nothing else uses.

### How the addresses are named

"Batch so far" lists the variables once, above the commands, as "Addresses". Each address has one variable, used by the actions and the checks alike:

- A token on the network's token list is named by its symbol there (`$usdc`). What a contract calls itself never names a variable: a token that is not on the list is `$contract`, whatever its `symbol()` says.
- The account that executes has the name you gave it by choosing the executor: `$safe`, `$governor` or `$dao`. For a Governor that executes through a timelock, the account the batch runs from is the timelock, so that one is `$timelock`. For a wallet it is `$executor`, or `$wallet` when you typed the account to simulate as. Change the executor and the variable is renamed with it. Only your choice of executor gives these names: a contract parameter or an imported file that uses one of these words (`safe`, `executor`…) for some other address gets a neutral name instead.
- Anything else is named for what it is in the line that first used it: `$to`, `$spender`, `$owner`. When the same address later appears in another part (the recipient of a transfer is also the spender of an approval), no single part names it, so the builder renames it everywhere to what it can read of it: `$account` when the address has no code, `$contract` when it has, `$address` when it could not tell.

To choose a name yourself, click it in "Addresses", type the new one and press Enter. Every line follows. A name must be letters and digits, starting with a letter, and must not be in use. A name you gave is never changed by the builder afterwards.

Read each one before adding it:

- It is the contract's own word. A suggestion comes from an event a contract emitted and a view of the same contract that agrees with it, and the row says which: "Suggested by USDC's Transfer event". The name is the one the contract gives itself, so a token that is not USDC can show that name too. It links to the contract on the chain's block explorer, and hovering it shows the full address; a contract without a name is shown by its shortened address. For a contract you have not reviewed, a suggestion is worth no more than that contract.
- A suggested floor is the number the sentence shows, rounded down, so "keeps at least 51,950.2982 USDC" checks `>= 51950.2982` and can sit a hair below the balance the simulation saw. An allowance is checked exactly.
- Amounts are the numbers this simulation produced. They fit a batch that executes right away. A Safe transaction or a proposal executes later, and the balance or the allowance may have moved by then, so the builder marks those suggestions and says which of the two it is.
- The floor on the executor's own ETH (or the chain's currency) leaves room for an assumed gas fee, and its description says how much. A transaction that costs more than that fails the check, so raise the room or drop the check when fees are high. The floor also depends on everything else the account does: any other transaction that spends from it before this one executes can take the balance below the floor, and the builder says so on that row.
- A check on someone else's balance, such as "the recipient holds at least what it received", can be made to fail by that account moving its funds first.

When you add suggested checks and simulate again, the builder runs that simulation at the same block the checks were drawn from, and the result says "at block" with its number. That run confirms the checks hold against the state they describe; it does not tell you they hold at the chain's latest block. Any other change to the batch, the executor or the network, or a wait of more than five minutes, puts the next simulation back on the latest block.

The list belongs to one simulation. Change an action, the executor or the network and it goes away until the protected batch passes again. It may also be incomplete for a very large run, and the builder says so when it is.

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

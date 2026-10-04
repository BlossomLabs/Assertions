---
title: DAO proposals
description: "Protect a Governor or Aragon OSx proposal: where the assertions go, why they must be absolute, how to simulate, create the proposal and what voters see."
---

You are writing a proposal that will execute days after the vote, and you want the vote to mean what you said it meant. This page walks through a Governor proposal that upgrades a vault and hands its admin role to a council Safe, and then shows the same pattern on an Aragon OSx DAO.

## Put the assertions inside the proposal

A proposal is an ordered list of calls. Assertions are calls too, so they go in the same list, in the same block as your actions. Put checks on the state the proposal relies on **before** the actions, and checks on the outcome **after** them. The builder asks "When should it run?" for each assertion and does the placement for you.

When the proposal executes, the actions and the assertions run in order. If an assertion fails on an OpenZeppelin Governor, executing the proposal reverts and none of its calls take effect, with or without a timelock. Other Governors may differ, so read [Executors](/docs/guides/executors) for the general rule. For Aragon OSx the proposal carries an allow-failure setting that defaults to no action being allowed to fail, which means a failing assertion fails the proposal. Leave it at the default.

## Use absolute thresholds, not captured values

Your script is built when you create the proposal. The calls run when the proposal executes, often a week later. A value you capture at build time (with `set $before ...`) is frozen into the script, so by execution day it describes the past:

```evml
set $token 0x4444444444444444444444444444444444444444
set $payee 0x6666666666666666666666666666666666666666
set $before @get($token "balanceOf(address)(uint256)" $payee)
assert $token::!{balanceOf(address)(uint256) $payee} == @num($before + 100e6) "payee not paid"
```

If the payee's balance changes during the voting period, this assertion compares against a number that is no longer true, and a correct proposal reverts. Say what must be true at execution instead:

```evml
assert $token::!{balanceOf(address)(uint256) $payee} >= 100e6 "payee not paid"
```

The same applies to prices, supplies and owner lists: state a threshold or an expected address, or compute from live reads with `@calc!`. See [Assert that something changed](/docs/evml#assert-that-something-changed) for captured values.

## Example: upgrade the vault, hand over the keys

The vote is to upgrade a vault proxy to an audited implementation and transfer its ownership to the council Safe. These four claims say what the vote meant:

- The vault's owner is the council Safe.
- The implementation behind the proxy has the audited code hash.
- Every signer on the council Safe is on the approved list.
- At least three signatures are required.

All four read live state when the proposal executes. Written as a Governor proposal:

```evml
load governor
load contracts
load lang
load safe

set $governor 0x323A76393544d5ecca80cd6ef2A560C6a395b7E3
set $vault 0x1111111111111111111111111111111111111111
set $newImpl 0x2222222222222222222222222222222222222222
set $councilSafe 0x3333333333333333333333333333333333333333
set $council [0x4444444444444444444444444444444444444444 0x5555555555555555555555555555555555555555 0x6666666666666666666666666666666666666666]

governor:propose $proposalId $governor "Upgrade the vault and hand admin to the council Safe" (
  exec $vault upgradeTo(address) $newImpl
  exec $vault transferOwnership(address) $councilSafe

  def @onCouncil! "$o: address -> bool" @includes!($council $o)
  assert $vault::!{owner()(address)} == $councilSafe "handover didn't land"
  assert @codeHash!($vault::!{implementation()(address)}) == 0xdfff0c54be05b5df7dc8f015f8c813825344770fee1ba1202130a4652b529ca9 "unaudited code"
  assert @all!(@safe:owners!($councilSafe) @onCouncil!) == true "unknown signer"
  assert @safe:threshold!($councilSafe) >= 3 "threshold too low"
)
```

The addresses here are placeholders. The code hash is a real one (WXDAI on Gnosis Chain) used as an example: use the hash of the build you audited. The proposal has six calls: the two actions, then the four assertions, in that order.

## Simulate

In the builder, choose **Governor** or **Aragon OSx DAO** as the executor and enter the Governor or DAO address (for Aragon, also the governance plugin, such as `token-voting`). The builder runs your composed block on a fork, as the account that will execute it, and can run it twice: once with only the actions, and once with the assertions. If the actions alone fail, the problem is in the batch. If only the protected run fails, an assertion caught something, and the error names the line.

Submitting is blocked until the protected batch has passed a simulation in its current form. Change the script and you simulate again.

The simulation runs the block as the account that will execute it. For a Governor that has a timelock, that is the timelock, and a check that depends on `@sender` is read against it. One limit remains: a fork passes if the claims hold now. It cannot tell you they will hold on execution day, which is why the thresholds above must describe the end state and not today's balances.

## Create the proposal

On the last step the builder wraps your block and shows the final script. For a Governor it is `governor:propose <governor> "<description>" ( ... )`. For Aragon OSx it is `aragonosx:connect <dao> ( aragonosx:propose <plugin> ... ( ... ) )`, with your description passed as the proposal metadata. Pressing the button sends the proposal-creation transaction from your wallet. Nothing in the proposal runs at that point.

A few things to know:

- A Governor proposal needs voting power above the Governor's proposal threshold at the previous block.
- If you want to vote, queue or execute the proposal later through EVMcrispr, you need the exact same description and the same block, because the proposal id is derived from them.
- A Governor block must contain at least one action, and cannot deploy contracts. An Aragon OSx block cannot deploy contracts or use delegatecall.
- Aragon OSx options include `--vote yes` to vote on creation, `--start` and `--end`.

Here is an Aragon OSx proposal with the same pattern on a treasury payment:

```evml
load aragonosx

set $usdc 0x4444444444444444444444444444444444444444
set $treasury 0x5555555555555555555555555555555555555555
set $payee 0x6666666666666666666666666666666666666666

aragonosx:connect 0x2222222222222222222222222222222222222222 (
  aragonosx:propose token-voting --metadata "ipfs://QmMetadata" (
    exec $usdc transfer(address,uint256) $payee 100e6
    assert $usdc::!{balanceOf(address)(uint256) $payee} >= 100e6 "payee not paid"
    assert $usdc::!{balanceOf(address)(uint256) $treasury} >= 50000e6 "treasury below floor"
  )
)
```

## What voters see

The proposal lists its actions as plain targets, values and calldata. The assertions are among them: calls to the Assertions contract, after the transfer or upgrade they protect. A voter or a delegate who opens the proposal in a block explorer or a governance interface sees those extra entries and can read them with [Reviewing an assertion](/docs/reviewing). Point voters to that page in your proposal description, and to the EVML script, which is shorter than the calldata.

Reviewers should confirm the Assertions address against [Deployments](/docs/contracts/deployments) for the proposal's chain.

---
title: Recipes
description: "Copy-pasteable assertions for common situations: funds, permissions, upgrades, prices, time and lists, with where each goes in the batch and what it does not cover."
---

Each recipe states a situation, gives the line, says where it goes in the batch and says what it does not protect against. Replace the `$variables` with your own addresses, or set them at the top of your script. The syntax is explained in [Writing assertions in EVML](/docs/evml), and the [builder](/builder) can write most of these lines for you.

Each recipe says whether it goes **before the actions** (a precondition) or **after** them (a postcondition). [Executors](/docs/guides/executors#placement) explains the difference, and the condition under which a failed assertion reverts your batch.

Several recipes assume these modules are loaded at the top of the script:

```evml
load token
load lang
load math
load receipts
load contracts
load safe
load governor
```

## Funds

### Treasury balance floor

Situation: a batch pays out of the treasury, and the treasury must keep a minimum balance.

```evml
assert $usdc::!{balanceOf(address)(uint256) $treasury} >= 500000e6 "treasury below floor"
assert @balance!(ETH $treasury) >= 100e18 "treasury ETH below floor"
```

Place it **after** the actions. The balance is read when the batch executes, so it reflects every transfer before it.

Does not protect against: value leaving in a form the balance does not show, such as a token you did not check, or a token that is still held but has lost its market value.

### Funds arrived at the recipient

Situation: a batch sends 250,000 USDC and you want proof that the recipient holds that much more than before.

```evml
set $before @get($usdc "balanceOf(address)(uint256)" $recipient)
assert $usdc::!{balanceOf(address)(uint256) $recipient} >= @num($before + 250000e6) "recipient did not receive the funds"
```

Place the `set` at the top of the script and the `assert` **after** the actions. `$before` is read when the script is built and frozen from then on. If the batch executes later, for example a proposal that waits a week, the recipient's balance may have moved. For delayed execution, assert an absolute amount instead.

Does not protect against: the recipient being the wrong address. The check confirms that the address you wrote received the funds, not that you wrote the right one.

## Permissions

### Admin or owner unchanged

Situation: a batch does unrelated work on a contract, and the owner must not change as a side effect.

```evml
assert $vault::!{owner()(address)} == $currentOwner "owner changed"
```

Place it **after** the actions. Use a fixed address you checked yourself, not a value read from the same contract before the batch.

Does not protect against: other roles. If the contract has a separate admin, pauser or minter, each needs its own line. It also does not catch a change that happens and is reversed inside the batch.

### Ownership handed over

Situation: a batch transfers a contract to a new owner.

```evml
assert $vault::!{owner()(address)} == $councilSafe "handover didn't land"
```

Place it **after** the actions. If the contract needs the new owner to accept the transfer and the batch never does that, `owner()` still names the old owner and the line fails, which is the point.

Does not protect against: the new owner being unable to act. A Safe whose signers have lost their keys passes this check. Pair it with the [Safe owners and threshold](#safe-owners-and-threshold-unchanged) recipe.

### Token allowance not left open

Situation: a batch approves a spender for one swap, and the approval must be gone afterwards.

```evml
assert @token:allowance!($usdc @sender $spender) == 0 "allowance left open"
```

Place it **after** the actions. Inside a Safe, Governor or Aragon block, `@sender` is the executor, which is the account that granted the approval.

Does not protect against: approvals granted by other accounts, or approvals on other tokens. It checks one owner, one spender and one token.

### Safe owners and threshold unchanged

Situation: a batch runs from a Safe, and the Safe's signers and threshold must come out the same.

```evml
assert @safe:threshold!($safe) == 3 "threshold changed"
assert @len!(@safe:owners!($safe)) == 5 "owner count changed"
assert @safe:isOwner!($safe $signer) == true "not an owner"
assert @safe:guard!($safe) == 0x0000000000000000000000000000000000000000 "guard set"
```

Place these **after** the actions. The `@safe:` helpers are experimental, so check the [builder](/builder) before relying on them.

Does not protect against: a swapped owner. The count can stay at 5 while one address is replaced, so name the owners you care about with `@safe:isOwner!`, or check the whole list as in the [list recipe](#every-holder-or-signer-is-on-an-allowlist). Modules enabled on the Safe are a separate matter that these lines do not read.

## Upgrades

### A contract is the build you expect

Situation: your batch calls a contract by address, and you want to be sure the code at that address is the contract you think it is, on this chain.

```evml
load contracts

assert @codeHash!(0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d) == 0xdfff0c54be05b5df7dc8f015f8c813825344770fee1ba1202130a4652b529ca9 "not the expected WXDAI"
```

Place it **before** the actions. This is the code hash of WXDAI on Gnosis Chain. Take the hash from a source you trust, such as the contract you reviewed, and not from the batch you are checking.

Does not protect against: behavior that depends on the contract's storage. Two contracts with the same code can behave differently. A proxy has the code of the proxy, so use the next recipe for upgradeable contracts.

### Proxy implementation matches an audited code hash

Situation: a vault is a proxy, and the code behind it must be the audited build, whatever the proxy's address says.

```evml
assert @codeHash!($vault::!{implementation()(address)}) == 0xdfff0c54be05b5df7dc8f015f8c813825344770fee1ba1202130a4652b529ca9 "unaudited code"
```

Place it **after** the actions. The implementation address is read when the batch executes, then the hash of the code at that address is compared with the audited hash. The hash shown is a real code hash (WXDAI on Gnosis Chain), used here as an example: use the code hash of the build you audited, which you can read from a block explorer.

Does not protect against: a proxy whose `implementation()` does not report the address that actually runs, such as one that stores it elsewhere, or an implementation that reads its behavior from other contracts. It also does not cover a function that needs a particular storage state.

## Prices

### Oracle price inside a band

Situation: a batch swaps or liquidates at the oracle's price, and the price must be near an expected level.

```evml
assert $oracle::!{price()(uint256)} ~= 2000e8 --delta 50e8 "price out of range"
```

Place it **before** the actions, so a bad price stops the batch before anything moves. Add the same line after if the actions themselves could move the oracle.

Does not protect against: a stale price that still sits inside the band, or a band that is too wide to matter. Choose the level and the delta yourself and keep them narrow.

### Two oracles agree

Situation: two independent feeds report the same asset and should not drift apart.

```evml
assert @absDiff!($a::!{price()(uint256)} $b::!{price()(uint256)}) <= 50e8 "oracles disagree"
```

Place it **before** the actions. Both prices are read live, so the check follows the market instead of a number you froze.

Does not protect against: both feeds being wrong in the same way, or both feeds reading from the same source.

## Time

### Expiry window

Situation: a batch is only valid before a deadline.

```evml
assert @block.timestamp! < 1780000000 "window closed"
```

Place it **before** the actions. The value is a Unix timestamp in seconds, compared with the timestamp of the block that executes the batch.

Does not protect against: the batch executing at a time you did not expect. The check only compares the execution block's timestamp with your deadline.

### Proposal or timelock operation in the right state

Situation: a batch executes a Governor proposal or a timelock operation and should only run while it is still live.

```evml
assert @governor:proposalState!($governor 42) != 6 "proposal expired"
assert @governor:timelockOperationState!($timelock $opId) == 2 "operation not ready"
```

Place both **before** the actions. Both helpers return the state as a number: here 6 is Expired and 2 is Ready. The [reference](/docs/reference#governor) lists every state. The `@governor:` helpers are experimental.

Does not protect against: the contents of the proposal. It tells you the proposal is in a given state, not that the calls inside it are the ones you meant.

## Lists

### Every holder or signer is on an allowlist

Situation: a registry returns a list of holders, and each must be on a list you approved.

```evml
def @onList! "$o: address -> bool" @includes!($allowed $o)
assert @all!($registry::!{holders()(address[])} @onList!) == true "holder not on allowlist"
```

Place it **after** the actions if the batch changes the list, or **before** if the batch relies on it. The list is read when the batch executes, so it covers however many entries there are at that moment. The same shape works for `@safe:owners!($safe)`.

Does not protect against: a list that is too short. Add a `@len!(...)` check, as in the Safe recipe, when the number of entries matters.

### Token name or symbol

Situation: a batch interacts with a token, and you want to be sure it is the token you think it is.

```evml
assert $token::!{symbol()(string)} == "USDC" "unexpected symbol"
assert @str.charset!($token::!{symbol()(string)} "A-Z0-9") == true "odd characters"
```

Place it **before** the actions. Strings compare with `==` and `!=`. `@str.charset!` requires every byte of the symbol to be in the allowed class, which catches symbols with lookalike characters.

Does not protect against: a counterfeit token that copies the name and symbol. A name is not an identity. Compare the token's address, or its code hash, when identity matters.

## Reads that may revert

### A fallback for a read that may revert

Situation: some tokens do not implement `decimals()`, and a missing method should count as 18 instead of failing the batch.

```evml
assert @bool!(@orElse!($token::!{decimals()(uint8)} 18) <= 18)
```

If the first read reverts, the assertion uses 18. Both values must be the same kind, and a constant fallback must fit in one word. Place it wherever the assertion it supports belongs.

Does not protect against: a fallback that hides a real failure. A contract that reverts because it is broken, paused or out of gas looks the same as one that lacks the method. Use `@orElse!` for contracts that lack a method, and `@reverts!` when the failure itself is what you want to observe.

## A real batch: TheDAO

On Jan 29, 2026, TheDAO's curator multisig moved 71,202 ETH (about $220M) and its remaining DAO tokens in one Safe batch. The batch had nineteen calls: ten that moved funds and changed settings, then nine calls to Assertions v1.0 ([Argos](/releases/argos)). The transaction is `0x462475a38cd8a3b75b2732db28ea21a7addfce059af03ea4f638f461c707bf10` on Ethereum.

The ten calls raised the old multisig's daily limit, sent 719.09 ETH to the Security Fund Safe, clawed 70,483.24 ETH back from ExtraBalance, sent 69,183.24 ETH to the staking withdraw Safe, refilled ExtraBalance with 1,300 ETH, swept the DAO tokens to the Security Fund Safe, allowed DGD and SAI as recipients and set the daily limit back to 0.

The nine assertions came last and checked the outcome:

1. ExtraBalance holds exactly 1,300 ETH.
2. The staking withdraw Safe holds at least 69,183.24 ETH.
3. The Security Fund Safe holds exactly 719.09 ETH.
4. The curators' Safe holds 0 ETH.
5. The Security Fund Safe's DAO token balance is exactly 390,644.98.
6. TheDAO's own DAO token balance is 0.
7. The old multisig's DAO token balance is 0.
8. DGD is an allowed recipient on TheDAO.
9. SAI is an allowed recipient on TheDAO.

These nine are exact balances at every destination, drained sources and two flags. Had any one failed, all nineteen calls would have reverted together. They are all postconditions, which is the placement the recipes above use for outcomes.

For a proposal that combines several of these recipes, see the example in [DAO proposals](/docs/guides/dao-proposals#example-upgrade-the-vault-hand-over-the-keys).

## Where to go next

- [Writing assertions in EVML](/docs/evml): the syntax behind every line here.
- [EVML assertion reference](/docs/reference): every operator and helper.
- [Test an assertion](/docs/test-an-assertion): make a recipe fail on purpose before you rely on it.
- [Reviewing an assertion](/docs/reviewing): reading these lines in a batch you did not write.
- [The builder](/builder): write and simulate assertions without the script.

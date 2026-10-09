---
title: Writing assertions in EVML
description: A task-by-task guide to the assert command, from comparing values to lists, strings, fallbacks and changes over a batch.
---

This guide is organized by what you want to check. Each section states the goal, shows the line, and says what to watch for. The [Overview](/docs) explains what an assertion is, and the [builder](/builder) writes many of these lines for you. 

## The shape of an assertion

```evml novalidate
assert <value> <operator> <expected> "message"
```

The value and the expected side are either **live** or **fixed**.

- A **live** side is read when the batch executes: a `::!` call, or a helper whose name ends in `!` (`@balance!`, `@calc!`, `@len!`).
- A **fixed** side is frozen into the script when it is built: a literal such as `100e18`, a `$variable`, or an ordinary helper such as `@token(WETH)`.

A plain `::` call reads the chain when the script builds, so it is refused inside an assertion. If you want to compare against a value read at build time, store it first with `set`.

The operators are `==`, `!=`, `>`, `<`, `>=`, `<=` and `~=` (approximately equal). An `assert` with no operator requires a boolean and checks that it is true. A message comes after the expected value, so to give a boolean check a message, write `== true "message"`.

Helpers come from modules. `std` is always loaded, and the others need a `load` line at the top of the script, which the examples below show. The [EVML assertion reference](/docs/reference) lists every operator, every helper and the module each helper belongs to.

## Check a balance or a state variable

Read the value with the function's signature written inline: `fn(argTypes)(returnTypes) args`.

```evml
load token

assert @token(WETH)::!{balanceOf(address)(uint256) @me} >= @token:amount(WETH 10) "insufficient balance"
assert $vault::!{paused()(bool)} == false "vault is paused"
assert $gov::!{paused()(bool)}
```

The first line reads the connected account's WETH balance. The last line has no operator, so it requires `paused()` to return true.

Use `@me` for the connected account and `@sender` for the account that sends the surrounding calls. Inside a Safe, Governor or Aragon OSx block, `@sender` is that executor, so an allowance check there usually reads `allowance(@sender, spender)`. `@tx.from!` is the transaction origin, which is a different identity again.

Native balances use `@balance!`:

```evml
assert @balance!(ETH $recipient) >= 1e18 "recipient underfunded"
```

## Check that a value stayed in range

For a price, a ratio or any number that should stay near a target, use `~=` with `--delta`:

```evml
assert $oracle::!{price()(uint256)} ~= 2000e8 --delta 50e8 "price out of range"
```

This passes when the price is within 50e8 of 2000e8. For two live values, use the absolute difference:

```evml
load math

assert @absDiff!($a::!{price()(uint256)} $b::!{price()(uint256)}) <= 50e8 "oracles disagree"
```

Signed returns compare signed:

```evml
assert $oracle::!{drift()(int256)} <= -5 "drifted"
```

## Follow an address

When one contract returns the address of another, chain the reads. Every hop except the last must return an address.

```evml
assert $pool::!{token()(address)}::!{symbol()(string)} == "WETH"
```

If a hop returns several values, a lens picks the address:

```evml
assert $pool::!{poolInfo()(uint112,uint112,address)}[_ _ $]::!{symbol()(string)} == "WETH"
```

The thing before `::!` can be any expression that gives an address when the batch executes, such as a helper. The signature is always written inline, since there is no address at build time to look an ABI up from:

```evml
assert @bytes!($reg::!{packedPool()(uint256)} ">>" 96)::!{fee()(uint24)} <= 3000
```

## Pick a value out of a return

A destructure lens in square brackets selects part of a return. `$` marks the part you want and `_` skips one.

```evml
# the second value of a three-value return
assert $pool::!{getReserves()(uint112,uint112,uint32)}[_ $ _] >= 1000 "low reserve"

# the second owner in an address array
assert $safe::!{getOwners()(address[])}[[_ $]] == @me "second owner changed"

# a field inside a struct inside an array
assert $gov::!{proposals()((address,uint256,bool)[])}[[_ [_ _ $]]] == true
```

Each nesting level steps into an array or a struct. A `...` marker counts from the end: `[... $]` is the last value, `[[... $]]` is the last array element, resolved against the live length.

## Use one read as the input to another

An argument can itself be a read. It is resolved when the batch executes and inserted into the outer call.

```evml
assert $vault::!{sharesOf(address)(uint256) $registry::!{owner()(address)}} > 0
```

This reads the registry's owner, then reads that owner's shares in the vault. Reads can nest to any depth. A value that returns an array can also be selected with a lens and used as an argument. Each live part adds execution cost, so nest only what the claim needs.

## Check chain state

The block, the chain and a contract's code are helpers, like everything else.

```evml
load receipts
load contracts

assert @chainId! == 100 "wrong chain"
assert @block.timestamp! < 1780000000 "proposal expired"
assert @codeHash!($proxy::!{implementation()(address)}) == 0xdfff0c54be05b5df7dc8f015f8c813825344770fee1ba1202130a4652b529ca9 "implementation changed"
```

`@chainId!` and `@block.timestamp!` need `load receipts`, and `@codeHash!` needs `load contracts`. The last line reads a proxy's implementation address and compares the hash of the code at that address with the audited build.

## Do arithmetic

Wrap arithmetic in `@calc!`. It uses checked integer math: `+ - * // % ^`, where `//` is integer division.

```evml
assert @calc!(@balance!(ETH @me) + $weth::!{balanceOf(address)(uint256) @me}) > 0
```

Wrap logic in `@bool!`: comparisons plus `and`, `or`, `xor` and `not`.

```evml
assert @bool!(($gov::!{quorum()(uint256)} > 0) or (not $gov::!{paused()(bool)}))
```

An infix expression without a wrapper is an error, so write `@calc!(a + b)` and `@bool!(a or b)`.

## Check every item in a list

Array helpers need `load lang`. Count a list with `@len!`:

```evml
load lang

assert @len!($registry::!{holders()(address[])}) >= 3 "not enough holders"
```

Test every element with `@all!`, any element with `@any!`, or sum the list with `@sum!`. The test is a named definition with `def`, and the definition takes the element as its parameter.

```evml
load lang

def @ge100! "$x: number -> bool" @bool!($x >= 100)
assert @all!($vault::!{caps()(uint256[])} @ge100!) == true "a cap is below 100"
assert @sum!($vault::!{caps()(uint256[])}) <= 10000e18 "caps exceed the limit"
```

The definition is inlined where it is used, so it must be fully typed. The length of the list is read when the batch executes, so the check covers however many elements there are at that moment.

Count the elements that pass a test with `@count!`, which gives a number to compare:

```evml
load lang

def @funded! "$who: address -> bool" @bool!($token::!{balanceOf(address)(uint256) $who} >= 1000)
assert @count!($registry::!{holders()(address[])} @funded!) >= 3 "fewer than three funded holders"
```

`@filter!`, `@find!`, `@map!` and `@reduce!` work the same way. `@find!` reverts the assertion when no element matches.

## Check a string

```evml
load lang

assert @str.includes!($token::!{name()(string)} "Wrapped") == true "unexpected name"
assert @str.split!($pool::!{name()(string)} " " -1) == "LP" "not an LP token"
assert @str.charset!($token::!{symbol()(string)} "A-Z0-9") == true "odd characters in symbol"
```

`@str.split!` splits on a delimiter and selects one segment (`-1` is the last). `@str.charset!` requires every byte to be in the character class. Strings compare with `==` and `!=` anywhere.

## Fall back, branch, and expect a failure

Some reads revert on some contracts. Use `@orElse!` to supply a value when the first read fails:

```evml
assert @bool!(@orElse!($token::!{decimals()(uint8)} 18) <= 18)
```

If `decimals()` reverts, the assertion uses 18. Both sides must be the same kind of value, and a constant fallback must fit in one word.

Use `@ifElse!` to choose a branch by a condition. Only the branch that is taken is read:

```evml
assert @ifElse!($gov::!{paused()(bool)} ? $a::!{safeLimit()(uint256)} : $a::!{limit()(uint256)}) >= 5
```

Spaces are required around `?` and `:`.

Use `@reverts!` when the claim is that a call must fail:

```evml
assert @reverts!($vault::!{deposit(uint256)(uint256) 0}) == true "zero deposit accepted"
```

A fallback that hides a failure weakens whatever you assert on the result. Use `@orElse!` for contracts that lack a method, and `@reverts!` when the failure is the thing you want to observe.

## Assert that something changed

An on-chain read cannot see the past, so capture the starting value when the script builds and compare against it:

```evml
set $before @get($token "balanceOf(address)(uint256)" @me)
# ... actions ...
assert $token::!{balanceOf(address)(uint256) @me} == @num($before + 100e18)
```

A captured value is fixed when the script is built. If the batch executes later, as in a proposal that waits a week, the number may be stale. For delayed execution, prefer an absolute threshold or a live `@calc!`.

## Read a Safe, a Governor or a token

Protocol modules add reads for common systems. These take a Safe's signers and threshold from the Safe itself:

```evml
load lang
load safe

def @onCouncil! "$o: address -> bool" @includes!($council $o)
assert @safe:threshold!($councilSafe) >= 3 "threshold too low"
assert @all!(@safe:owners!($councilSafe) @onCouncil!) == true "unknown signer"
```

The contract these helpers read does not have to be an address you know in advance. It can be a call that returns the address, read when the batch executes. Use this when the batch itself changes which contract is the right one, for example after it migrates a vault or rotates a Safe:

```evml
load safe
load token

assert @safe:threshold!($registry::!{treasury()(address)}) >= 2 "treasury threshold too low"
assert @token:decimals!($vault::!{asset()(address)}) == 18 "unexpected asset"
```

The helper trusts the call to return the kind of contract it expects. If it returns something else, the read reverts and the assertion fails.

The `token`, `vault`, `acl`, `safe` and `governor` modules work the same way. Some of them are experimental, so their helpers may change between versions: the [reference](/docs/reference#helpers) says which, and lists every helper with its arguments.

## Where to go next

- [EVML assertion reference](/docs/reference): every operator and helper.
- [Recipes](/docs/recipes): ready-made assertions for common situations.
- [Test an assertion](/docs/test-an-assertion): make a check fail on purpose before you rely on it.
- [Reviewing an assertion](/docs/reviewing): how the compiled calls read to someone approving a batch.
- [The builder](/builder): write and simulate assertions without writing the script by hand.

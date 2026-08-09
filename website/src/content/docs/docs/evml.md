---
title: EVMcrispr integration
description: Writing assertions as one-line EVML scripts with the assertions module.
---

The [EVMcrispr](https://evmcrispr.blossom.software) `assertions` module compiles readable one-line scripts into the exact core and Operators calldata described in the rest of these docs. Load it with `load assertions`, then every command batches an assertion action into the script. The [visual builder](/builder) generates these lines for you and previews their live values.

```evml
load assertions

assertions:assert $token::balanceOf(@me) >= 100e18 "not enough tokens"
```

## The assert command

```evml
assertions:assert <target>::<viewFn(args)> <op> <expected> "revert msg"            # named method, ABI fetched automatically
assertions:assert <target>::{viewFn(argTypes)(returnType) <args>} <op> <expected>  # inline ABI when needed
```

Operators: `==` `!=` `>` `<` `>=` `<=` and `~=` (approximate equality, with `--delta`). Strings support `==` / `!=` anywhere (nested comparisons compile to on-chain keccak). A bare `assertions:assert <call>` with no operator requires a boolean call and compiles to an `EQ true` constraint.

Every line compiles to the ERC-8211 judge: the live expression becomes an `InputParam` (a staticcall, balance read, or nested core expression) validated by inline constraints (`EQ`/`GTE`/`LTE`/`IN`) via `assertParam`. Comparisons the constraints can't express directly (`!=`, signed and two-live-side comparisons) route through a read-spliced [Operators](/docs/operators) comparison judged `EQ 1`.

### Chained calls

`::` chains hop through addresses and compile to the core's [`chain`](/docs/core/reads): every hop but the last must continue on an address, and a multi-value hop selects it with a lens.

```evml
assertions:assert $pool::{token()(address)}::{symbol()(string)} == "WETH"
assertions:assert $t::{f()(uint112,uint112,address)}[_ _ $]::{b()(uint256)} > 0
```

### Lenses

A destructure lens after a call selects which return value the assertion uses:

- `[_ $ _]` picks one output of a multi-value return (compiles to the core's [`pick`](/docs/core/reads) raw word selection).
- Nested levels navigate into arrays and structs, one step per nesting level: `{owners()(address[],address)}[[_ $]]` is element 1 of the first return value; `{proposals()((address,uint256,bool)[])}[[_ [_ _ $]]]` is `proposals[1].executed`. These compile to the core's typed [`nav`](/docs/core/reads) navigation.
- A `...` rest marker anchors the slots after it from the end: `[... $]` = last return value, `[[... $]]` = last array element, resolved against the live length on-chain.

### Nested live calls as arguments

A call's argument can itself be a call, resolved **at assertion time** and spliced into the enclosing calldata (any nesting depth):

```evml
assertions:assert $vault::{sharesOf(address)(uint256) $registry::{owner()(address)}} > 0
assertions:assert $a::{a(address)(uint256,uint256[]) $b::{b(uint256,uint256)(address) $c::{c(address)(uint256) @me} $d::{d()(uint256)}}}[_ [$]] == 7
```

A lens on a nested call argument selects the value to splice, including dynamic values (arrays) navigated at runtime:

```evml
assertions:assert $a::{a(address[])(uint256) $b::{b()(address,address[][])}[_ [_ $]]} == 5
```

These compile to the core's [`read`](/docs/core/reads): each nesting level becomes a `read` whose segments fetch the inner values and splice them into the enclosing calldata at judge time. Word-typed arguments (uint, int, address, bool, bytes32) splice anywhere; a dynamic-typed argument (array/string/bytes selected by a lens) must be the last argument of the outermost judged call, and there can be at most one.

### Other commands

| Command | Description |
|---------|-------------|
| `assertions:assert` | Assert that an on-chain expression satisfies a comparison |
| `assertions:assert-balance` | Assert the native balance of an account |
| `assertions:assert-block-number` | Assert the current block number |
| `assertions:assert-chainid` | Assert the chain ID equals an expected value |
| `assertions:assert-code` | Assert an address has deployed code |
| `assertions:assert-codehash` | Assert an address has a specific code hash |
| `assertions:assert-no-code` | Assert an address has no deployed code |
| `assertions:assert-timestamp` | Assert the current block timestamp |

## On-chain helpers (trailing `!`)

Helpers with a trailing `!` evaluate **on-chain at assertion time** by compiling to core and Operators calldata; ordinary helpers (`@token`, `@get`, `@num`, ...) resolve at composition time and freeze into the calldata.

| Helper | Returns | Description |
|--------|---------|-------------|
| `@absdiff!(a b)` | number | Absolute difference computed on-chain; never underflows. `@absdiff!(a b) <= d` is the composable approximate-equality |
| `@balance!(ETH\|token addr)` | number | Live balance: native for ETH, else ERC-20 `balanceOf` (token symbols resolve like `@token`) |
| `@basefee!` / `@blobbasefee!` | number | The block base fee / blob base fee in wei at assertion time |
| `@blockhash!(n)` | bytes32 | The hash of block `n` (0 outside the last 256 blocks); the number composes live, e.g. `@blockhash!(@blocknumber! - 1)` |
| `@blocknumber!` | number | The block number at assertion time |
| `@coinbase!` / `@origin!` | address | The block proposer fee recipient / the transaction origin at assertion time |
| `@gaslimit!` | number | The block gas limit at assertion time |
| `@prevrandao!` | number | The previous RANDAO mix at assertion time |
| `@sqrt!(expr)` | number | Integer square root (floor) computed on-chain, e.g. `@sqrt!($pool::reserve0() * $pool::reserve1())` |
| `@bool!(expr)` | bool | On-chain comparisons and logic: `== != < <= > >= and or xor not` |
| `@bytelen!(call)` | number | Byte length of a call's returned bytes/string payload |
| `@bytes!(a "&" b)` | number | Bitwise word ops (`&` `\|` `^` `<<` `>>`, operator quoted); single-arg `@bytes!(x)` is the raw-word cast |
| `@chainid!` | number | The live chain id, composable (unlike `assert-chainid`'s constant comparison) |
| `@charset!(call "a-z0-9-")` | bool | Whether every byte of a string return is in the character class (ranges + literals, byte-level ASCII) |
| `@codehash!(addr-or-call)` | bytes32 | Live EXTCODEHASH; the argument may be a `::` call resolving to an address |
| `@hash!(call)` | bytes32 | keccak256 of the decoded return payload, on-chain (a string return hashes as keccak256 of the string bytes) |
| `@includes!(call "part")` | bool | Whether a string return contains a substring (exact bytes, case-sensitive) |
| `@len!(call)` | number | Decoded length of a dynamic return: element count for arrays, byte length for string/bytes |
| `@min!(a b ...)` / `@max!(a b ...)` | number | On-chain minimum / maximum of two or more values |
| `@not!(x)` | any | On-chain negation: logical not on bools (stays bool), bitwise complement on numbers/bytes32 |
| `@num!(expr)` | number | On-chain arithmetic (`+ - * / % ^`, `xor`) over live calls and constants; unsigned `a * b / c` fuses into one 512-bit `mulDiv`, and a live string operand coerces through `parseUint` |
| `@read!(target "sig(args)(ret)" ...args)` | any | Direct access to the core's `read`: call any view function with computed arguments |
| `@split!(call "delim" i)` | string | Split a string return and select one segment; negative index counts from the end (`-1` = last, `-2` = second-last) |
| `@timestamp!` | number | The block timestamp at assertion time |

The string helpers compile to compositions rather than dedicated ops: `@split!` compiles to `indexOf`/`slice`, `@includes!` to the `indexOf`/`byteLen` sentinel comparison, and `@charset!` to the `foldBytes` + `bitSet` recipe (see [the fold page](/docs/operators/fold)).

Examples:

```evml
assertions:assert @num!(@balance!(ETH $addr) + $weth::balanceOf($addr)) > 0
assertions:assert @bool!(($gov::quorum() > 0) or (not $gov::paused()))
assertions:assert @split!($pool::name() " " -1) == "LP"
assertions:assert @len!($registry::{holders()(address[])}) >= 3
assertions:assert @codehash!($proxy::{implementation()(address)}) == 0x1234...cdef
```

## Composition-time captures

To assert a **change**, capture the pre-state at composition time and assert against it:

```evml
set $before @get($token "balanceOf(address)(uint256)" @me)
# ... actions ...
assertions:assert $token::balanceOf(@me) == @num($before + 100e18)
```

Composition-time captures go stale, so for proposals executed later prefer absolute thresholds or live `@bool!` / `@num!` forms.

## Configuration variables

| Variable | Type | Description |
|----------|------|-------------|
| `$assertions:address` | address | Override the resolved assertions contract address (forks / testing) |
| `$assertions:operators` | address | Override the resolved Operators contract address (forks / testing) |

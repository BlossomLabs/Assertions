---
title: EVMcrispr integration
description: Writing assertions as one-line EVML scripts with the assertions module.
---

The [EVMcrispr](https://evmcrispr.blossom.software) `assertions` module compiles readable one-line scripts into the exact core and Operators calldata described in the rest of these docs. Load it with `load assertions`, then every command batches an assertion action into the script. Scripts that use the lang module's array/string helpers (`@len!`, `@str.split!`, `@bytes.len!`, ...) also need `load lang`; the block and transaction context reads (`@block.timestamp!`, `@tx.from!`, ...) need `load receipts`, and the arithmetic conveniences (`@min!`, `@sqrt!`, ...) need `load math`. The [visual builder](/builder) generates these lines for you and previews their live values.

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

Helpers with a trailing `!` evaluate **on-chain at assertion time** by compiling to core and Operators calldata; ordinary helpers (`@token`, `@get`, `@num`, ...) resolve at composition time and freeze into the calldata. Since the helper unification each helper is one name with up to two faces: the plain face runs (or snapshots) at script build time, the `!` face compiles to on-chain calldata.

Array faces (`@map!`, `@filter!`, `@all!`, `@any!`, `@find!`, `@reduce!`) apply a NAMED definition rather than an inline expression. `def @name!` declares one, and the face supplies the arguments it takes:

```evml
def @ge100! "$x: number -> bool" @bool!($x >= 100)
assertions:assert @all!($vault::{caps()(uint256[])} @ge100!)
```

The definition is inlined where it is used, so naming a parameter more than once stamps the element at each place it appears — `@num!($x * $x)` squares in one call. It compiles rather than runs, so it must be fully typed and cannot be called off-chain, and it is scoped like any other `def`.

The on-chain surface spans five modules:

- **std** (always available, no `load` needed): `@num!`, `@bool!`, `@bytes!`, `@hash!`, `@balance!`.
- **lang** (needs `load lang`): the array and string faces, including `@len!`, `@bytes.len!`, `@str.len!`, `@str.split!`, `@str.includes!`, `@str.charset!`.
- **assertions** (needs `load assertions`): the judges and environment checks `@ok!`, `@not!`, `@chainid!` and `@codehash!`.
- **receipts** (needs `load receipts`): the block and transaction context reads, the `@block.*` and `@tx.*` families below.
- **math** (needs `load math`): the arithmetic conveniences `@min!`, `@max!`, `@absdiff!` and `@sqrt!`.

| Helper | Module | Returns | Description |
|--------|--------|---------|-------------|
| `@absdiff!(a b)` | math | number | Absolute difference computed on-chain; never underflows. `@absdiff!(a b) <= d` is the composable approximate-equality (plain `@absdiff` computes off-chain) |
| `@balance!(ETH\|token addr)` | std | number | Live balance: native for ETH, else ERC-20 `balanceOf` (token symbols resolve like `@token`); replaces the removed `@token:balance` |
| `@block.basefee!` / `@block.blobbasefee!` | receipts | number | The block base fee / blob base fee in wei at assertion time (plain `@block.basefee(block? chain?)` / `@block.blobbasefee(block? chain?)` read a sealed block off-chain; the blob fee with no block argument reads the live `eth_blobBaseFee` value) |
| `@block.hash!(n)` | receipts | bytes32 | The hash of block `n` (0 outside the last 256 blocks); the number composes live, e.g. `@block.hash!(@block.number! - 1)`; plain `@block.hash(block? chain?)` reads ANY sealed block off-chain, unbounded by the 256-block window |
| `@block.number!` | receipts | number | The block number at assertion time (plain `@block.number(block? chain?)` reads a sealed block off-chain, default latest) |
| `@block.coinbase!` / `@tx.from!` | receipts | address | The block proposer fee recipient / the sender (origin) of the executing transaction at assertion time (plain `@block.coinbase(block? chain?)` and `@tx.from(hash chain?)` read sealed data off-chain) |
| `@block.gaslimit!` | receipts | number | The block gas limit at assertion time (plain `@block.gaslimit(block? chain?)` reads a sealed block off-chain) |
| `@block.prevrandao!` | receipts | number | The previous RANDAO mix at assertion time (plain `@block.prevrandao(block? chain?)` reads a sealed block's mixHash; pre-merge blocks carry difficulty semantics there) |
| `@sqrt!(expr)` | math | number | Integer square root (floor) computed on-chain, e.g. `@sqrt!($pool::reserve0() * $pool::reserve1())` (plain `@sqrt` computes off-chain) |
| `@bool!(expr)` | std | bool | On-chain comparisons and logic: `== != < <= > >= and or xor not` |
| `@bytes.at!(call i)` | lang | bytes | One byte of a bytes/string return, sliced on-chain; a negative index resolves against the live byte length |
| `@bytes.len!(call)` / `@str.len!(call)` | lang | number | Decoded byte length of a bytes/string return (multi-byte UTF-8 characters count once per byte) |
| `@bytes.slice!(call start end?)` | lang | bytes | A byte range of a bytes/string return, sliced on-chain; negative bounds resolve against the live byte length (inverted live ranges revert, there is no silent clamp) |
| `@bytes!(a "&" b)` | std | number | Bitwise word ops (`&` `\|` `^` `<<` `>>`, operator quoted); single-arg `@bytes!(x)` is the raw-word cast |
| `@chainid!` | assertions | number | The live chain id, composable (unlike `assert-chainid`'s constant comparison) |
| `@str.charset!(call "a-z0-9-")` | lang | bool | Whether every byte of a string return is in the character class (ranges + literals, byte-level ASCII) |
| `@codehash!(addr-or-call)` | assertions | bytes32 | Live EXTCODEHASH; the argument may be a `::` call resolving to an address |
| `@enumerate!(call)` | lang | array | Pair every element with its index on-chain (`zipWords(iotaWords(n), payload)` with the live length); the result is an on-chain record (see `@keys!`) |
| `@filter!(call pred)` | lang | array | Keep the elements passing `pred`, a named `def @name!` of one parameter returning bool; the kept words payload composes with the other array faces |
| `@find!(call pred)` | lang | any | The first element passing the predicate: a core pick over the `filterWords` output; no match REVERTS the assertion at judge time |
| `@hash!(call)` | std | bytes32 | Hash of the decoded return payload, on-chain: keccak256 by default, sha256 with a second `"sha256"` argument |
| `@str.includes!(call "part")` | lang | bool | Whether a string return contains a substring (exact bytes, case-sensitive) |
| `@keys!(record)` / `@values!(record)` | lang | array | Lanes 0/1 of an on-chain record through `unzipWords`. A record is a zipped key/value word-pair payload, the interleaved words that `@zip!`/`@enumerate!` produce; string keys travel as their keccak digests |
| `@len!(call)` | lang | number | Decoded length of a dynamic return: element count for arrays (nested array faces included), byte length for string/bytes |
| `@lookup!(record name)` | lang | any | The value at `wordIndexOf(keys, key)` of a record: literal string keys keccak-hash at composition time, live keys hash on-chain; a missing key REVERTS (the sentinel index lands past the values lane) |
| `@min!(a b ...)` / `@max!(a b ...)` | math | number | On-chain minimum / maximum of two or more values (plain `@min` / `@max` compute off-chain) |
| `@not!(x)` | assertions | any | On-chain negation: logical not on bools (stays bool), bitwise complement on numbers/bytes32 |
| `@num!(expr)` | std | number | On-chain arithmetic (`+ - * / % ^`, `xor`) over live calls and constants; unsigned `a * b / c` fuses into one 512-bit `mulDiv`, and a live string operand coerces through `parseUint` |
| `@ok!(call)` | assertions | bool | Whether a live call resolves without reverting: true when it succeeds, false when it reverts |
| `@slice!(call start end?)` | lang | array | Elements `[start, end)` of an array return as a live words payload (indices scale to byte offsets at composition time, negative bounds resolve against the live length); composes with the other array faces |
| `@str.concat!("a" call ...)` | lang | string | Concatenate constant strings with at most one live call part through a single on-chain `concat` |
| `@str.split!(call "delim" i)` | lang | string | Split a string return and select one segment; negative index counts from the end (`-1` = last, `-2` = second-last) |
| `@sum!(call)` | lang | number | The checked sum of an array return's single-word elements, on-chain (native `sumWords`); the fixed-operation form of `@reduce!(add 0)` |
| `@block.timestamp!` | receipts | number | The block timestamp at assertion time (plain `@block.timestamp(block? chain?)` reads a sealed block off-chain, default latest) |
| `@tx.gasprice!` | receipts | number | The gas price of the executing transaction in wei; bound what the batch is willing to pay |
| `@tx.blobhash!(i)` | receipts | bytes32 | The versioned hash of blob `i` carried by the executing transaction (0 when out of range) |

Beyond these, the lang module gives most of its array and string helpers an on-chain face too: `@str.slice!`, `@str.at!`, `@str.concat!`, `@str.replace!`, `@str.lower!`, `@str.upper!`, `@str.join!`, the bytes twins `@bytes.at!`/`@bytes.slice!`/`@bytes.concat!`, and over arrays `@at!`, `@slice!`, `@includes!`, `@all!`, `@any!`, `@map!`, `@filter!`, `@find!`, `@reduce!`, `@sum!`, `@sort!`, `@unique!`, `@reverse!`, `@zip!`, `@unzip!`, `@enumerate!`, `@flat!`, `@concat!`, plus the record faces `@keys!`/`@values!`/`@lookup!`. Protocol modules follow the same pattern with live read faces (token's `@token:decimals!`, `@token:allowance!` and `@token:symbol!` (digest-judged), safe's `@safe:threshold!` and the array operands `@safe:owners!`/`@safe:modules!` (composable with the lang array faces), governor's `@governor:proposalState!` and `@governor:timelockOperationState!` (OZ's numeric OperationState via nested conds), the vault and acl reads).

The string helpers compile to compositions rather than dedicated ops: `@str.split!` compiles to `indexOf`/`slice`, `@str.includes!` to the `indexOf`/`byteLen` sentinel comparison, and `@str.join!` to a single `concat` with the delimiter interleaved at composition time. `@str.charset!` compiles to the native `charset` op (its class-spec mask baked in at composition time; the `foldBytes` + `bitSet` form it replaced stays the general pattern for other per-byte predicates), and `@sum!` to the native `sumWords` (see [the fold page](/docs/operators/fold)).

Examples:

```evml
load assertions
load lang

assertions:assert @num!(@balance!(ETH $addr) + $weth::balanceOf($addr)) > 0
assertions:assert @bool!(($gov::quorum() > 0) or (not $gov::paused()))
assertions:assert @str.split!($pool::name() " " -1) == "LP"
assertions:assert @len!($registry::{holders()(address[])}) >= 3
assertions:assert @codehash!($proxy::{implementation()(address)}) == 0x1234...cdef
```

## Constructed calls: the `!::` operator

`<head>!::{sig(argTypes)(retTypes) args}` constructs a whole call **at assertion time** through the core's [`read`](/docs/core/reads), replacing the old `@read!` helper. The head may be any expression: a `::` chain, an on-chain helper, or a computed word, as long as it resolves to a clean address word on-chain. The arguments splice like nested live calls, and the inline ABI form is mandatory (a `!::` hop has no composition-time address to fetch an ABI from).

```evml
assertions:assert @bytes!($reg::packedPool() ">>" 96)!::{fee()(uint24)} <= 3000
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

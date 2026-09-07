---
title: EVMcrispr integration
description: Writing assertions as one-line EVML scripts with the assert command.
---

[EVMcrispr](https://evmcrispr.blossom.software)'s `assert` command compiles readable one-line scripts into the exact core, Operations and Collections calldata described in the rest of these docs. It lives in the std module, which is always loaded, so an assertion needs no `load` line of its own. Scripts that use the lang module's array/string helpers (`@len!`, `@str.split!`, `@bytes.len!`, ...) also need `load lang`; the chain id and the block and transaction context reads (`@chainId!`, `@block.timestamp!`, `@tx.from!`, ...) need `load receipts`; the code and storage reads (`@codeHash!`, ...) need `load contracts`, and the arithmetic conveniences (`@min!`, `@sqrt!`, ...) need `load math`. The [visual builder](/builder) generates these lines for you and previews their live values.

```evml

assert $token::balanceOf(@me) >= 100e18 "not enough tokens"
```

## The assert command

### Builder compiler and execution account

The builder and this site's EVML highlighting use a vendored EVMcrispr checkout (`website/.evmcrispr`), pinned by `evmcrispr.commit` in `website/package.json`. The pinned revision compiles against the canonical Assertions, Operations and Collections addresses listed under [Deployments](/docs/reference/deployments): all three must exist on the selected chain, so check [the deployments page](/deployments) before executing. The addresses are the same on every chain, so there is nothing to configure; a fork that wants different code installs it at those addresses. Expressions is unreleased and has no SDK face.

The builder supports `lang`, `receipts`, `contracts`, `math`, `token`, `vault`, `acl`, `sim`, `safe`, `governor` and `aragonosx`, in addition to the always-loaded `std`. Other modules in the full EVMcrispr terminal are not automatically available here. At the pinned revision, `receipts` and the protocol modules among these (`vault`, `acl`, `safe`, `governor`, `aragonosx`) are flagged experimental in the checkout: their faces may change between pins.

Use `@sender` for the account sending the surrounding block's calls. Inside a Safe, Governor or Aragon OSx block it refers to that executor; `@me` refers to the connected account. For example, inside a Safe block, an allowance assertion should usually check `allowance(@sender, spender)`. `@tx.from!` reads the transaction origin and is a different identity.

`@hash!` and `@bytes.len!` require a decoded `string` or `bytes` return. Use `@len!` for an array's element count; array envelopes cannot be passed to bytes operations because their length word counts elements, not bytes.

### Syntax

```evml
assert <target>::<viewFn(args)> <op> <expected> "revert msg"            # named method, ABI fetched automatically
assert <target>::{viewFn(argTypes)(returnType) <args>} <op> <expected>  # inline ABI when needed
```

Comparison operators: `==` `!=` `>` `<` `>=` `<=` and `~=` (approximate equality, with `--delta`). Strings support `==` / `!=` anywhere (nested comparisons compile to on-chain keccak). A bare `assert <call>` with no operator requires a boolean call and compiles to an `EQ true` constraint.

Every line compiles to the ERC-8211 judge: the live expression becomes an `InputParam` (a staticcall, balance read, or nested core expression) validated by inline constraints via `assertParam`. Comparisons the [constraints](/docs/core/reads#constraints) can't express directly (`!=`, signed and two-live-side comparisons) route through a read-spliced [Operations](/docs/operators) comparison judged `EQ 1`.

### Chained calls

`::` chains hop through addresses and compile to the core's [`chain`](/docs/core/reads): every hop but the last must continue on an address, and a multi-value hop selects it with a lens.

```evml
assert $pool::{token()(address)}::{symbol()(string)} == "WETH"
assert $t::{f()(uint112,uint112,address)}[_ _ $]::{b()(uint256)} > 0
```

### Lenses

A destructure lens after a call selects which return value the assertion uses:

- `[_ $ _]` picks one output of a multi-value return (compiles to the core's [`pick`](/docs/core/reads) raw word selection).
- Nested levels navigate into arrays and structs, one step per nesting level: `{owners()(address[],address)}[[_ $]]` is element 1 of the first return value; `{proposals()((address,uint256,bool)[])}[[_ [_ _ $]]]` is `proposals[1].executed`. These compile to the core's typed [`nav`](/docs/core/reads) navigation.
- A `...` rest marker anchors the slots after it from the end: `[... $]` = last return value, `[[... $]]` = last array element, resolved against the live length on-chain.

### Nested live calls as arguments

A call's argument can itself be a call, resolved **at assertion time** and spliced into the enclosing calldata (any nesting depth):

```evml
assert $vault::{sharesOf(address)(uint256) $registry::{owner()(address)}} > 0
assert $a::{a(address)(uint256,uint256[]) $b::{b(uint256,uint256)(address) $c::{c(address)(uint256) @me} $d::{d()(uint256)}}}[_ [$]] == 7
```

A lens on a nested call argument selects the value to splice, including dynamic values (arrays) navigated at runtime:

```evml
assert $a::{a(address[])(uint256) $b::{b()(address,address[][])}[_ [_ $]]} == 5
```

These compile to the core's [`read`](/docs/core/reads): each nesting level becomes a `read` whose segments fetch the inner values and splice them into the enclosing calldata at judge time. Word-typed arguments (uint, int, address, bool, bytes32) splice anywhere. Up to four live dynamic values can share a call when the compiler can derive their runtime sizes. A live value whose size cannot be derived must be the last dynamic argument. Later offsets may re-resolve earlier values, so adding live parts increases execution cost.

### Chain state

Chain state has no commands of its own: every piece of it is an on-chain helper, so `assert` compares it like anything else.

```evml
assert @balance!(ETH $recipient) >= 1e18 "recipient underfunded"   # native balance
assert @chainId! == 100 "wrong chain"                              # needs load receipts
assert @block.timestamp! < 1780000000 "proposal expired"           # needs load receipts
assert @codeHash!($proxy) == 0x1234… "implementation changed"      # needs load contracts
assert @bytes.len!(@codeAt!($t)) > 0 "not a contract"              # needs load lang + contracts
```

## On-chain helpers (trailing `!`)

Helpers with a trailing `!` evaluate **on-chain at assertion time** by compiling to core, Operations and Collections calldata; ordinary helpers (`@token`, `@get`, `@num`, ...) resolve at composition time and freeze into the calldata. Each helper is one name with up to two faces: the plain face runs (or snapshots) at script build time, the `!` face compiles to on-chain calldata.

Array faces (`@map!`, `@filter!`, `@all!`, `@any!`, `@find!`, `@reduce!`) apply a NAMED definition rather than an inline expression. `def @name!` declares one, and the face supplies the arguments it takes:

```evml
def @ge100! "$x: number -> bool" @bool!($x >= 100)
assert @all!($vault::{caps()(uint256[])} @ge100!)
```

The definition is inlined where it is used, so naming a parameter more than once stamps the element at each place it appears: `@calc!($x * $x)` squares in one call. It compiles rather than runs, so it must be fully typed and cannot be called off-chain, and it is scoped like any other `def`.

The on-chain surface of the builder's modules:

- **std** (always available, no `load` needed): `@calc!`, `@bool!`, `@bytes!`, `@hash!`, `@balance!`, the control faces `@ifElse!`, `@orElse!` and `@reverts!`, the signature check `@sigValid!`, and the `@abi.*!` family (`@abi.encode!`, `@abi.encodePacked!`, `@abi.encodeCall!`, `@abi.decode!`, `@abi.decodeCall!`).
- **lang** (needs `load lang`): the array and string faces, including `@len!`, `@bytes.len!`, `@str.len!`, `@str.split!`, `@str.includes!`, `@str.charset!`.
- **receipts** (needs `load receipts`): the chain id `@chainId!`, plus the block and transaction context reads, the `@block.*!` and `@tx.*!` families, tabulated on [the words page](/docs/operators/words#environment-reads).
- **contracts** (needs `load contracts`): the code reads `@codeHash!` and `@codeAt!`, and the storage-slot derivations `@slot.array!` and `@slot.mapping!`.
- **math** (needs `load math`): the arithmetic conveniences `@min!`, `@max!`, `@absDiff!`, `@sqrt!`, and the fixed-point family `@exp!`, `@ln!`, `@log2!`, `@pow!`.

| Helper | Module | Returns | Description |
|--------|--------|---------|-------------|
| `@abi.encode!(types values...)` | std | bytes | `abi.encode` over live values: live values must be elementary static types, at most 4 per call; dynamic, array and tuple types only encode when every value is constant |
| `@abi.encodePacked!(types values...)` | std | bytes | Packed encoding, compiled to `concat` over `slice`-narrowed words: live values are cut to their packed width and live string/bytes values pass through whole, at most 4 per call |
| `@abi.encodeCall!(signature params...)` | std | bytes | Calldata for a call: the signature must be a constant, live arguments must be elementary static types contributing one word each (at most 4 per call) |
| `@abi.decode!(types data)[_ $]` | std | any | Decode a live bytes value: needs a `[_ $]` lens and returns only the selected value; array selections are refused |
| `@abi.decodeCall!(contract calldata)[...]` | std | any | Decode live calldata against an inline signature: checks the selector on-chain (a mismatch reverts) and returns the selected argument |
| `@absDiff!(a b)` | math | number | Absolute difference computed on-chain; never underflows. `@absDiff!(a b) <= d` is the composable approximate-equality (plain `@absDiff` computes off-chain) |
| `@balance!(ETH\|token addr)` | std | number | Live balance: native for ETH, else ERC-20 `balanceOf` (token symbols resolve like `@token`) |
| `@bool!(expr)` | std | bool | On-chain comparisons and logic: `== != < <= > >= and or xor not` |
| `@bytes!(a "&" b)` | std | number | Bitwise word ops (`&` `\|` `xor` `<<` `>>`, the operator quoted; spelled `xor` rather than `^`, which `@calc!` uses for powers); single-arg `@bytes!(x)` is the raw-word cast |
| `@bytes.at!(call i)` | lang | bytes | One byte of a bytes/string return, sliced on-chain; a negative index resolves against the live byte length |
| `@bytes.len!(call)` / `@str.len!(call)` | lang | number | Decoded byte length of a bytes/string return (multi-byte UTF-8 characters count once per byte) |
| `@bytes.slice!(call start end?)` | lang | bytes | A byte range of a bytes/string return, sliced on-chain; negative bounds resolve against the live byte length (inverted live ranges revert, there is no silent clamp) |
| `@codeAt!(addr)` | contracts | bytes | The deployed bytecode at an address, read at assertion time through `Operations.code`; sees code a batch deployed in an earlier step |
| `@codeHash!(addr-or-call)` | contracts | bytes32 | Live EXTCODEHASH; the argument may be a `::` call resolving to an address |
| `@enumerate!(call)` | lang | array | Pair every element with its index on-chain (`zipWords(iotaWords(n), payload)` with the live length); the result is an on-chain record ([records](/docs/operators/fold#on-chain-records)) |
| `@exp!(x)` / `@ln!(x)` | math | number | e^x and the natural log in wad (1e18) fixed point, via `expWad`/`lnWad`; the result carries its wad scale so surrounding arithmetic aligns to it |
| `@filter!(call pred)` | lang | array | Keep the elements passing `pred`, a named `def @name!` of one parameter returning bool; the kept words payload composes with the other array faces |
| `@find!(call pred)` | lang | any | The first element passing the predicate: a core pick over the `filterWords` output; no match REVERTS the assertion at judge time |
| `@hash!(call)` | std | bytes32 | Hash of the decoded return payload, on-chain: keccak256 by default, sha256 with a second `"sha256"` argument |
| `@ifElse!(cond ? then : else)` | std | any | The lazy ternary, compiled to the core's `cond`: the condition's first word judges (nonzero = then) and the losing branch is never resolved; spaces are required around `?` and `:`. Branching on resolvability is `@ifElse!(@bool!(not @reverts!(call)) ? a : b)` |
| `@keys!(record)` / `@values!(record)` / `@lookup!(record name)` | lang | array / any | The lanes of an on-chain record and a keyed read into it ([records](/docs/operators/fold#on-chain-records)) |
| `@len!(call)` | lang | number | Decoded length of a dynamic return: element count for arrays (nested array faces included), byte length for string/bytes |
| `@log2!(x)` | math | number | Floor binary logarithm on-chain (`log2`); 0 reverts |
| `@min!(a b ...)` / `@max!(a b ...)` | math | number | On-chain minimum / maximum of two or more values (plain `@min` / `@max` compute off-chain) |
| `@calc!(expr)` | std | number | On-chain checked integer arithmetic (`+ - * // % ^`, `xor`; integer division is `//`) over live calls and constants; unsigned `a * b / c` fuses into one 512-bit `mulDiv` with `Trunc` rounding, and a live string operand coerces through `parseUint` |
| `@orElse!(a b)` | std | any | The core's `orElse`: the value of the first read, or the second one when the first reverts; both branches must resolve to the same kind of value, and a constant fallback must fit in one word |
| `@pow!(x n base?)` | math | number | Fixed-point power via `rpow`, where `base` is one unit (default 1e18, 1e27 for a ray); unsigned operands only |
| `@reverts!(call)` | std | bool | Whether a live call reverts: true when the chain refuses it, false when it resolves (the core's `isValid`, negated); `-!> ErrName(types)` matches the reason through `revertData` and a `[_ $]` lens selects an error argument |
| `@sigValid!(signer data signature)` | std | bool | Whether a signature is valid on-chain: contract signers verify through ERC-1271, EOAs through the recovery precompile; the signer and message must be constants, and a delegated account verifies against its key |
| `@slice!(call start end?)` | lang | array | Elements `[start, end)` of an array return as a live words payload (indices scale to byte offsets at composition time, negative bounds resolve against the live length); composes with the other array faces |
| `@slot.array!(base index)` / `@slot.mapping!(base key)` | contracts | bytes32 | The storage slot of `array[index]` / `mapping[key]` declared at a constant base slot, with a live index or key; reading it on-chain needs a target with an extsload-style getter |
| `@sqrt!(expr)` | math | number | Integer square root (floor) computed on-chain, e.g. `@sqrt!($pool::reserve0() * $pool::reserve1())` (plain `@sqrt` computes off-chain) |
| `@str.charset!(call "a-z0-9-")` | lang | bool | Whether every byte of a string return is in the character class (ranges + literals, byte-level ASCII) |
| `@str.concat!("a" call ...)` | lang | string | Concatenate constant strings with up to four live call parts through a single on-chain `concat` |
| `@str.includes!(call "part")` | lang | bool | Whether a string return contains a substring (exact bytes, case-sensitive) |
| `@str.split!(call "delim" i)` | lang | string | Split a string return and select one segment; negative index counts from the end (`-1` = last, `-2` = second-last) |
| `@sum!(call)` | lang | number | The checked sum of an array return's single-word elements, on-chain (Collections' native `sumWords`); the fixed-operation form of `@reduce!(call add 0)` |

Beyond these, the lang module gives most of its array and string helpers an on-chain face too: `@str.slice!`, `@str.at!`, `@str.concat!`, `@str.replace!`, `@str.lower!`, `@str.upper!`, `@str.join!`, the bytes twins `@bytes.at!`/`@bytes.slice!`/`@bytes.concat!`/`@bytes.not!`, and over arrays `@at!`, `@slice!`, `@includes!`, `@all!`, `@any!`, `@map!`, `@filter!`, `@find!`, `@reduce!`, `@sum!`, `@sort!`, `@unique!`, `@reverse!`, `@zip!`, `@unzip!`, `@enumerate!`, `@flat!`, `@concat!`, plus the record faces `@keys!`/`@values!`/`@lookup!`. Protocol modules follow the same pattern with live read faces: token's `@token:decimals!`, `@token:allowance!`, `@token:totalSupply!`, `@token:amount!` (scaled against a live `decimals()`) and `@token:symbol!` (digest-judged); safe's `@safe:threshold!`, `@safe:nonce!`, `@safe:guard!`, `@safe:isOwner!` and the array operands `@safe:owners!`/`@safe:modules!` (composable with the lang array faces); governor's `@governor:proposalState!` and `@governor:timelockOperationState!` (OZ's numeric OperationState via nested conds), and the vault and acl reads.

The string helpers compile to compositions rather than dedicated ops: `@str.split!` compiles to `indexOf`/`slice`, `@str.includes!` to the `indexOf`/`byteLen` sentinel comparison, and `@str.join!` to a single `concat` with the delimiter interleaved at composition time. `@str.charset!` compiles to the native `charset` op with its class-spec mask baked in at composition time (the `foldBytes` + `bitSet` form stays the general pattern for other per-byte predicates), and `@sum!` to Collections' native `sumWords`; `@unique!` removes adjacent duplicates (`uniqueWords` with `ordered = true`), so nest `@sort!` for set-uniqueness. See [the fold page](/docs/operators/fold).

Examples:

```evml
load lang
load contracts

assert @calc!(@balance!(ETH $addr) + $weth::balanceOf($addr)) > 0
assert @bool!(($gov::quorum() > 0) or (not $gov::paused()))
assert @str.split!($pool::name() " " -1) == "LP"
assert @len!($registry::{holders()(address[])}) >= 3
assert @codeHash!($proxy::{implementation()(address)}) == 0x1234...cdef
```

## Constructed calls: the `::!` operator

`<head>::!{sig(argTypes)(retTypes) args}` constructs a whole call **at assertion time** through the core's [`read`](/docs/core/reads). The head may be any expression: a `::` chain, an on-chain helper, or a computed word, as long as it resolves to a clean address word on-chain. The arguments splice like nested live calls, and the inline ABI form is mandatory (a `::!` hop has no composition-time address to fetch an ABI from).

The `!` trails the `::` rather than leading it, so it never sits against the head. Leading, it would be indistinguishable from the trailing `!` of an on-chain helper face: `@name!::{…}` splits as `@name!` before a plain hop or as `@name` before a read hop, and the text does not say which. After the operator there is nothing to collide with, so `@me::!{…}` and `@name!::!{…}` each read one way only.

```evml
assert @bytes!($reg::packedPool() ">>" 96)::!{fee()(uint24)} <= 3000
```

## Composition-time captures

To assert a **change**, capture the pre-state at composition time and assert against it:

```evml
set $before @get($token "balanceOf(address)(uint256)" @me)
# ... actions ...
assert $token::balanceOf(@me) == @num($before + 100e18)
```

Composition-time captures go stale, so for proposals executed later prefer absolute thresholds or live `@bool!` / `@calc!` forms.

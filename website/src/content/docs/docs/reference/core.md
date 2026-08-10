---
title: Core reference
description: The ERC-8211 judge's functions and wire format, the core primitives, and the Operators surface.
---

The core (judge + primitives) lives at the interim address `0x637d99Ff8bcB919e5203b0B96Ad0520A9943a32C` (a vanity `0xa55E...` address will be re-mined before the canonical roll; see [Deployments](/docs/reference/deployments)). Every judge function has an overloaded version accepting a custom `string` message as the last parameter, echoed inside `ConstraintFailed` on failure. The computation vocabulary lives on the separate [Operators contract](/docs/operators).

## Judge functions

| Function | Description |
|----------|-------------|
| `assertParam(InputParam)` | Resolve one input parameter (raw bytes, staticcall, or balance read) and validate its inline constraints (the 90% case, no batch scaffolding) |
| `assertComposable(ComposableExecution[])` | Evaluate an ERC-8211 composable batch under view semantics: predicate entries resolve and validate their parameters; entries with a `TARGET` parameter construct a call by splicing resolved values into calldata and execute it via `staticcall` (the call must not revert) |

The judge consumes the **unmodified ERC-8211 wire format**, so batches built by any ERC-8211 SDK judge here unchanged. Being view-only, it rejects what a view context cannot express: output parameters (Storage writes) revert with `OutputParamsNotSupported`, `VALUE` parameters with `ValueParamNotSupported`, a second `TARGET` parameter with `DuplicateTargetParam`, and a `BALANCE`-fetched target with `BalanceCannotBeTarget`.

## Wire format

```solidity
struct InputParam {
    InputParamType paramType;         // where the value routes in a constructed call
    InputParamFetcherType fetcherType;// how the value is obtained
    bytes paramData;                  // fetcher-specific payload
    Constraint[] constraints;         // inline predicates on the resolved value
}

struct Constraint {
    ConstraintType constraintType;    // EQ | GTE | LTE | IN
    bytes referenceData;              // 32 bytes (EQ/GTE/LTE) or 64 bytes lo,hi (IN)
}

struct ComposableExecution {
    bytes4 functionSig;               // selector of the constructed call
    InputParam[] inputParams;
    OutputParam[] outputParams;       // must be empty in view-mode batches
}
```

### Fetcher types

| Fetcher | `paramData` | Resolves to |
|---------|-------------|-------------|
| `RAW_BYTES` | the value itself | the literal bytes, unchanged |
| `STATIC_CALL` | `abi.encode(target, callData)` | the raw returndata of the staticcall (reverting or code-less targets fail with `CallFailed`) |
| `BALANCE` | `abi.encodePacked(token, account)` (40 bytes) | native balance when `token == address(0)`, else `IERC20(token).balanceOf(account)` |

### Constraint types

Constraints compare the resolved value's first 32-byte word, unsigned:

| Constraint | Meaning |
|------------|---------|
| `EQ` | word equals the 32-byte reference |
| `GTE` | word >= reference |
| `LTE` | word <= reference |
| `IN` | lo <= word <= hi (inclusive; `abi.encode(lo, hi)` as reference) |

Everything richer (`!=`, signed comparisons, string equality, live-vs-live tolerance) is a read-spliced [Operators](/docs/operators) expression that returns a 0/1 word or a hash, judged with `EQ`.

## Core primitives

The primitives live on the core alongside the judge, because they hold operands unresolved (in the ERC-8211 `InputParam` format). Every operand is an `InputParam` with its own inline constraints, so expressions nest recursively; a `STATIC_CALL` operand may target the core itself. See [core reads](/docs/core/reads) and [resolution control](/docs/core/control) for usage.

| Function | Description |
|----------|-------------|
| `resolve` | Resolve one operand and return its bytes raw; constraint violations revert with `ConstraintFailed`, turning any expression node into an inline assert |
| `pick` | Select one raw 32-byte word from a resolved operand (signed index, negative from the end) |
| `nav` | Typed navigation: interpret the resolved bytes as a declared return tuple (`retTypes`) and walk an index path through tuples and dynamic arrays: single-word terminals, canonical dynamic envelopes, and decoded lengths via the `LEN` sentinel |
| `chain` | Follow runtime-resolved addresses: each hop staticcalls the address word the previous hop returned |
| `read` | Construct a staticcall at judge time: resolve the target and concatenate the selector with each argument segment's full resolved bytes (ERC-8211 CALL_DATA routing), then return the call's raw returndata; the composition socket that splices operand expressions into plain calldata for Operators or any other view/pure contract |
| `cond` | Resolve the condition (first word nonzero = true), then resolve and return ONLY the winning branch; the losing branch is never resolved |
| `orElse` | Resolve the attempt behind a self-staticcall boundary; ANY failure (revert, code-less target, violated constraint) selects and resolves the fallback instead |
| `ok` | 1 when the operand resolves without reverting (constraints included), else 0; the failure probe, judged `EQ 1` / `EQ 0` or fed to `cond` |

## Operators (separate contract)

These live at the Operators address (interim `0x7FE48d55c709AB58A7Da296893b5C6a8ab38D623`), not on the core, and take plain ABI types: live operands reach them through the core's `read` splicing. Functions marked "uint + int" are overloaded on `uint256` and `int256` (explicit selectors required in Solidity encoders). See [Operators](/docs/operators) for usage.

| Function | Description |
|----------|-------------|
| `add` / `sub` / `mul` / `div` / `mod` | Checked word arithmetic, uint + int (`div` truncates toward zero; `mod` takes the dividend's sign) |
| `exp` | Checked `**`, unsigned only (`0 ** 0 == 1`) |
| `mulDiv` / `mulDivUp` | `floor(a * b / d)` / `ceil(a * b / d)` with a full 512-bit intermediate product; `Panic(0x12)` on a zero denominator, `Panic(0x11)` when the result does not fit 256 bits |
| `addMod` / `mulMod` | `(a + b) % m` / `(a * b) % m` over 512-bit intermediates (EVM ADDMOD/MULMOD); `Panic(0x12)` on `m == 0` |
| `sqrt` | Floor square root |
| `min` / `max` | Smaller / larger of two values, uint + int |
| `absDiff` | The magnitude `\|a - b\|` as a `uint256`, uint + int operands; total, never reverts |
| `eq` / `ne` | Bit-level (in)equality on words, covers all word types; returns `bool` |
| `lt` / `gt` / `le` / `ge` | Orderings, uint + int; return `bool` |
| `bitAnd` / `bitOr` / `bitXor` | Bitwise words; conjoin/disjoin 0/1 comparison results; `bitXor(x, ~0)` is bitwise NOT |
| `shl` / `shr` | Shifts, EVM semantics (256 or more yields 0); `shr(int256, uint256)` is the arithmetic shift (SAR: sign-filling, toward negative infinity) |
| `bitSet` | Whether bit `index` of `mask` is set (indices past 255 are never set); the character-class fold lambda |
| `balance` / `codehash` | Native balance / EXTCODEHASH of an address at judge time |
| `timestamp` / `blockNumber` / `chainId` | Environment values at judge time |
| `baseFee` / `prevRandao` / `coinbase` / `gasLimit` / `blobBaseFee` / `origin` / `gasPrice` / `blobHash` | Block-header and transaction environment values at judge time |
| `blockHash` | The hash of block `n`, BLOCKHASH semantics (0 for the current block, the future, and blocks older than 256) |
| `concat` / `slice` / `byteLen` | Bytes concatenation, bounds-checked slicing, and raw byte length |
| `hash` | keccak256 of the `bytes` argument; through `read` splicing the digest covers the decoded payload |
| `indexOf` | Position of the occurrence-th non-overlapping occurrence of `needle` in `s` (0, 1, ... from the start; -1, -2, ... from the end); sentinel `s.length` when it does not exist; total |
| `parseUint` / `toString` | Decimal ASCII string to `uint256` (strict: reverts on empty input or non-digit bytes) and its no-leading-zeros inverse |
| `encode` | Runtime `abi.encode` of a tuple from canonical single-value encodings (`nav`'s inverse); raw return, a calldata segment for `read` splicing |
| `foldRange` / `foldBytes` / `foldWords` | Bounded folds over an index range / a string's bytes / 32-byte words, with a template-lambda staticcall per element and `FoldExit` `Full`/`Any`/`All` |
| `mapWords` / `filterWords` / `iotaWords` / `wordIndexOf` / `reverseWords` / `zipWords` / `unzipWords` / `sortWords` / `uniqueWords` | Word-array shape operations over aligned word payloads: lambda map/filter, the index generator, first-match index (word-count sentinel), reversal, pair interleaving and lane selection, unsigned sort, adjacent deduplication (see [Folds and word arrays](/docs/operators/fold)) |

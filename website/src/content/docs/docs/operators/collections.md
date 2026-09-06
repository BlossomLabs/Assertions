---
title: Generic ABI collections
description: Multiword collection values, typed callback envelopes, and stable collection operations.
---

`Collections` is the optional generic collection periphery. It uses the same plain staticcall interface as Operations; the Assertions core and ERC-8211 format are unchanged. The family is separate because combining it with Operations exceeds the EVM runtime size limit.

## Value envelopes

Each `bytes[]` element is one canonical `abi.encode(value)`, not packed bytes and not a raw array payload. A string includes its leading offset, length and padded data; a static struct includes all its words. Elements may be words, structs, strings, nested arrays, or tuples containing dynamic fields.

`packArray(elementType, values)` returns the canonical encoding of the complete array inside a bytes return envelope. `unpackArray(elementType, encodedArray)` reverses that operation and rebases dynamic element offsets. `validateValue(valueType,value)` validates a single envelope. The grammar is the shared AbiCodec shape grammar, for example `(uint256,string)` or `string[2]`.

The codec checks descriptor structure, canonical offsets, bounds, exact lengths and zero bytes/string padding. It is a shape validator, not a scalar type checker: a shape-compatible incorrect scalar claim remains the caller's responsibility. It does not turn a word into a checked `uint8` or validate an address's upper bits. Predicate callbacks separately require canonical booleans.

## Callback specification

```solidity
struct Callback {
    address target;
    bytes4 selector;
    string arguments;
    bytes[] constants;
    uint256 first;
    uint256 second;
}
```

`arguments` is the callback argument tuple descriptor. `constants` contains one single-value envelope per argument, including placeholder slots. Each invocation replaces `first` with the current element for map/filter, the accumulator for fold, or the first value for comparison/equality. Binary operations also replace `second` with the current element or second value. Binary slots must differ. Unary operations ignore `second`.

Calldata is rebuilt from these values on every invocation, so variable-length strings and accumulators are safe. Calls use `staticcall`; map and fold retain the complete return encoding and validate its declared type. Callbacks returning multiple named return values should instead return one tuple/struct value if their result type is dynamic.

Predicates must return exactly 32 bytes containing zero or one. Comparators return exactly one `int256` word: negative, zero, or positive. `CallbackFailed` includes the operation selector, element indexes, target and revert data. `InvalidCallbackResult` identifies malformed callback results without silently truncating them. Comparators and equality predicates must be consistent.

## Operations

| Function | Behavior |
|---|---|
| `mapValues(inputType,outputType,values,callback)` | Map in input order, validating result envelopes. |
| `filterValues(inputType,values,callback)` | Stable filtering, preserving original encodings. |
| `foldValues(inputType,accumulatorType,values,initial,callback)` | Left fold with accumulator first; empty input returns the initial envelope. |
| `sortValues(inputType,values,callback)` | Stable merge sort using the supplied comparator. |
| `uniqueValues(inputType,values,callback,ordered)` | Keep first occurrence according to an equality predicate; `ordered = true` compares only adjacent groups, `false` checks every retained value. |
| `flattenValues(inputType,values)` | Validate each canonical value against `inputType` and flatten a `bytes[][]` by one level in order. |

These routines perform finite loops over supplied inputs; transaction gas bounds practical sizes. Stable distinct performs quadratic comparisons in the worst case. Sorting uses O(n log n) comparisons. Generic encoding and callback validation carry more overhead than word-specialized operations; use the latter when values really are single words.

In Collections, `uniqueWords(bytes,bool ordered)` preserves the first occurrence of each word. Pass `false` for arbitrary input (O(n squared)), or `true` when equal values are already grouped for an O(n) adjacent-only pass. Ordering is trusted, not checked. In Operations, `split(bytes,bytes)` returns every segment, preserves empty segments, and rejects an empty delimiter.

This contract release does not update the vendored EVMcrispr compiler or helper APIs. Its integration is a separate change.

Typed callbacks prepare their argument layout and validate constants once per operation. Each invocation validates substituted values and results. Word-template operations remain in Operations: their fixed-width windows can reach nested calldata, while typed callbacks rebuild complete argument slots when encoded sizes change.

## Callback policy

Callbacks must target an address containing EVM bytecode; precompiles are not accepted. The target is checked only when a callback is needed, so empty inputs and callback-free singleton cases do not inspect it.

Predicates must return exactly one ABI boolean (0 or 1). Word mapping and folding require exactly 32 return bytes; generic mapping and folding validate the full declared ABI result. `CallbackFailed` identifies the operation and callback indices, and preserves both calldata and revert data.

Generic `foldValues` always visits every element because its accumulator may be any ABI type. Word folds retain explicit zero/nonzero `Any` and `All` modes.

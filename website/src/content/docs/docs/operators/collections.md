---
title: Generic ABI collections
description: Multiword collection values, typed callback envelopes, and stable collection operations.
---

`CollectionOperators` is the optional generic collection periphery. It uses the same plain staticcall interface as Operators; the Assertions core and ERC-8211 format are unchanged. The family is separate because combining it with Operators exceeds the EVM runtime size limit.

## Value envelopes

Each `bytes[]` element is one canonical `abi.encode(value)`, not packed bytes and not a raw array payload. A string includes its leading offset, length and padded data; a static struct includes all its words. Elements may be words, structs, strings, nested arrays, or tuples containing dynamic fields.

`packArray(elementType, values)` returns the canonical encoding of the complete array inside a bytes return envelope. `unpackArray(elementType, encodedArray)` reverses that operation and rebases dynamic element offsets. `validateValue(valueType,value)` validates a single envelope. The grammar is the existing AbiShape grammar, for example `(uint256,string)` or `string[2]`.

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
| `distinctValues(inputType,values,callback)` | Keep first occurrence according to a supplied equality predicate. |
| `flattenValues(values)` | Flatten a `bytes[][]` by one level in order. |

These routines perform finite loops over supplied inputs; transaction gas bounds practical sizes. Stable distinct performs quadratic comparisons in the worst case. Sorting uses O(n log n) comparisons. Generic encoding and callback validation carry more overhead than word-specialized operations; use the latter when values really are single words.

In Operators, `distinctWords(bytes)` provides stable whole-word deduplication. `uniqueWords(bytes)` retains its original adjacent-only behavior. `split(bytes,bytes)` returns every segment, preserves empty segments, and rejects an empty delimiter.

This contract release does not update the vendored EVMcrispr compiler or helper APIs. Its integration is a separate change.

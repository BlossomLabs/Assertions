---
title: Generic ABI collections
description: The Collections contract's generic family, multiword value envelopes, typed callbacks (direct or through an expression graph), and stable traversals over arrays of canonical ABI values.
---

`Collections` owns iteration. Its word-array family and the folds (aligned 32-byte payloads, template lambdas) are on [the fold page](/docs/operators/fold); this page covers the generic family, which operates on arrays of whole canonical ABI values through typed callbacks. It uses the same plain staticcall interface as Operations, reached through the core's [`read`](/docs/core/reads); the core and the ERC-8211 format are untouched. The family is a separate contract because Operations plus Collections exceeds the EVM runtime size limit, and a further split of the generic family into a third periphery contract is the documented next step should Collections need bytes again.

## Value envelopes

Each `bytes[]` element is one canonical `abi.encode(value)`, not packed bytes and not a raw array payload. A string includes its leading offset, length and padded data; a static struct includes all its words. Elements may be words, structs, strings, nested arrays, or tuples containing dynamic fields. The type of the elements is a descriptor in the shared AbiCodec shape grammar, for example `(uint256,string)` or `string[2]`.

`packArray(elementType, values)` returns the canonical encoding of the complete array inside a bytes return envelope. `unpackArray(elementType, encodedArray)` reverses that operation and rebases dynamic element offsets. Both validate their inputs. To check a single encoded value without keeping the result, pass it as the only element of `packArray(elementType, values)` and discard the returned array encoding.

The codec checks descriptor structure, canonical offsets, bounds, exact lengths and zero padding of bytes and strings. It is a shape validator, not a scalar type checker: a shape-compatible incorrect scalar claim remains the caller's responsibility, as with `nav` descriptors. It does not turn a word into a checked `uint8` or validate an address's upper bits. Predicate callbacks separately require canonical booleans.

## Callback specification

```solidity
struct Callback {
    address target;
    bytes4 selector;
    string arguments;    // the argument tuple descriptor, e.g. "(uint256,string)"
    bytes[] constants;   // one single-value envelope per argument slot, placeholders included
    uint256 first;       // the slot the element (or the fold accumulator) is bound to
    uint256 second;      // the slot the other value is bound to, binary operations only
    bytes expression;    // empty: a direct call; else abi.encode(Expressions.Expression)
}
```

`arguments` describes the callback's argument tuple and `constants` holds one canonical single-value envelope per slot, including placeholders for the slots that get substituted. Each invocation binds `first` to the current element for map, filter, any, all and find, to the accumulator for fold, or to the first value for comparison and equality; binary operations (fold, sort, unique, indexOf) also bind `second` to the element or the second value, and their two slots must differ. Unary operations ignore `second`. The non-substituted constants are validated once per operation; the substituted values are validated on every binding.

Calldata is rebuilt from these values on every invocation, so variable-length strings and accumulators are safe. Calls use `staticcall`; map and fold retain the complete return encoding and validate its declared type. A callback returning several named values should instead return one tuple or struct value when its result type is dynamic.

**Expression callbacks.** With a non-empty `expression`, the callback is `abi.encode(Expressions.Expression)`: the slots are bound exactly as above, and the invocation is `target.evaluateEncoded(expression, boundArguments)` instead of a selector call (`selector` is ignored, and `target` is the [Expressions](/docs/operators/expressions) contract). Inside the graph, `Parameter` nodes read the bound slots, so an element can be referenced any number of times, arguments may be dynamic and multi-word, and live reads compose without byte-offset substitution. Memoisation inside the graph lasts one invocation, not the whole traversal. This is the only in-tree consumer of Expressions, which is unreleased.

Predicates must return exactly 32 bytes containing zero or one. Comparators return exactly one `int256` word: negative, zero, or positive. `CallbackFailed` carries the operation selector, element indexes, target, calldata and revert data. `InvalidCallbackResult` identifies malformed callback results without silently truncating them. Comparators and equality predicates must be consistent.

## Traversals

Every function validates each visited element against `inputType` and reverts with the `AbiCodec` errors on a malformed one.

| Function | Behavior |
|---|---|
| `mapValues(inputType, outputType, values, cb)` | Map in input order; each result is validated against `outputType`. |
| `filterValues(inputType, values, cb)` | Stable filter, preserving the original encodings of the kept elements. |
| `foldValues(inputType, accumulatorType, values, initial, cb)` | Left fold with the accumulator in `first` and the element in `second`; empty input returns `initial`. It always visits every element: an arbitrary ABI accumulator has no implicit truth value, so there are no `Any`/`All` modes here. |
| `sortValues(inputType, values, cb)` | Stable bottom-up merge sort using the supplied comparator (a non-positive answer keeps the left element first). |
| `uniqueValues(inputType, values, cb, ordered)` | Keep the first representative of each callback-defined equality class; `ordered = true` compares only against the last retained value, `false` against every retained value. Grouping is trusted, not checked. |
| `flattenValues(inputType, bytes[][] values)` | Flatten one level in order, validating every element. |
| `reverseValues(inputType, values)` | Reverse the order without changing the encodings. |
| `sliceValues(inputType, values, int256 start, int256 end)` | Clamped signed indexes with `end` exclusive, as `Array.slice`; a reversed range is empty. |
| `indexOfValues(inputType, values, needle, cb)` | The index of the first element for which the equality callback (element in `first`, `needle` in `second`) answers true, or `uint256.max`; calls stop at the match. |
| `anyValues(inputType, values, cb)` | Whether any element satisfies the predicate; empty input is false; calls stop at the first true. |
| `allValues(inputType, values, cb)` | Whether every element satisfies the predicate; empty input is true; calls stop at the first false. |
| `findValues(inputType, values, cb)` | The index of the first element satisfying the predicate, or `uint256.max`. |
| `zipValues(leftType, rightType, left, right)` | Pair equally sized arrays into canonical `(leftType, rightType)` tuple envelopes, preserving order; different lengths revert with `LengthMismatch`. |
| `unzipValues(leftType, rightType, pairs, lane)` | Extract lane 0 or 1 from canonical pair tuples (`InvalidLane` otherwise), validating both components of every pair. |

These routines perform finite loops over supplied inputs; transaction gas bounds practical sizes. Unordered distinct performs quadratic comparisons in the worst case; sorting uses O(n log n) comparisons. Generic encoding and callback validation carry more overhead than the word-specialized family. The EVMcrispr compiler uses the [word arrays](/docs/operators/fold#word-arrays) for eligible word-sized values and callbacks, and the generic family for dynamic or multiword values and typed callbacks that need it.

## Callback policy

Callbacks must target an address containing EVM bytecode; precompiles are not accepted. The target is checked only when a callback is needed, so empty inputs and callback-free singleton cases do not inspect it.

Predicates must return exactly one ABI boolean (0 or 1). Word mapping and folding require exactly 32 return bytes; generic mapping and folding validate the full declared ABI result. `CallbackFailed` identifies the operation and callback indices, and preserves both calldata and revert data.

Typed callbacks prepare their argument layout and validate constants once per operation, then validate each substituted value and result. Word-template operations live alongside them on Collections: their fixed-width windows can reach nested calldata, while typed callbacks rebuild complete argument slots when encoded sizes change.

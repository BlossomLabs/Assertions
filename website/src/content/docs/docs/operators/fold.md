---
title: "Folds & word arrays: bounded iteration"
description: The fold family's template-lambda mechanics, early-exit modes, the word-array shape operations, the charset recipe and the on-chain record representation.
---

The folds are the one loop primitive in the system: apply a lambda over a bounded domain, threading a 32-byte accumulator. They live on `Collections`, the iteration contract, and the lambda they call is typically an `Operations` function. Three functions share one engine, differing only in what the element is:

```solidity
enum FoldExit { Full, Any, All }

function foldRange(uint256 n,      address target, bytes template,
                   uint256 accOffset, uint256[] elemOffsets, bytes32 init, FoldExit exit)
    external view returns (bytes32);
function foldBytes(bytes s,        address target, bytes template, ...) // same tail
function foldWords(bytes s,        address target, bytes template, ...) // same tail
```

- **`foldRange`** iterates the index range `0 .. n-1`; the element is the index itself.
- **`foldBytes`** iterates the bytes of `s`; the element is the byte VALUE as a word.
- **`foldWords`** iterates the 32-byte words of `s`; the element is the word. Feed it an array PAYLOAD (elements without the envelope), e.g. sliced out of a returned array; a length that is not a multiple of 32 reverts with `UnalignedWords` (silent truncation of a partial trailing word would be a wrong-answer machine).

## Template-lambda mechanics

The lambda is a single staticcall per element, described by a *template*: `template` is complete, valid calldata for `target` in which 32-byte windows are rewritten per iteration: the accumulator at `accOffset`, then the element at every offset in `elemOffsets`, in the supplied order (the element wins over the accumulator on overlap; later element windows win over earlier ones). The lambda must return exactly 32 bytes, which become the new accumulator, and the final accumulator is the fold's result.

Any single-word-returning view or pure function is a lambda; there is no closure format to learn. Summing `0..4` with the `add` operation as the lambda (`ADD_U` from [the selector constants](/docs/solidity#selector-constants)):

```solidity
// template: add(0, 0); acc window at byte 4 (first arg), elem at 36 (second)
bytes memory template = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
uint256[] memory elemOffsets = new uint256[](1);
elemOffsets[0] = 36;
collections.foldRange(5, address(operations), template, 4, elemOffsets, bytes32(0), Collections.FoldExit.Full);
// = 10
```

Window offsets are byte offsets into the template: after the 4-byte selector, argument words sit at 4, 36, 68, ... A lambda that ignores the accumulator (a pure predicate) can park both windows on the same offset, since the element wins.

## Exit modes

`Full` scans every element. `Any` stops at the first NONZERO accumulator (exists), `All` at the first ZERO (forall); the final accumulator is returned either way, so `Any` folds judge `EQ 1`-shaped words and `All` folds start from `init = 1`. Early exit is also failure-avoidance: elements after the exit point are never touched, so a would-revert application past a satisfied `Any` never happens.

An empty domain returns `init` after validating the template length and window bounds; the target is not inspected or called.

## Recipes

**Charset**: "every byte of the string is in the class" has a native operation, `charset(bytes s, uint256 mask)` on Operations, so EVMcrispr's [`@str.charset!`](/docs/evml) compiles straight to it (one call with the loop inside Solidity), not to a fold. The mask is a 256-bit set where bit `i` covers byte value `i`, built off-chain (`a-z` is bits 97..122):

```solidity
// mask: bits 97..122 = a-z
operations.charset(bytes(symbol), mask); // true iff every byte is a-z
```

The fold form is what `charset` collapses, and it stays the general pattern for any OTHER per-byte predicate: `foldBytes` with a lambda over the byte value, the `All` exit and `init = 1`. With `bitSet(mask, elem)` from Operations as the lambda it reproduces `charset` (both windows share the element offset, since `bitSet` ignores its accumulator):

```solidity
// the template for a custom per-byte test, shown with bitSet as the predicate
bytes memory template = abi.encodeWithSelector(Operations.bitSet.selector, mask, uint256(0));
uint256[] memory elemOffsets = new uint256[](1);
elemOffsets[0] = 36;
collections.foldBytes(bytes(symbol), address(operations), template, 36, elemOffsets, bytes32(uint256(1)), Collections.FoldExit.All);
```

The check is byte-level, so multi-byte UTF-8 characters (every byte >= 0x80) fail any ASCII-only mask, and the empty string is vacuously in every set.

**Includes and split segments** need no fold: they are `indexOf`/`byteLen`/`slice` compositions, documented once on [the bytes page](/docs/operators/data#search-indexof). Array membership is either an `Any`-exit `foldWords` with an `eq(item, elem)` lambda, or `wordIndexOf`'s sentinel composition below.

## Word arrays

The word-array family operates on the same payloads `foldWords` consumes: aligned 32-byte words without the ABI envelope (an array's elements, sliced out of a returned array or produced by another word op). Every function validates alignment first (`UnalignedWords`) and returns a plain bytes payload, so they nest into each other, into the folds, and into `read` splicing.

```solidity
function mapWords    (bytes s, address target, bytes template, uint256[] elemOffsets)
    external view returns (bytes);
function filterWords (bytes s, address target, bytes template, uint256[] elemOffsets)
    external view returns (bytes);
function iotaWords   (uint256 n) external pure returns (bytes);
function wordIndexOf (bytes s, bytes32 w) external pure returns (uint256);
function reverseWords(bytes s) external pure returns (bytes);
function zipWords    (bytes a, bytes b) external pure returns (bytes);
function unzipWords  (bytes s, uint256 which) external pure returns (bytes);
function sortWords   (bytes s) external pure returns (bytes);
function uniqueWords (bytes s, bool ordered) external pure returns (bytes);
function sumWords    (bytes s) external pure returns (uint256);
```

**`mapWords`** applies a single-staticcall lambda to every word and returns the transformed payload: the bytes-producing map the scalar folds cannot express. Lambda conventions match the folds (`template` is complete calldata for `target` whose 32-byte windows at `elemOffsets` are rewritten per element; the lambda's single return word is the mapped element), and so do the failure modes below. An empty payload returns empty after validating the template length and window bounds, without inspecting or calling the target. In [EVMcrispr](/docs/evml) it is `@map!` applied to a named definition, e.g. `def @dbl! "$x: number -> number" @calc!($x * 2)` then `@map!($t::values() @dbl!)`.

**`filterWords`** is `mapWords`' variable-length sibling, byte-identical in signature and lambda conventions: it keeps the ELEMENTS whose lambda application returns canonical ABI true, in order, so the output length is the kept count and the result nests into `len`, the folds and the other word ops. EVMcrispr compiles `@filter!` to it, and `@find!` is a core `pick` of the first kept word (no match leaves the pick out of bounds, so it reverts).

**`iotaWords(n)`** is the index generator: the payload `0, 1, ..., n-1`. Its canonical pairing is `zipWords(iotaWords(n), payload)`, the enumeration that EVMcrispr's `@enumerate!` compiles with a live `n`.

**`wordIndexOf(s, w)`** returns the index of the first word of `s` equal to `w`, with the word COUNT as the not-found sentinel. The sentinel composes: contains is `lt(wordIndexOf(s, w), div(byteLen(s), 32))`, and a word-index read past the sentinel reverts, which is how `@lookup!` turns a missing key into an assertion failure.

**`reverseWords`** reverses the word order (`@reverse!`). **`zipWords(a, b)`** interleaves two payloads as `a0, b0, a1, b1, ...` for a fold or for `unzipWords` to split back; different word counts revert with `WordCountMismatch` (silent truncation would be a wrong-answer machine). **`unzipWords(s, which)`** is its inverse: every second word, lane 0 (words 0, 2, 4, ...) or lane 1 (words 1, 3, 5, ...); a lane past 1 reverts with `InvalidLane`, and an odd word count leaves the extra word in lane 0. EVMcrispr's `@zip!` and `@unzip!` compile to the pair.

**`sortWords`** sorts ascending as UNSIGNED words (`@sort!`). Stable bottom-up merge sort uses O(n log n) comparisons and O(n) scratch memory. Signed sorting is a three-node recipe instead of an overload: flip the sign bit (`mapWords` with `bitXor(2^255, elem)`), sort, flip back. **`uniqueWords(s, ordered)`** removes duplicates while retaining first-occurrence order. With `ordered = true`, equal values must already be grouped: it compares adjacent words in O(n). With `false`, it checks all retained words in O(n squared). Ordering is trusted, not validated. Sorted deduplication is `uniqueWords(sortWords(s), true)`; EVMcrispr's `@unique!` passes `true`, so it removes adjacent duplicates only and `@unique!(@sort!(...))` is the set-uniqueness spelling.

**`sumWords`** is the checked sum of the payload's words (overflow past 2^256 - 1 reverts with `Panic(0x11)`): the native, fixed-operation form of the `foldWords(add)` recipe, one on-chain loop instead of a call per element. EVMcrispr compiles `@sum!` to it; use `@reduce!(call add 0)` (or `foldWords` directly) for any other reduction (min, max, bitOr, bitAnd) or a nonzero initial accumulator.

### On-chain records

A zipped key/value word-pair payload, the interleaved words `zipWords` and `iotaWords` produce, is also EVMcrispr's on-chain RECORD representation. String keys travel as their keccak digests. The record faces are:

| Helper | Compiles to | Description |
|--------|-------------|-------------|
| `@enumerate!(call)` | `zipWords(iotaWords(n), payload)` | Pair every element with its index, with `n` the live length; the result is a record |
| `@zip!(a b)` / `@unzip!(record lane)` | `zipWords` / `unzipWords` | Interleave two word payloads into a record, or split a record back into a lane |
| `@keys!(record)` / `@values!(record)` | `unzipWords(record, 0)` / `unzipWords(record, 1)` | The key lane and the value lane of a record |
| `@lookup!(record name)` | `wordIndexOf` over the key lane, then a word read at that index of the value lane | The value stored under a key: literal string keys keccak-hash at composition time, live keys hash on-chain; a missing key REVERTS because the sentinel index lands past the value lane |

## Failure modes and gas

A callback revert produces `CallbackFailed(operation, index, other, target, callData, reason)`, preserving both the attempted call and its revert data. Invalid windows revert with `LambdaOffsetOutOfBounds`; a target without bytecode (including a precompile) reverts with `InvalidCallbackTarget`. Word callbacks must return exactly 32 bytes; filters additionally require 0 or 1. Invalid results revert with `InvalidCallbackResult`. Early exits may avoid a later failing callback.

Gas is the loop bound. Every application pays real staticcall overhead, so domain sizes are naturally limited by the block gas limit: fine for symbols, names and moderate arrays, wrong for megabyte scans. Prefer the `indexOf`/`byteLen` compositions where they express the same predicate, and let `Any`/`All` exit early.

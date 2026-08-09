---
title: "Folds & word arrays: bounded iteration"
description: The fold family's template-lambda mechanics, early-exit modes, the word-array shape operations, and the charset, includes and split recipes.
---

The folds are the one loop primitive in the system: apply a lambda over a bounded domain, threading a 32-byte accumulator. Three functions share one engine, differing only in what the element is:

```solidity
enum FoldExit { Full, Any, All }

function foldRange(uint256 n,      address target, bytes template,
                   uint256 accOffset, uint256 elemOffset, bytes32 init, FoldExit exit)
    external view returns (bytes32);
function foldBytes(bytes s,        address target, bytes template, ...) // same tail
function foldWords(bytes s,        address target, bytes template, ...) // same tail
```

- **`foldRange`** iterates the index range `0 .. n-1`; the element is the index itself.
- **`foldBytes`** iterates the bytes of `s`; the element is the byte VALUE as a word.
- **`foldWords`** iterates the 32-byte words of `s`; the element is the word. Feed it an array PAYLOAD (elements without the envelope), e.g. sliced out of a returned array; a length that is not a multiple of 32 reverts with `UnalignedWords` (silent truncation of a partial trailing word would be a wrong-answer machine).

## Template-lambda mechanics

The lambda is a single staticcall per element, described by a *template*: `template` is complete, valid calldata for `target` in which two 32-byte windows are rewritten per iteration, the accumulator at `accOffset`, then the element at `elemOffset` (the element wins on overlap; every byte outside the windows stays pristine template). The first word of the lambda's return becomes the new accumulator, and the final accumulator is the fold's result.

Any single-word-returning view or pure function is a lambda; there is no closure format to learn. Summing `0..4` with the `add` operator as the lambda:

```solidity
bytes4 constant ADD_U = bytes4(keccak256("add(uint256,uint256)"));

// template: add(0, 0); acc window at byte 4 (first arg), elem at 36 (second)
bytes memory template = abi.encodeWithSelector(ADD_U, uint256(0), uint256(0));
operators.foldRange(5, address(operators), template, 4, 36, bytes32(0), Operators.FoldExit.Full);
// = 10
```

Window offsets are byte offsets into the template: after the 4-byte selector, argument words sit at 4, 36, 68, ... A lambda that ignores the accumulator (a pure predicate) can park both windows on the same offset, since the element wins.

## Exit modes

`Full` scans every element. `Any` stops at the first NONZERO accumulator (exists), `All` at the first ZERO (forall); the final accumulator is returned either way, so `Any` folds judge `EQ 1`-shaped words and `All` folds start from `init = 1`. Early exit is also failure-avoidance: elements after the exit point are never touched, so a would-revert application past a satisfied `Any` never happens.

An empty domain returns `init` without touching the lambda (the target is not even inspected).

## Recipes

**Charset**: "every byte of the string is in the class" is `foldBytes` with a `bitSet(mask, elem)` lambda and the `All` exit, `init = 1`. The mask is a 256-bit set where bit `i` covers byte value `i`, built off-chain (`a-z` is bits 97..122); `bitSet` ignores its accumulator, so both windows share the element offset:

```solidity
// mask: bits 97..122 = a-z
bytes memory template = abi.encodeWithSelector(Operators.bitSet.selector, mask, uint256(0));
operators.foldBytes(bytes(symbol), address(operators), template, 36, 36, bytes32(uint256(1)), Operators.FoldExit.All);
// 1 iff every byte is a-z
```

The check is byte-level, so multi-byte UTF-8 characters (every byte >= 0x80) fail any ASCII-only mask, and the empty string is vacuously in every set.

**Includes**: no fold needed. Substring containment is `lt(indexOf(s, part, 0), byteLen(s))` judged `EQ 1` ([the sentinel composes](/docs/operators/data)), and its negation asserts absence. Array membership is either an `Any`-exit `foldWords` with an `eq(item, elem)` lambda, or `wordIndexOf`'s sentinel composition below.

**Split segments**: `indexOf`/`slice` compositions, no fold needed. Segment k sits between delimiter occurrences k-1 and k, so any segment is two `indexOf` reads and a `slice`: segment 0 is `slice(s, 0, indexOf(s, delim, 0))`, segment 1 spans `[indexOf(s, delim, 0) + dlen, indexOf(s, delim, 1))`, and negative indexes anchor at the end the same way (`-1` = last, `-2` = second-last), with the not-found sentinel `byteLen(s)` supplying the trailing segment's end for free. Version-string checks work the same way: split `"2.1.0"` by `"."` and pin segment 0, or [parseUint](/docs/operators/data) a segment to compare it numerically.

## Word arrays

The word-array family operates on the same payloads `foldWords` consumes: aligned 32-byte words without the ABI envelope (an array's elements, sliced out of a returned array or produced by another word op). Every function validates alignment first (`UnalignedWords`) and returns a plain bytes payload, so they nest into each other, into the folds, and into `read` splicing.

```solidity
function mapWords    (bytes s, address target, bytes template, uint256 elemOffset)
    external view returns (bytes);
function filterWords (bytes s, address target, bytes template, uint256 elemOffset)
    external view returns (bytes);
function iotaWords   (uint256 n) external pure returns (bytes);
function wordIndexOf (bytes s, bytes32 w) external pure returns (uint256);
function reverseWords(bytes s) external pure returns (bytes);
function zipWords    (bytes a, bytes b) external pure returns (bytes);
function unzipWords  (bytes s, uint256 which) external pure returns (bytes);
function sortWords   (bytes s) external pure returns (bytes);
function uniqueWords (bytes s) external pure returns (bytes);
```

**`mapWords`** applies a single-staticcall lambda to every word and returns the transformed payload: the bytes-producing map the scalar folds cannot express. Lambda conventions match the folds (`template` is complete calldata for `target` whose 32-byte window at `elemOffset` is rewritten per element; the lambda's FIRST return word is the mapped element), and so do the failure modes below. An empty payload returns empty without inspecting the lambda. In [EVMcrispr](/docs/evml) it is `@map!` with an Operators-backed lambda, e.g. `@map!($t::values() @num!(* 2))`.

**`filterWords`** is `mapWords`' variable-length sibling, byte-identical in signature and lambda conventions: it keeps the ELEMENTS whose lambda application returns nonzero, in order, so the output length is the kept count and the result nests into `len`, the folds and the other word ops. EVMcrispr compiles `@filter!` to it, and `@find!` is a core `pick` of the first kept word (no match leaves the pick out of bounds, so it reverts).

**`iotaWords(n)`** is the index generator: the payload `0, 1, ..., n-1`. Its canonical pairing is `zipWords(iotaWords(n), payload)`, the enumeration that EVMcrispr's `@enumerate!` compiles with a live `n`. That zipped key/value word-pair payload is also EVMcrispr's on-chain RECORD representation (string keys travel as their keccak digests), consumed by `@keys!`, `@values!` and `@lookup!`.

**`wordIndexOf(s, w)`** returns the index of the first word of `s` equal to `w`, with the word COUNT as the not-found sentinel. The sentinel composes: contains is `lt(wordIndexOf(s, w), div(byteLen(s), 32))`, and a word-index read past the sentinel reverts, which is how `@lookup!` turns a missing key into an assertion failure.

**`reverseWords`** reverses the word order (`@reverse!`). **`zipWords(a, b)`** interleaves two payloads as `a0, b0, a1, b1, ...` for a fold or for `unzipWords` to split back; different word counts revert with `WordCountMismatch` (silent truncation would be a wrong-answer machine). **`unzipWords(s, which)`** is its inverse: every second word, lane 0 (words 0, 2, 4, ...) or lane 1 (words 1, 3, 5, ...); a lane past 1 reverts with `InvalidLane`, and an odd word count leaves the extra word in lane 0. EVMcrispr's `@zip!` and `@unzip!` compile to the pair.

**`sortWords`** sorts ascending as UNSIGNED words (`@sort!`). Insertion sort: O(n^2) word moves, so gas caps practical inputs at hundreds of words, not thousands. Signed sorting is a three-node recipe instead of an overload: flip the sign bit (`mapWords` with `bitXor(2^255, elem)`), sort, flip back. **`uniqueWords`** collapses ADJACENT duplicates in O(n), so set-semantics deduplication is `uniqueWords(sortWords(s))`; on unsorted input it is run-length deduplication, by design (`@unique!`, nesting `@sort!` for the set form).

## Failure modes and gas

A lambda revert is an assertion failure: it reverts the fold (or `mapWords`) with `LambdaCallFailed` naming the element index, the target and the constructed calldata (early exits can make this data-dependent: an `Any` fold that satisfies before a poisoned element never reaches it, where `Full` reverts). Offsets must leave room for a 32-byte word inside the template or the call reverts with `LambdaOffsetOutOfBounds`; a code-less lambda target reverts with `LambdaCallFailed(0, target, "")`; a lambda returning fewer than 32 bytes with `LambdaReturnTooShort`.

Gas is the loop bound. Every application pays real staticcall overhead, so domain sizes are naturally limited by the block gas limit: fine for symbols, names and moderate arrays, wrong for megabyte scans. Prefer the `indexOf`/`byteLen` compositions where they express the same predicate, and let `Any`/`All` exit early.

---
title: "Folds: bounded iteration"
description: The fold family's template-lambda mechanics, early-exit modes, and the charset, includes and split recipes.
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

**Includes**: the cheap form needs no fold at all, `lt(indexOf(s, part, 0), byteLen(s))` judged `EQ 1` ([the sentinel composes](/docs/operators/data)). The fold form is `foldRange` with a `matchAt(s, needle, elem)` lambda and the `Any` exit over positions `0 .. byteLen(s) - byteLen(needle)`, useful when the position domain itself is what varies:

```solidity
// matchAt(s, "LP", pos): s and needle baked into the template, pos is the
// third head word, byte 4 + 64 = 68
bytes memory template = abi.encodeWithSelector(Operators.matchAt.selector, s, bytes("LP"), uint256(0));
operators.foldRange(13, address(operators), template, 68, 68, bytes32(0), Operators.FoldExit.Any);
```

**Split segments**: `indexOf`/`slice` compositions, no fold needed. Segment k sits between delimiter occurrences k-1 and k, so any segment is two `indexOf` reads and a `slice`: segment 0 is `slice(s, 0, indexOf(s, delim, 0))`, segment 1 spans `[indexOf(s, delim, 0) + dlen, indexOf(s, delim, 1))`, and negative indexes anchor at the end the same way (`-1` = last, `-2` = second-last), with the not-found sentinel `byteLen(s)` supplying the trailing segment's end for free. Version-string checks work the same way: split `"2.1.0"` by `"."` and pin segment 0, or [parseUint](/docs/operators/data) a segment to compare it numerically.

## Failure modes and gas

A lambda revert is an assertion failure: it reverts the fold with `LambdaCallFailed` naming the element index, the target and the constructed calldata (early exits can make this data-dependent: an `Any` fold that satisfies before a poisoned element never reaches it, where `Full` reverts). Offsets must leave room for a 32-byte word inside the template or the fold reverts with `LambdaOffsetOutOfBounds`; a code-less lambda target reverts with `LambdaCallFailed(0, target, "")`; a lambda returning fewer than 32 bytes with `LambdaReturnTooShort`.

Gas is the loop bound. Every application pays real staticcall overhead, so domain sizes are naturally limited by the block gas limit: fine for symbols, names and moderate arrays, wrong for megabyte scans. Prefer the `indexOf`/`byteLen` compositions where they express the same predicate, and let `Any`/`All` exit early.

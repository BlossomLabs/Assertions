---
title: "data: returndata operations"
description: Hashing, string splitting, substring and charset checks, and byte lengths over resolved call chains.
---

`data(op, target, calls, arg, index)` operates on the raw returndata of a resolved call chain (hops here are plain calldata chaining through single-address returns; for a navigated chain, self-chain a `read` call). `arg` and `index` are per-op arguments; unused ones pass as `""` / `0`.

```solidity
function data(DataOp op, address target, bytes[] calls, bytes arg, int256 index) external view;
```

## Hashing complex returns

When a function returns something the typed assertions can't decode (structs, arrays, long strings), `data(Hash, ...)` returns `keccak256` of the final returndata so the existing bytes32 assertions can check it against a precomputed hash:

```solidity
bytes[] memory calls = new bytes[](1);
calls[0] = abi.encodeCall(IVault.getPosition, (positionId)); // returns a struct

assertions.assertEqCallBytes32(
    address(combinators),
    abi.encodeCall(Combinators.data, (
        Combinators.DataOp.Hash, vault, calls, "", 0
    )),
    keccak256(abi.encode(expectedAmount, expectedDebt, expectedOwner))
);
```

## String splitting

`data(Split, target, calls, delimiter, index)` decodes the chain's final string return, splits it by the delimiter, and returns the `index`-th segment as a normal ABI-encoded string, so string assertions consume it directly. The index is an `int256`: 0-based from the start, or negative from the end (`-1` = last segment), resolved against the segment count at execution time. So "the name ends with LP" is delimiter `" "` with index `-1`, with no composition-time segment counting.

"The second word of the pool's name is LP":

```solidity
bytes[] memory calls = new bytes[](1);
calls[0] = abi.encodeCall(IPool.name, ()); // "Curve LP Token"

assertions.assertEqCallStringN(
    address(combinators),
    abi.encodeCall(Combinators.data, (
        Combinators.DataOp.Split, pool, calls, " ", 1
    )),
    0,
    "LP"
);
```

```evml
assertions:assert @split!($pool::name() " " 1) == "LP"
```

Split semantics: the delimiter is a non-empty exact byte sequence (empty reverts with `EmptyDelimiter`); segments are the maximal runs between occurrences, so adjacent delimiters produce empty segments; a string that doesn't contain the delimiter is one segment (index 0 = index -1 = the whole string); and an index outside the segments in either direction (valid range `-segments .. segments-1`) reverts with `SegmentIndexOutOfBounds(index, segments)`, a loud failure with the actual segment count. Version-string checks work the same way: split `"2.1.0"` by `"."` and assert segment 0 equals `"2"`.

## Substring & character-set checks

Two string predicates return a 0/1 word, so they compose with `calc`'s logic opcodes and `unary(IsZero, ...)` and assert via `assertTrue` / `assertFalse`.

`data(Includes, target, calls, part, 0)` is `String.includes`: whether the chain's final string return contains `part` as an exact byte sequence (case-sensitive, no wildcards; an empty `part` reverts with `EmptySubstring` since it would match everything).

`data(Charset, target, calls, mask, 0)` is the character-class check that usually gets reached for with a regex: `mask` is a 32-byte set where bit `i` covers byte value `i` (any other `arg` length reverts with `InvalidMaskLength`), and the call returns whether every byte of the string is in the set. "The token's symbol is lowercase a-z":

```solidity
bytes[] memory calls = new bytes[](1);
calls[0] = abi.encodeCall(IERC20.symbol, ());

assertions.assertTrue(
    address(combinators),
    abi.encodeCall(Combinators.data, (
        Combinators.DataOp.Charset, token, calls,
        abi.encodePacked(bytes32(uint256(0x07fffffe) << 96)), // bits 97..122 = a-z
        0
    ))
);
```

Masks are built off-chain from ranges and single bytes (`a-z` is `0x07fffffe << 96`, digits OR in bits 48..57, `-` is bit 45). The check is byte-level, so multi-byte UTF-8 characters (every byte >= 0x80) fail any ASCII-only mask, and the empty string is vacuously in every set; combine with a `LEN` read `> 0` to also require non-empty. Anything needing positional structure ("exactly one dash, not at the start") is deliberately out of scope: an on-chain regex engine would make assertion calldata unreviewable.

## Returndata byte length

`data(ByteLen, target, calls, "", 0)` (EVMcrispr's `@bytelen!`) returns the byte length of the final resolved returndata: a `uint256[]` with `n` items measures `64 + n * 32` (offset word + length word + items). Use it for size checks on returns that are not a single dynamic value. The decoded counterpart is `read`'s `LEN` sentinel (element count for arrays, byte length for string/bytes).

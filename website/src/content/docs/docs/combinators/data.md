---
title: "data: raw-bytes operations"
description: Hashing, string splitting, substring and charset checks, and byte lengths over resolved operands.
---

`data(op, a, arg, index)` operates on the raw bytes a resolved operand produces (for a navigated or chained read, nest a `nav` or `chain` call as the operand). `arg` and `index` are per-op arguments; unused ones pass as `""` / `0`.

```solidity
function data(DataOp op, InputParam a, bytes calldata arg, int256 index) external view;
```

The examples reuse the `callParam`/`eq`/`noConstraints` helpers from [the Solidity guide](/docs/solidity) and `comboParam` from [the expressions page](/docs/combinators/calc).

## Hashing complex returns

When a function returns something a word constraint can't compare (structs, arrays, long strings), `data(Hash, ...)` returns `keccak256` of the resolved bytes so an `EQ` constraint can check it against a precomputed hash:

```solidity
assertions.assertParam(
    callParam(
        address(combinators),
        abi.encodeCall(Combinators.data, (
            Combinators.DataOp.Hash,
            callParam(vault, abi.encodeCall(IVault.getPosition, (positionId)), noConstraints()),
            "", 0
        )),
        eq(keccak256(abi.encode(expectedAmount, expectedDebt, expectedOwner)))
    )
);
```

## String splitting

`data(Split, a, delimiter, index)` decodes the operand's string return, splits it by the delimiter, and returns the `index`-th segment as a normal ABI-encoded string, so any string consumer takes it directly (compare via `data(Hash)` over the split, or EVMcrispr's string `==`). The index is an `int256`: 0-based from the start, or negative from the end (`-1` = last segment), resolved against the segment count at execution time. So "the name ends with LP" is delimiter `" "` with index `-1`, with no composition-time segment counting.

"The second word of the pool's name is LP":

```solidity
bytes memory secondWord = abi.encodeCall(Combinators.data, (
    Combinators.DataOp.Split,
    callParam(pool, abi.encodeCall(IPool.name, ()), noConstraints()), // "Curve LP Token"
    " ", 1
));
// judge: keccak256 of the segment envelope EQ the expected hash
assertions.assertParam(
    callParam(
        address(combinators),
        abi.encodeCall(Combinators.data, (
            Combinators.DataOp.Hash,
            comboParam(address(combinators), secondWord),
            "", 0
        )),
        eq(keccak256(abi.encode("LP")))
    )
);
```

```evml
assertions:assert @split!($pool::name() " " 1) == "LP"
```

Split semantics: the delimiter is a non-empty exact byte sequence (empty reverts with `EmptyDelimiter`); segments are the maximal runs between occurrences, so adjacent delimiters produce empty segments; a string that doesn't contain the delimiter is one segment (index 0 = index -1 = the whole string); and an index outside the segments in either direction (valid range `-segments .. segments-1`) reverts with `SegmentIndexOutOfBounds(index, segments)`, a loud failure with the actual segment count. Version-string checks work the same way: split `"2.1.0"` by `"."` and assert segment 0 equals `"2"`.

## Substring & character-set checks

Two string predicates return a 0/1 word, so they compose with `calc`'s logic opcodes and `unary(IsZero, ...)` and judge with an `EQ 1` / `EQ 0` constraint.

`data(Includes, a, part, 0)` is `String.includes`: whether the operand's string return contains `part` as an exact byte sequence (case-sensitive, no wildcards; an empty `part` reverts with `EmptySubstring` since it would match everything).

`data(Charset, a, mask, 0)` is the character-class check that usually gets reached for with a regex: `mask` is a 32-byte set where bit `i` covers byte value `i` (any other `arg` length reverts with `InvalidMaskLength`), and the call returns whether every byte of the string is in the set. "The token's symbol is lowercase a-z":

```solidity
assertions.assertParam(
    callParam(
        address(combinators),
        abi.encodeCall(Combinators.data, (
            Combinators.DataOp.Charset,
            callParam(token, abi.encodeCall(IERC20.symbol, ()), noConstraints()),
            abi.encodePacked(bytes32(uint256(0x07fffffe) << 96)), // bits 97..122 = a-z
            0
        )),
        eq(bytes32(uint256(1)))
    )
);
```

Masks are built off-chain from ranges and single bytes (`a-z` is `0x07fffffe << 96`, digits OR in bits 48..57, `-` is bit 45). The check is byte-level, so multi-byte UTF-8 characters (every byte >= 0x80) fail any ASCII-only mask, and the empty string is vacuously in every set; combine with a `LEN` nav `>= 1` to also require non-empty. Anything needing positional structure ("exactly one dash, not at the start") is deliberately out of scope: an on-chain regex engine would make assertion calldata unreviewable.

## Byte length

`data(ByteLen, a, "", 0)` (EVMcrispr's `@bytelen!`) returns the byte length of the operand's resolved bytes: a `uint256[]` with `n` items measures `64 + n * 32` (offset word + length word + items). Use it for size checks on returns that are not a single dynamic value. The decoded counterpart is [`nav`'s `LEN` sentinel](/docs/combinators/reads) (element count for arrays, byte length for string/bytes).

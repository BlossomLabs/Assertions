---
title: "Bytes: concat, slice, hash, search & encode"
description: Bytes and string operations, occurrence-ordinal search, decimal parsing, and the runtime ABI encoder over resolved operands.
---

The bytes family operates on plain `bytes` arguments; live data reaches it through the core's [`read`](/docs/core/reads) splicing. The key fact making that work: a resolved dynamic operand (a string or bytes return, a `nav` dynamic terminal, a `chain` result) arrives as the canonical single-value envelope `[0x20][length][payload]`, which is byte-for-byte the ABI encoding of one `bytes` argument. So for the single-argument functions (`hash`, `byteLen`, and `concat`'s whole-array case) the envelope splices directly after the selector, and the function sees the *decoded payload*.

```solidity
function concat (bytes[] parts) external pure returns (bytes);
function slice  (bytes data, uint256 start, uint256 len) external pure returns (bytes);
function byteLen(bytes data) external pure returns (uint256);
function hash   (bytes data) external pure returns (bytes32);
function indexOf(bytes s, bytes needle, int256 from) external pure returns (uint256);
function matchAt(bytes s, bytes needle, uint256 pos) external pure returns (uint256);
function encode (string types, bytes[] values) external pure;   // raw return
```

The examples reuse `callParam`/`eq`/`noConstraints` from [the Solidity guide](/docs/solidity) and `lit`/`read1` from [the Operators overview](/docs/operators).

## Hashing: the payload semantic

`hash(data)` returns `keccak256` of its `bytes` argument, so an `EQ` constraint can pin complex or hard-to-decode values against a precomputed hash (keccak is an opcode, not a precompile, so it must be a function here). Through `read` splicing, a string operand's resolved envelope IS `hash`'s calldata encoding, which means **the digest covers the decoded payload**: pinning a `name()` return compares against `keccak256("Curve LP Token")`, the string itself.

```solidity
bytes memory nameHash = read1(operators, Operators.hash.selector,
    callParam(pool, abi.encodeCall(IPool.name, ()), noConstraints())
);
assertions.assertParam(
    callParam(address(assertions), nameHash, eq(keccak256("Curve LP Token")))
);
```

For returns that are not a single dynamic value (multi-word tuples, structs), extract the field first with the core's `pick` or `nav` and compare words directly; the envelope framing above only holds for single dynamic returns.

## Byte length

`byteLen(data)` is the raw byte length of its argument. Spliced over a string or bytes return it measures the decoded payload (`"Curve LP Token"` measures 14), matching [`nav`'s `LEN` sentinel](/docs/core/reads) for those types; the empty string measures 0. Its main role in composition is the `includes` recipe below, where it doubles as `indexOf`'s not-found sentinel.

## Slice and concat

`slice(data, start, len)` returns `data[start .. start + len)` as a normal bytes value, reverting with `SliceOutOfBounds` when the range leaves the data (zero-length slices at any in-range position are fine). `concat(parts)` concatenates the parts in order, also returned as a normal bytes value: the canonical form every consumer of a single bytes argument expects, including `encode`'s `values[]`.

## Search: indexOf and matchAt

`indexOf(s, needle, occurrence)` returns the position of the occurrence-th occurrence of `needle` in `s`, counted from either end (the repo-wide negative-index idiom):

- `occurrence >= 0`: the (occurrence+1)-th match from the start (0 = first, 1 = second, ...);
- `occurrence < 0`: counted from the end (-1 = last, -2 = second-last, ...).

Occurrences are enumerated left to right and **non-overlapping**: after a match the scan resumes past it, so in `"aaaa"` the needle `"aa"` occurs at 0 and 2. That is delimiter semantics, and it makes occurrence counting and splitting agree. Requesting an occurrence that does not exist returns the sentinel `s.length` in both directions. The function is **total by design**: an empty needle vacuously matches at every position `0 .. s.length`, out-of-range ordinals return the sentinel, and nothing ever reverts. On `"Curve LP Token"` (length 14, spaces at 5 and 8):

```solidity
indexOf(name, "LP", 0)    // 6
indexOf(name, " ", 0)     // 5   (first space)
indexOf(name, " ", 1)     // 8   (second space)
indexOf(name, "xyz", 0)   // 14  (sentinel: not found)
indexOf(name, " ", -1)    // 8   (last space)
indexOf(name, " ", -2)    // 5   (second-to-last space)
```

The sentinel composes: **includes** is `lt(indexOf(s, part, 0), byteLen(s))` judged `EQ 1`, and its negation (`ge(...)` judged `EQ 1`, or the same expression judged `EQ 0`) asserts absence. **Split segments** are two `indexOf` reads and a `slice`, whatever the index: segment k sits between delimiter occurrences k-1 and k, so segment 1 of a space-split name is `slice(s, start, indexOf(s, " ", 1) - start)` with `start = indexOf(s, " ", 0) + 1`, and negative segments anchor at the end the same way (the last segment spans from `indexOf(s, " ", -1) + 1` to `byteLen(s)`, which is exactly what the not-found sentinel returns for the missing next boundary). So "the name ends with LP" needs no composition-time segment counting. The [fold page](/docs/operators/fold) collects these recipes.

`matchAt(s, needle, pos)` returns 1 when `needle` occurs in `s` at exactly position `pos`, else 0 (a match that would run past the end is 0, not a revert; an empty needle vacuously matches any `pos <= s.length`). It is the single-call fold lambda behind substring recipes, and on its own it is an anchored check: `matchAt(name, "Curve", 0)` is "starts with".

## Parse: parseUint and toString

`parseUint(s)` is the bridge from string returns into arithmetic: it decodes a decimal ASCII string as a uint256, so a split version segment composes straight into a numeric comparison (`gt(parseUint(segment), 2)`). It is strict by design: empty input reverts with `EmptyNumber`, any byte outside `0-9` with `InvalidDecimalDigit` (no signs, no whitespace, no decimal points), and a value past `2^256 - 1` with the checked-arithmetic panic. Leading zeros are accepted (`"007"` is 7). `toString(v)` is its inverse, the decimal rendering with no leading zeros, so `toString(parseUint(s))` normalizes. In [EVMcrispr](/docs/evml), a live string operand inside `@num!` arithmetic coerces through `parseUint` automatically.

## Calldata layout for multi-argument calls

`read` appends each segment's full resolved bytes in order, so functions taking a dynamic argument *plus* other arguments need the encoder to lay out heads and tails, exactly as ABI encoding requires. `RAW_BYTES` segments carry the head words (offsets, static arguments) and any pre-encoded tails; a live envelope splices as a tail, with one trick: its leading `0x20` word rides along as dead calldata bytes, and the head offset points one word past it. `slice(liveData, start, len)` built by hand:

```text
selector
0x00: 0x80          <- RAW head word: offset of data's [length][payload]
0x20: start         <- RAW head word
0x40: len           <- RAW head word
0x60: [0x20][length][payload...]   <- the live envelope; its length word sits at 0x80
```

Four segments: three literal words and the operand. Hand-writing this is rare; [EVMcrispr](/docs/evml) compiles `@split!`/`@includes!`/`@charset!` to these layouts, and single-dynamic-argument calls (`hash`, `byteLen`) need none of it.

## encode: runtime abi.encode

`encode(types, values)` assembles the canonical ABI encoding of a tuple from pre-encoded component values: `nav`'s inverse. `types` is the tuple's type as a parenthesized descriptor (`"(address,uint256[])"`, the same grammar as `nav`, only the SHAPE is parsed), and `values[i]` is the canonical single-value encoding of component `i`:

- a **static** component with a head footprint of `w` words: exactly `w * 32` bytes (one word for `uint256`/`address`/`bool`/`bytes32`, the flattened words for static tuples and fixed arrays), copied verbatim into the head;
- a **dynamic** component (`bytes`, `string`, `T[]`, dynamic tuples): the canonical envelope `[0x20][tail...]`, exactly what a bytes-returning call, `nav`'s dynamic terminal, or `abi.encode` of the single value produces. The leading offset word is stripped, the true top-level offset written into the head, and the tail appended verbatim. ABI offsets are frame-relative, so verbatim tail splicing is correct at any nesting depth: nested dynamics (`string[]`, `(uint256,bytes)[]`) need no special handling.

The output comes back via a raw assembly return with NO bytes envelope, deliberately the one raw-returning function in the contract: its output is a calldata SEGMENT for the core's `read` to splice, not a value to decode. That is its role in composition: resolve pieces live (a `nav` selection here, a `pick` word there), `encode` them into one multi-value span, and splice that span into a constructed call's arguments.

Like `nav`, deep tail validation is skipped: the descriptor is the author's claim about the encoding, and a wrong claim about a tail travels as-is. Failure modes: a malformed descriptor reverts with `InvalidTypeDescriptor`, a `values` array whose length differs from the component count with `ComponentCountMismatch`, a static component of the wrong size with `InvalidComponentLength`, and a dynamic component that is not an envelope with `InvalidComponentEnvelope`.

---
title: "Bytes: calls, hash, search, strings & encode"
description: Raw calls, bytes and string operations, occurrence-ordinal search, decimal parsing, and the runtime ABI encoder over resolved operands.
---

The bytes family operates on plain `bytes` arguments; live data reaches it through the core's [`read`](/docs/core/reads) splicing. The key fact making that work: a resolved dynamic operand (a string or bytes return, a `nav` dynamic terminal, a `chain` result) arrives as the canonical single-value envelope `[0x20][length][payload]`, which is byte-for-byte the ABI encoding of one `bytes` argument. So for the single-argument functions (`hash`, `byteLen`, `toLower`, `toUpper`) the envelope splices directly after the selector, and the function sees the *decoded payload*.

```solidity
function rawCall    (address target, bytes data) external view returns (bytes);
function code       (address account) external view returns (bytes);
function concat     (bytes[] parts, bytes delimiter) external pure returns (bytes);
function slice      (bytes data, uint256 start, uint256 len) external pure returns (bytes);
function sliceRange (bytes data, int256 start, int256 end) external pure returns (bytes);
function byteAt     (bytes data, int256 index) external pure returns (bytes);
function byteLen    (bytes data) external pure returns (uint256);
function hash       (bytes data) external pure returns (bytes32);
function hashPairSorted(bytes32 a, bytes32 b) external pure returns (bytes32);
function indexOf    (bytes s, bytes needle, int256 occurrence) external pure returns (uint256);
function contains   (bytes s, bytes needle) external pure returns (bool);
function split      (bytes s, bytes delimiter) external pure returns (bytes[]);
function replace    (bytes s, bytes needle, bytes repl) external pure returns (bytes);
function toLower    (bytes s) external pure returns (bytes);
function toUpper    (bytes s) external pure returns (bytes);
function charset    (bytes s, uint256 mask) external pure returns (bool);
function stringSlice(bytes s, int256 start, int256 end) external pure returns (bytes);
function stringAt   (bytes s, int256 index) external pure returns (bytes);
function parseUint  (bytes s) external pure returns (uint256);
function parseInt   (bytes s) external pure returns (int256);
function toString   (uint256 v) public pure returns (string);              // int256 overload too
function parseUnits (bytes s, uint256 decimals, Rounding r) external pure returns (int256);
function parseUnitsUnsigned(bytes s, uint256 decimals, Rounding r) external pure returns (uint256);
function formatUnits(uint256 v, uint256 decimals) public pure returns (string); // int256 overload too
function encode     (string types, bytes[] values) external pure;          // raw return
function encodeBytes(string types, bytes[] values) external pure returns (bytes);
```

The examples reuse `callParam`/`eq`/`noConstraints` from [the Solidity guide](/docs/solidity) and `lit`/`read1` from [the Operations overview](/docs/operators).

## Calls: rawCall and code

`rawCall(target, data)` executes a staticcall with raw calldata and returns the returndata as a bytes value: the precompile reach-through. Unlike the core's constructed calls, no selector is prepended and no code-length check is performed, because precompiles (sha256 at `0x02`, ecrecover at `0x01`, modexp at `0x05`, ...) have no code and raw calldata is their entire input. The caveat is the flip side: a staticcall to a code-less non-precompile address "succeeds" with empty returndata, so pin the result with `byteLen` or a constraint when that matters. A revert wraps as `RawCallFailed` carrying the calldata. In [EVMcrispr](/docs/evml), `@hash!(call "sha256")` routes its digest through a `rawCall` to the SHA-256 precompile.

Its second role is the envelope wrapper: because the returndata comes back as a bytes value, `rawCall` bridges any call's raw return, whatever its shape or runtime length, into every bytes-consuming operation. The [whole-returndata recipe](#whole-returndata-hash-over-rawcall) below builds on it.

`code(account)` returns the full runtime code of an account as a bytes value: `codeHash`'s sibling for prefix/suffix/segment assertions (slice out the ERC-1167 target of a minimal proxy, pin a code segment). A code-less account yields empty bytes. EVMcrispr's `@codeAt!` compiles to it.

## Hashing: the payload semantic

`hash(data)` returns `keccak256` of its `bytes` argument, so an `EQ` constraint can pin complex or hard-to-decode values against a precomputed hash (keccak is an opcode, not a precompile, so it must be a function here). Through `read` splicing, a string operand's resolved envelope IS `hash`'s calldata encoding, which means **the digest covers the decoded payload**: pinning a `name()` return compares against `keccak256("Curve LP Token")`, the string itself.

```solidity
bytes memory nameHash = read1(operations, Operations.hash.selector,
    callParam(pool, abi.encodeCall(IPool.name, ()), noConstraints())
);
assertions.assertParam(
    callParam(address(assertions), nameHash, eq(keccak256("Curve LP Token")))
);
```

One warning before leaning on the envelope framing: it holds for `string` and `bytes` returns only. An **array** return also arrives as an envelope, so the splice compiles and executes, but its length word counts *elements*, not bytes: `hash` over a spliced `address[3]` return digests the first 3 bytes of a 96-byte payload and returns a plausible word for a value nobody computed. Never splice an array return directly into `hash` (or `byteLen`, which would report the element count as a byte length); use the whole-returndata form below, or extract a field with the core's `pick`/`nav` and compare words directly.

### Whole returndata: hash over rawCall

For everything the envelope framing does not cover (multi-value returns, structs with dynamic members, array returns, revert payloads, even empty returndata), `rawCall` is the bridge: it returns the target call's **raw returndata as a bytes value**, at its true byte length, whatever its shape. Composing `hash` over it pins a call's entire return with a standard `EQ` constraint:

```text
hash(rawCall(target, callData))        keccak256 of the whole returndata
hash(rawCall(core, resolveCalldata))   keccak256 of any resolved operand
```

The second form routes through the core's [`resolve`](/docs/core/reads), so constraint-guarded operands, `BALANCE` fetchers, and nested core expressions are all reachable. Snapshot equality falls out: "the signer set and owner have not changed" is one hash judged `EQ` against the precomputed value, with no per-element navigation and no build-time length knowledge. Empty returndata works too: a call returning nothing hashes as `keccak256("")`, the one way to assert emptiness (a direct constraint on an empty value has no word to judge). Two care points: the digest covers the raw bytes, envelope words included, so precompute the expected hash from the full ABI encoding rather than the payload alone; and `rawCall`'s code-less caveat carries over, so pair with `codeHash` when "returned nothing" must not be satisfied by "was nothing".

When you need the *conventional* digest of a single string or bytes value (the `keccak256(value)` the rest of the EVM computes: stored name hashes, Merkle leaves), keep the direct splice from the example above; the payload semantic is exactly right there.

`hashPairSorted(a, b)` hashes the ascending-sorted pair of two words, byte-identical to OpenZeppelin MerkleProof's node combiner, so a `foldWords` over a proof payload with `hashPairSorted` as the lambda and the leaf as the initial accumulator reproduces the root (the crypto module's `@crypto:merkle.verify!` compiles exactly this fold). Order-preserving pair hashing needs no dedicated function: it composes as `hash` over `concat`.

## Byte length

`byteLen(data)` is the raw byte length of its argument. Spliced over a string or bytes return it measures the decoded payload (`"Curve LP Token"` measures 14), matching [`nav`'s `LEN` sentinel](/docs/core/reads) for those types; the empty string measures 0. Its main role in composition is the `includes` recipe below, where it doubles as `indexOf`'s not-found sentinel. Composed like the hashing recipe, `byteLen(rawCall(target, callData))` measures a call's raw returndata length, whatever its shape.

## Slice, ranges and concat

`slice(data, start, len)` returns `data[start .. start + len)` as a normal bytes value, reverting with `SliceOutOfBounds` when the range leaves the data (zero-length slices at any in-range position are fine). EVMcrispr's `@bytes.slice!` and `@bytes.at!` compile to it, with negative bounds resolved against the live `byteLen`.

`sliceRange(data, start, end)` is the clamped signed form: `start` and `end` are byte positions counted from the start, or from the end when negative (`-1` is the last byte), each clamped into `[0, length]`, with `end` exclusive; a reversed or empty range returns empty bytes, and nothing reverts. `byteAt(data, index)` returns the single byte at a signed index as a bytes value and is strict instead: an index outside the data in either direction reverts with `InvalidByteIndex(index, length)`. The compiler does not emit either of these two yet.

`concat(parts, delimiter)` concatenates the parts in order with the delimiter between consecutive elements, returned as a normal bytes value: the canonical form every consumer of a single bytes argument expects, including `encode`'s `values[]`. It allocates once, preserves empty elements, and an empty `parts` array yields empty bytes. Pass empty bytes as the delimiter for plain concatenation, which is what `@str.concat!`, `@concat!` and `@bytes.concat!` do; a constant delimiter turns it into a join.

## Search: indexOf

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

The sentinel composes. **Includes** is `lt(indexOf(s, part, 0), byteLen(s))` judged `EQ 1`, and its negation (`ge(...)` judged `EQ 1`, or the same expression judged `EQ 0`) asserts absence; EVMcrispr's `@str.includes!` compiles to this comparison. **Split segments** are two `indexOf` reads and a `slice`, whatever the index: segment k sits between delimiter occurrences k-1 and k, so segment 1 of a space-split name is `slice(s, start, indexOf(s, " ", 1) - start)` with `start = indexOf(s, " ", 0) + 1`, and negative segments anchor at the end the same way (the last segment spans from `indexOf(s, " ", -1) + 1` to `byteLen(s)`, which is exactly what the not-found sentinel returns for the missing next boundary). So "the name ends with LP" needs no composition-time segment counting; `@str.split!` compiles to this pair of reads. Version-string checks work the same way: split `"2.1.0"` by `"."` and pin segment 0, or [parseUint](#parse-parseuint-and-tostring) a segment to compare it numerically.

`contains(s, needle)` is the boolean form of the same question, one call with the loop inside: true when `needle` occurs anywhere in `s`, and an empty needle always matches, including in an empty `s`. It is total. The `includes` recipe predates it and remains what the compiler emits.

Anchored checks compose from `slice` and `hash`: "starts with Curve" is `eq(hash(slice(name, 0, 5)), keccak256("Curve"))`, and "ends with" anchors the slice at `byteLen(s) - n` the same way.

## Strings: replace, case folds, charset and UTF-8 slicing

`replace(s, needle, repl)` returns `s` with every occurrence of `needle` replaced by `repl`. The scan is non-overlapping and left-to-right, the same enumeration `indexOf` and occurrence counting use (in `"aaaa"` the needle `"aa"` is replaced at positions 0 and 2). An empty `repl` deletes; an empty needle reverts with `EmptyNeedle` (it would vacuously match everywhere). In [EVMcrispr](/docs/evml) this is `@str.replace!`.

`toLower(s)` and `toUpper(s)` fold ASCII letters and pass every other byte through verbatim. Multi-byte UTF-8 units have the high bit set, so they are untouched: the folds are ASCII-only and UTF-8 safe (`@str.lower!` / `@str.upper!`). A case-insensitive comparison is a two-node recipe: `toLower` both sides, then `eq` on their hashes.

`charset(s, mask)` returns true when every byte of `s` is a member of the 256-bit character class `mask` (bit `i` set means byte value `i` is allowed), the native single-call form of the `foldBytes(bitSet, All)` recipe. The empty string is vacuously in every set, and the check is byte-level, so multi-byte UTF-8 characters fail any ASCII-only class. EVMcrispr's `@str.charset!` builds the mask from a class spec (`a-z0-9-`) at composition time and compiles to this call; see the [fold recipes](/docs/operators/fold#recipes) for the general per-byte-predicate form.

`split(s, delimiter)` returns every segment as a `bytes[]`, including empty leading, trailing and consecutive segments; matches are non-overlapping, and an empty delimiter reverts with `EmptyNeedle`. Where a single segment is all that is needed, the `indexOf`/`slice` pair above is cheaper and is what the compiler emits.

`stringSlice(s, start, end)` and `stringAt(s, index)` are the UTF-8-aware siblings of `sliceRange` and `byteAt`. Both validate the whole input as UTF-8 first and revert with `InvalidUtf8(position)` at the first malformed byte. `stringSlice` takes the same clamped signed byte range as `sliceRange` and additionally rejects a nonempty range whose start or end falls inside a multibyte code point (`InvalidUtf8` at that boundary); an empty range returns empty bytes. `stringAt` returns the single byte at a strict signed index (`InvalidByteIndex` outside the data) and rejects a byte that belongs to a multibyte code point. Both return bytes values that transport as `string`.

## Parse: parseUint and toString

`parseUint(s)` is the bridge from string returns into arithmetic: it decodes a decimal ASCII string as a uint256, so a split version segment composes straight into a numeric comparison (`gt(parseUint(segment), 2)`). It is strict by design: empty input reverts with `EmptyNumber`, any byte outside `0-9` with `InvalidDecimalDigit` (no signs, no whitespace, no decimal points), and a value past `2^256 - 1` with the checked-arithmetic panic. Leading zeros are accepted (`"007"` is 7). `toString(v)` is its inverse, the decimal rendering with no leading zeros, so `toString(parseUint(s))` normalizes. In [EVMcrispr](/docs/evml), a live string operand inside `@calc!` arithmetic coerces through `parseUint` automatically.

`parseInt(s)` accepts an optional `+` or `-` followed by at least one decimal digit, including the full signed minimum; `toString(int256)` formats signed integers without leading zeros and with a minus sign when negative.

`parseUnits(value, decimals, rounding)` returns an `int256`; `parseUnitsUnsigned` returns a `uint256`. `decimals` runs from 0 to 77 (`InvalidPrecision` above). Inputs accept one optional sign and one decimal point, require at least one digit, and reject whitespace, exponent notation, separators and additional points. The unsigned variant rejects a minus sign, including negative zero. Fractional digits past `decimals` are rounded with `Trunc` (0), `Floor` (1) or `Ceil` (2), with range validation after rounding. `formatUnits` has signed and unsigned overloads, trims trailing fractional zeros and omits the point for integral values.

## Calldata layout for multi-argument calls

`read` appends each segment's full resolved bytes in order, so functions taking a dynamic argument *plus* other arguments need the encoder to lay out heads and tails, exactly as ABI encoding requires. `RAW_BYTES` segments carry the head words (offsets, static arguments) and any pre-encoded tails; a live envelope splices as a tail, with one trick: its leading `0x20` word rides along as dead calldata bytes, and the head offset points one word past it. `slice(liveData, start, len)` built by hand:

```text
selector
0x00: 0x80          <- RAW head word: offset of data's [length][payload]
0x20: start         <- RAW head word
0x40: len           <- RAW head word
0x60: [0x20][length][payload...]   <- the live envelope; its length word sits at 0x80
```

Four segments: three literal words and the operand. Hand-writing this is rare; [EVMcrispr](/docs/evml) compiles `@str.split!`/`@str.includes!`/`@str.charset!` to these layouts, and single-dynamic-argument calls (`hash`, `byteLen`) need none of it.

## encode: runtime abi.encode

`encode(types, values)` assembles the canonical ABI encoding of a tuple from pre-encoded component values: `nav`'s inverse. `types` is the tuple's type as a parenthesized descriptor (`"(address,uint256[])"`, the same grammar as `nav`, only the SHAPE is parsed), and `values[i]` is the canonical single-value encoding of component `i`:

- a **static** component with a head footprint of `w` words: exactly `w * 32` bytes (one word for `uint256`/`address`/`bool`/`bytes32`, the flattened words for static tuples and fixed arrays), copied verbatim into the head;
- a **dynamic** component (`bytes`, `string`, `T[]`, dynamic tuples): the canonical envelope `[0x20][tail...]`, exactly what a bytes-returning call, `nav`'s dynamic terminal, or `abi.encode` of the single value produces. The leading offset word is stripped, the true top-level offset written into the head, and the tail appended verbatim. ABI offsets are frame-relative, so verbatim tail splicing is correct at any nesting depth: nested dynamics (`string[]`, `(uint256,bytes)[]`) need no special handling.

The output comes back via a raw assembly return with NO bytes envelope, deliberately the one raw-returning function in the contract: its output is a calldata SEGMENT for the core's `read` to splice, not a value to decode. That is its role in composition: resolve pieces live (a `nav` selection here, a `pick` word there), `encode` them into one multi-value span, and splice that span into a constructed call's arguments. `encodeBytes(types, values)` returns the same tuple payload inside a normal bytes envelope, for consumers that want a value rather than a segment.

Both use the shared `AbiCodec` to validate complete canonical encodings: nested offsets, lengths, bounds, zero padding, and the absence of trailing data. Scalar semantics, such as narrow-integer ranges, remain the caller's claim. Failure modes: a malformed descriptor reverts with `InvalidTypeDescriptor`, a `values` array whose length differs from the component count with `ComponentCountMismatch`, a static component of the wrong size with `InvalidComponentLength`, a dynamic component that is not an envelope with `InvalidComponentEnvelope`, and a malformed nested value with `InvalidComponentValue(componentIndex, byteOffset)`.

Packed encoding (Solidity's `abi.encodePacked`) needs no runtime encoder at all: it is pure composition over `concat` and `slice`. Full-width words (`uint256`/`int256`/`bytes32`) and dynamic payloads go straight into `concat`'s parts (a compiler synthesizes the constant envelopes around spliced words), and each narrowed part costs one `slice` over its word-as-bytes value: `address` is `slice(w, 12, 20)`, `bool`/`uintN` is `slice(w, 32 - N/8, N/8)`, `bytesN` is `slice(w, 0, N)`. So `hash(concat(...))` over sliced parts reproduces a Solidity `keccak256(abi.encodePacked(...))` commitment over live operands; EVMcrispr's `@abi.encodePacked!` compiles to exactly that.

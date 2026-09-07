---
title: Error reference
description: Every custom error the four contracts and their shared libraries can revert with.
---

Every contract uses typed custom errors for gas-efficient and informative failure messages. They are filed under the source that declares them: the shared ERC-8211 vocabulary, the shared `AbiCodec` library, and then `Assertions`, `Operations`, `Collections` and `Expressions`.

## Shared ERC-8211 errors

Defined once in `ERC8211.sol`, the standard's shared vocabulary, thrown by the core's judge and primitives (decoders treat them uniformly):

| Error | Description |
|-------|-------------|
| `ConstraintFailed(string, uint256, uint256, uint256, ConstraintType, bytes32, bytes)` | **THE assertion failure**: a resolved value violated an inline constraint. Arguments: the assertion message (`""` on expression operands), entry index, parameter index (the operand's position in a primitive: a `read` or `readArgs` target is 0 and args follow at index + 1; `cond`'s condition/then/else are 0/1/2; `orElse`'s fallback is 1), constraint index, the constraint kind, the actual word as compared, and the reference data echoed as given |
| `CallFailed(address, bytes)` | a staticcall fetcher, chain hop, constructed call or expression operand reverted or targets a code-less address (identifies the exact failing call) |
| `ReturnDataOutOfBounds(int256, uint256)` | resolved data is too short for the requested read: an operand returned fewer than 32 bytes, data doesn't match a declared shape, or a raw word index (possibly negative) lies outside the data |
| `InvalidAddressWord(uint256, bytes32)` | a word that must hold an address has dirty upper bytes (arguments: position, a parameter or hop index, and the offending word) |
| `InvalidBalanceData(uint256, uint256, uint256)` | a `BALANCE` fetcher's `paramData` is not exactly 40 bytes (two packed addresses) |
| `InvalidConstraintData(uint256, uint256, uint256, uint256)` | a constraint's `referenceData` has the wrong length (32 bytes for EQ/GTE/LTE, 64 for IN) |

## AbiCodec (shared ABI machinery)

`InvalidTypeDescriptor` is declared at file level in `AbiCodec.sol` and the rest inside the library; the core and every periphery contract share its descriptor grammar and canonical-value validation. `ElementIndexOutOfBounds` is declared at file level in `Assertions.sol` for navigation:

| Error | Description |
|-------|-------------|
| `InvalidTypeDescriptor(uint256)` | a type descriptor cannot be parsed: empty or non-tuple, an unknown character where a type was expected, an unterminated array suffix, or trailing garbage (the argument is the byte position where parsing failed) |
| `ElementIndexOutOfBounds(int256, uint256)` | a path or component index is outside the tuple or array it steps into, in either direction for negative array indices (arguments: requested index as given, and the component/element count) |
| `InvalidValue(uint256)` | a canonical value or array encoding is malformed at the given byte offset: `validateValue`, `packArray`/`unpackArray`, every Collections element check, `unzipValues`' pair envelopes, every Expressions node result and the array or tuple terminals `nav` re-encodes go through this validation |
| `ComponentCountMismatch(uint256, uint256)` | a tuple encoder received a `values` array whose length differs from the descriptor's component count (`encode`, `encodeBytes`, the core's `readArgs`, the arguments of an Expressions `Call` or a `Tuple` node) |
| `InvalidComponentLength(uint256, uint256, uint256)` | a static tuple component's value is not exactly its head footprint (arguments: component index, expected bytes, actual bytes) |
| `InvalidComponentEnvelope(uint256, uint256, bytes32)` | a dynamic tuple component's value is not a canonical `[0x20][tail]` envelope (arguments: component index, value length, first word) |
| `InvalidComponentValue(uint256, uint256)` | a nested component value is malformed (component index and byte offset within its single-value encoding) |
| `InvalidCallbackResult(bytes4, uint256, uint256, address)` | a Collections callback returned the wrong shape: a word lambda returned other than 32 bytes, a predicate other than a 0/1 word, a comparator other than one word, or a generic map/fold result that is not canonical for its declared type (arguments: the operation selector, the element indices and the callback target) |

## Assertions (core)

View-mode batch restrictions from the judge, plus the primitives' own errors:

| Error | Description |
|-------|-------------|
| `OutputParamsNotSupported(uint256)` | a batch entry carries output parameters (Storage writes don't exist in view mode) |
| `ValueParamNotSupported(uint256, uint256)` | a batch entry carries a `VALUE` input parameter (no ETH forwarding in view mode) |
| `DuplicateTargetParam(uint256)` | a batch entry carries more than one `TARGET` input parameter |
| `BalanceCannotBeTarget(uint256, uint256)` | a `TARGET` input parameter uses the `BALANCE` fetcher (a balance is not an address) |
| `EmptyCallChain()` | `chain` received an empty `calls` array |
| `InvalidNavigation(uint256)` | a `nav` path step indexes a non-composite value, a multi-word static terminal has no single return, or `LEN`/`PAYLOAD` is applied to a value without a length word or byte payload (descriptor *parse* failures revert with `InvalidTypeDescriptor` instead) |
| `RevertProbeNotACall(uint8)` | `revertData`'s operand is not a `STATIC_CALL` fetcher: a literal or a balance read has no call whose reason could be reported |
| `RevertProbeConstrained(uint256)` | `revertData`'s operand carries constraints; the call itself is the subject, so its value is never validated |
| `DidNotRevert(address, bytes)` | the call `revertData` (or an Expressions `ProbeCall`) probed succeeded; an assertion that a call fails is not satisfied by it working (identifies the offending call) |
| `UnexpectedRevertData(bytes4, bytes4)` | the probed call reverted, but its data does not start with the expected error selector (arguments: expected, actual; a `0x00000000` actual means the revert carried fewer than four bytes, or the target had no code) |

## Operations

| Error | Description |
|-------|-------------|
| `SliceOutOfBounds(uint256, uint256, uint256)` | `slice` bounds fall outside the data (arguments: requested start, requested length, actual data length) |
| `InvalidByteIndex(int256, uint256)` | `byteAt` or `stringAt` received an index outside the data in either direction (arguments: the index as given, the data length) |
| `InvalidUtf8(uint256)` | `stringSlice` or `stringAt` met malformed UTF-8 at the given byte, or a range boundary or index that falls inside a multibyte code point |
| `EmptyNumber()` | `parseUint`, `parseInt` or `parseUnits` received no digits (0 would be a silent wrong answer) |
| `InvalidDecimalDigit(uint256, bytes1)` | a decimal parser met a byte outside `0-9` where a digit was required (arguments: byte position, offending byte); `parseUnitsUnsigned` reports a leading minus sign this way |
| `InvalidPrecision(uint256)` | `parseUnits`, `parseUnitsUnsigned` or `formatUnits` received a `decimals` above 77 |
| `RawCallFailed(address, bytes)` | a `rawCall` staticcall reverted (arguments: the called address and the calldata that was sent) |
| `EmptyNeedle()` | `replace` or `split` received an empty needle or delimiter (it would match everywhere) |
| `ModularInverseDoesNotExist(uint256, uint256)` | a negative `powMod` exponent has no inverse because the base and modulus magnitudes are not coprime (arguments: base magnitude, modulus magnitude) |
| `LogarithmUndefined(int256)` | `log2(0)`, or `lnWad` of zero or a negative value: the logarithm is undefined there (argument: the input, zero for `log2`) |

Arithmetic failures in Operations surface as Solidity panics: overflow/underflow (including `exp`, `mulDiv`, `rpow`, the parsers' accumulators and `type(int256).min / -1`) as `Panic(0x11)`, and division or modulo by zero (including `mulDiv`, `addMod`, `mulMod` and `powMod`) as `Panic(0x12)`. A zero `rpow` base is a zero divisor (`Panic(0x12)`) and an `expWad` result that leaves `int256` an overflow (`Panic(0x11)`); only the logarithms carry a named domain error, `LogarithmUndefined`.

## Collections

| Error | Description |
|-------|-------------|
| `LambdaOffsetOutOfBounds(uint256, uint256)` | a fold, `mapWords` or `filterWords` window offset does not leave room for a 32-byte word inside the template (arguments: the offending offset, the template length) |
| `UnalignedWords(uint256)` | `foldWords` or a word-array function received data that is not a whole number of 32-byte words |
| `WordCountMismatch(uint256, uint256)` | `zipWords` received payloads of different word counts (silent truncation would be a wrong-answer machine) |
| `LengthMismatch(uint256, uint256)` | `zipValues` received arrays of different lengths (silent truncation would be a wrong-answer machine) |
| `InvalidLane(uint256)` | `unzipWords` or `unzipValues` received a lane other than 0 or 1 |
| `InvalidCallback()` | a `Callback` is malformed: `first` (or `second` for binary operations) is not a slot of `constants`, the two slots coincide, `arguments` is not a parenthesized tuple, or `constants` has a different length than the descriptor's component count |
| `InvalidCallbackTarget(address)` | a callback or lambda target has no bytecode; precompiles are excluded |
| `CallbackFailed(bytes4, uint256, uint256, address, bytes, bytes)` | a callback or lambda reverted; carries the operation selector, the element indices, the target, the calldata and the revert data |

A malformed callback result reverts with `AbiCodec.InvalidCallbackResult` (above). An out-of-range `FoldExit` surfaces as `Panic(0x21)`, and `sumWords` overflow as `Panic(0x11)`.

## Expressions

| Error | Description |
|-------|-------------|
| `InvalidNode(uint256)` | a malformed node: the `result` index out of range, the wrong reference count for the node's kind, a `Parameter` whose data is not one word, a `Select` condition shorter than 32 bytes, a target word that is not a clean address |
| `NotSelf(address)` | `evaluateGuarded` was called by anyone other than the Expressions contract itself |
| `InvalidReference(uint256, uint256)` | a node references itself or a later node, or a `Parameter` index is past the supplied parameters |
| `InvalidTarget(uint256, address)` | a `Call`, a `Resolve`, a resolve-once operand or the `evaluateEncoded` self-call targets an address without code |
| `NodeCallFailed(uint256, address, bytes, bytes)` | the staticcall a node or a resolve-once entry point made reverted; carries the node (or operand) index, the target, the calldata and the reason. A different error from the core's two-argument `CallFailed` |

`ProbeCall` reuses the core's `DidNotRevert` and `UnexpectedRevertData`; descriptor and value validation raise the `AbiCodec` errors. See [Expressions](/docs/operators/expressions).

The `includes` and split [recipes](/docs/operators/data#search-indexof) have no dedicated errors: they are total compositions of `indexOf`, `slice` and `byteLen`, and `charset` and `contains` are total as well. The string operations with errors of their own are `replace` and `split` (`EmptyNeedle`), `byteAt` and `stringAt` (`InvalidByteIndex`) and `stringSlice` and `stringAt` (`InvalidUtf8`).

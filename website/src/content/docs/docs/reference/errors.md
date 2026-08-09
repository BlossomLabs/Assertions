---
title: Error reference
description: Every custom error both contracts can revert with.
---

Both contracts use typed custom errors for gas-efficient and informative failure messages.

## Shared ERC-8211 errors

Defined once in `ERC8211.sol`, the standard's shared vocabulary, thrown by the core's judge and primitives (decoders treat them uniformly):

| Error | Description |
|-------|-------------|
| `ConstraintFailed(string, uint256, uint256, uint256, ConstraintType, bytes32, bytes)` | **THE assertion failure**: a resolved value violated an inline constraint. Arguments: the assertion message (`""` on expression operands), entry index, parameter index (the operand's position in a primitive: a `read`'s target is 0 and args follow at index + 1; `cond`'s condition/then/else are 0/1/2; `orElse`'s fallback is 1), constraint index, the constraint kind, the actual word as compared, and the reference data echoed as given |
| `CallFailed(address, bytes)` | a staticcall fetcher, chain hop, constructed call or expression operand reverted or targets a code-less address (identifies the exact failing call) |
| `ReturnDataOutOfBounds(int256, uint256)` | resolved data is too short for the requested read: an operand returned fewer than 32 bytes, data doesn't match a declared shape, or a raw word index (possibly negative) lies outside the data |
| `InvalidAddressWord(uint256, bytes32)` | a word that must hold an address has dirty upper bytes (arguments: position, a parameter or hop index, and the offending word) |
| `InvalidBalanceData(uint256, uint256, uint256)` | a `BALANCE` fetcher's `paramData` is not exactly 40 bytes (two packed addresses) |
| `InvalidConstraintData(uint256, uint256, uint256, uint256)` | a constraint's `referenceData` has the wrong length (32 bytes for EQ/GTE/LTE, 64 for IN) |

## AbiShape (shared descriptor grammar)

Defined in `AbiShape.sol`, the type-descriptor grammar both contracts import: the core raises them from `nav`, Operators from `encode`:

| Error | Description |
|-------|-------------|
| `InvalidTypeDescriptor(uint256)` | a type descriptor cannot be parsed: empty or non-tuple, an unknown character where a type was expected, an unterminated array suffix, or trailing garbage (the argument is the byte position where parsing failed) |
| `ElementIndexOutOfBounds(int256, uint256)` | a path or component index is outside the tuple or array it steps into, in either direction for negative array indices (arguments: requested index as given, and the component/element count) |

## Assertions (core)

View-mode batch restrictions from the judge, plus the primitives' own errors:

| Error | Description |
|-------|-------------|
| `OutputParamsNotSupported(uint256)` | a batch entry carries output parameters (Storage writes don't exist in view mode) |
| `ValueParamNotSupported(uint256, uint256)` | a batch entry carries a `VALUE` input parameter (no ETH forwarding in view mode) |
| `DuplicateTargetParam(uint256)` | a batch entry carries more than one `TARGET` input parameter |
| `BalanceCannotBeTarget(uint256, uint256)` | a `TARGET` input parameter uses the `BALANCE` fetcher (a balance is not an address) |
| `EmptyCallChain()` | `chain` received an empty `calls` array |
| `InvalidNavigation(uint256)` | a `nav` path step indexes a non-composite value, or the terminal cannot be represented as a single return (descriptor *parse* failures revert with `InvalidTypeDescriptor` instead) |

## Operators

| Error | Description |
|-------|-------------|
| `SliceOutOfBounds(uint256, uint256, uint256)` | `slice` bounds fall outside the data (arguments: requested start, requested length, actual data length) |
| `ComponentCountMismatch(uint256, uint256)` | `encode` received a `values` array whose length differs from the descriptor's component count |
| `InvalidComponentLength(uint256, uint256, uint256)` | an `encode` static component's value is not exactly its head footprint (arguments: component index, expected bytes, actual bytes) |
| `InvalidComponentEnvelope(uint256, uint256, bytes32)` | an `encode` dynamic component's value is not a canonical `[0x20][tail]` envelope (arguments: component index, value length, first word) |
| `LambdaOffsetOutOfBounds(uint256, uint256)` | a fold window offset does not leave room for a 32-byte word inside the template |
| `LambdaCallFailed(uint256, address, bytes)` | a fold lambda call reverted, or the lambda target has no code (index 0 with empty calldata for the code check); names the element index, target and constructed calldata |
| `LambdaReturnTooShort(uint256, uint256)` | a fold lambda returned fewer than 32 bytes |
| `UnalignedWords(uint256)` | `foldWords` received data that is not a whole number of 32-byte words |
| `EmptyNumber()` | `parseUint` received empty input (0 would be a silent wrong answer) |
| `InvalidDecimalDigit(uint256, bytes1)` | `parseUint` met a byte outside `0-9` (arguments: byte position, offending byte) |

Arithmetic failures in Operators surface as Solidity panics: overflow/underflow (including `exp`, `mulDiv` and `type(int256).min / -1`) as `Panic(0x11)`, division or modulo by zero (including `mulDiv`, `addMod` and `mulMod`) as `Panic(0x12)`, and an out-of-range `FoldExit` value as `Panic(0x21)`.

There are no dedicated string-op errors: the `Split`/`Includes`/`Charset` [recipes](/docs/operators/fold) are total compositions of `indexOf`, `slice`, `byteLen` and the folds.

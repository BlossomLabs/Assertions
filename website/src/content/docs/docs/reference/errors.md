---
title: Error reference
description: Every custom error both contracts can revert with.
---

Both contracts use typed custom errors for gas-efficient and informative failure messages.

## Shared ERC-8211 errors

Defined once in the shared library, thrown by both the judge and the Combinators (decoders treat them uniformly):

| Error | Description |
|-------|-------------|
| `ConstraintFailed(string, uint256, uint256, uint256, ConstraintType, bytes32, bytes)` | **THE assertion failure**: a resolved value violated an inline constraint. Arguments: the assertion message (`""` on combinator operands), entry index, parameter index, constraint index, the constraint kind, the actual word as compared, and the reference data echoed as given |
| `CallFailed(address, bytes)` | a staticcall fetcher, chain hop or expression operand reverted or targets a code-less address (identifies the exact failing call) |
| `ReturnDataOutOfBounds(int256, uint256)` | resolved data is too short for the requested read: an operand returned fewer than 32 bytes, data doesn't match a declared shape, or a raw word index (possibly negative) lies outside the data |
| `InvalidAddressWord(uint256, bytes32)` | a word that must hold an address has dirty upper bytes (arguments: position — parameter or hop index — and the offending word) |
| `InvalidBalanceData(uint256, uint256, uint256)` | a `BALANCE` fetcher's `paramData` is not exactly 40 bytes (two packed addresses) |
| `InvalidConstraintData(uint256, uint256, uint256, uint256)` | a constraint's `referenceData` has the wrong length (32 bytes for EQ/GTE/LTE, 64 for IN) |

## Assertions (judge)

View-mode batch restrictions:

| Error | Description |
|-------|-------------|
| `OutputParamsNotSupported(uint256)` | a batch entry carries output parameters — Storage writes don't exist in view mode |
| `ValueParamNotSupported(uint256, uint256)` | a batch entry carries a `VALUE` input parameter — no ETH forwarding in view mode |
| `DuplicateTargetParam(uint256)` | a batch entry carries more than one `TARGET` input parameter |
| `BalanceCannotBeTarget(uint256, uint256)` | a `TARGET` input parameter uses the `BALANCE` fetcher (a balance is not an address) |

## Combinators

| Error | Description |
|-------|-------------|
| `EmptyCallChain()` | `chain` received an empty `calls` array |
| `ElementIndexOutOfBounds(int256, uint256)` | a `nav` path index is outside the tuple or array it steps into (arguments: requested index as given, possibly negative, and the component/element count) |
| `InvalidNavigation(uint256)` | a `nav` type descriptor is malformed at the given character, a path step indexes a non-composite value, or the terminal is not representable |
| `EmptyDelimiter()` | `data(Split)` received an empty delimiter |
| `SegmentIndexOutOfBounds(int256, uint256)` | `data(Split)` index is outside the split's segments in either direction (arguments: requested index as given, possibly negative, and segment count) |
| `EmptySubstring()` | `data(Includes)` received an empty search string (every string vacuously contains `""`) |
| `InvalidMaskLength(uint256)` | `data(Charset)` received a mask that isn't exactly 32 bytes |

Arithmetic failures in `calc` surface as Solidity panics: overflow/underflow (including `Exp`) as `Panic(0x11)`, division or modulo by zero as `Panic(0x12)`.

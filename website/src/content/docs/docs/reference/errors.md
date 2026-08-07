---
title: Error reference
description: Every custom error both contracts can revert with.
---

Both contracts use typed custom errors for gas-efficient and informative failure messages.

## Assertions (core)

| Error | Description |
|-------|-------------|
| `AssertionFailedUint(string, uint256, uint256)` | uint256 assertion failed |
| `AssertionFailedInt(string, int256, int256)` | int256 assertion failed |
| `AssertionFailedAddress(string, address, address)` | address assertion failed |
| `AssertionFailedBool(string, bool, bool)` | bool assertion failed |
| `AssertionFailedBytes32(string, bytes32, bytes32)` | bytes32 assertion failed |
| `AssertionFailedBytes(string, bytes32, bytes32)` | bytes assertion failed (shows hashes) |
| `AssertionFailedString(string, string, string)` | string assertion failed |
| `AssertionFailedApprox(string, uint256, uint256, uint256, uint256)` | approximate equality failed |
| `AssertionFailedApproxInt(string, int256, int256, uint256, uint256)` | approximate int256 equality failed |
| `CallFailed(address, bytes)` | staticcall to target reverted, or target has no code |
| `ReturnDataOutOfBounds(int256, uint256)` | tuple index points outside the returned data (int256 only to keep the signature identical to Combinators'; core indices are never negative) |

## Combinators

| Error | Description |
|-------|-------------|
| `CallFailed(address, bytes)` | a chain hop or expression operand reverted or targets a code-less address (identifies the exact failing call) |
| `ReturnDataOutOfBounds(int256, uint256)` | an operand or chain hop returned fewer than 32 bytes, data doesn't match a declared shape, or a raw word index (possibly negative) lies outside the returndata |
| `EmptyCallChain()` | `read` / `data` received an empty `calls` array |
| `ArgumentCountMismatch(uint256, uint256, uint256)` | `read`'s `calls`, `retTypes` and `paths` arrays disagree in length |
| `InvalidAddressWord(uint256, bytes32)` | a mid-chain `read` selection is not a clean address word (dirty upper bytes); arguments: hop index and the offending word |
| `EmptyDelimiter()` | `data(Split)` received an empty delimiter |
| `EmptySubstring()` | `data(Includes)` received an empty search string (every string vacuously contains `""`) |
| `InvalidMaskLength(uint256)` | `data(Charset)` received a mask that isn't exactly 32 bytes |
| `ElementIndexOutOfBounds(int256, uint256)` | a typed `read` path index is outside the tuple or array it steps into (arguments: requested index as given, possibly negative, and the component/element count) |
| `InvalidNavigation(uint256)` | a typed `read` descriptor is malformed at the given character, a path step indexes a non-composite value, or the terminal is not representable |
| `SegmentIndexOutOfBounds(int256, uint256)` | `data(Split)` index is outside the split's segments in either direction (arguments: requested index as given, possibly negative, and segment count) |

The two contracts define `CallFailed` and `ReturnDataOutOfBounds` with identical signatures, so decoders treat them uniformly.

Arithmetic failures in `calc` surface as Solidity panics: overflow/underflow (including `Exp`) as `Panic(0x11)`, division or modulo by zero as `Panic(0x12)`.

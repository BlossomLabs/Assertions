---
title: Errors
description: "The errors that more than one of the four contracts raises, with their arguments: the ERC-8211 errors of the judge and the descriptor and value errors of the shared ABI codec."
---

The errors specific to one contract are listed on its own page. These are declared once and raised by more than one contract.

## ERC-8211 errors

Defined once in `ERC8211.sol`, the standard's shared vocabulary, thrown by the core's judge and primitives (decoders treat them uniformly):

| Error | Description |
|-------|-------------|
| `ConstraintFailed(string, uint256, uint256, uint256, ConstraintType, bytes32, bytes)` | **THE assertion failure**: a resolved value violated an inline constraint. Arguments: the assertion message (`""` on expression operands), entry index, parameter index (the operand's position in a primitive: a `read` or `get` target is 0 and args follow at index + 1; `gather` names the operand by its position in the list; `cond`'s condition/then/else are 0/1/2; `orElse`'s fallback is 1), constraint index, the constraint kind, the actual word as compared, and the reference data echoed as given |
| `CallFailed(address, bytes)` | a staticcall fetcher, chain hop, constructed call or expression operand reverted or targets a code-less address (identifies the exact failing call) |
| `ReturnDataOutOfBounds(int256, uint256)` | resolved data is too short for the requested read: an operand returned fewer than 32 bytes, data doesn't match a declared shape, or a raw word index (possibly negative) lies outside the data |
| `InvalidAddressWord(uint256, bytes32)` | a word that must hold an address has dirty upper bytes (arguments: position, a parameter or hop index, and the offending word) |
| `InvalidBalanceData(uint256, uint256, uint256)` | a `BALANCE` fetcher's `paramData` is not exactly 40 bytes (two packed addresses) |
| `InvalidConstraintData(uint256, uint256, uint256, uint256)` | a constraint's `referenceData` has the wrong length (32 bytes for equality/order, 64 for either range, zero for SKIP) |
| `InvalidOrConstraint(uint256, uint256, uint256)` | empty OR or nested OR; identifies entry, operand and outer constraint/word index |
| `InvalidConstraintRange(uint256, uint256, uint256)` | range lower bound exceeds upper bound under its signedness; identifies entry, operand and outer constraint/word index |

Wire bytes that solc's decoder cannot read revert **without data**, exactly as they do in Biconomy's reference: a `STATIC_CALL` fetcher's `paramData` that is not `abi.encode(address, bytes)`, an `OR` constraint's `referenceData` that is not `abi.encode(Constraint[])`, and, on Expressions, a Resolve node's `data`. An `evaluateEncoded` payload is not decoded up front: one shorter than a word reverts without data, and a field that evaluation reads and cannot decode fails inside the self-call, so it arrives as `NodeCallFailed` with an empty reason. The SDK always encodes these correctly; a bare revert or an empty reason here means hand-built calldata.

## ABI descriptor and value errors

`InvalidTypeDescriptor` is declared at file level in `AbiCodec.sol` and the rest inside the library; all four contracts share its descriptor grammar and canonical-value validation. `ElementIndexOutOfBounds` is declared at file level in `Assertions.sol` for navigation:

Descriptor and value diagnostics assume sufficient gas, stack and memory. Very
large or deeply nested inputs can exhaust those resources; checked descriptor
and cursor arithmetic can also raise `Panic(0x11)`.

| Error | Description |
|-------|-------------|
| `InvalidTypeDescriptor(uint256)` | a type descriptor cannot be parsed: empty, non-tuple where a tuple is required, an unknown character where a type was expected, an unterminated array suffix, a fixed length of 0 or above 2^32 − 1 (or a static fixed-array footprint above 2^32 − 1 words), or trailing garbage (the argument is the byte position where parsing failed) |
| `ElementIndexOutOfBounds(int256, uint256)` | a path or component index is outside the tuple or array it steps into, in either direction for negative array indices (arguments: requested index as given, and the component/element count) |
| `InvalidValue(uint256)` | a canonical value or array encoding is malformed at the given byte offset: `packArray`/`unpackArray`, every Collections element check, `unzipValues`' pair envelopes, every Expressions node result and the array or tuple terminals `nav` re-encodes go through this validation; trailing data is reported at its first byte |
| `ComponentCountMismatch(uint256, uint256)` | a tuple encoder received a `values` array whose length differs from the descriptor's component count (`encode`, `encodeBytes`, the core's `get`, the arguments of an Expressions `Call` or a `Tuple` node) |
| `InvalidComponentLength(uint256, uint256, uint256)` | a static tuple component's value is not exactly its head footprint (arguments: component index, expected bytes, actual bytes) |
| `InvalidComponentEnvelope(uint256, uint256, bytes32)` | a dynamic tuple component's value is not a canonical `[0x20][tail]` envelope (arguments: component index, value length, first word) |
| `InvalidComponentValue(uint256, uint256)` | a nested component value is malformed (component index and byte offset within its single-value encoding); trailing data is reported at its first byte |
| `InvalidCallbackResult(bytes4, uint256, uint256, address)` | a Collections callback returned the wrong shape: a word lambda returned other than 32 bytes, a predicate other than a 0/1 word, a comparator other than one word, or a generic map/fold result that is not canonical for its declared type (arguments: the operation selector, the element indices and the callback target) |

## Errors of one contract

- [Assertions](/docs/contracts/assertions#failure-modes-and-limits)
- [Operations](/docs/contracts/operations#failure-modes-and-limits)
- [Collections](/docs/contracts/collections#failure-modes-and-limits)
- [Expressions](/docs/contracts/expressions#failure-modes-and-limits)

To work out why an assertion of yours failed, start with [Troubleshooting](/docs/troubleshooting).

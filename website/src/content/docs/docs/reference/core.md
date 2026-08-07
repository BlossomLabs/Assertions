---
title: Core reference
description: Every assertion function on the frozen Assertions core, by family.
---

All assertion functions live on the frozen core at `0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0` and have overloaded versions accepting a custom `string` message as the last parameter. The composition functions live on the separate [Combinators contract](/docs/combinators).

## Uint256 assertions

| Function | Description |
|----------|-------------|
| `assertEqCallUint` | Assert return equals expected |
| `assertNeCallUint` | Assert return not equals expected |
| `assertGtCallUint` | Assert return > expected |
| `assertLtCallUint` | Assert return < expected |
| `assertGeCallUint` | Assert return >= expected |
| `assertLeCallUint` | Assert return <= expected |
| `assertApproxEqCallUint` | Assert return ≈ expected (within delta) |

## Int256 assertions

| Function | Description |
|----------|-------------|
| `assertEqCallInt` | Assert return equals expected |
| `assertNeCallInt` | Assert return not equals expected |
| `assertGtCallInt` | Assert return > expected |
| `assertLtCallInt` | Assert return < expected |
| `assertGeCallInt` | Assert return >= expected |
| `assertLeCallInt` | Assert return <= expected |
| `assertApproxEqCallInt` | Assert return ≈ expected (within delta) |

## Address assertions

| Function | Description |
|----------|-------------|
| `assertEqCallAddress` | Assert return equals expected address |
| `assertNeCallAddress` | Assert return not equals expected address |

## Bool assertions

| Function | Description |
|----------|-------------|
| `assertEqCallBool` | Assert return equals expected bool |
| `assertTrue` | Assert return is true |
| `assertFalse` | Assert return is false |

There is no `assertNeCallBool`: on a two-valued type, "not equal to true" is `assertFalse`.

## Bytes32 assertions

| Function | Description |
|----------|-------------|
| `assertEqCallBytes32` | Assert return equals expected bytes32 |
| `assertNeCallBytes32` | Assert return not equals expected bytes32 |

## Raw bytes assertions

| Function | Description |
|----------|-------------|
| `assertEqCallBytes` | Assert raw returndata equals expected bytes |
| `assertNeCallBytes` | Assert raw returndata not equals expected bytes |

## Tuple-indexed assertions (N suffix)

All basic assertion types have tuple-indexed variants with an `N` suffix that accept an additional `index` parameter:

- `assertEqCallUintN`, `assertNeCallUintN`, `assertGtCallUintN`, `assertLtCallUintN`, `assertGeCallUintN`, `assertLeCallUintN`
- `assertEqCallIntN`, `assertNeCallIntN`, `assertGtCallIntN`, `assertLtCallIntN`, `assertGeCallIntN`, `assertLeCallIntN`
- `assertEqCallAddressN`, `assertNeCallAddressN`
- `assertEqCallBoolN`
- `assertEqCallBytes32N`, `assertNeCallBytes32N`
- `assertEqCallStringN`, `assertNeCallStringN`
- `assertApproxEqCallUintN`, `assertApproxEqCallIntN`

An `index` that points past the returned data reverts with `ReturnDataOutOfBounds` instead of silently comparing against zeroed memory. String assertions only exist in the N form; a plain string return is index 0 of its own tuple.

## Array length assertions

| Function | Description |
|----------|-------------|
| `assertEqCallArrayLength` | Assert array length equals expected |
| `assertNeCallArrayLength` | Assert array length not equals expected |
| `assertGtCallArrayLength` | Assert array length > expected |
| `assertGeCallArrayLength` | Assert array length >= expected |
| `assertLtCallArrayLength` | Assert array length < expected |
| `assertLeCallArrayLength` | Assert array length <= expected |

## Balance assertions

| Function | Description |
|----------|-------------|
| `assertEqBalance` | Assert native balance equals expected |
| `assertGtBalance` | Assert native balance > expected |
| `assertLtBalance` | Assert native balance < expected |
| `assertGeBalance` | Assert native balance >= expected |
| `assertLeBalance` | Assert native balance <= expected |
| `assertApproxEqBalance` | Assert native balance ≈ expected |

## Block assertions

| Function | Description |
|----------|-------------|
| `assertEqBlockNumber` | Assert block.number equals expected |
| `assertGtBlockNumber` | Assert block.number > expected |
| `assertLtBlockNumber` | Assert block.number < expected |
| `assertGeBlockNumber` | Assert block.number >= expected |
| `assertLeBlockNumber` | Assert block.number <= expected |
| `assertEqBlockTimestamp` | Assert block.timestamp equals expected |
| `assertGtBlockTimestamp` | Assert block.timestamp > expected |
| `assertLtBlockTimestamp` | Assert block.timestamp < expected |
| `assertGeBlockTimestamp` | Assert block.timestamp >= expected |
| `assertLeBlockTimestamp` | Assert block.timestamp <= expected |

## Chain & contract assertions

| Function | Description |
|----------|-------------|
| `assertEqChainId` | Assert chain ID equals expected |
| `assertHasCode` | Assert address has deployed code |
| `assertNoCode` | Assert address has no code |
| `assertEqCodeHash` | Assert address has specific code hash |

## Combinators (separate contract)

These live at the Combinators address (`0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC`), not on the core. See [Combinators](/docs/combinators) for usage.

| Function | Description |
|----------|-------------|
| `read` | THE read primitive: resolve a chain of staticcalls with per-hop typed navigation (`retTypes`/`paths`) and return the final selection raw. Passthrough (empty path), raw word extraction (`""` type + word index), typed navigation into tuples/arrays (declared return tuple + index path, negative array indices from the end), dynamic terminals as canonical single-value returns, and decoded lengths via the `LEN` sentinel |
| `calc` | Binary word operation over two `(target, data)` operands, one `CalcOp` enum: checked arithmetic (Add…Exp, Min/Max) with `S`-prefixed signed variants, total `AbsDiff`/`SAbsDiff` magnitudes, bitwise And/Or/Xor/Shl/Shr, and 0/1-returning comparisons (Eq…SGe) |
| `unary` | Unary word operation over one operand (`UnaryOp`): Not (bitwise complement), IsZero (logical not), Balance / CodeHash of the address the operand call returns |
| `data` | Raw-returndata operation over a resolved chain (`DataOp`): Split (delimiter + signed segment index), Includes (substring), Charset (32-byte byte-class mask), Hash (keccak256), ByteLen |
| `env` | Constants and environment values as operands (`EnvOp`): Constant echo (ints as two's-complement words), Timestamp, BlockNumber, ChainId, Balance(addr), CodeHash(addr, EXTCODEHASH semantics: `bytes32(0)` if the account doesn't exist) |

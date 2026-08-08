---
title: Core reference
description: The ERC-8211 judge's functions and wire format, and the Combinators surface.
---

The judge lives at `0xA55E4797c1b755183B7Aad07BFd39D3e824621f9`. Every judge function has an overloaded version accepting a custom `string` message as the last parameter, echoed inside `ConstraintFailed` on failure. The composition functions live on the separate [Combinators contract](/docs/combinators).

## Judge functions

| Function | Description |
|----------|-------------|
| `assertParam(InputParam)` | Resolve one input parameter (raw bytes, staticcall, or balance read) and validate its inline constraints — the 90% case, no batch scaffolding |
| `assertComposable(ComposableExecution[])` | Evaluate an ERC-8211 composable batch natively under view semantics: predicate entries resolve and validate their parameters; entries with a `TARGET` parameter construct a call by splicing resolved values into calldata and execute it via `staticcall` (the call must not revert) |
| `assertComposable(address, ComposableExecution[])` | Wrapped mode: `composable.staticcall(executeComposable(executions))` — assert that a deployed ERC-8211 implementation would accept the batch right now (the relayer `eth_call` gate, composable on-chain). Failures surface as `ComposableFailed` with the implementation's revert data |

The native mode consumes the **unmodified ERC-8211 wire format**, so batches built by any ERC-8211 SDK judge here unchanged. Being view-only, it rejects what a view context cannot express: output parameters (Storage writes) revert with `OutputParamsNotSupported`, `VALUE` parameters with `ValueParamNotSupported`, a second `TARGET` parameter with `DuplicateTargetParam`, and a `BALANCE`-fetched target with `BalanceCannotBeTarget`.

## Wire format

```solidity
struct InputParam {
    InputParamType paramType;         // where the value routes in a constructed call
    InputParamFetcherType fetcherType;// how the value is obtained
    bytes paramData;                  // fetcher-specific payload
    Constraint[] constraints;         // inline predicates on the resolved value
}

struct Constraint {
    ConstraintType constraintType;    // EQ | GTE | LTE | IN
    bytes referenceData;              // 32 bytes (EQ/GTE/LTE) or 64 bytes lo,hi (IN)
}

struct ComposableExecution {
    bytes4 functionSig;               // selector of the constructed call
    InputParam[] inputParams;
    OutputParam[] outputParams;       // must be empty in view-mode batches
}
```

### Fetcher types

| Fetcher | `paramData` | Resolves to |
|---------|-------------|-------------|
| `RAW_BYTES` | the value itself | the literal bytes, unchanged |
| `STATIC_CALL` | `abi.encode(target, callData)` | the raw returndata of the staticcall (reverting or code-less targets fail with `CallFailed`) |
| `BALANCE` | `abi.encodePacked(token, account)` (40 bytes) | native balance when `token == address(0)`, else `IERC20(token).balanceOf(account)` |

### Constraint types

Constraints compare the resolved value's first 32-byte word, unsigned:

| Constraint | Meaning |
|------------|---------|
| `EQ` | word equals the 32-byte reference |
| `GTE` | word >= reference |
| `LTE` | word <= reference |
| `IN` | lo <= word <= hi (inclusive; `abi.encode(lo, hi)` as reference) |

Everything richer — `!=`, signed comparisons, string equality, live-vs-live tolerance — is computed by a combinator that returns a 0/1 word or a hash, judged with `EQ`.

## Combinators (separate contract)

These live at the Combinators address (`0xA55EC06e0A82a5ed05bf08c0ff07A45d4BC2eBf8`), not on the judge. Every operand is an `InputParam` (with its own inline constraints), so expressions nest recursively. See [Combinators](/docs/combinators) for usage.

| Function | Description |
|----------|-------------|
| `resolve` | Resolve one operand and return its bytes raw; constraint violations revert with `ConstraintFailed`, turning any expression node into an inline assert |
| `pick` | Select one raw 32-byte word from a resolved operand (signed index, negative from the end) |
| `nav` | Typed navigation: interpret the resolved bytes as a declared return tuple (`retTypes`) and walk an index path through tuples and dynamic arrays — single-word terminals, canonical dynamic envelopes, and decoded lengths via the `LEN` sentinel |
| `chain` | Follow runtime-resolved addresses: each hop staticcalls the address word the previous hop returned |
| `calc` | Binary word operation over two operands, one `CalcOp` enum: checked arithmetic (Add…Exp, Min/Max) with `S`-prefixed signed variants, total `AbsDiff`/`SAbsDiff` magnitudes, bitwise And/Or/Xor/Shl/Shr, and 0/1-returning comparisons (Eq…SGe) |
| `unary` | Unary word operation over one operand (`UnaryOp`): Not (bitwise complement), IsZero (logical not), Balance / CodeHash of the address the operand resolves to |
| `data` | Raw-bytes operation over a resolved operand (`DataOp`): Split (delimiter + signed segment index), Includes (substring), Charset (32-byte byte-class mask), Hash (keccak256), ByteLen |
| `env` | Constants and environment values (`EnvOp`): Constant echo (ints as two's-complement words), Timestamp, BlockNumber, ChainId, Balance(addr), CodeHash(addr, EXTCODEHASH semantics: `bytes32(0)` if the account doesn't exist) |

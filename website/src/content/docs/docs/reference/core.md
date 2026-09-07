---
title: Core reference
description: The ERC-8211 judge's functions and wire format, and the frozen core's nine primitives.
---

The core (judge + primitives) has the same CREATE2 address on every chain; the current address and the retired ones are on the [Deployments](/docs/reference/deployments) page. Every judge function has an overloaded version accepting a custom `string` message as the last parameter, echoed inside `ConstraintFailed` on failure. Computation over resolved values lives on the periphery contracts: [Operations](/docs/operators) for scalars, [Collections](/docs/operators/collections) for iteration and [Expressions](/docs/operators/expressions) for typed expression graphs; their surfaces are documented on those pages.

## Judge functions

| Function | Description |
|----------|-------------|
| `assertParam(InputParam)` | Resolve one input parameter (raw bytes, staticcall, or balance read) and validate its inline constraints (the 90% case, no batch scaffolding) |
| `assertBatch(ComposableExecution[])` | Evaluate an ERC-8211 composable batch under view semantics: predicate entries resolve and validate their parameters; entries with a `TARGET` parameter construct a call by splicing resolved values into calldata and execute it via `staticcall` (the call must not revert) |

The judge consumes the **unmodified ERC-8211 wire format**, so batches built by any ERC-8211 SDK judge here unchanged. Being view, it is also itself an operand: a `STATIC_CALL` parameter encoding an `assertBatch` self-call makes a whole batch probeable with `isValid`, `orElse` and `revertData` ([a batch as an operand](/docs/core/control#a-batch-as-an-operand)). Being view-only, it rejects what a view context cannot express: output parameters (Storage writes) revert with `OutputParamsNotSupported`, `VALUE` parameters with `ValueParamNotSupported`, a second `TARGET` parameter with `DuplicateTargetParam`, and a `BALANCE`-fetched target with `BalanceCannotBeTarget`.

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

| Constraint | Reference data | Meaning |
|------------|----------------|---------|
| `EQ` | 32 bytes | word equals the reference |
| `GTE` | 32 bytes | word >= reference |
| `LTE` | 32 bytes | word <= reference |
| `IN` | `abi.encode(lo, hi)` | lo <= word <= hi, inclusive |

How the word is chosen and what routes elsewhere is described once, under [constraints on the core reads page](/docs/core/reads#constraints).

## Core primitives

The primitives live on the core alongside the judge because they hold operands unresolved (in the ERC-8211 `InputParam` format). Every operand is an `InputParam` with its own inline constraints, so expressions nest recursively; a `STATIC_CALL` operand may target the core itself. See [core reads](/docs/core/reads) and [resolution control](/docs/core/control) for usage.

| Function | Description |
|----------|-------------|
| `resolve` | Resolve one operand and return its bytes raw; constraint violations revert with `ConstraintFailed`, turning any expression node into an inline assert |
| `pick` | Select one raw 32-byte word from a resolved operand (signed index, negative from the end) |
| `nav` | Typed navigation: interpret the resolved bytes as a declared return tuple (`retTypes`) and walk an index path through tuples and dynamic arrays: single-word terminals, canonical dynamic envelopes, decoded lengths via the `LEN` sentinel, and raw string/bytes payloads (typed re-entry into encoded blobs) via the `PAYLOAD` sentinel |
| `chain` | Follow runtime-resolved addresses: each hop staticcalls the address word the previous hop returned |
| `read` | Construct a staticcall at judge time: resolve the target and concatenate the selector with each argument segment's full resolved bytes (ERC-8211 CALL_DATA routing), then return the call's raw returndata; the composition socket that splices operand expressions into plain calldata for Operations, Collections or any other view/pure contract |
| `cond` | Resolve the condition (first word nonzero = true), then resolve and return ONLY the winning branch; the losing branch is never resolved |
| `orElse` | Resolve the attempt behind a self-staticcall boundary; ANY failure (revert, code-less target, violated constraint) selects and resolves the fallback instead |
| `isValid` | 1 when the operand resolves and passes its constraints, else 0; the failure probe, judged `EQ 1` / `EQ 0` or fed to `cond` |
| `revertData` | the revert data of a call that MUST fail; a non-zero expected selector must match and is stripped, leaving the error's arguments word-aligned for `pick`/`nav` |

The two sentinels are public constants: `LEN` is `type(int256).min` and `PAYLOAD` is `type(int256).min + 1`; both are only meaningful as the last entry of a `nav` path.

---
title: Eight functions
description: The Combinators contract's whole surface, its op enums, and how values travel through it.
---

Assertion constraints revert or pass: they judge. Everything that *computes* lives in the separate `Combinators` contract (`0xA55EC06e0A82a5ed05bf08c0ff07A45d4BC2eBf8`). Each function is a composable building block, and every operand is an ERC-8211 `InputParam` — a raw literal, a staticcall, a balance read — so operands may themselves be calls to the Combinators contract (a `nav`, another `calc`, `data`, `env`, …) and expressions nest recursively. The judge consumes the result through a `STATIC_CALL` fetcher pointed at the Combinators address.

Operands carry their own inline constraints, validated as they resolve: any expression node can double as an inline assert. Combinators is versionable: a future version would deploy at a new address without breaking anything that references v2.

The whole surface is eight functions — four resolution/selection primitives and four operators:

```solidity
function resolve(InputParam param) external view;                                  // raw return
function pick   (InputParam param, int256 wordIndex) external view returns (bytes32);
function nav    (InputParam a, string retTypes, int256[] path) external view;      // raw return
function chain  (InputParam start, bytes[] calls) external view;                   // raw return
function calc   (CalcOp op, InputParam a, InputParam b) external view returns (uint256);
function unary  (UnaryOp op, InputParam a) external view returns (uint256);
function data   (DataOp op, InputParam a, bytes arg, int256 index) external view;  // raw return, per-op type
function env    (EnvOp op, uint256 arg) external view returns (uint256);
```

- [`resolve`, `pick`, `nav` and `chain`](/docs/combinators/reads) get values out of contract state: raw passthrough, word selection, typed navigation into tuples and dynamic arrays, and runtime-address call chains.
- [`calc` and `unary`](/docs/combinators/calc) apply word operations over live operands; `env` supplies constants and environment values as operands.
- [`data`](/docs/combinators/data) operates on the raw bytes of a resolved operand: splitting, substring and charset checks, hashing and byte length.

## Op enums

The numeric encodings encoders put in calldata:

| Enum | Values |
|------|--------|
| `CalcOp` | `Add = 0`, `SAdd = 1`, `Sub = 2`, `SSub = 3`, `Mul = 4`, `SMul = 5`, `Div = 6`, `SDiv = 7`, `Mod = 8`, `SMod = 9`, `Exp = 10`, `Min = 11`, `SMin = 12`, `Max = 13`, `SMax = 14`, `AbsDiff = 15`, `SAbsDiff = 16`, `And = 17`, `Or = 18`, `Xor = 19`, `Shl = 20`, `Shr = 21`, `Eq = 22`, `Ne = 23`, `Lt = 24`, `SLt = 25`, `Gt = 26`, `SGt = 27`, `Le = 28`, `SLe = 29`, `Ge = 30`, `SGe = 31` |
| `UnaryOp` | `Not = 0` (bitwise complement), `IsZero = 1` (logical not), `Balance = 2`, `CodeHash = 3` (of the address the operand resolves to) |
| `DataOp` | `Split = 0`, `Includes = 1`, `Charset = 2`, `Hash = 3`, `ByteLen = 4` |
| `EnvOp` | `Constant = 0`, `Timestamp = 1`, `BlockNumber = 2`, `ChainId = 3`, `Balance = 4`, `CodeHash = 5` |

## Words and signedness

Every word (uint, int as two's complement, bool as 0/1, address, bytes32) travels through `calc`/`unary`/`env` as a raw `uint256`; the *opcode* carries the signedness. `S`-prefixed calc ops are the signed variants with checked Solidity semantics; comparisons return 0/1 words. There is no `SExp` (Solidity defines `**` for unsigned operands only).

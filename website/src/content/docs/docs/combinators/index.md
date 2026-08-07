---
title: Five functions
description: The Combinators contract's whole surface, its op enums, and how values travel through it.
---

Assertion functions revert or pass: they judge. Everything that *computes* lives in the separate `Combinators` contract (`0xA55Ec0AA973C18Cb7D7874d4c52B663FFFf6b1dC`). Each function is a composable building block, and nested `(target, data)` operands in calldata compose the blocks into arbitrary expressions. The core consumes the result by pointing any call assertion at the Combinators address.

The core is frozen forever; Combinators is versionable. A future `Combinators` v2 would deploy at a new address without touching the core or breaking anything that references v1.

The whole surface is five functions, one read primitive and four operators:

```solidity
function read (address target, bytes[] calls, string[] retTypes, int256[][] paths) external view;  // raw return
function calc (CalcOp op, address target1, bytes data1, address target2, bytes data2) external view returns (uint256);
function unary(UnaryOp op, address target, bytes callData) external view returns (uint256);
function data (DataOp op, address target, bytes[] calls, bytes arg, int256 index) external view;   // raw return, per-op type
function env  (EnvOp op, uint256 arg) external view returns (uint256);
```

- [`read`](/docs/combinators/read) resolves navigated staticcall chains: raw passthrough, word extraction, typed navigation into tuples and arrays, and decoded lengths, all in one primitive.
- [`calc` and `unary`](/docs/combinators/calc) apply word operations over live operands; `env` supplies constants and environment values as operands.
- [`data`](/docs/combinators/data) operates on the raw returndata of a resolved chain: splitting, substring and charset checks, hashing and byte length.

## Op enums

The numeric encodings encoders put in calldata:

| Enum | Values |
|------|--------|
| `CalcOp` | `Add = 0`, `SAdd = 1`, `Sub = 2`, `SSub = 3`, `Mul = 4`, `SMul = 5`, `Div = 6`, `SDiv = 7`, `Mod = 8`, `SMod = 9`, `Exp = 10`, `Min = 11`, `SMin = 12`, `Max = 13`, `SMax = 14`, `AbsDiff = 15`, `SAbsDiff = 16`, `And = 17`, `Or = 18`, `Xor = 19`, `Shl = 20`, `Shr = 21`, `Eq = 22`, `Ne = 23`, `Lt = 24`, `SLt = 25`, `Gt = 26`, `SGt = 27`, `Le = 28`, `SLe = 29`, `Ge = 30`, `SGe = 31` |
| `UnaryOp` | `Not = 0` (bitwise complement), `IsZero = 1` (logical not), `Balance = 2`, `CodeHash = 3` (of the address the operand call returns) |
| `DataOp` | `Split = 0`, `Includes = 1`, `Charset = 2`, `Hash = 3`, `ByteLen = 4` |
| `EnvOp` | `Constant = 0`, `Timestamp = 1`, `BlockNumber = 2`, `ChainId = 3`, `Balance = 4`, `CodeHash = 5` |

## Words and signedness

Every word (uint, int as two's complement, bool as 0/1, address, bytes32) travels through `calc`/`unary`/`env` as a raw `uint256`; the *opcode* carries the signedness. `S`-prefixed calc ops are the signed variants with checked Solidity semantics; comparisons return 0/1 words. There is no `SExp` (Solidity defines `**` for unsigned operands only).

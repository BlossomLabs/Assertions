---
title: The Operators vocabulary
description: The plain-ABI operator contract, its whole surface, and how the core's read splices live operands into it.
---

Assertion constraints revert or pass: they judge. Everything that *computes* lives in the separate `Operators` contract (v1.0, currently at the interim address `0x8913104652CC0C15A94CEB07Dd3187a0fa4C8F4F`; see [Deployments](/docs/reference/deployments)). Every function takes and returns plain ABI types: there is not one ERC-8211 import in the contract. The tagline of the two-contract split: **the core reads and judges; Operators compute.**

Composition happens in the core. Its [`read` primitive](/docs/core/reads) resolves `InputParam` operand expressions and splices the resolved values into plain calldata, so an operator call IS the composed expression: `ge(token.balanceOf(treasury), 100e18)` with a live first argument is one `read` whose segments are the balance call and the literal. Any deployed view or pure contract extends the vocabulary through the same socket; Operators is just the canonical first extension. And because it is plain periphery, it stays versionable: old deployments never break, new versions ship at new addresses as pure opt-ins, without touching the frozen core.

Why named functions instead of the old op-code enums: decoded calldata reads on explorers. `ge(balance, 100e18)` needs no docs open.

## The surface

| Group | Functions |
|-------|-----------|
| [Arithmetic](/docs/operators/words) | `add`, `sub`, `mul`, `div`, `mod`, `min`, `max` (uint256 + int256 overloads), `exp` (uint only), `absDiff` (uint + int operands, uint256 magnitude, total), `mulDiv`/`mulDivUp` (512-bit mul-then-div), `addMod`/`mulMod` (512-bit EVM builtins), `sqrt` (floor) |
| [Comparisons](/docs/operators/words) | `eq`, `ne` (bit-level, uint), `lt`, `gt`, `le`, `ge` (uint256 + int256 overloads); all return `bool` |
| [Bitwise](/docs/operators/words) | `bitAnd`, `bitOr`, `bitXor`, `shl`, `shr` (uint, plus an int256 overload: arithmetic shift, EVM SAR), `bitSet(mask, index)` |
| [Environment](/docs/operators/words) | `balance(address)`, `codehash(address)`, `timestamp()`, `blockNumber()`, `chainId()`, `baseFee()`, `prevRandao()`, `coinbase()`, `gasLimit()`, `blobBaseFee()`, `blockHash(n)`, `origin()` |
| [Bytes](/docs/operators/data) | `concat(bytes[])`, `slice(bytes, start, len)`, `byteLen(bytes)`, `hash(bytes)` |
| [Search](/docs/operators/data) | `indexOf(bytes, bytes, int256 occurrence)` (signed occurrence ordinal: 0, 1, ... from the start, -1, -2, ... from the end), `matchAt(bytes, bytes, pos)` |
| [Parse](/docs/operators/data) | `parseUint(bytes)` (decimal string to uint256), `toString(uint256)` (its inverse) |
| [Encode](/docs/operators/data) | `encode(string types, bytes[] values)` (runtime `abi.encode`, `nav`'s inverse) |
| [Folds](/docs/operators/fold) | `foldRange`, `foldBytes`, `foldWords`, with `FoldExit` `Full`/`Any`/`All` |

## Signedness rides on overloads

Word operations ship in pairs: `add(uint256,uint256)` next to `add(int256,int256)`, and so on. The int256 overloads carry signed semantics (ordering, truncation, sign display in decoders), and since `int256` spans the full word, raw spliced words pass through unchanged; pick the overload, not a cast. One consequence for Solidity encoders: `abi.encodeCall` cannot disambiguate overloads, so overloaded operators take explicit selectors:

```solidity
bytes4 constant ADD_U = bytes4(keccak256("add(uint256,uint256)"));
bytes4 constant GE_U  = bytes4(keccak256("ge(uint256,uint256)"));
bytes4 constant GT_S  = bytes4(keccak256("gt(int256,int256)"));
```

Non-overloaded functions (`exp`, the bitwise ops, the environment reads, the bytes/search/parse/encode/fold family) work with plain `Operators.exp.selector`. The one asymmetric pair is `shr`: its signed overload takes `(int256, uint256)` (the shift amount stays unsigned), so its explicit selector is `shr(int256,uint256)`.

## The composition model

Three helpers cover the pattern (reusing `callParam`/`noConstraints`/`eq` from [the Solidity guide](/docs/solidity)):

```solidity
/// A literal word operand.
function lit(uint256 x) pure returns (InputParam memory) {
    return InputParam(
        InputParamType.CALL_DATA,
        InputParamFetcherType.RAW_BYTES,
        abi.encode(x),
        new Constraint[](0)
    );
}

/// Core `read` calldata splicing two operands into a binary Operators call.
function read2(address operators, bytes4 sel, InputParam memory a, InputParam memory b)
    pure returns (bytes memory)
{
    InputParam[] memory args = new InputParam[](2);
    args[0] = a;
    args[1] = b;
    return abi.encodeCall(Assertions.read, (lit(uint256(uint160(operators))), sel, args));
}

/// Same, for unary operators.
function read1(address operators, bytes4 sel, InputParam memory a)
    pure returns (bytes memory)
{
    InputParam[] memory args = new InputParam[](1);
    args[0] = a;
    return abi.encodeCall(Assertions.read, (lit(uint256(uint160(operators))), sel, args));
}
```

"The treasury holds at least 100 whole tokens" is then one judged parameter: the fetcher points a `STATIC_CALL` at the core with the `read` calldata, and the constraint judges the comparison's 0/1 word:

```solidity
bytes memory holds = read2(operators, GE_U,
    callParam(token, abi.encodeCall(IERC20.balanceOf, (treasury)), noConstraints()),
    lit(100e18)
);
assertions.assertParam(callParam(address(assertions), holds, eq(bytes32(uint256(1)))));
```

Operands are still full `InputParam`s, so they nest (an operand may be another `read`, a `pick`, a `nav`, a `cond`) and they carry inline constraints, validated as they resolve. Operators functions take plain values, and the core's `read` is the one place operand expressions get resolved and spliced.

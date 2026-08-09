---
title: The Operators vocabulary
description: The plain-ABI operator contract, its whole surface, and how the core's read splices live operands into it.
---

Assertion constraints revert or pass: they judge. Everything that *computes* lives in the separate `Operators` contract (v1.0, currently at the interim address `0xaE0a2f9A3065CE8E1Dd6D1007c32D0bCF6e5D4b9`; see [Deployments](/docs/reference/deployments)). Every function takes and returns plain ABI types: there is not one ERC-8211 import in the contract. The tagline of the two-contract split: **the core reads and judges; Operators compute.**

Composition happens in the core. Its [`read` primitive](/docs/core/reads) resolves `InputParam` operand expressions and splices the resolved values into plain calldata, so an operator call IS the composed expression: `ge(token.balanceOf(treasury), 100e18)` with a live first argument is one `read` whose segments are the balance call and the literal. Any deployed view or pure contract extends the vocabulary through the same socket; Operators is just the canonical first extension. And because it is plain periphery, it stays versionable: old deployments never break, new versions ship at new addresses as pure opt-ins, without touching the frozen core.

Why named functions instead of the old op-code enums: decoded calldata reads on explorers. `ge(balance, 100e18)` needs no docs open.

## The surface

| Group | Functions |
|-------|-----------|
| [Arithmetic](/docs/operators/words) | `add`, `sub`, `mul`, `div`, `mod`, `min`, `max` (uint256 + int256 overloads), `exp` (uint only), `absDiff` (uint + int operands, uint256 magnitude, total), `mulDiv`/`mulDivUp` (512-bit mul-then-div), `addMod`/`mulMod` (512-bit EVM builtins), `sqrt` (floor) |
| [Comparisons](/docs/operators/words) | `eq`, `ne` (bit-level, uint), `lt`, `gt`, `le`, `ge` (uint256 + int256 overloads); all return `bool` |
| [Bitwise](/docs/operators/words) | `bitAnd`, `bitOr`, `bitXor`, `shl`, `shr` (uint, plus an int256 overload: arithmetic shift, EVM SAR), `bitSet(mask, index)` |
| [Environment](/docs/operators/words) | `balance(address)`, `codehash(address)`, `timestamp()`, `blockNumber()`, `chainId()`, `baseFee()`, `prevRandao()`, `coinbase()`, `gasLimit()`, `blobBaseFee()`, `blockHash(n)`, `origin()`, `gasPrice()`, `blobHash(uint256)` |
| [Calls](/docs/operators/data) | `rawCall(address, bytes)` (raw staticcall, the precompile reach-through), `code(address)` (full runtime code as bytes) |
| [Bytes](/docs/operators/data) | `concat(bytes[])`, `slice(bytes, start, len)`, `byteLen(bytes)`, `hash(bytes)`, `hashPairSorted(bytes32, bytes32)` (the sorted Merkle node combiner) |
| [Search](/docs/operators/data) | `indexOf(bytes, bytes, int256 occurrence)` (signed occurrence ordinal: 0, 1, ... from the start, -1, -2, ... from the end) |
| [Strings](/docs/operators/data) | `replace(bytes, bytes, bytes)`, `toLower(bytes)`, `toUpper(bytes)` (ASCII-only case folds) |
| [Parse](/docs/operators/data) | `parseUint(bytes)` (decimal string to uint256), `toString(uint256)` (its inverse) |
| [Encode](/docs/operators/data) | `encode(string types, bytes[] values)` (runtime `abi.encode`, `nav`'s inverse) |
| [Folds](/docs/operators/fold) | `foldRange`, `foldBytes`, `foldWords`, with `FoldExit` `Full`/`Any`/`All` |
| [Word arrays](/docs/operators/fold) | `mapWords`/`filterWords` (lambda map/filter over a word payload), `iotaWords(n)` (the index generator), `wordIndexOf` (word-count sentinel), `reverseWords`, `zipWords`, `unzipWords`, `sortWords`, `uniqueWords` |

## What earns a slot here

The surface stays small on purpose, and every function passes one of two admission tests. Either the operation is inexpressible at any node count by composing the rest of the vocabulary (loops like `sortWords` or `replace`, opcode exposures like `gasPrice`, variable-length output like `filterWords`), or it is the single-call form of a fold or map lambda whose composed form would multiply the hot loop's external calls.

The second test is the reason `bitSet` and `hashPairSorted` earn slots even though both compose in principle (`bitSet` is `bitAnd(shr(mask, i), 1)`, and once `sortWords` exists `hashPairSorted` is `hash(sortWords([a, b]))`). A fold or map lambda is one staticcall per element; the composed form routes each element through the core's `read` and a nested `read`, so every iteration pays roughly nine times the gas. Measured, per element:

| Recipe | Native lambda | Composed lambda | Extra per element |
|--------|---------------|-----------------|-------------------|
| `bitSet` character-class fold | ~1,650 gas/byte | ~14,700 gas/byte | +13,100 |
| `hashPairSorted` Merkle fold | ~2,350 gas/level | ~13,700 gas/level | +11,400 |

So a 20-byte charset check is ~33k gas native against ~295k composed, and a depth-16 Merkle proof (a 65k-leaf allowlist) is ~38k against ~220k. Two roughly ten-line functions, about 340 bytes of runtime bytecode, buy back on the order of 180k to 260k gas on their loops, and more as inputs grow.

Everything that fails both tests composes and stays out: `join` is `concat` with the delimiter interleaved at composition time, pair hashing (unsorted) is `hash` over an encoder-built two-word payload, and packed encoding is `concat` over `slice`-narrowed words.

## Signedness rides on overloads

Word operations ship in pairs: `add(uint256,uint256)` next to `add(int256,int256)`, and so on. The int256 overloads carry signed semantics (ordering, truncation, sign display in decoders), and since `int256` spans the full word, raw spliced words pass through unchanged; pick the overload, not a cast. One consequence for Solidity encoders: `abi.encodeCall` cannot disambiguate overloads, so overloaded operators take explicit selectors:

```solidity
bytes4 constant ADD_U = bytes4(keccak256("add(uint256,uint256)"));
bytes4 constant GE_U  = bytes4(keccak256("ge(uint256,uint256)"));
bytes4 constant GT_S  = bytes4(keccak256("gt(int256,int256)"));
```

Non-overloaded functions (`exp`, the bitwise ops, the environment reads, the calls, the bytes/string/search/parse/encode/fold family and the word-array ops) work with plain `Operators.exp.selector`. The one asymmetric pair is `shr`: its signed overload takes `(int256, uint256)` (the shift amount stays unsigned), so its explicit selector is `shr(int256,uint256)`.

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

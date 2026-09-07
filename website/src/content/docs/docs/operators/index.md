---
title: The Operations vocabulary
description: The plain-ABI operations contracts, their whole surface, and how the core's read splices live operands into them.
---

Assertion constraints revert or pass: they judge. Plain-value computation lives in the periphery: `Operations` for scalars, `Collections` for iteration and [`Expressions`](/docs/operators/expressions) for typed expression graphs. Every function takes and returns plain ABI types, without ERC-8211 coupling. The core reads and judges; the periphery computes. The contracts' addresses are on the [Deployments](/docs/reference/deployments) page.

Composition happens in the core. Its [`read` primitive](/docs/core/reads) resolves `InputParam` operand expressions and splices the resolved values into plain calldata, so an operation call IS the composed expression: `ge(token.balanceOf(treasury), 100e18)` with a live first argument is one `read` whose segments are the balance call and the literal. Any deployed view or pure contract extends the vocabulary through the same socket; Operations is just the canonical first extension. And because it is plain periphery, it stays versionable: old deployments never break, new versions ship at new addresses as pure opt-ins, without touching the core.

Why named functions instead of op-code enums: decoded calldata reads on explorers. `ge(balance, 100e18)` needs no docs open.

## Operations surface

| Group | Functions |
|-------|-----------|
| [Arithmetic](/docs/operators/words) | `add`, `sub`, `mul`, `div`, `mod`, `min`, `max` (uint256 + int256 overloads), `exp` (uint or int base, uint exponent), `absDiff` (uint + int operands, uint256 magnitude, total), `mulDiv(a, b, denominator, rounding)` (signed/unsigned 512-bit mul-then-div with explicit `Trunc`/`Floor`/`Ceil`), `addMod`/`mulMod` (signed/unsigned full-width remainder), `powMod` (modular powers and inverses, four overloads), `sqrt` (floor), `log2` (floor, reverts on 0) |
| [Fixed point](/docs/operators/words#fixed-point-rpow-expwad-and-lnwad) | `rpow(x, n, base)` (compounding, `base` is one unit: 1e27 ray or 1e18 wad), `expWad(int256)` and `lnWad(int256)` (e^x and ln x in 1e18 fixed point) |
| [Comparisons](/docs/operators/words) | `eq`, `ne` (bit-level, uint), `lt`, `gt`, `le`, `ge` (uint256 + int256 overloads); all return `bool` |
| [Bitwise](/docs/operators/words) | `bitAnd`, `bitOr`, `bitXor`, `shl`, `shr` (uint, plus an int256 overload: arithmetic shift, EVM SAR), `bitSet(mask, index)` |
| [Environment](/docs/operators/words#environment-reads) | `balance(address)`, `codeHash(address)`, `timestamp()`, `blockNumber()`, `chainId()`, `baseFee()`, `prevRandao()`, `coinbase()`, `gasLimit()`, `blobBaseFee()`, `blockHash(n)`, `origin()`, `gasPrice()`, `blobHash(uint256)` |
| [Calls](/docs/operators/data) | `rawCall(address, bytes)` (raw staticcall, the precompile reach-through), `code(address)` (full runtime code as bytes) |
| [Bytes](/docs/operators/data) | `concat(bytes[], bytes delimiter)`, `slice(bytes, start, len)`, `sliceRange(bytes, int256 start, int256 end)` (clamped signed range), `byteAt(bytes, int256)`, `byteLen(bytes)`, `hash(bytes)`, `hashPairSorted(bytes32, bytes32)` (the sorted Merkle node combiner) |
| [Search](/docs/operators/data) | `indexOf(bytes, bytes, int256 occurrence)` (signed occurrence ordinal: 0, 1, ... from the start, -1, -2, ... from the end), `contains(bytes, bytes)` |
| [Strings](/docs/operators/data) | `split(bytes, bytes)`, `replace(bytes, bytes, bytes)`, `toLower(bytes)`, `toUpper(bytes)` (ASCII-only case folds), `charset(bytes, uint256)` (every byte in a 256-bit class, native), `stringSlice(bytes, int256, int256)` and `stringAt(bytes, int256)` (UTF-8 aware) |
| [Parse](/docs/operators/data) | `parseUint`/`parseInt`, signed/unsigned `toString`, `parseUnits`/`parseUnitsUnsigned`, signed/unsigned `formatUnits` |
| [Encode](/docs/operators/data) | `encode` (raw runtime `abi.encode`) and `encodeBytes` (bytes envelope) |

## Collections surface

`Collections` owns iteration and array processing; `Operations` supplies the scalar functions its lambdas call.

| Group | Functions |
|---|---|
| [Folds](/docs/operators/fold) | `foldRange`, `foldBytes`, `foldWords`, with `FoldExit` `Full`/`Any`/`All` |
| [Word arrays](/docs/operators/fold#word-arrays) | `mapWords`/`filterWords` (lambda map/filter over a word payload), `iotaWords(n)` (the index generator), `wordIndexOf` (word-count sentinel), `reverseWords`, `zipWords`, `unzipWords`, `sortWords`, `uniqueWords(s, ordered)`, `sumWords` (checked sum of a payload, native) |
| [Generic values](/docs/operators/collections) | `mapValues`, `filterValues`, `foldValues`, `sortValues`, `uniqueValues`, `flattenValues`, `reverseValues`, `sliceValues`, `indexOfValues`, `anyValues`, `allValues`, `findValues`, `zipValues`, `unzipValues` over arrays of canonical ABI values, with typed `Callback`s (direct, or through an [expression graph](/docs/operators/expressions)) |
| [Envelope adapters](/docs/operators/collections#value-envelopes) | `packArray`, `unpackArray` |

Both word sorting and generic comparator sorting use stable bottom-up merge sort.

## What earns a slot here

Admission is a demand test: a function earns a slot only when it is not expressible as a few-node recipe at practical cost AND a concrete assertion workload needs it. What passes the first half is hot loops that would otherwise cost one external call per element (`charset`, `sumWords`, the lambda-shaped `bitSet` and `hashPairSorted`) and calldata-exponential compositions (`rpow`, `log2`: a raw operand tree cannot name a subterm, so squaring duplicates its whole operand). Everything else composes and stays out: `join` uses `concat`'s delimiter argument, unsorted pair hashing is `hash` over an encoder-built two-word payload, packed encoding is `concat` over `slice`-narrowed words, and specialist families go to optional contracts. The rule, its measurements (from `contracts/tests/OperationsGas.t.sol`, which move with the compiler) and what it has refused are recorded in the repository's [`AGENTS.md`](https://github.com/blossomlabs/Assertions/blob/master/AGENTS.md).

## Signedness rides on overloads

Word operations ship in pairs: `add(uint256,uint256)` next to `add(int256,int256)`, and so on. The int256 overloads carry signed semantics (ordering, truncation, sign display in decoders), and since `int256` spans the full word, raw spliced words pass through unchanged; pick the overload, not a cast. One consequence for Solidity encoders: `abi.encodeCall` cannot disambiguate overloads, so overloaded operations take explicit selectors, `bytes4(keccak256("add(uint256,uint256)"))` and friends; the constants the examples use are collected once in [the Solidity guide](/docs/solidity#selector-constants).

The overloaded names are `add`, `sub`, `mul`, `div`, `mod`, `exp`, `min`, `max`, `absDiff`, `mulDiv`, `addMod`, `mulMod`, `powMod`, `lt`, `gt`, `le`, `ge`, `shr`, `toString` and `formatUnits`. Everything else (`eq`, `ne`, `sqrt`, `rpow`, `expWad`, `lnWad`, `log2`, the other bitwise ops, the environment reads, the calls, the bytes, search, string, parse and encode families, and the whole of Collections) works with plain member access such as `Operations.bitAnd.selector`. Two pairs are asymmetric: `shr`'s signed overload takes `(int256, uint256)` because the shift amount stays unsigned, and `exp`'s takes `(int256, uint256)` because the exponent does, so their selectors are `shr(int256,uint256)` and `exp(int256,uint256)`.

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

/// Core `read` calldata splicing two operands into a binary Operations call.
function read2(address operations, bytes4 sel, InputParam memory a, InputParam memory b)
    pure returns (bytes memory)
{
    InputParam[] memory args = new InputParam[](2);
    args[0] = a;
    args[1] = b;
    return abi.encodeCall(Assertions.read, (lit(uint256(uint160(operations))), sel, args));
}

/// Same, for unary operations.
function read1(address operations, bytes4 sel, InputParam memory a)
    pure returns (bytes memory)
{
    InputParam[] memory args = new InputParam[](1);
    args[0] = a;
    return abi.encodeCall(Assertions.read, (lit(uint256(uint160(operations))), sel, args));
}
```

"The treasury holds at least 100 whole tokens" is then one judged parameter: the fetcher points a `STATIC_CALL` at the core with the `read` calldata, and the constraint judges the comparison's 0/1 word:

```solidity
bytes memory holds = read2(operations, GE_U,
    callParam(token, abi.encodeCall(IERC20.balanceOf, (treasury)), noConstraints()),
    lit(100e18)
);
assertions.assertParam(callParam(address(assertions), holds, eq(bytes32(uint256(1)))));
```

Operands are still full `InputParam`s, so they nest (an operand may be another `read`, a `pick`, a `nav`, a `cond`) and they carry inline constraints, validated as they resolve. Operations functions take plain values, and the core's `read` is the one place operand expressions get resolved and spliced.

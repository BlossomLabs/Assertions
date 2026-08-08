---
title: "resolve, pick, nav & chain: reads"
description: Getting values out of contract state — passthrough, word selection, typed navigation and runtime-address chains.
---

Every way of getting a value out of contract state goes through four primitives. Each resolves an `InputParam` operand and returns its selection via a raw assembly return — indistinguishable from a contract returning that value directly, so any consumer (a judge fetcher, another combinator's operand) decodes it as if it had called the final target itself.

```solidity
function resolve(InputParam param) external view;                             // raw return
function pick   (InputParam param, int256 wordIndex) external view returns (bytes32);
function nav    (InputParam a, string retTypes, int256[] path) external view; // raw return
function chain  (InputParam start, bytes[] calls) external view;              // raw return
```

- **`resolve`** is THE primitive — the ERC-8211 static call exposed as a combinator: resolve the operand, validate its constraints, return the bytes unchanged. Because a constraint violation reverts with `ConstraintFailed`, any expression node doubles as an inline assert.
- **`pick`** returns one raw 32-byte word of the resolved bytes. `wordIndex` is signed: 0-based from the start, negative from the end (`-1` = last word), resolved against the live data; outside the full words it reverts with `ReturnDataOutOfBounds`. Word positions follow the raw ABI encoding, so dynamic types contribute head offsets, not content — to select *into* tuples and arrays, use `nav`.
- **`nav`** is the typed selector: interpret the resolved bytes as a declared return tuple and walk a path through it, following runtime offsets and lengths that raw word positions cannot express.
- **`chain`** follows runtime-resolved addresses — the thing a `STATIC_CALL` fetcher cannot do, since its target is fixed at encoding time.

## Chained lookups

"The pool's token has the symbol WETH": `start` resolves `pool.token()` to the token address, and the hop calls `symbol()` on it. In practice `start` is a `STATIC_CALL` fetcher (`abi.encode(pool, token())` as `paramData`) and the chain's result feeds the judged parameter:

```solidity
bytes[] memory hops = new bytes[](1);
hops[0] = abi.encodeCall(IERC20.symbol, ());

// judged value: chain(pool.token() -> symbol()) — compare its hash EQ
// keccak256(abi.encode("WETH")) or navigate it with nav("(string)")
abi.encodeCall(Combinators.chain, (
    callParam(pool, abi.encodeCall(IPool.token, ()), noConstraints()),
    hops
));
```

Every hop except the last must return an address as its first word (a dirty-upper-bytes word reverts with `InvalidAddressWord`, identifying the hop); the final hop's returndata passes through raw. In [EVMcrispr](/docs/evml) the same chain is written inline:

```evml
assertions:assert $pool::{token()(address)}::{symbol()(string)} == "WETH"
```

## Typed navigation

Typed navigation is self-describing calldata: `nav(param, "(address[][],address)", [0, 3, 1])` reads as "return value 0, element 3, element 1". The first path step selects a return component; each further step indexes the current tuple or array, and array steps accept negative indices resolved against the live length (`-1` = last). The contract derives every offset-follow and bounds check from the descriptor, parsing only the *shape* (dynamic vs static, head footprints). Struct arrays navigate the same way: `proposals()[1].executed` against `"((address,uint256,bool)[])"` is path `[0, 1, 2]`, EVMcrispr's nested lens `[[_ [_ _ $]]]`. The declared type is the author's claim about the encoder, like an inline ABI: a wrong claim reverts loudly in almost all cases, but a shape-compatible wrong type can read the wrong value.

The terminal may be a single word, or a dynamic value (string/bytes/array of static single-word elements) returned as the canonical `[0x20][length][payload]` envelope; dynamic tuples and arrays of dynamic elements revert with `InvalidNavigation`. An empty path is a byte-for-byte passthrough (`nav` degenerates to `resolve`).

## Raw word extraction

EVMcrispr's single-index lens (`[_ $ _]`, or the end-anchored `[... $]`) compiles to `pick`: `pick(getReservesParam, 1)` returns reserve1 as a word. It is raw-word extraction for static-layout returns, **not** an ABI decoder.

## Nested lengths

EVMcrispr's `@len!`: a path ending in the `LEN` sentinel (`type(int256).min`, exposed as the public constant `LEN`) returns the decoded *length* of the dynamic value the preceding steps navigate to — element count for arrays, byte length for string/bytes. `nav(holdersParam, "(address[])", [0, LEN])` returns the holder count as a word. Because the sentinel composes with navigation, the length of an array *inside* a struct is one call too.

## Failure modes

Failures are descriptive: an operand that reverts or targets a code-less address reverts with `CallFailed(target, data)` identifying the exact failing call, and an operand constraint violation with `ConstraintFailed`. In `nav`, a malformed descriptor, a step into a non-composite or an unrepresentable terminal reverts with `InvalidNavigation`, a path index outside its tuple/array with `ElementIndexOutOfBounds`, and data not matching the declared shape (truncated returndata, out-of-range offsets or word indices) with `ReturnDataOutOfBounds`. In `chain`, an empty `calls` array reverts with `EmptyCallChain`, a mid-chain selection with dirty upper bytes with `InvalidAddressWord`, and a mid-chain hop returning fewer than 32 bytes with `ReturnDataOutOfBounds`. See the [error reference](/docs/reference/errors).

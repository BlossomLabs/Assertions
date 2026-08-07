---
title: "read: chained calls & navigation"
description: The read primitive resolves navigated staticcall chains with per-hop typed selection.
---

`read` is THE read primitive: every way of getting a value out of contract state goes through it. `calls[0]` runs on `target`; for each earlier hop the word its path selects (a clean address word) becomes the next hop's target; the final hop's selection is returned via a raw assembly return. The result is indistinguishable from a contract returning that value directly, so every call assertion (and every combinator consuming a nested `read`) decodes it as if it had called the final target itself.

```solidity
function read(address target, bytes[] calls, string[] retTypes, int256[][] paths) external view;
```

`retTypes` and `paths` are parallel to `calls`, one entry per hop, and each hop is in one of two modes:

- **Raw**: `retTypes[i]` is `""` and `paths[i]` holds at most one signed raw word index into the returndata (negative from the end, `-1` = last word; empty defaults to word 0 mid-chain, and to a byte-for-byte returndata passthrough on the final hop). No decoding: word positions follow the raw ABI encoding, so dynamic types contribute head offsets, not content.
- **Typed**: `retTypes[i]` is the hop's return tuple written as a parenthesized type (structs as parenthesized tuples, e.g. `"((address,uint256)[])"`), and `paths[i]` walks it: the first step selects a return component, each further step indexes the current tuple or array (array steps accept negative indices resolved against the live length). The terminal may be a single word, or a dynamic value (string/bytes/array of static elements) returned as the canonical `[0x20][length][payload]` envelope. A typed path ending in the `LEN` sentinel (`type(int256).min`, exposed as the public constant `LEN`) returns the decoded *length* of the navigated dynamic value instead: element count for arrays, byte length for string/bytes.

## Chained lookups

"The pool's token has the symbol WETH" is a two-hop chain in raw passthrough mode:

```solidity
bytes[] memory hops = new bytes[](2);
hops[0] = abi.encodeCall(IPool.token, ());   // pool.token()   -> address of the token
hops[1] = abi.encodeCall(IERC20.symbol, ()); // token.symbol() -> asserted value
string[] memory retTypes = new string[](2);  // ["", ""]: raw mode throughout
int256[][] memory paths = new int256[][](2); // [[], []]: word 0 mid-chain, passthrough at the end

assertions.assertEqCallStringN(
    address(combinators),                                        // target: the Combinators contract
    abi.encodeCall(Combinators.read, (pool, hops, retTypes, paths)),
    0,                                                           // string returns decode at index 0
    "WETH"
);
```

In [EVMcrispr](/docs/evml) the same chain is written inline:

```evml
assertions:assert $pool::{token()(address)}::{symbol()(string)} == "WETH"
```

## Typed navigation

Typed navigation is self-describing calldata: `read(reg, calls, ["(address[][],address)"], [[0, 3, 1]])` reads as "return value 0, element 3, element 1". The contract derives every offset-follow and bounds check from the descriptor, parsing only the *shape* (dynamic vs static, head footprints, strides). Struct arrays navigate the same way: `proposals()[1].executed` against `"((address,uint256,bool)[])"` is path `[0, 1, 2]`, EVMcrispr's nested lens `[[_ [_ _ $]]]`. The declared type is the author's claim about the encoder, like an inline ABI: a wrong claim reverts loudly in almost all cases, but a shape-compatible wrong type can read the wrong value.

## Raw word extraction

EVMcrispr's single-index lens (`[_ $ _]`, or the end-anchored `[... $]`) is a final hop with `retTypes` `""` and a one-index path: `read(pair, [getReservesCall], [""], [[1]])` returns reserve1 as a word. It is raw-word extraction for static-layout returns, **not** an ABI decoder. To select *into* tuples and arrays, use a typed hop, which decodes as it goes.

## Nested lengths

EVMcrispr's `@len!`: `read(reg, [holdersCall], ["(address[])"], [[0, LEN]])` returns the holder count as a word. Because the sentinel composes with navigation, the length of an array *inside* a struct is one call too.

## Failure modes

Failures are descriptive: a hop that reverts or targets a code-less address makes `read` revert with `CallFailed(target, data)` identifying the exact failing hop; array-length mismatches revert with `ArgumentCountMismatch`, a mid-chain selection with dirty upper bytes with `InvalidAddressWord`, a malformed descriptor or unrepresentable terminal with `InvalidNavigation`, a path index outside its tuple/array with `ElementIndexOutOfBounds`, and data not matching the declared shape (truncated returndata, out-of-range offsets or word indices) with `ReturnDataOutOfBounds`. An empty `calls` array reverts with `EmptyCallChain`. See the [error reference](/docs/reference/errors).

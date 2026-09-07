---
title: "resolve, pick, nav, chain & read: core reads"
description: Getting values out of contract state with the core's selection and call-construction primitives.
---

Every way of getting a value out of contract state goes through seven primitives on the `Assertions` core itself. Each resolves an ERC-8211 `InputParam` operand and returns its selection via a raw assembly return, indistinguishable from a contract returning that value directly, so any consumer (a judge fetcher, another primitive's operand) decodes it as if it had called the final target itself.

They live on the core, not on the other three contracts, because of [the admission test](/docs): every primitive holds operands **unresolved**, in the ERC-8211 `InputParam` format, and decides how (or whether) to resolve them. A `STATIC_CALL` operand may target the core itself, so the primitives nest into arbitrary expressions. Computation over already-resolved values belongs to [Operations](/docs/operators), reached through `read`; the [control primitives](/docs/core/control) (`cond`, `orElse`, `isValid`, `revertData`) decide *whether* operands resolve at all. The EVML spelling of every primitive is on the [EVMcrispr page](/docs/evml).

```solidity
function resolve(InputParam param) external view;                             // raw return
function gather(InputParam[] args) external view returns (bytes[] values);
function pick   (InputParam param, int256 wordIndex) external view returns (bytes32);
function nav    (InputParam a, string retTypes, int256[] path) external view; // raw return
function chain  (InputParam start, bytes[] calls) external view;              // raw return
function read   (InputParam target, bytes4 selector, InputParam[] args) external view; // raw return
function get(InputParam target, bytes4 selector, string argumentTypes, InputParam[] args) external view; // raw return
```

- **`resolve`** is THE primitive: the ERC-8211 static call exposed as a read. Resolve the operand, validate its constraints, return the bytes unchanged. Because a constraint violation reverts with `ConstraintFailed`, any expression node doubles as an inline assert.
- **`gather`** is `resolve` over a list: each operand resolves exactly once and the raw results come back as one `bytes[]`, in order, taken as-is and validated against no type. It is how a `bytes[]` value is assembled from N live operands without an encoder computing array offsets on-chain: the values list of [`Operations.concat`](/docs/operators/data) or `encode`, or a [generic collection](/docs/operators/collections)'s values array. Because an ordinary ABI return of `bytes[]` is that type's canonical single-value encoding, the operand feeds a `bytes[]` position of `get` as one whole argument; the descriptor there does the type check. Constraint violations name the operand by its index.
- **`pick`** returns one raw 32-byte word of the resolved bytes. `wordIndex` is signed: 0-based from the start, negative from the end (`-1` = last word), resolved against the live data; outside the full words it reverts with `ReturnDataOutOfBounds`. Word positions follow the raw ABI encoding, so dynamic types contribute head offsets, not content; to select *into* tuples and arrays, use `nav`.
- **`nav`** is the typed selector: interpret the resolved bytes as a declared return tuple and walk a path through it, following runtime offsets and lengths that raw word positions cannot express.
- **`chain`** follows runtime-resolved addresses, the thing a `STATIC_CALL` fetcher cannot do, since its target is fixed at encoding time.
- **`read`** constructs a call at judge time, the other thing a `STATIC_CALL` fetcher cannot do, since its calldata is also fixed at encoding time: any external view function becomes callable with computed arguments. This makes `read` the composition socket for the whole [Operations](/docs/operators) vocabulary, and the extension point for any other deployed view or pure contract.
- **`get`** is `read` for calls with several dynamic arguments. `read` splices resolved bytes as calldata *segments*, so an encoder that wants two runtime-sized values (two live strings, an array and a string) in one call has to compute the second value's head offset from the first value's length on-chain, re-resolving the first value once per later offset. `get` takes each argument as a whole canonical ABI value (a word, a `[0x20][len][payload]` string envelope, an `abi.encode(T[])` array), resolves every operand exactly once and lays the tuple out in its own frame through the shared `AbiCodec` grammar (`argumentTypes` such as `"(address,string,uint256[])"`). The destination sees the core as `msg.sender`, exactly as with `read`. Measured through `Assertions.resolve` on 2026-09-07 (`contracts/tests/ExpressionsGas.t.sol`), two live string arguments cost 32,440 gas through `get` against 51,474 through the offset splice, and at three arguments 43,887 against 126,757; one live argument stays on `read` (19,000 against 20,217), and word-only calls too (14,718 against 21,219). Those are snapshots of one compiler on one day: the test prints the numbers and asserts the ordering, not the values, so treat the ordering as the durable claim and re-measure before quoting a figure.

## Constraints

Every operand carries inline constraints, and `resolve` (like the judge) validates them against the resolved value's **first 32-byte word, unsigned**: `EQ` equal to the 32-byte reference, `GTE` and `LTE` against it, `IN` within `abi.encode(lo, hi)` inclusive (the wire format is on the [core reference](/docs/reference/core#constraint-types)). That covers `uint256`, `address`, `bool` and `bytes32` values directly; for anything else the first word is whatever the encoding puts there (a dynamic return's offset word, the first component of a tuple), so select first with `pick` or `nav`. A violation reverts with `ConstraintFailed`, which names the operand (entry, parameter and constraint index) and echoes the word as compared. Everything richer (`!=`, signed comparisons, string equality, live-vs-live tolerance) is a read-spliced [Operations](/docs/operators) expression whose 0/1 word or hash is judged `EQ`: `gt(int256,int256)` judged `EQ 1`, `hash(name)` judged `EQ keccak256("...")`, `absDiff(a, b)` judged `LTE d`.

## Chained lookups

"The pool's token has the symbol WETH": `start` resolves `pool.token()` to the token address, and the hop calls `symbol()` on it. In practice `start` is a `STATIC_CALL` fetcher (`abi.encode(pool, token())` as `paramData`) and the chain's result feeds the judged parameter:

```solidity
bytes[] memory hops = new bytes[](1);
hops[0] = abi.encodeCall(IERC20.symbol, ());

// judged value: chain(pool.token() -> symbol()); compare its hash EQ
// keccak256("WETH") via Operations.hash, or navigate it with nav("(string)")
abi.encodeCall(Assertions.chain, (
    callParam(pool, abi.encodeCall(IPool.token, ()), noConstraints()),
    hops
));
```

Every hop except the last must return an address as its first word (a dirty-upper-bytes word reverts with `InvalidAddressWord`, identifying the hop); the final hop's returndata passes through raw.

## Typed navigation

Typed navigation is self-describing calldata: `nav(param, "(address[][],address)", [0, 3, 1])` reads as "return value 0, element 3, element 1". The first path step selects a return component; each further step indexes the current tuple or array, and array steps accept negative indices resolved against the live length (`-1` = last). The contract derives every offset-follow and bounds check from the descriptor, parsing only the *shape* (dynamic vs static, head footprints). Struct arrays navigate the same way: `proposals()[1].executed` against `"((address,uint256,bool)[])"` is path `[0, 1, 2]`. The declared type is the author's claim about the encoder, like an inline ABI: a wrong claim reverts loudly in almost all cases, but a shape-compatible wrong type can read the wrong value.

Every terminal returns its canonical single-value encoding. Static words, fixed arrays and static tuples return their complete bounded encoding without an offset or length prefix. Dynamic values return: `[0x20][length][payload]` for string, bytes and arrays of statically encoded elements, `abi.encode(value)` for dynamic tuples and arrays of dynamic elements (re-encoded from a canonical-form walk of their extent, so malformed nested data reverts with `AbiCodec`'s `InvalidValue` at the offending offset). `nav(param, "(uint256,int256[2])", [1])`, for example, returns exactly the two signed words. An empty path is a byte-for-byte passthrough (`nav` degenerates to `resolve`). An encoded `bytes` value's *content* is reachable too, through [the `PAYLOAD` sentinel](#typed-re-entry-the-payload-sentinel) below.

## Raw word extraction

`pick(getReservesParam, 1)` returns reserve1 as a word. It is raw-word extraction for static-layout returns, **not** an ABI decoder.

## Constructed calls

`read` builds calldata from resolved segments: the 4-byte `selector`, then each of `args`' **full resolved bytes** concatenated in order, exactly ERC-8211's CALL_DATA routing. Args are calldata *segments*, not necessarily one per Solidity argument: a `RAW_BYTES` segment carries any literal span (head words, pre-encoded tails), and a `STATIC_CALL` segment computes a span at judge time (word-returning expressions contribute exactly 32 bytes). The constructed call is executed via `staticcall` against the address `target` resolves to, and its raw returndata passes through:

```solidity
// balanceOf(computedHolder) on whatever token the vault currently reports:
// both the target and the argument resolve at judge time
InputParam[] memory args = new InputParam[](1);
args[0] = callParam(registry, abi.encodeCall(IRegistry.treasury, ()), noConstraints());

abi.encodeCall(Assertions.read, (
    callParam(vault, abi.encodeCall(IVault.asset, ()), noConstraints()),
    IERC20.balanceOf.selector,
    args
));
```

The encoder owns the calldata layout: a segment resolving to anything other than its expected length shifts everything after it, so live word segments must fill single-word parameters and runtime-sized envelopes need their head offsets accounted for (see [the bytes page](/docs/operators/data) for the layout technique). Because any deployed view or pure contract is reachable this way with fully composable operands, `read` is how the core stays extensible: [Operations](/docs/operators) is the canonical first extension, and deploying a custom pure function once makes it callable from every assertion with computed arguments.

## Nested lengths

A path ending in the `LEN` sentinel (`type(int256).min`, exposed as the public constant `LEN`) returns the decoded *length* of the dynamic value the preceding steps navigate to: element count for arrays, byte length for string/bytes. `nav(holdersParam, "(address[])", [0, LEN])` returns the holder count as a word. Because the sentinel composes with navigation, the length of an array *inside* a struct is one call too.

`LEN` validates that the selected bytes/string payload (including ABI padding)
or array element heads fit in the returndata before returning the length. For
arrays of dynamic elements, it checks the offset-word region but does not
recursively validate each element's tail. A length check is not a full ABI
validation of every array element.

## Typed re-entry: the PAYLOAD sentinel

`bytes` is a sealed leaf in the descriptor grammar: an encoded blob's content is opaque to the descriptor that reaches it, and the grammar stays plain ABI syntax. A path ending in the `PAYLOAD` sentinel (`type(int256).min + 1`, exposed as the public constant `PAYLOAD`) opens the seal: it navigates to a string or bytes value and returns its raw payload, exactly its byte length, no envelope, no padding. Re-entry is then ordinary composition, with the payload's encoding claimed by the consuming nav's own descriptor:

```solidity
// f() returns (uint256 ok, bytes data), where data encodes (address,uint256):
// the inner nav strips the blob in the same frame that navigates to it, and
// the outer nav claims the payload's type
nav( nav(x, "(uint256,bytes)", [1, PAYLOAD]), "(address,uint256)", [0] )
```

The claim has the same status as any descriptor: the author's statement about the encoder, checked by shape. Composed over `rawCall` (which wraps any call's raw returndata as a bytes value, see [the bytes page](/docs/operators/data)) the sentinel is a general unwrapper, and on a string value it returns the true unpadded bytes. Arrays and dynamic tuples refuse the sentinel with `InvalidNavigation`: only string and bytes carry a byte-counted payload (a plain path returns an array or tuple as its canonical value). Like `LEN`, the sentinel is only meaningful as the last path entry; anywhere else it falls into the ordinary bounds checks and reverts loudly.

## Failure modes

Failures are descriptive: an operand that reverts or targets a code-less address reverts with `CallFailed(target, data)` identifying the exact failing call, and an operand constraint violation with `ConstraintFailed`. In `nav`, a malformed type descriptor reverts with `InvalidTypeDescriptor` at the offending character, a step into a non-composite value or an unrepresentable terminal with `InvalidNavigation`, a path index outside its tuple/array with `ElementIndexOutOfBounds`, and data not matching the declared shape (truncated returndata, out-of-range offsets or word indices) with `ReturnDataOutOfBounds` (`InvalidValue` for a re-encoded array or tuple terminal). In `chain`, an empty `calls` array reverts with `EmptyCallChain`, a mid-chain selection with dirty upper bytes with `InvalidAddressWord`, and a mid-chain hop returning fewer than 32 bytes with `ReturnDataOutOfBounds`. In `read`, a target word with dirty upper bytes reverts with `InvalidAddressWord` (index 0), a code-less target or a reverting constructed call with `CallFailed`, and a violated segment constraint with `ConstraintFailed` naming the operand (target 0, args at index + 1). `get` adds the codec's own errors: `ComponentCountMismatch` when the argument count disagrees with the descriptor, `InvalidComponentEnvelope`, `InvalidComponentLength` or `InvalidComponentValue` naming the argument whose resolved value does not fit its declared type, and `InvalidTypeDescriptor` for a malformed descriptor. See the [error reference](/docs/reference/errors).

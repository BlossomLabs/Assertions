# Recursive source control: conditional correspondence

This package connects `_evaluate`'s recursive control to an independent
functional specification and to the canonical-value/cache invariant. It covers
arbitrary finite admitted graphs, every node kind, ordered strict children,
lazy selection/fallback, cache hits, guard adoption/discard, first failing
subcomputation and the validation-before-store boundary. The theorem is
**conditional on faithful primitive receipts**; it is not yet a complete
Expressions implementation or bytecode proof.

`Spec.dfy` defines a recursive value function. It differs structurally from the
lowered method: `Gather` recursively collects arguments, `Body` selects the node
rule, and `Complete` applies validation/store. `Source.Run` proves exact result,
cache and request-history equality with this function, together with canonical
validity, preservation of existing entries and the backward-reference footprint.
Loop invariants relate the remaining imperative traversal to the specification's
recursive suffix. First-failure propagation follows this equality; exact ABI
payloads come from the explicit receipts described below.

`generate.py` gates complete normalized `_evaluate`, `_tryEvaluate` and
`evaluateGuarded` ASTs plus node/cache/enum/error definitions. The selected slots
are Select's two branch indices, presence of the final cached validation call,
and Call's argument-reference offset. All other control and call arguments are
pinned. Validation must be immediately before the cache writes. The absent
validation fault is lowered to a disabled check, not rejected by the gate.
Compiler-allocated overload IDs are normalized while preserving cardinality.
The restricted translator, structural gate and manual lowering are trusted.

The map projection contains exactly ready entries; a cache hit must use its own
index. Strict traversal groups Wrap/Array/Tuple/Call/ProbeCall but keeps their
actual child order. Call/ProbeCall address checking follows the target child
before any remaining argument/calldata child. A failed guarded child issues a
separate `GuardFailure` receipt for that boundary's sampled gas/revert decision;
its local cache is discarded. All executed primitive requests remain in history,
including those inside a failed attempt. This does not assume external reads
are independent of gas, caller or prior requests.

`Connection.EvaluateInitialized` consumes the admitted graph and valid cache
premises supplied by the earlier admission/cache packages. It instantiates
validity with canonical ABI validation, derives a successful cache receipt and
proves the returned value equals its canonical encoding.
`ValidationProjection` calls the existing source-connected cached validator and
proves its success predicate matches this validity predicate under `CursorRoom`
and representable lengths. It does not assume a validator verdict.

## Primitive boundary and remaining obligations

A receipt oracle closes over the original nodes (including data/type/selector/
argument fields), parameters, actual call context and observations. Its stages:

- `Leaf`: Literal bytes; Parameter length/index checks and retrieval; Resolve
  decoding and call. Their detailed semantic adapters remain to be connected.
- `Address`: exact-word/clean-upper-bits check before later children. A success
  acknowledges the original target word; final Call/Probe receipts consume it.
- `Finish`: Wrap encoding, Array packing, Tuple argument encoding/envelope, Call
  argument encoding and staticcall, or Probe calldata decoding/call/revert body.
- `Boolean`: the actual ABI encoding of the guarded attempt's success flag.
- `GuardFailure`: the actual sampled `_rejectOutOfGas` result and signal payload.

`truth` must be the actual first-word-nonzero test. `reject(index,value)` carries
the actual validation rejection bytes; it is not invented node-index revert
encoding. These adapters, error serialization, top-level raw return and full
call-context composition remain open. Likewise, this result does not yet prove
graph/tree equivalence; that needs explicit deterministic context premises.

Memory/call-frame projection, faithful receipts, valid calldata, representable
arithmetic, per-validation `CursorRoom`, and sufficient local resources are
explicit assumptions. External calls may fail. The local mathematical recursion
terminates by backward indices; it makes no universal EVM gas guarantee.

The runner retains native Dafny results, dependency-closure audit, source/tool
hashes, complete compiler AST input/output and EVM inventory. The EVM suite
checks branch direction/laziness, validation, Call argument order, target-error
precedence, and the existing cache tests. Three actual Solidity faults must each
pass translation, fail a named semantic theorem and fail their named EVM test.
A parser/type/resource/timeout failure is not accepted as a semantic kill.

```sh
python3 -B formal/expressions/recursive/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 --output /fresh/baseline
python3 -B formal/expressions/recursive/mutations.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 --output /fresh/faults
```

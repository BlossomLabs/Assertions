# Expression cache transition invariants

This package proves selected source-connected cache transitions and reusable
invariants. It does **not** prove the complete recursive evaluator. In
particular, `SuccessfulReceipt` is a condition the forthcoming evaluator proof
must establish for every successful guarded attempt; it is not assumed to be a
completed theorem about `_evaluate`.

The [baseline](evidence/cache-transitions/manifest.json) and
[source-fault campaign](evidence/cache-faults/manifest.json) retain executed
checks. Production Solidity is unchanged.

## Established results

`ExpressionCache.Valid` requires all four arrays to have the graph's length,
shape metadata to match admitted descriptors, and every ready value to pass the
independent canonical ABI validator. Unready values need not validate.
`Extends` preserves all previously ready values and metadata. `ColdValid`,
`StoreValid`, `AdoptValid`, `ReuseCanonical` and `ExtensionsCompose` establish
the algebra needed for recursive evaluation.

`ExpressionCacheSource.Begin` composes the admitted graph with cold-cache
initialization. Its descriptor witness is proof-only, not a second runtime
parser call. `Initialize` projects the source's fresh arrays and shape assignments
to mathematical sequences. Allocation occurs before admission in Solidity;
the successful-state projection is equivalent under the stated sufficient
resource and memory premises. Failure exposes no initialized cache. Actual
allocation failure order and gas are outside this theorem.

`Reuse` returns the requested ready entry and proves its canonical validity.
`ValidateAndStore` calls the source-connected cached ABI validator before writing
the value and ready bit. Success extends a valid cache; failure propagates the
validator's receipt and performs neither write. The input cache is the state
**after child evaluation**. This theorem does not claim that child computations
never changed the current frame before a later validation failure.

`TryResult` models the exact success/failure branches of `_tryEvaluate`.
Success adopts returned values and ready bits while retaining the original
shape arrays. Given `SuccessfulReceipt`, `GuardSuccessValid` proves that the
resulting cache remains valid, preserves old ready entries and returns a
canonical value. Failure discards an arbitrary temporary cache, preserves the
caller's cache, and either reports ordinary failure or propagates the source's
sampled exhaustion classification. The discarded cache may be invalid; no
invariant is required of a failed attempt's intermediate state.

`CheckSelf` proves the admission condition on `evaluateGuarded`: an external
caller is rejected before cache use. Its NotSelf error bytes are checked on the
EVM. The complete guarded entrypoint and recursive evaluation remain separate.

## Source connection and premises

`generate.py` structurally gates `evaluate`, `_evaluate`, `evaluateGuarded`,
`_tryEvaluate`, `_rejectOutOfGas`, and their types/errors. It translates the cache
hit index, final ready bit, adopted arrays, self-call check and exhaustion guard.
Only the selected cache/auth transitions and initialization projection are
proved here. Pinning the remaining node-evaluation statements is not proof of
them. Compiler-allocated overload IDs are normalized while preserving candidate
counts and executable structure.

The manual decomposition, restricted translation, solc AST, typed byte/array
memory projection and Dafny/Boogie/Z3 are trusted. Valid typed calldata, actual
call receipts, ABI/error serialization, separate call-frame memory and the
calldata-to-memory copy in `evaluateGuarded` are explicit premises. The failed
attempt's temporary cache is a ghost witness, not part of returndata. The
boundary projection is why discarding it models rollback; compiler correctness
and physical aliasing are not proved by immutable-sequence algebra.

Lengths, indices and intermediate memory arithmetic must be representable, and
local gas/stack/allocation must suffice. Checked codec panics remain distinct.
No universal exhaustion detector is claimed: the guard follows actual sampled
gas and the exact reserved four-byte marker. Success-receipt cache invariants
and frame correspondence must be discharged when composing the evaluator.
Repeated external reads are not assumed deterministic. No graph/tree or exact
compiled-bytecode equivalence follows from this package.

New cache declarations run afresh. ABI, admission and resolution dependencies
are reused only after complete transitive source/tool hashes, successful native
results/declaration accounting and retained artifact hashes pass audit. Copied
manifests preserve original commands and linked logs. Missing results, timeouts
and source drift prevent a passed baseline.

Six EVM regressions check indexed reuse, successful cache sharing (one target
call), recomputation after failed guarded validation (two calls), rejection of
invalid values, external cache injection, and reserved-marker propagation.
Five real Solidity faults must translate, fail their named semantic theorem
without timeout, and fail the designated EVM regression.

```sh
python3 -B formal/expressions/cache/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/cache-transitions
python3 -B formal/expressions/cache/mutations.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/cache-faults
```

The full evaluator, all node kinds and external-call branches, guarded/encoded
entrypoint composition, deterministic graph/tree equivalence, Collections and
exact-bytecode work remain in `../../verification-plan.json`.

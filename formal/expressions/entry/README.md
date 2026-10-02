# Admission and canonical execution composition

Evaluate calls the source-proved admission/cache initializer and then the proved
generated-trace evaluator. It rejects exactly when the admission specification
rejects, with the identical structured admission error. Accepted graphs have
backward references, the required arities and descriptor metadata from parsing
each node's declared type. Their initial memo is empty, not an arbitrary
user-supplied cache.

CanonicalRun specializes recursive validity to canonical ABI encodings. It
reifies the final memo into the existing cache representation and proves cache
extension, preserved metadata, and a typed decoded value plus exact re-encoding
for every ready cache entry. Successful result bytes are exactly Encode of a
well-typed value of the declared descriptor, with no extra result envelope in
the mathematical RawResult projection. A warm cache hit returns its original
value without changing the cache or emitting primitive requests.

The trace and receipts are constructed during recursion. Covered retains every
per-request dispatcher condition and excludes mathematical fallback receipts,
including those in caught failed attempts. Canonicality and cache preservation
are properties of the model even when Covered is false; source primitive
correspondence is claimed only when it is true.

This composes existing source-proved prefixes and recursive control. It does not
yet connect the concrete assembly return's memory region, encode admission
errors, prove evaluateGuarded's full external ABI return, or prove evaluateEncoded's
decoding and wrapping boundary. Actual validation rejection bytes remain supplied
through reject; canonical acceptance is proved, but no unique all-input rejection
offset function is added. Actual external/guarded call frames, decoder and
resource conditions, manual translation and memory assumptions remain explicit.
Graph/tree substitution still requires context determinism. Compiled-bytecode
verification is a separate track.

The baseline verifies every local declaration and audits complete dependency
source/tool/artifact/native inventories. This proof-only composition adds no
EVM or actual-source fault campaign and changes no production source.

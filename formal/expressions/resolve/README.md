# Resolve node source and core bridge

The source adapter models the actual InputParam decoder outcome explicitly.
Malformed input emits a bare revert before any core request. Accepted input is
re-encoded as the resolve selector plus the standard dynamic InputParam argument
frame, then passed to the proved call/receipt adapter at the original node index.
The wire projection covers every route/fetcher/constraint ID and arbitrary
finite reference payloads/lists. The generator checks production enum ordering,
struct member order and the ICore.resolve signature, and gates the complete
_evaluate AST. It permits a node-index source fault, which must fail both the
Resolve theorem and a concrete exact-wrapped-error test.

ResolveAgainstCore connects the node adapter to CoreSource.ResolveRaw and the
independent resolver/constraint theorem. Under the explicit CoreObservation
premise, success is equivalent to successful fetching, sufficient complete
words and every positional constraint passing. Success bytes agree exactly.
Outer and callee histories are kept distinct; external calls may depend on
history and their own caller context. Actual failure bytes retain the call
adapter's gas-marker classification and NodeCallFailed wrapping.

This is conditional source correspondence. The decoder observation and standard
compiler ABI encoding projection are trusted, including noncanonical source
encodings the decoder accepts. CoreObservation requires the actual target to
execute the proved core with faithful sender/static context and sufficient
resources; it is not a deployed-code identity or compiler/bytecode theorem.
Complete frame-trace composition, independent core error serialization, final
node-type validation and full evaluator entrypoints remain separate.

Seven EVM cases exercise bare malformed decoding, missing-core and constraint
failure node indices, all wire enum IDs and dynamic offsets through a calldata
reflector, and RAW_BYTES, STATIC_CALL and BALANCE through actual Assertions.
The general theorem remains conditioned on representable ABI lengths/offsets,
faithful memory, sufficient resources and audited dependency proofs.

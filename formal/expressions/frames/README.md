# Recursive frame cache provenance

This package records every recursive evaluator entry, including cache hits,
failed guarded attempts and fallback work. It proves that the resulting trace
is exactly an independent Trace/BodyTrace/GatherTrace specification. Select
records only its chosen branch; failed arguments and address checks stop later
children; guarded failure classification precedes any fallback.

The instrumented evaluator is generated from the already-proved recursive
source adapter. Removing the listed instrumentation edits recovers that file
byte-for-byte. Instrumentation adds only entry records, recursive trace returns,
proof calls, postconditions and invariants; the semantic result and its request
history remain exactly the source-proved recursive specification.

Every entry has a valid memo extending the initial memo. Guarded entries carry
the owning TryOrElse/IsValid node and its first backward reference. Public
admission and generated receipt execution provide the initial descriptors,
cold cache and final replay oracle. Reification then gives each recorded entry
a canonical cache with unchanged metadata and a memo projection exactly equal
to that entry's memo. All evaluateGuarded Ready premises follow, including
matching descriptors and uint256 metadata widths. Nested valid-cache provenance
is therefore derived from the complete execution trace, not assumed per entry.

The trace uses the recursive model's history across attempts. It does not yet
prove EVM call-frame transitions or relate caller/static/history observations
across external self-call boundaries. Exact codec rejection observations,
primitive Covered eligibility, standard ABI/memory projections and sufficient
resources retain their existing boundaries. Graph/tree determinism and compiled
bytecode are separate obligations. No new EVM or actual-source fault campaign is
claimed by this proof-only composition.

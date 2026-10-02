# Generated recursive receipt traces

Evaluate constructs requests and receipts as recursive evaluation proceeds. It
returns the complete result, receipt sequence and a Covered flag. The exact
recursive specification evaluated with replay of that generated sequence equals
the returned result. No matching input trace or complete primitive oracle is
assumed. Oracle stability transports child results across subsequent extensions.

Run, Body and Gather follow the independent recursive specification across all
node kinds: lazy branches, successful and failed guarded attempts, address
validation before remaining arguments, ordered traversal, cache hits and final
value validation. Certified records a stage-specific dispatcher postcondition
for each eligible request. The complete history includes work from failed
attempts even when their cache changes are discarded.

Dispatcher eligibility contains the established input, representability, memory,
codec and external-observation premises. When a materialized request is not
eligible, the model uses a bare-error fallback solely to stay total, and Covered
is false. A later guarded recovery cannot hide this: Covered checks every entry
in the complete history. No Solidity outcome is asserted for a run with that
flag false. When Covered is true, every receipt was constructed by the proved
dispatcher, ValidTrace holds, and the replay is aligned with the constructed
execution by theorem rather than by an additional history-equality premise.

The final connection reuses the request-instrumented source refinement to prove
valid cache contents, extension and footprint, successful value validation,
cache-hit identity, typed requests and byte-valued errors. Canonical ABI values
are obtained by specializing valid to the established canonical predicate.
Exact validation rejection bytes remain supplied by reject and its codec
adapter; this does not add a unique all-input rejection-offset specification.

This closes the generated oracle/trace-alignment step under per-request
eligibility. Actual decoder/call/guard frame provenance, inherited translation
and memory assumptions, admission-to-entrypoint composition, ABI raw-return
boundaries and exact compiled bytecode remain separate. It does not infer that
view calls are context independent; graph/tree equivalence still needs explicit
determinism assumptions.

This is proof-only composition of existing source-connected pieces. The baseline
audits complete dependency source/tool/artifact/native inventories. No new EVM
or actual-source mutation campaign is claimed, and no production source changes
are made by this package.

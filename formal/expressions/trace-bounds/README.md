# Exact receipt windows for recursive entries

The complete recursive-entry trace now has a proved containment invariant:
each entry history and that entry's entire evaluation history are prefixes of
the enclosing evaluation's final request history. This covers warm cache hits,
lazy branches, guarded failures, fallback work, stopped arguments and failed
address checks. The theorem applies to arbitrary history-dependent oracles.

Public admission, generated receipt execution and the source-corresponding
frame instrumentation produce canonical entry caches and the complete frame
trace. When the outer trace is Covered, every local evaluation receives the
exact receipt window between its entry and completion. The window is Covered
and ValidTrace in the prefix-rebased context, and its full result equals the
outer-context subevaluation after restoring the prefix. Local eligibility and
trace containment are derived for these reached entries, not assumed per call.

The local replay oracle may contain a longer suffix, but the proved execution
uses only its exact window. Prefix validation then supplies the matching
receipt slice, including request work performed inside caught failed attempts.
This does not compare fresh executions under different environments or gas
budgets. Modeled external observations are preserved; EVM caller/static frame
transitions, exact validation rejection bytes and inherited source/ABI/memory
and resource premises remain explicit. Graph/tree determinism and exact
compiled bytecode remain separate. This package is proof-only composition with
no new EVM or production source-fault campaign.

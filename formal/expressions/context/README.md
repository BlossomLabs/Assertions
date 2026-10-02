# History-sensitive guarded execution contexts

A recursive attempt has a local request history, while the enclosing evaluation
already has a prefix. Resetting to an empty history without rebasing the oracle
could change external calls, gas observations or failure routing. This package
proves the required rebasing for arbitrary history-sensitive oracle functions.

The mutual Evaluate/Body/Gather proof preserves the complete result: success or
failure, exact value/error, memo, and ordered request history. Select remains
lazy, failed arguments still stop evaluation, caught attempts retain their
request history, and failed-attempt cache changes remain discarded. The local
oracle queries the outer oracle at prefix plus local history. No determinism
or history-insensitivity premise is introduced.

At selects each primitive frame from that same combined history. Eligibility
and semantic receipts therefore agree with the outer configuration, retaining
the exact external environment, its external-call history and the boundary's
gas and revert-data observations. Suffix proves a covered valid outer receipt
trace remains valid in the rebased configuration; ReplaySuffix proves pointwise
oracle equality, including out-of-trace behavior. FromTrace connects that actual
receipt suffix to recursive evaluation. EvaluateAt additionally constructs a
canonical resumed execution and its receipts at a supplied prefix.

The proof preserves modeled context. It does not yet establish EVM caller/static
frame transitions, or prove that every reached recursive subevaluation ends
within the outer receipt trace. Validation rejection bytes, source/ABI/memory
projections and sufficient resources keep their existing assumptions. The
constructed Resume oracle's outside-prefix fallback is only mathematical
completion. Primitive source correspondence requires Covered. This is a
proof-only composition, with no new EVM or production source-fault campaign.

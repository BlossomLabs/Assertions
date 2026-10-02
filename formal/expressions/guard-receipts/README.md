# Guarded receipts from reached execution windows

EvaluateWindow runs the source-proved recursive request control over an actual
local receipt window. The result is exactly that window's local evaluation,
with canonical updated cache, identical memo projection, byte-valued errors and
a derived successful-cache receipt. Existing guarded ABI proofs apply to these
result/cache values under their explicit Fits premise.

The mutual event proof establishes a further trace fact: every failed typed
guarded attempt is immediately followed by the GuardFailure request for its
owning node and exact error payload. This includes nested failed work, lazy
branches, fallback execution and stopped argument evaluation. Root derives the
fact for the complete entry trace using its proved containment invariant.

FromRoot connects these results to the cache source adapter. Success adopts the
attempt's exact cache and value. Failure keeps the original cache and uses the
boundary observation at the derived next request. Covered/ValidTrace provides
that request's actual gas samples and revert bytes, and the classifier result
is exactly its recorded reply: ordinary failure or the reserved exhaustion
signal. No separate observation is supplied for the failed attempt. Both the
returned cache and its memo projection agree with recursive control.

Inputs are the complete root trace and canonical reached-entry cache already
established by the public-entry and receipt-window packages. Primitive source
correspondence requires a Covered outer trace. The node-validation rejection
function remains an abstraction requiring source-validator receipts. Faithful
EVM caller/static transitions, ABI/memory projections, resources, and compiled
bytecode keep their existing boundaries. No physical gas guarantee or graph/tree
determinism is inferred. This package is proof-only composition; it adds no new
EVM or production source-fault campaign.

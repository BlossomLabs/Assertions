# Constrained RAW cond composition

This development package consumes the frozen non-OR arbitrary-count constrained
RAW resolver interface. It does not claim a whole public entry or add public
exact-bytecode coverage.

`Heap.dfy` proves that the validator's abstract allocation heap retains the
original condition's first word, and satisfies the frozen first-word physical
helper's heap premise. `Condition.dfy` composes the actual resolver at PC3393,
return PC1770, the physical first-word call at PC3975, and success PC1783 or exact
short-condition rejection. Its input is the resolver's admitted physical input,
including constraint layout and successful judgments, not a resolved-result
assumption. `Spec.dfy` states the independent operand shape, original payload,
non-OR constraint judgments, and cost budget. `Prefix.dfy`, `Selected.dfy`, and
`Body.dfy` compose the actual cond body with lazy selected constrained resolution.
`Admission.dfy` and `Connection.dfy` connect independent calldata to fresh PC0
dispatch/decoder, exact short rejection or the original selected payload.

Development receipts are retained under `development/`. The owner runner captures
the transitive source snapshot, hashes, exact command, native output, and CSV.
It checks only new owners, so imported helpers must still receive a full closure
recheck before acceptance. The initial normal run timed out; `isolated-v1`
passed127 Condition obligations and timed out three, with no failed assertions.
Those snapshots and diagnostics are immutable. Subsequent fresh owner runs pass
the complete new owner inventory. `concrete-v2` retains68 complete public
receipts with every reached instruction, mixed0/1/5/13 constraint counts and
partial words. The physically faithful DUP5→DUP4 mutation at1824 changes a valid
constrained then result9 to the else result11 without reverting; its native
Advance6 postcondition also fails. Any subsequent attempt uses a fresh directory.

Acceptance still requires complete current native dependency closure, generation,
audit, runtime/tool/source binding and independent coordinator review. First
BadData/BadRange caller propagation remains open. Gather and pick constrained caller packages
follow after this cond closure. OR/ConstraintFailed and non-RAW fetchers remain
resolution-lane dependencies.

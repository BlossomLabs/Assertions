# Exact validator rejection throughout recursive evaluation

`Model.Reject` is a single deterministic function of node index and value bytes,
bound to the admitted descriptors. Its payload is the exact source validator's
encoded result. It is total and byte-valued; non-byte/out-of-range fallback
arguments are excluded at actual cold completion by the existing invariants.

The generated completion adapter uses the strengthened exact ABI receipt
contract. Its result equals recursive completion under `Model.Reject` without
an agreement premise or independently chosen rejection witness. The generated
cold-entry connection then equals the recursive evaluator outright, preserving
canonical cache storage and the actual error bytes.

`ValidateFrames` constructs a source completion receipt for every cold entry in
a finite trace, skipping validation for warm entries and after body failure.
`FromRoot` derives the complete entry trace from the source evaluator, including
lazy branches and failed attempts. It derives canonical entry caches and trace
containment, then constructs all those receipts using the same rejection
function. Repeated attempts on the same descriptor/value therefore cannot pick
different validation errors.

The given outer receipt trace must be Covered/ValidTrace and match root
completion. Every reached successful body must meet explicit length and
CursorRoom premises. Source translation, EVM/ABI/memory/resource projections
remain explicit; this is not a physical gas theorem. Public admission/entrypoint
composition, frame transitions, graph/tree determinism and exact bytecode are
separate. No new EVM or production source-fault campaign is claimed.

The generator records reversible edits to existing composition adapters.
`verify.py` retains full declaration coverage, dependency/tool/source/evidence
hashes, audit and formatting checks. Only a passed retained manifest is evidence
of completed verification; development work is not promoted automatically.

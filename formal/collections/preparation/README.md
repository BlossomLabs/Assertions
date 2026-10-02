# Callback preparation and binding

The source-gated `_prepareCallback` and `_bindValue` adapters refine a recursive
specification for arbitrary finite argument lists, under explicit **faithful
codec observations**. Actual descriptor parsing and component validation are
connection premises here; they are not replaced by successful-result assumptions.
Both success and exact error bytes are modeled, in request-history order.

Preparation rejects invalid substitution slots before descriptor processing.
A nonempty descriptor missing tuple parentheses is sent to `shape` first: its
error wins, otherwise preparation reports `InvalidCallback`. Other descriptors,
including empty bytes, go to `tupleLayout`. Component-count mismatch precedes
constant validation. The recursion visits precisely the constants outside the
unary or binary substitution slots, in increasing order, stopping at the first
failure. Empty traversals still perform these preparation checks.

`Connection.Prepare` proves the exact validation-index prefix and successful
prepared state: the arguments equal the original constants, the projected layout
is well formed, the slots are admissible, and `targetChecked` starts false.
`BindValue` validates against the selected component before replacing that one
slot. The plan, other arguments and target-check flag are preserved. On failure
there is no successful replacement state; trace receipts do not commit reverted
memory.

The codec environment can depend on the full request history. Its admission
premise requires shape/validation to return success or an error, and layout to
return an error or a plan whose component slices are in bounds. Parallel Solidity
layout arrays project to component records. Matching that representation and
instantiating all codec outcomes with the existing codec proofs are still open.
No target inspection or external callback is modeled by these two helpers.

The complete function ASTs preserve call arguments, validation/write order,
loop increment and callback fields. Selected slot/count/loop predicates, the
binding validation index and the destination slot are translated from AST
expressions. Reviewed manual lowering, initialized memory, accurate slice/read
projections, representable nonaliasing arithmetic/memory and adequate local
resources remain trust premises. No verifier run bootstraps its source gate.

Retained evidence includes fresh AST/generated equality, native declarations,
zero audit findings, formatting, immutable snapshots, unchanged inputs and
identical dependency source/tool/artifact hashes. Seven EVM fixtures cover
admission order, binary placeholders, first invalid constants and binding.
Three real Solidity faults must pass the source gate and fail both a semantic
proof and the designated EVM test. Parser/type errors, timeouts and gate rejection
never count as source-fault kills. Whole Collections composition, concrete call
construction and exact compiled bytecode remain open; gas, deployment and
historical performance claims are unaffected.

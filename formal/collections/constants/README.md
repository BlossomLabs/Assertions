# Actual constant validation through preparation

This package removes the initial canonical-constant premise from the admitted
callback preparation/binding path. It composes the production tuple-layout and
component-validation adapters with the source-connected preparation loop.

`Receipts` obtains the actual typed component result for every non-substituted
constant using its projected descriptor slice, index, dynamic flag and width.
The result succeeds exactly when the independent ABI validator accepts the
constant. Substituted slots retain arbitrary placeholders and are not validated.
The receipt table is ghost evidence for pure computations: constructing later
entries does not claim that Solidity evaluates them after an earlier failure.

`Environment` exposes those exact results for matching source requests.
`Tail` selects the prefix the preparation loop actually reaches, proving the
first failing non-substituted index, the corresponding encoded typed result,
and success of every earlier checked slot. Other hypothetical requests in the
local environment are not certified as source executions.

`Prepare` invokes the gated production preparation adapter with that environment.
It succeeds if and only if every non-substituted constant is canonical. Success
retains the original arguments, the actual projected layout and the false
initial target-check flag. The canonical-except-placeholder invariant is now a
conclusion rather than an assumption.

`PrepareAndBind` composes this result with actual first-slot and optional
second-slot validation/replacement. Success is equivalent to canonical constants
outside the slots and valid bound values for their respective types. It carries
the reached request histories and derives full canonicality and direct-encoding
readiness. This is the pure preparation/binding path, not an execution of the
separate target check or an external callback.

The scope is an admitted rendered tuple descriptor, matching arity and valid
substitution slots, with explicit uint256/CursorRoom/total-byte bounds. Malformed
descriptor, wrong arity and invalid-slot admission remain separate connections.
Failure serialization still uses a supplied faithful encoder of actual codec
results; invalid-byte offsets remain source receipts rather than a newly proved
independent offset algorithm. Physical memory/resources and earlier translation,
compiler/context premises remain. Full callback/traversal instantiation is open.

The retained driver verifies all local native declarations, zero audit findings,
formatting, snapshots, unchanged inputs and identical transitive dependency
source/tool/artifact hashes/results. This proof-only composition adds no EVM or
source-fault campaign and no bytecode, deployment, gas or performance claim.

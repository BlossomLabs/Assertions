# Source validator receipts at cold-node completion

Primitive replies are proved byte-valued under Covered/ValidTrace. The mutual
Evaluate/Body/Gather byte-flow proof extends this to intermediate node bodies,
including values that will fail canonical validation, as well as propagated
errors and memo entries. Byte validity is therefore established before the
validator is called.

The strengthened recursive source adapter changes only its contract, include
and module name. Erasing those edits recovers the previously audited adapter
exactly. For a cold node, its body memo is valid, extends the incoming memo and
does not yet contain the current node. These are the actual preconditions for
validation and storage; they are proved from source control.

Complete calls the existing cached source-validator receipt adapter exactly once
when the body succeeds. It skips validation after body failure. Canonical
acceptance stores the original bytes, while rejection propagates the adapter's
exact error bytes without changing the body memo or request history. Cold
connects that step to a reached source body and a canonical updated cache.
Descriptor/value representability and CursorRoom remain explicit resource
premises; this package does not assert a physical gas bound.

The returned rejection function instantiates the recursive completion semantics
for this checked node/value pair. Substitute proves equality with an earlier
rejection function when it agrees at that actual rejected pair; accepted values
and pre-existing body failures require no such agreement. This is local
completion provenance, not yet a whole-run construction of compatible source
validation receipts. Child rejection functions in the body remain abstract
until that construction is complete. No independent all-input rejection-offset
function or additional offset-bound result is claimed. Inherited EVM/ABI/memory
projections, graph/tree determinism and compiled bytecode remain separate.
This is proof-only composition, with no new EVM or production source-fault
campaign.

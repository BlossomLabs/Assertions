# Combined primitive dispatch

Dispatch composes all primitive stages needed by recursive evaluation: Literal,
Parameter, Resolve, address checking, Boolean results, sampled guard failure,
Wrap, Array, Tuple, Call argument construction/execution and Probe bytes decoding.
Its Post relation states each stage's actual result semantics and external
request history. Constructors retain their exact source-produced codec witness;
Array carries acceptance and canonical output guarantees, and argument failure
prevents a Call request. Every aborted receipt is byte-valued and a successful
address stage establishes the clean-address specification.

TypedRequestShape proves that the recursive request theorem supplies this
interface's ordered byte arguments and shape. LiftReceiptContracts connects
pointwise dispatcher receipt contracts to the recursive Receipts predicate.
These are composition lemmas, not an assertion that one whole-run oracle has
already been constructed.

The dispatcher is a ghost composition of proved helpers. External operations
and guard classification use the exact pure summaries already proved against
their source methods, since non-ghost methods cannot be called from ghost code.
No new Solidity runtime implementation or independently gated rewrite is claimed.
The baseline audits complete identical source/tool/evidence/native inventories
for those dependencies and verifies every new declaration.

Inputs must satisfy explicit shape and allocation bounds, faithful decoder and
external call-frame observations, actual guard revert bytes/gas, and canonical
Probe bytes. Standard compiler ABI encoding/decoding and sufficient local
resources remain inherited assumptions. Unique validation-offset semantics,
construction of the complete history-dependent primitive oracle, propagation of
resource conditions, actual guarded frame provenance, graph entrypoints and
compiled bytecode are still open. No new EVM or actual-source fault campaign is
claimed for this proof-only composition.

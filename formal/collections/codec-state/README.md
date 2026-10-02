# Codec-derived canonical callback state

This package derives direct-encoding readiness from actual codec results and
canonical-value invariants. It adds no new Solidity lowering: the completed
layout, component validation, binding and assembly source proofs are composed
under identical transitive source/tool/artifact hashes.

`Layout` invokes the production tuple-layout adapter for an admitted rendered
tuple descriptor. It projects its parallel arrays into prepared component records
and proves that each slice, dynamic flag, width and head size matches the
corresponding independent descriptor witness.

`Binding` invokes the production component validator on the selected component
and then the source-connected binding adapter. The local environment records
that actual validation result for the one reached request. Under `CursorRoom`
and arithmetic bounds, the validator cannot panic and binding succeeds exactly
when the replacement satisfies the independent ABI validator. Other hypothetical
queries in that one-request environment are not claimed as source executions.
The failure encoder remains a supplied faithful mapping of the typed codec
result; this package does not independently calculate invalid-byte offsets.

`CanonicalExcept` permits arbitrary placeholders only in a specified set of
unbound slots. Successful validation/replacement removes that slot from the set
without changing the others. `CompleteBindings` handles the source's unary and
binary binding order, carries both request receipts, stops on the first failure,
and proves that success leaves every argument canonical. The incoming constants
outside substitution slots are assumed canonical here; deriving that invariant
from preparation's complete constant-validation loop remains a next connection.

`Ready` uses the codec's canonical-piece and frame-budget theorems to derive
`DirectReady` for the actual projected plan. It needs only canonical arguments
and representable count/total bytes, rather than assuming readiness itself.
`Encode` then invokes the proved production assembler and establishes equality
to the independent ABI tuple body of the decoded values, including dynamic and
multiword static components.

Scope limits: this is the admitted rendered-descriptor path; malformed descriptor
receipts and universal arbitrary-byte admission are not completed here. Physical
memory/resources and earlier source/compiler/context premises remain. Full
preparation, call/traversal state composition, expression/error size bounds and
the remaining Collections operations are still open.

The retained driver audits every local declaration, native obligation, zero-finding
audit, formatting, snapshots, unchanged inputs and all dependency hashes/results.
No new EVM or production source-fault campaign is claimed for this proof-only
composition. Existing concrete evidence keeps its original scope. Exact compiled
bytecode, deployment, gas and historical performance are unaffected.

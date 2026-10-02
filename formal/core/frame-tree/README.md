# Finite Assertions self-call receipt trees

`Tree.Build` recursively invokes the proved all-entrypoint dispatcher in every
child frame, installs those child outcomes at their parent history/request keys,
and invokes the parent dispatcher. Each frame begins with its own empty request
history and may have its own external observations. Repeated calls are not
assumed deterministic or context-independent. Actual get/navigation witnesses
remain the witnesses returned by the source adapters.

`Tree.Compose` reports certification only when every frame satisfies its source
resource premises, all children are certified, site keys are unique, and the
supplied child sites equal the reached self-call sites. Equality checks both
missing and unused children. History keys distinguish identical requests at
different positions. `AllInstalled` proves that no other child overrides a
receipt; `Unrelated` preserves all other calls, balances and decoders.
`Connection.ReachedChild` extracts the certified source receipt for any reached
self-call. `ResolverReceipt` derives the earlier guarded-resolution matching
premise from that child receipt. `RawLeaf` proves a certifiable successful
raw-bytes leaf without any external-observation assumption.

`Wire.Serialize` derives success/failure and raw successful values from the
actual typed source result. Bare decode reverts and the reserved exhaustion
signal are fixed directly. The remaining error ABI encoders and successful
bytes[] serializer are explicit projection parameters. Faithful call ABI,
return/error encoding and caller/static/gas contexts are required to interpret
this theorem as a production execution. They are not supplied as successful
execution outcomes. Gas observations remain inputs to the proved source
classification, not a universal EVM exhaustion guarantee.

This finite typed-frame construction does not cover infinite recursion or
unknown-selector/malformed-top-level-calldata self-calls. Such calls need
explicit decoder-rejected leaves before a complete raw-calldata dispatch claim.
Local insufficient-resource receipts are not certified. Compiler correctness,
physical memory/gas guarantees and exact compiled-bytecode verification remain
separate. This package adds proof composition, not a new EVM or source-fault
campaign. The retained driver checks native declarations, complete dependency
source/tool/artifact hashes, audit, formatting and unchanged inputs.

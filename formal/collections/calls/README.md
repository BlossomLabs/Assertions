# Callback invocation and prepared state

The gated `_callValue` and `_checkTarget` adapters compose the completed binding
and exhaustion adapters with explicit encoding and external observations.
`Connection.Run` proves exact refinement, event-history extension, one target
check when the incoming cache is false (none when true), at most one external
call, and exactly one on success. A successful result preserves the layout,
sets the checked flag and retains the expected first/second argument updates.

A missing-code target fails before binding. First-slot validation/replacement
precedes optional second-slot validation/replacement. Either failure stops before
encoding and calling. The direct path asks `AbiCodec.assemble` for a tuple body
with its array flag false, then prepends the selector. The expression path asks
for `evaluateEncoded(expression, prepared.args)` calldata and ignores the direct
selector. A successful staticcall returns its unmodified bytes. A failed call
uses the proved exhaustion guard before producing the complete structured
`CallbackFailed` context, calldata and reason.

The reference specification separates target admission, binding, encoding and
invocation. The generated source adapter follows the imperative source and calls
the existing proved binding and exhaustion methods. Its full AST gate preserves
statement/call order and encoding branches; selected cache/target/branch flags,
binding slots/values, array flag and failure indices are translated. Manual
lowering and the projection to mathematical memory remain trusted.

Every observation receives the preceding full event history. Codec environments
are selected at each binding with that context, and their local validation
requests are appended to the outer history. This retains history-sensitive
behavior without assuming that equal calls have equal outcomes. Prepared state
in failures is a ghost receipt, not state committed by a reverted frame.

Remaining connections are explicit: instantiate actual codec validation and
layout projections; establish both concrete callback encoders and error ABI;
match code length, staticcall, caller/context and sampled gas observations; and
compose these helpers into all traversal entry points. The cached target check
assumes unchanged target code during the enclosing static operation. Memory,
intermediate arithmetic and resources must permit the modeled execution.

Retained evidence checks fresh AST/generated equality, all local native
declarations, zero audit findings, formatting, snapshots and unchanged inputs.
Dependency reuse checks complete transitive source/tool/artifact hashes and
successful native evidence. Seven EVM fixtures exercise direct/expression calls,
binary argument roles, dynamic argument rebuilding, target precedence, error
calldata/index and caller identity. Three planted Solidity faults must pass the
gate and fail semantic proof plus designated EVM test. None of this constitutes
an exact compiled-bytecode proof, deployment evidence or a gas/performance claim.

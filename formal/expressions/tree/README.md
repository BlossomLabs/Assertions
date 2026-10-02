# Conditional graph/tree equivalence

`Spec.dfy` independently evaluates the reference-unfolding tree: every reference
occurrence is evaluated, and no memo is read or written. It preserves lazy
selection, ordered arguments and address checks, guarded fallback/classification,
validation and exact error propagation. Original node identities are retained in
requests and errors.

`Equivalence.dfy` proves mutual Evaluate/Body/Gather outcome equivalence for a
history-independent primitive function. Its memo invariant requires each entry
to equal a successful tree evaluation and is proved preserved, including through
failed attempts and their discarded cache changes. The public empty memo meets
that invariant without any assumption about cached values.

`Connection.FromPublic` connects this mathematical theorem to complete public
source evidence. `StableConfig` explicitly requires every eligible source
primitive receipt at every call history to agree with one request function.
That includes caller/static context, gas-sensitive results and guard exhaustion
classification. Merely declaring a target `view` does not meet this condition.

The conclusion is equality of returned values or propagated errors for the
logical unfolding with original node identities. It does not equate call counts,
request traces or gas, and does not assert identical error indices after an
arbitrary physical graph renumbering. When the determinism premise is absent,
this theorem makes no graph/tree equivalence claim.

Inherited source translation, complete public coverage and ABI/memory/resource
premises remain explicit. Exact compiled bytecode is a separate track. There is
no new EVM or production source-fault campaign in this proof-only composition.
`verify.py` retains dependency/source/tool hashes, complete native declaration
coverage, audit and formatting results. A retained passing manifest is required
before promoting this development work to a completed claim.

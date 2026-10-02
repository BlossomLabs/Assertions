# Codec error receipts

This package serializes all codec construction errors and the standard Panic
receipt into the recursive evaluator's error-byte interface. ExactError proves
selector placement, total length, equivalence to an independent static ABI
argument frame and round-trip preservation of every representable field.
Callbacks encode the uint32 operation selector left-aligned as bytes4; their
other fields and target remain in their declared positions. Error signatures
and selectors are checked against production solc AST output.

ValidateReceipt calls the source-connected cached validator and preserves the
actual returned error offset. Under its cursor/resource premises it succeeds
exactly when independent validation accepts. TupleReceipt carries the compound
source constructor's actual first-failure result into exact error bytes and
preserves its successful tuple encoding. These are receipt adapters, not a
completed full evaluator oracle.

The existing validator contract specifies its acceptance verdict but does not
expose a unique rejection-offset function for every invalid value. This package
does not invent one: its theorem relates the bytes to the actual source-produced
Outcome, which it also returns. Strengthening complete error-offset semantics
and composing all evaluator/entrypoint paths remain open.

Premises include faithful source/memory projection, actual representable error
fields, sufficient resources, standard compiler custom-error/Panic ABI encoding,
and the audited codec dependency proofs. The compiler's generated encoder and
exact bytecode are not proved here. Eight EVM cases check every error geometry,
including nonzero validation offsets, callback selector alignment, component
index/length/head fields, descriptor position and a real arithmetic panic.
There is no new actual-source mutation campaign in this package; dependency
fault evidence retains its original scope.

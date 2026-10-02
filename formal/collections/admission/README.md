# Arbitrary callback descriptor admission

`Prepare` handles arbitrary descriptor bytes and decoded slot/count values. It
removes the earlier requirement to provide an admitted tuple witness up front.
The completed whole-descriptor and tuple-layout source proofs produce actual
outcomes; `LayoutWitness` recovers a rendered grammar witness only after a
successful tuple parse. That witness feeds the constant-validation bridge.

Admission preserves source order. Invalid slots fail before any codec request.
A nonempty descriptor missing tuple parentheses runs `shape`; its failure bytes
propagate, while a valid non-tuple becomes `InvalidCallback`. Empty descriptors
and parenthesized inputs go to `tupleLayout`. Layout failure propagates before
arity comparison; a count mismatch becomes `InvalidCallback` before constant
validation. Only matching plans continue to the exact first-failure constant
loop. Success is equivalent to canonical constants outside substitution slots,
with the original arguments and the false initial target-check flag.

The returned environment matches every reached source request. Defaults for
unreached queries are not claimed as codec executions. The reference admission
function is built from the independent parser/layout specifications, while the
method calls the corresponding source adapters and the gated preparation body.
`StopSource` connects all rejecting branches to that body.

Admission failures use concrete `InvalidCallback`, `InvalidTypeDescriptor(at)`
and arithmetic `Panic(17)` bytes. Fresh solc AST/ABI metadata binds the custom
selectors and field types; the panic selector is the standard compiler ABI rule.
Error offsets remain the actual source parser receipts. Component-validation
failure serialization still uses a supplied faithful encoder; that remaining
parameter does not affect admission failures.

`Room` requires uint256 descriptor/count sizes and, for a successfully admitted
matching tuple with valid slots, representable component values/widths and
`CursorRoom`. This sufficient resource condition can cover constants beyond the
first actual failure; it is not a minimum-gas theorem. Physical memory and prior
translation/compiler/context assumptions remain. Whole callback/traversal
instantiation and other Collections entry points are not completed here.

The retained driver checks fresh signature generation, native declarations,
zero audit findings, formatting, immutable snapshots, unchanged inputs and full
dependency source/tool/artifact hashes/results. Seven EVM fixtures compare exact
admission failures with direct codec outcomes and check the accepted empty path.
No new source-fault, exact-bytecode, deployment or performance claim is made.

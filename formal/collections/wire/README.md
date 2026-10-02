# Concrete callback encoding and failure bytes

This package replaces callback encoding slots with explicit byte construction.
`ExpressionCanonical` proves that `evaluateEncoded(expression, args)` calldata
is the fresh compiler selector followed by the independent ABI tuple body for
`(bytes, bytes[])`, for every finite expression and argument list. There is no
extra enclosing tuple offset. Element offsets, counts, lengths and padding come
from the existing frame algebra.

`DirectAssembly` invokes the already proved production `AbiCodec.assemble`
adapter and obtains the independent tuple frame. Its `DirectReady` premise ties
the actual prepared arguments to canonical dynamic envelopes/static bodies,
aligned per-component flags, the computed head size and representable lengths.
It does not assume an arbitrary successful encoding result.

Fresh solc AST/ABI output checks the five callback-related error signatures and
the `IExpressions.evaluateEncoded` signature and selector. `ErrorLayout` proves
the reserved signal is exactly four bytes, invalid targets use their address
word, helper failures propagate unchanged, and `CallbackFailed` uses the exact
ordered static fields, dynamic offsets, lengths and padded data/reason bytes.
The error model preserves arbitrary helper bytes without reinterpreting them.

`Run` calls the existing source-connected invocation theorem with these concrete
encoding functions. `PredicateResult` passes its raw return/failure into the
proved canonical predicate checker. Certification requires `WireReady` on the
reached trace: each direct request must satisfy `DirectReady` and use the false
array flag; each expression encoding and final error must fit ABI bounds. The
total function's fallback outside `DirectReady` is deliberately not certified as
a source outcome. Establishing these readiness conditions from actual codec
preparation/binding and composing the complete traversal environment remain open.

Source correspondence still assumes faithful compiler ABI behavior, existing
reviewed source translations, valid physical memory and adequate resources.
Codec outcomes, target/code/staticcall/caller/gas contexts remain matched
observations. The mathematical byte encoder does not prove compiler correctness
or unbounded physical execution.

The evidence driver retains fresh solc AST/ABI metadata, generated-signature
equality, native declaration coverage, zero audit findings, formatting, source
snapshots, unchanged inputs and identical transitive dependency/tool/artifact
hashes. Six EVM fixtures compare concrete expression and error layouts against
solc ABI encoding, including empty values and unequal padded lengths. Existing
source-fault evidence is preserved in its original layers; this package adds no
new source-fault, exact-bytecode, deployment or gas/performance claim.

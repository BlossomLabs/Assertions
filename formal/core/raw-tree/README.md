# Raw-calldata Assertions frame composition

This extends the finite typed-frame construction to arbitrary calldata at every
self-call boundary. A frame carries its actual calldata. `Boundary.decode`
projects the Solidity dispatcher and ABI decoder to either rejection or one of
the fifteen typed entrypoint/overload cases. Accepted noncanonical encodings do
not have to equal any encoder output. The separate `encodeResolve` projection
models only the compiler-generated self-call used by guarded resolution.

`Build` constructs children and invokes the existing source dispatcher on each
accepted frame. Decoder rejection produces an empty revert and no requests.
A decoded frame whose operation-specific resource premises do not hold is
explicitly unready and cannot be certified. Child construction is ghost proof
work: supplying children for a rejected or untaken branch does not establish
that they executed; exact reached-site equality rejects those extra receipts.

`Compose` certifies only complete finite trees, with independent frame contexts,
unique history/request keys and exact coverage of reached self-calls.
`ReachedChild` extracts either a source-proved typed outcome or a decoder-rejected
empty revert for any reached self-call. `ResolverReceipt` derives the prior
guarded-resolution matching premise from an accepted resolver child. Successful
raw-value leaves and rejected leaves both have nonvacuity construction proofs.

The decoder/dispatcher, generated resolver call ABI and error/bytes[] serializers
must faithfully project the production compiler ABI. This package connects those
explicit boundary premises; it does not prove the compiler decoder itself.
The exact request bytes are preserved. Successful/failed typed outcomes come from
source adapters, and bare reverts and the reserved exhaustion signal are fixed
by the shared wire layer. Actual caller/static/gas context and sufficient local
memory/resources remain explicit premises. External calls may vary across
histories and frames; no deterministic-read assumption is imposed.

Full concrete error and bytes[] serialization is still a separate boundary
obligation. Infinite recursion, universal physical gas/resource behavior and
exact compiled-bytecode correctness remain outside this source theorem. No new
EVM or production source-fault campaign is claimed. The retained verifier checks
native declarations, full dependency hashes, audit, formatting and unchanged
inputs without editing prior proof artifacts.

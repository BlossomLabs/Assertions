# Concrete word fold loop

`Source.Run` is an AST-gated translation of the complete `_foldLoop` body.
It invokes the retained actual domain, memory-stamping and word-call source
proofs and refines `Model.Tail`, an independent recursive fold specification.

The loop threads actual byte memory, full low-level call history and accumulator
feedback. `Memory.Stamp` proves that reused calldata equals a fresh independent
last-writer patch of the pristine template on every iteration, including
unaligned, duplicate and overlapping windows. The frame header and outside bytes
remain unchanged.

`Connection.RowAt`, `History`, `Last` and `Run` establish every reached index,
input accumulator, calldata and callback answer; consecutive accumulator/history
links; the exact first failure or stopping point; and the final value. Full
success consumes the entire domain. Any stops after the first nonzero returned
word, All after the first zero. Initial accumulator truthiness does not skip the
first nonempty step. History contains precisely the reached external calls.

Entry assumes admitted windows, valid domain/count bounds, the caller's target
check and a faithful copied template frame. The finite `Budget` follows continuing
callbacks only: failures and early exits require no unreachable callback suffix.
The external environment can depend on full history and gas. Source/compiler,
context/ABI/copy/allocation/memory projections, packet/size/execution resources and
Dafny/Boogie/Z3 remain premises. Raw `_fold` and public wrapper composition remain
open, so no public source count is added here.

`verify.py` snapshots and hashes inputs, regenerates the adapter, checks complete
retained dependencies, proves all new declarations, audits proof escapes and
replays eight EVM fixtures. Three isolated source mutations remove accumulator
feedback or invert Any/All stopping; each must pass translation and fail native
and EVM checks. Exact compiled bytecode and performance claims remain separate.

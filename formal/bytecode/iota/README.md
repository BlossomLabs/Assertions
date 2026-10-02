# iotaWords exact-runtime proof components

The generated controls bind the complete canonical Collections runtime identity
and every reached instruction/immediate/destination byte. They cover PC-zero
routing, accepted scalar decoding and every short scalar-head rejection,
checked multiplication, physical panic serialization, the compiler allocation
length guard, header allocation, and the empty/nonempty paths up to zero-padding
CALLDATACOPY. `Output.dfy` proves the physical heap, header words and original
index written by each actual MSTORE.

The symbolic input is a full Word. Multiplication overflow derives Panic(0x11);
the allocation guard derives Panic(0x41) for counts from 2^59 through the
multiplication limit. The smaller accepted count bound is derived from these
actual checks. The loop has no fixture or fuel bound. Adequate reached execution
resources remain an explicit premise; these proofs do not establish that an
arbitrary output can be produced with physically available gas or memory.

`development/allocate-headers-v6` passed 3,676 obligations with unchanged inputs.
Earlier terminal failed snapshots remain preserved. Full physical allocator
composition is in `../iota-allocation`, arbitrary finite actual loop composition
in `../iota-loop`, physical MCOPY/dynamic ABI RETURN in `../iota-return`, and the
full body and raw PC-zero entry connection in `../iota-entry`.

Those components are development proofs until the complete retained native
include graph, zero audit, exact regeneration, tool/source/dependency/runtime
closure, independent complete EVM receipts and semantic bytecode faults pass.
The independent current-source checker must then pass before public coverage
changes. Valid representations, truthful call/calldata observations, reviewed
instruction scanning/interpreter semantics and adequate reached resources stay
explicit. No gas, deployment, complexity or performance claim follows.

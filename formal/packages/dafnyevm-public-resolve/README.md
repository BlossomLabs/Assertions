# Public RAW_BYTES resolve profile

`PublicResolve.dfy` proves the RAW_BYTES source equation for arbitrary payloads,
environments, histories and all source routing tags. Its ABI layout theorem binds
the selector, offsets, lengths, payload and empty constraints. The generic
`Execution.Run` driver has native fuel bounds and correspondence with
`EVM.ExecuteN`; it lives in the upstream patch and contains no Assertions details.

The public-call gate starts at PC 0 with empty stack and memory and independent
viem calldata. It compares every instruction's PC, opcode, stack, memory and
remaining gas, then the final verdict, returndata and gas, against py-evm Cancun.
It covers 84 canonical RAW_BYTES calls with empty constraints, all three routing
tags, boundary and seeded random payloads up to 4,096 bytes. Exact gas boundaries,
malformed calldata and bounded-driver exhaustion are separate probes. Four
bytecode mutations must produce a detected failure of the output specification.

Fresh runtime capture uses the same pinned source/compiler binding as the helper
gate. Independent review recompiles the reviewed interpreter snapshot, repeats
the complete calls and requires identical reports. Evidence remains local or in
CI artifacts.

These are universal source/ABI statements and finite concrete public-call
conformance. There is no universal dispatcher/decoder/return theorem, deployed
runtime credit, STATIC_CALL/BALANCE coverage or nonempty constraint coverage in
this package. Existing source contracts and public claim wording are preserved.
The optimizer skips decoding the unused `paramType` field in this public method;
a route tag of 3 is observed to succeed and is recorded outside the canonical
profile, rather than treated as a promised rejection.

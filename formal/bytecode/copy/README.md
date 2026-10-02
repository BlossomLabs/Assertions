# Physical byte-copy foundations (development)

This package prepares physical CALLDATACOPY and MCOPY memory correspondence for
remaining exact runtime entries. `Memory.dfy` models actual rounded memory
expansion, calldata zero padding, unchanged memory outside the destination,
word loads and copies from the original memory image when spans overlap.
`Machine.dfy` adds reached CALLDATACOPY/MCOPY steps to the existing scan model.
Connections to an EVM execution retain a valid operand stack (at most 1024
words), enabled opcodes, fitting rounded footprints and adequate resources.
Zero-length copying leaves memory unchanged for arbitrary full-width offsets.

The MCOPY specification is [EIP-5656](https://eips.ethereum.org/EIPS/eip-5656):
the destination and source may overlap; copying acts as if using an intermediate
buffer; positive-length copies expand memory for both spans. No gas result is
inferred from these functional equations. Future machine/entry connections must
keep representable span and adequate reached resource premises explicit.

Native development checks do not prove any reached runtime path or public
entry, compiler allocation/return behavior, whole-contract semantics, gas,
deployment, complexity, performance or unconditional resource safety.
`development-run.py` snapshots selected include graphs, package inputs and native
CSV/declaration results. A finished retained package, exact runtime connection,
zero audit and concrete/semantic-fault closure remain required for public claims.

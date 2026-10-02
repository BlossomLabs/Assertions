# Memory word helpers

This package connects the complete actual `_wordAt` and `_setWord` bodies to
byte-level memory effects. `generate.py` checks their pinned solc AST structure
and translates their actual address expressions using modulo-2^256 addition and
multiplication. The reviewed structural gate fixes the load/store instruction,
operands, signatures and complete function bodies; address expressions are the
only supported variable slots. Verification never bootstraps the gate.

`Address` proves that a complete in-bounds word in a well-framed Solidity bytes
object has address `base + 32 + 32*index`, with no modular wrap. `Read` connects
actual loading to independent big-endian decoding. `Write` connects actual
storage to replacement of precisely one decoded word. It preserves memory
length, the bytes length header and every byte outside the selected word.
`Assignment` additionally preserves trailing partial-word bytes; helper proofs
do not assume alignment. `DisjointFrame` preserves a separate bytes object's
header and payload when its complete frame does not overlap the write interval.

Memory is modeled as a finite byte sequence shorter than 2^256. The caller must
supply an existing valid length-header/payload frame and complete-word index;
write values must fit uint256. The interpretation of EVM mload/mstore, source
translation, solc AST, and Dafny/Boogie/Z3 remain trusted. Physical allocation,
caller-provided disjointness, gas/resources, outer ABI behavior and verified
compiler lowering are outside this package. No new public entry point receives
completed source coverage until its entire implementation is connected.

The driver snapshots all inputs, regenerates and compares the adapter, checks
identical retained ABI round-trip evidence, verifies every local declaration,
checks zero auditor findings and formatting, and runs six finite public
`sortWords` EVM fixtures against the actual helpers. These cover empty/single,
first/last, odd middle, full-width unsigned/endian, multiple passes/duplicates,
and unaligned rejection. Two isolated address faults must still pass translation
but fail both the source address theorem and the concrete fixture suite. A
verification timeout never counts as a detected semantic fault.

Run from the repository root with pinned binaries:

```sh
python3 formal/collections/word-memory/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/word-memory/evidence/actual-word-helpers-v2
```

The retained manifest is authoritative for completion and counts. This is helper
source correspondence, not the completed sorting source theorem or a bytecode,
complexity, gas, deployment or historical-performance result.

The initial `actual-word-helpers` run failed because its fault-log recognizer did
not accept Dafny's postcondition-failure wording. Its successful ordinary proof
and fixture checks do not make that attempt a completed evidence baseline.

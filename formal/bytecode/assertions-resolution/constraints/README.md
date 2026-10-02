# Exact Assertions constraint bytecode

The retained decoder package is [decoder-bound-v3](evidence/decoder-bound-v3/manifest.json).
It reuses and verifies the immutable native include closure in
[decoder-native-v2](evidence/decoder-native-v2/manifest.json): 8,392 native checks,
zero errors, zero audit findings, exact source and tool hashes. The binding
package reproduces the current compiled runtime, regenerates the 206-instruction
certificate byte for byte, checks 72 complete native EVM decoder traces and
independent whole-heap results, and rejects the actual PC18492
`CALDATACOPY → MCOPY` mutant. The directed native mutation witness has one
postcondition failure and no timeout; 63 concrete cases reject its heap.
The generic mutant experiment timed out and is retained as failed evidence in
`decoder-bound-v1`; it does not count as a native mutant kill.

The decoder theorem starts at PC19377 and ends at the physical caller
continuation. Its inputs are arbitrary legal enum values, reference bytes and
length, subject to its explicit calldata, stack and allocation bounds. It proves
the returned record's kind, reference pointer, header, payload, free pointer and
zero footer. Actual caller jump targets must be certified instruction boundaries.
This theorem alone does not complete a public entry.

`LoopSpec.dfy` independently describes an arbitrary positional constraint array,
word values, leaf truth and total allocation cost. `DecoderFacts.dfy` discharges
the leaf representation and proves that new records preserve existing resolved
words and bytes. `LoopFacts.dfy` connects those statements to decoder admission
and the next heap. `Success.dfy` composes the exact initialization, preparation,
decoder, dispatch, physical leaf, increment and exit paths in a decreasing loop.
Its admitted non-OR all-Holds validator class passed 465 development checks; the
immutable full include closure is being retained separately in
`evidence/success-native-v1`. An incomplete manifest is not a passed proof.

The adjacent `constrained-raw` directory composes that validator with the RAW
resolver and its public wrapper. Those development proofs and EVM fixtures are
not substitutes for final native closure, runtime binding and mutation evidence.
Nested-OR rejection and OR short-circuiting, predicate-failure serialization,
malformed ABI classes, remaining fetchers, assertion wrappers and batch judging
remain separate obligations. No whole Assertions or whole `resolve` completion
claim follows from these packages.

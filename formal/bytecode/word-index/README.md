# Exact wordIndexOf runtime development

The generator extracts the current Collections runtime's PC-zero route, raw bytes
and bytes32 decoder, loop segments, reached arithmetic/slice/read helpers, hit and
miss branches, alignment error stores and physical scalar return. The source map
only located instructions; actual bytes, instruction boundaries and step proofs
must establish each path. Never edit generated certificates directly.

`Loop.dfy` composes the actual instruction traces with the finite count-index rank.
Its intended property is the first matching full-width calldata word or the word
count sentinel, with every earlier word unequal to the needle. No fixture bound,
execution fuel, callback stability or dropped-input argument substitutes for that
unbounded invariant. Empty inputs and unaligned inputs need the actual entry/error
connection. The raw decoder has five malformed frame classes under the explicit
calldata-size representation from four through 2^64-1; accepted loose offsets and
trailing data remain allowed.

All results here are development. The first accepted decoder run and isolated
extraction checks do not establish completed public bytecode evidence. Complete
native declaration/include inventories, stable generation, zero audit, canonical
runtime reproduction, independent physical EVM fixtures and semantic bytecode faults
must pass retention before a ledger or coverage update.

The shared reached EVM interpretation and instruction-boundary scanning, faithful
calldata/environment observations, fresh memory, sufficient reached execution and
allocation resources, and proof/EVM toolchains remain explicit trusted premises.
No source-to-whole-bytecode, unrestricted representation, gas, deployment,
performance or resource-availability claim follows from these developments.

Development results include the corrected accepted decoder and five raw paths
(13,148 obligations, stable inputs), the loop/branches/scalar package (1,421),
accepted connection (212), PC-zero accepted connection (38), corrected raw
partition (36), 26 complete EVM receipts and three semantic byte-fault detections.
The helper/segment/error/return inventory passed every component except a single
prefix timeout. Isolating the unchanged selector admission behind an opaque
predicate made the complete prefix pass 1,465 obligations in an isolated check.
Failed snapshots remain preserved and do not establish public evidence.

`verify.py` snapshots the finished package, resolves every root include file,
reproduces all three full canonical runtimes, regenerates every certificate,
checks formatting, verifies each module's complete native declaration/CSV
inventory, requires a zero-finding audit, and checks the immutable physical raw
rejection dependency before and after. The three byte faults skip an index,
return the wrong hit result, or reverse tail admission; each requires a
baseline-covered semantic postcondition failure and a contradictory EVM receipt.
Timeout, parse, type, generation and precondition failures are excluded.

Use the pinned Dafny and solc paths with a fresh evidence output directory.
Never restart a live verification because observation polling times out.
Only after retention and its checker pass may a ledger or coverage be updated.

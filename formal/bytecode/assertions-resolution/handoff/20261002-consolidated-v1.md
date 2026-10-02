# Resolution lane consolidated continuation

All paths are relative to `formal/bytecode/assertions-resolution` unless stated.
No production/shared sources edited. One native job, at most two cores per lane.
Frozen historical evidence has not been rewritten.

## New OR structural helper candidate

`constraints/or/evidence/structure-bound-consolidated-v1/manifest.json` passed
worker gates and was independently accepted by coordinator. Review:
`proof-workspace/work/coordinator-reviews-20261002/or-review.json`; root updated
`formal/bytecode/ASSERTIONS.md` with helper-only credit. Native closure
`structure-native-consolidated-v1` has 25 files / 828 checks. All four maps reproduce
byte-for-byte. Fresh Node v26.10.0 six independent policies pass; full stack/memory
replay covers 539 reached instructions over 19 structural segments. A mutation of
PC7889 SUB to ADD fails the universal independent kind-6 branch postcondition and
the concrete nested-after-true invalid-OR policy. Both failure receipts are retained.
Fresh compiler/runtime identity is hash-linked from coordinator receipt
`proof-workspace/work/coordinator-runtime-identity-20261002/identity.json`.

This is a helper over an independently supplied decoded nonempty child table and
first nested position. It does not establish allocation/record decoding, verdict
loops, ABI/public admission or complete public entries. Historical mapping scope
text inaccurately says empty OR; native code and new manifest explicitly scope
structural scan, with original maps retained unchanged.

Fresh runnable sources:
- `constraints/verify-modular-consolidated-v1.py` (and relocation receipt)
- `constraints/or/generate-structure-consolidated-v1.py` (and receipt)
- `constraints/or/evm-discovery-consolidated-v1.mjs` (and receipt)
- `constraints/or/check-structure-replay-consolidated-v1.py`
- `constraints/or/NativeStructureBranch.dfy`
- `constraints/or/retain-structure-binding-consolidated-v1.py`

## ConstraintFailed selector-bearing heap

`constraints/failed/Heap.dfy` now permits initial memory through `free+32`, but
requires both payload ends at/before `free`. Preserved ranges stop at `free+4`:
existing bytes below `free` and the first four selector bytes survive; the caller's
remaining selector MSTORE padding may be overwritten by the ABI head.
Filtered development v2 passed 489 checks; v1 retained successful native output
with failed CSV logger syntax, not accepted evidence.

Complete `Serialization.dfy`+`Spec.dfy` minimal-context closure
`constraints/failed/development/selector-serialization-native-consolidated-v2`
passed 37 files / 1505 checks. V1 retained one cold shared
`BytecodeExternalExecution.NoExternal` postcondition failure; v2 passed unchanged
120-second retry and reused only exact passed file closures. No shared edits.

The subsequent `Last` exposes prefix-preservation; the generic `Selector`
lemma instantiates that frame for canonical first-four selector bytes. Complete
current v5 closure PASSED 37 files / 1531 checks; Heap itself passed 448 checks.
V3 and v4 failed direct image-wrapper variants remain retained (timeout and
missing contract WF prerequisites); none were reused as successful proofs.
Current terminal evidence is
`constraints/failed/development/selector-serialization-native-consolidated-v5`.
All lane native and concrete sessions are terminal; no job remains live.

Canonical full `Spec.Error` equality, exact false caller and public-false class
remain open. Existing Serialization proves only computed-image physical REVERT.

## Next

1. Structural helper accepted by coordinator; preserve supplied-table scope.
2. Current v5 selector-serialization native closure passes; finish independent
   canonical head/two-blob `Spec.Error` equality, then caller PC8035→19793.
3. Nonempty OR allocation, memory record decoder induction, verdict short circuit,
   all-false error; retain structural-first nested rejection ordering.
4. Remaining resolver fetchers and public assert/judge/batch admission still open.

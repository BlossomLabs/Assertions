# Resolution proof lane restart handoff — 2026-10-02

Branch `pr-3`, workspace `/home/sem/assertions`. Agent `/root/resolution_61` owns `formal/bytecode/assertions-resolution`; production Solidity was not edited. The user asked to prepare for a computer restart. No new jobs were launched after the restart instruction. All lane proof/binder processes have stopped; scoped process inspection found none.

The pinned Assertions runtime is 20,049 bytes, SHA-256 `84ab614cb3395df4575bfb525e3278273361a7b7b75289d5b12dd13518b91903`. Dafny is `/home/sem/assertions-tools/dafny/dafny` (4.11); Z3 is its bundled `z3/bin/z3-4.12.1`; solc is `/home/sem/assertions-tools/solc-0.8.36`; Node is `/home/sem/assertions-tools/node-v24.14.0-linux-x64/bin/node`. Runtime function-debug data remains `/tmp/assertions-resolution-debug.json`, but regenerate that after reboot if `/tmp` is cleared.

## Accepted retained packages

All paths below are relative to this directory. Preserve their frozen source closures. They are internal helpers or complete public classes as stated, never a claim that the whole `resolve` entry is complete.

- `evidence/leaf-v4/manifest.json`: 6,564 native checks, all 22 non-OR leaf cases, physical success/false returns and BadData/BadRange REVERTs, complete audits, pinned runtime, fixtures and native/EVM mutants.
- `raw/evidence/raw-v6/manifest.json`: 971 native checks; 266-instruction RAW resolver helper, arbitrary bytes, zero constraints.
- `raw/public/evidence/public-raw-v1/manifest.json`: 1,388 native checks; complete PC0 → physical RETURN class, RAW/zero constraints.
- `constraints/evidence/leaf-frame-v1/manifest.json`: 167 native checks; leaf world-frame connection including terminal errors.
- `constraints/evidence/decoder-native-v2/manifest.json` plus `decoder-bound-v3/manifest.json`: 8,392 native checks; exact arbitrary calldata Constraint decoder and runtime/mutation binding.
- `constrained-raw/evidence/before-native-v1/manifest.json`: 16,990 native checks; exact 239-instruction RAW preparation PC3393 → validator PC7580.
- `constrained-raw/public/evidence/count-bound-v3/manifest.json`: complete PC0 → physical ReturnDataOutOfBounds REVERT when constraint count exceeds complete RAW words. 1,998 native checks over 31 files. No constraint record contents are read or admitted in this class; actual LT→GT mutant was killed natively and by receipts.
- **New** `constrained-raw/public/evidence/success-bound-v7/manifest.json` and `first-error-bound-v7/manifest.json`: both PASSED with complete 85-file minimal-context native closure, 11,077 checks, all declarations/zero-finding audits, pinned compiler/runtime identity, reproducible maps, complete PUSH-aware return certificates, 18 success or 22 first-error receipts, actual RETURN→REVERT or BadData selector mutants killed by native semantic postconditions and receipts. They cover arbitrary non-OR constraint counts, and arbitrary successful prefixes before BadData/BadRange respectively. Internal interfaces are `constrained-raw/Connection.dfy` and `Error.dfy`; sibling has been told they are frozen.
- **New** `constraints/or/evidence/empty-bound-v5/manifest.json`: PASSED; 1,207 native checks over 33 files. Exact in-memory empty OR decoder PC19462 → physical InvalidOrConstraint REVERT, including full world frame, independent error bytes, 179-instruction exact helper receipt, runtime/maps/hashes/scanned continuations and native/EVM selector mutation. Separate 35-instruction prepare PC7723 →19462 is included. Public admission and nonempty/nested OR are open.
- **New** `constraints/or/evidence/structure-segments-native-v1/manifest.json`: PASSED; 662 native checks over 23 files with complete per-file audits/hashes. Four exact structural segments: count>0 start (11 instructions), arbitrary non-nested iteration (42), nested OR physical InvalidOrConstraint REVERT (74), scan exit (8). Development counts are 33/95/301/27. Runtime/mutation binding for this new segment package is still open.

The fresh successful matrix used by both public v7 bindings is `constrained-raw/public/evidence/success-error-modular-native-v5/manifest.json`. Failed v1/v3/v4 matrices and both binding v6 outcomes remain retained. V4 had all native bodies pass but rejected generic sequence inventory bookkeeping; isolated v5 parser correctly inventories generic `<T>` declarations. Reuse is per-file against an exact matched transitive minimal dependency closure and executable hashes, not whole-union identity. `constraints/verify-modular-v5.py` is the latest runner. It verifies every declaration and function WF, permits genuinely zero-obligation definition-only files, and records complete prior evidence provenance. No failed native obligation is reused.

## Terminal development work saved for restart

`restart/20261002-v1/manifest.json` retains sources, exact minimal include-closure hashes, tool hashes and native logs/CSVs for these passed filtered development jobs:

| Module | Checks | Last shell handle | Terminal result |
| --- | ---: | --- | --- |
| ConstraintFailed Start | 52 | 33577 | exit 0 |
| ConstraintFailed Heads | 250 | 82219 | exit 0 |
| ConstraintFailed End | 84 | 59707 | exit 0 |
| ConstraintFailed Heap v4 | 416 | 53161 | exit 0, handle closed |
| ConstraintFailed Serialization v2 | 9 | 68355 | exit 0 |
| OR arbitrary structural composition | 162 | 95009 | exit 0 |

All four OR segment handles (74731, 8258, 34260, 17211), segment closure handle 53293, empty connection handle 38592, empty binder handle 36628, public matrix handle 73291 and both public binder handles 10876/18451 also finished exit 0. No handle remains live. Earlier failures are preserved; do not resume terminal handles.

`constraints/failed/Serialization.dfy` composes 12 Start +40 first blob +51 Heads +40 second blob +22 End =165 reached instructions, preserving the external frame and reaching physical REVERT1431 of the computed memory slice. The independent canonical error specification is `constraints/failed/Spec.dfy`. The two arbitrary-length dynamic byte encoders use destinations congruent to 4 modulo 32, so the private unaligned `BlobSpec/BlobMemory/Blob.generated/BlobConnection` proofs are necessary; sibling's aligned serializer cannot be substituted. Their development checks passed (118 encoder, 14 memory, 6 connection), but complete fresh acceptance remains open.

**Important next memory correction:** the current passed `failed/Heap.dfy` requires initial `|mem| <= free`, which proves its stated physical-image theorem but is too narrow to compose the real caller after its selector MSTORE at `free`. That store makes initial serializer memory approximately `free+32`. Broaden the independent initial heap to admit selector-bearing memory up to `free+32`, keep both source payloads ending at or before `free`, and change preserved old-memory ranges from all `j<|mem|` to bytes before `free` plus a separate first-four selector-byte frame. Then prove the final memory slice equals independent `Spec.Error`. No canonical ConstraintFailed/public-false completion claim has been made.

`constraints/or/Structure.dfy` passed 162 checks for a universal arbitrary-length scan, proving every earlier child is not OR before either scan exit PC7943 or exact nested error. It uses independent `Table` and first nested position `limit`. It has not yet received a complete include-closure/audit/runtime/mutation gate. Generator `generate-structure.py` derives all four segments from exact bytecode. The structural scan deliberately precedes alternative verdict evaluation, matching the nested-after-true receipt.

## Next work after user resumes

1. Retain the complete minimal-context closure for `constraints/or/Structure.dfy`, reusing only exact matched passed segment dependencies, then bind its maps/runtime/independent receipts and an actual structural-branch mutation. Compose it with the arbitrary nonempty in-memory Constraint[] decoder, which still needs allocation/fill/record-decode induction. Current empty decoder alone does not handle nonempty arrays.
2. Correct and close the ConstraintFailed memory premise described above; prove independent canonical selector/head/two-blob bytes, retain full native/audit/runtime/mutation closure, and add exact failed-leaf caller PC8035 →19793. Then compose arbitrary successful prefixes followed by a false non-OR constraint into the complete public false class.
3. Build nonempty OR allocation/decoding and evaluation short-circuit induction, including empty/nested structural rejection before verdicts, BadData/BadRange ordering, successful alternatives and all-false canonical ConstraintFailed.
4. Remaining resolver fetchers (staticcall, balance, inlined expressions etc.), judge/assertParam/batch loops and their public admissions remain open. Root handles navigation/get codec and sibling handles primitive/control/gather proofs. Complete helper/class evidence does not complete a public entry.

No live proof should be restarted solely to adjust CPU. When work resumes, prior user authorization permits about six solver workers in this lane, coordinated with parent and sibling and measured available RAM. Do not launch any work during the requested restart pause.

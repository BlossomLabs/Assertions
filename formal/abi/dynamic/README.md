# Recursive dynamic validation correspondence

The [complete baseline](../evidence/dynamic-body-verified/manifest.json) passes
**159 lemmas, 74 proof methods and 4,511 verification batches**, all 16 dynamic
EVM oracle tests, source-generation checks, audit and formatting. It verifies
every dependency module body once. These totals include the earlier static and
parser work and must not be added to their counts.

`Body.generated.dfy` connects the complete recursive array and tuple walker,
including the second tuple pass, to the independent `Walk`/`WalkFields`
specification. `Validation.generated.dfy` connects the dynamic envelope and
exact-consumption checks and the whole noncached `validate` dispatch, including
malformed descriptors. Successful validation implies a canonical mathematical
encoding. Acceptance equivalence holds when the recorded cursor/resource
conditions exclude the separately characterized arithmetic panic.

`Zero.dfy` retains zero-copy traversal precisely: no value words are read, but
visited tuple cursor additions can still overflow. Its `ZeroFits` condition
describes the cursors actually visited rather than requiring an unused final
cursor to fit. `Semantics.dfy` derives a sufficient `CursorRoom` condition from
`|value| + 32 * 2^32 * |descriptor| < 2^256`. This places no chosen cap on
nesting depth, tuple arity or array count. Adequate EVM gas, stack, allocation and
nonwrapping physical memory/calldata layout remain assumptions.

The restricted AST translation and source-loop factoring are trusted. The
complete AST gate prevents unsupported source changes from silently retaining
the correspondence. Arithmetic kernels and the bytes/string wrapper are derived
from the source AST. This milestone covers the default Value error context;
the [construction successor](../construction/README.md) adds the other contexts,
layout and construction/splitting.

The [fault campaign](../evidence/dynamic-body-faults/mutations.json) detects all
three actual Solidity mutations in both named proofs and the EVM: wrong body
extent, wrong second-pass descriptor cursor and wrong tuple word stride. All
16 EVM tests are accounted for on each mutant. No timeout counts as detection.

Retained unsuccessful runs are explicit history:

- `dynamic-body-connection`: proof obligations passed, but formatting and source
  drift prevented a complete baseline.
- `dynamic-body-complete`: a proof-hint failure and source drift; not a proof.
- `dynamic-body-mutations`: two detected faults and one translator rejection.
  The replacement `dynamic-body-faults` campaign uses a same-width arithmetic
  fault, preserving unrelated solc source-location annotations, and succeeds.

Reproduce with the pinned toolchain and a fresh directory:

```sh
python3 -B formal/abi/dynamic/verify.py \
  --dafny /path/to/dafny/dafny \
  --solc /path/to/solc-0.8.36 \
  --connection-evidence formal/abi/evidence/connection-static-heads/manifest.json \
  --word-evidence formal/abi/evidence/abi-codec-words-complete/manifest.json \
  --output /tmp/abi-dynamic-validation

python3 -B formal/abi/dynamic/faults.py \
  --dafny /path/to/dafny/dafny \
  --solc /path/to/solc-0.8.36 \
  --baseline /tmp/abi-dynamic-validation/manifest.json \
  --output /tmp/abi-dynamic-faults
```

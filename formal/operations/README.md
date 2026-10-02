# Operations conditional source verification

All 92 public ABI entries have retained conditional source evidence on the current
corrected source (SHA256
`9203dfb7d3213c599f3f5390725e5be3e83dbdcc14b267642a042e652fb325ce`).
The 24 package ledgers, proof premises and current manifests are indexed in
`verification-plan.json`; old and failed snapshots remain preserved. The
historical 84-entry pre-guard-fix evidence is distinct from current evidence.

`check-source-coverage.py` matches the exact complete compiler public
signature/selector inventory to the ledger union and independently runs every
package checker. Each checks current and frozen input/tool/evidence identity,
native declaration/obligation receipts, zero audit, concrete EVM and semantic
source-mutation receipts, and current source regeneration. This is a check of
retained proofs, rather than a new native solver run.

```
python3 -B formal/operations/check-source-coverage.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791
```

The source-to-Dafny correspondence remains conditional on reviewed restricted
compiler-AST lowering and primitive/representation semantics. Reached internal
mathematical helpers are connected to proved source semantics; external world,
hash, call/gas observations, physical memory/resources and compiler ABI
serialization premises are listed per package. Encoding reuses the independently
identity-checked retained codec graph; other reached-helper graphs are freshly
verified in their retained source packages.

`fixed-point` proves exact finite-word quantized rational kernels for expWad and
lnWad, with range reduction, normalization, positive denominators and precise
error/guard behavior. Real exp/log equality, approximation error, inverse error,
monotonicity and ideal positivity claims remain open.

This source coverage does not prove exact runtime bytecode, deployment, gas or
performance. Operations exact-bytecode work follows completion of the original
49 Assertions/Expressions/Collections exact-bytecode entries in the parent track.
No commit, push, stash or reset is part of this source work.

# Kontrol checks for the signed modular runtime

`SignedModSpec.t.sol` checks the **exact Hardhat runtime bytes**, including its
metadata, at a fixed address using `vm.etch`. It does not recompile a substitute
Operations contract. The runner checks that the artifact's compiler input matches
the current Operations source and records the compiler settings and runtime hash.

The [retained result](../../../docs/verification/signed-mod/kontrol/README.md)
is **two proved panic properties and two incomplete value properties**. All
outcomes, including solver errors and time limits, are accounted for explicitly.

Four properties partition the inputs:

| Property | Inputs and obligation |
|---|---|
| `prove_addZeroModulus` | All int256 `a,b`, `m=0`: exact 36-byte Panic(0x12). |
| `prove_mulZeroModulus` | All int256 `a,b`, `m=0`: exact 36-byte Panic(0x12). |
| `prove_addReference` | All int256 `a,b,m`, `m!=0`: successful 32-byte result equals the reference. |
| `prove_mulReference` | All int256 `a,b,m`, `m!=0`: successful 32-byte result equals the reference. |

The reference computes unsigned magnitudes using EVM two's-complement subtraction
and uses ADDMOD/MULMOD with their full-width intermediates. It omits the production
helper's signed-range panic branch: success is explicitly required, so the proof
must establish that this branch is unreachable on valid nonzero-modulus inputs.
Failed calls cannot disappear as discarded reverting paths: every target call is
low-level and both success and exact return/revert data are asserted.

These properties concern arithmetic with sufficient gas on Cancun. They make no
gas-exhaustion, deployment, malformed-calldata, or compiler-correctness claim.
No input magnitude is narrowed, no function is mocked, and no project-specific K
lemma or CSE summary is assumed. A proof of bytecode equality to this reference
must still be distinguished from a mechanically checked translation between the
reference and the separate Dafny mathematical specification.

`../Reference.dfy` models this oracle's word conversion, unsigned subtraction,
full-width modular arithmetic and sign restoration. `AddReferenceCorrect` and
`MulReferenceCorrect` establish equality to the original unbounded mathematical
specification for every nonzero int256 modulus, including `int256.min`. The
positive run verifies **all included lemmas**, not just the new obligations:
101 assertion batches pass. A sign-restoration mutation fails the corresponding
lemma. Mapping the Yul operations to this word model remains a manually reviewed
interface between the two verifiers; no certified Yul-to-Dafny translation is
claimed. See `docs/verification/signed-mod/reference/manifest.json` for evidence.

## Run

Requires the locally installed Docker image
`runtimeverificationinc/kontrol:ubuntu-jammy-1.0.255` and native solc
`0.8.36+commit.8a079791`. The runner resolves and pins the local image ID; it does
not pull images or use network access inside containers.

```sh
python3 formal/signed-mod/kontrol/run.py \
  --solc /path/to/solc-0.8.36 \
  --output /tmp/signed-mod-kontrol-evidence \
  --seconds 300

python3 formal/signed-mod/kontrol/check-harness.py \
  --solc /path/to/solc-0.8.36 \
  --output /tmp/signed-mod-kontrol-harness

dafny verify formal/signed-mod/Reference.dfy --verify-included-files \
  --cores 2 --verification-time-limit 30 \
  --solver-path /path/to/z3-4.12.1
```

Each property runs sequentially with two CPU cores, an 8 GiB memory limit,
3-second SMT queries without retries, and a wall-clock limit. The 400 expansion
limit leaves any remaining paths incomplete; it does not turn an unfinished
exploration into a bounded proof. There is no loop-unrolling assumption.
The runner refuses to overwrite evidence and checks source/artifact drift.

`prepare-backend.py` copies the pinned image's bundled `kontrol.base` backend
without modifying any file, verifies every copy's hash, and records the hashes.
This avoids a Kontrol 1.0.255 build-option issue: with both `keccak_lemmas` and
`auxiliary_lemmas` false, `kontrol/kompile.py` selects `KONTROL-FULL`. Loading the
bundled `KONTROL-BASE` also avoids rebuilding the generic backend for this project.
No previously generated gas-proof definition or custom finite-gas lemma is used.

`audit-proofs.py`, executed inside the same pinned image in the retained work
directory, reads Pyk's proof status, pending/failing nodes, admissions and bounds.
Only a completed proof without pending/failing/bounded nodes or admissions may
be cited as proved. Build errors, timeouts, and open paths remain incomplete.

Evidence is retained in `docs/verification/signed-mod/kontrol*`. Discovery runs
are separate from subsequent runs; they are never silently promoted to passes.

`Concrete.t.sol` calls the identical property bodies on a real EVM, with 1,024
fuzz cases across four tests and four fixed full-width cases in a fifth test.
The harness checker first recompiles the canonical Hardhat input and requires
byte-for-byte equality with its runtime artifact. It then recompiles an isolated
mutant that returns zero for zero modulus in both signed operations; the two
panic tests must fail. The production source and artifact are never modified.

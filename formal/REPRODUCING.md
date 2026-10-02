# Reproducing verification evidence

Git retains proof definitions, generator templates and gates, instruction/source
bindings, fixtures and verification/checker programs. Run output, logs, snapshots,
compiler caches and local evidence ledgers are intentionally ignored. A checkout
contains the machinery to rerun proofs, not a retained record that they passed.
Existing package READMEs describe their exact premises and verification commands.

Use Dafny 4.11.0 with its bundled Z3 4.12.1 and solc
0.8.36+commit.8a079791. Install the repository's locked Node/Solidity dependencies
and compile the canonical Hardhat artifacts before runtime-dependent generators.
The ABI word-classifier also requires Python with z3-solver 4.12.6. Verifiers check
tool versions and record executable hashes; equivalent versions alone do not
permit reuse of old native receipts.

## ABI prerequisite for tuple source proofs

`formal/operations/tuple-encode/codec-evidence.py` requires a completed production
ABI baseline at `formal/abi/evidence/production-abi-correspondence/manifest.json`.
Build it from the committed verifiers in this dependency order:

| Verifier under `formal/abi/` | Required earlier manifest arguments |
| --- | --- |
| `words/verify.py` | None; additionally supply `--smt-python` |
| `descriptor/verify.py` | `--word-evidence` |
| `shape/verify.py` | `--descriptor-evidence` |
| `parser/verify.py` | `--shape-evidence` |
| `tuples/verify.py` | `--parser-evidence`, `--word-evidence` |
| `connection/verify.py` | `--tuple-evidence`, `--word-evidence` |
| `dynamic/verify.py` | `--connection-evidence`, `--word-evidence` |
| `construction/verify.py` | `--dynamic-evidence` |

Every verifier requires `--dafny`, `--solc` and a fresh `--output` directory.
Supply each prerequisite's newly produced `manifest.json`, and give the final
construction verifier the production baseline path above as its output directory.
Do not supply `--reuse-evidence` when starting without retained native receipts.
Run the mutation verifiers listed in the corresponding package READMEs as well.
Only a complete passing baseline can satisfy the tuple verifier's reuse checks.
An interrupted or timed-out baseline remains incomplete; retain it for diagnosis.

## Package regeneration and checking

Each package's `generate.py` recreates compiler requests/output and translated
models from the current contracts. Regenerate in a fresh directory and compare
against the committed proof/binding files as its verifier specifies; never edit
generated models by hand. Missing generated compiler caches are expected.

Run prerequisites before dependent package verifiers. Where a verifier requires
an evidence path or reuse receipt, generate that prerequisite first. In particular,
a reuse-only verifier cannot bootstrap its own missing native baseline; use the
package's original full verifier first. Keep outputs at the paths required by the
dependent verifier, or use its explicit evidence/output arguments.

Independent package checkers accepting `--manifest` can inspect a fresh run
directly. Historical ledger wrappers bind saved manifest hashes and are not a
fresh-run entrypoint. Generate new local ledgers from newly passing manifests,
check them independently, then bind coverage to their new hashes. Do not copy old
success statuses or hashes into a new run. Aggregate coverage depends on those
local records and cannot be inferred from committed theorem declarations.

The ignore rules also name existing unfinished/obsolete campaigns. Remove a
campaign's rule when its completed reproduction package is ready for review.
Source proofs retain their representation, resource and observation assumptions;
exact bytecode verification remains a separate track. Neither track alone implies
gas, deployment or performance claims.

# Reproducing verification evidence

Git retains handwritten proof definitions, generator templates, frozen AST gates,
specifications, fixtures and verification/checker programs. Generated Dafny models
and instruction/source mapping JSON are recreated locally. Run output, logs, snapshots,
compiler caches and local evidence ledgers are intentionally ignored. A checkout
contains the machinery to rerun proofs, not a retained record that they passed.
Existing package READMEs describe their exact premises and verification commands.
Documented development runners remain available for selected component checks;
unreferenced standalone development-run wrappers are omitted. Retained verifiers,
generators, independent checkers and their proof dependencies remain in the tree.

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

Before running package verifiers in a fresh checkout, recreate their generated
inputs from the repository root:

```sh
python scripts/regenerate-formal.py --solc /path/to/solc --jobs 4
```

Use a Python environment with `z3-solver==4.12.6.0`. Existing generators invoke
the Dafny formatter at `/tmp/assertions-dafny-4.11.0/dafny/dafny`; unpack the pinned
Dafny distribution there. Install locked dependencies and run `pnpm compile`
first so runtime generators can check the canonical Hardhat artifacts.

`formal/generated-files.json` inventories the reproduction commands and SHA-256
hashes of the removed outputs. The regeneration script checks every recreated
file against those pins and stops on missing files, generator failures or drift.
The pins hash Dafny bytes exactly. JSON mappings use canonical JSON (sorted object
keys and compact separators) so Python dictionary ordering does not cause drift;
every key, value and array order remains checked.
It never passes `--bootstrap`: frozen `structure.json`, entry inventories,
mathematical input hashes and proof specifications remain committed review inputs.
An intentional model change requires reviewing its generator/gates and explicitly
updating the affected output hashes. Hash agreement establishes reproduction;
it does not establish native verification or a passing evidence baseline.

Use `python scripts/regenerate-formal.py --list` to list package names.
`--package formal/abi/source` (repeatable) regenerates selected packages together
with their generated dependencies. Packages run in dependency order; `--jobs`
controls concurrency for independent packages (the default is one).
Outputs are ignored by Git. CI should upload resulting evidence, logs
and receipts as artifacts rather than commit them.

Each package's `generate.py` recreates compiler requests/output and translated
models from the current contracts. Verifiers still regenerate in fresh directories
and compare against these locally recreated models and bindings; never edit
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

Source proofs retain their representation, resource and observation assumptions;
exact bytecode verification remains a separate track. Neither track alone implies
gas, deployment or performance claims.

## Formatting review inputs

Keep AST gates, inventories and specifications readable with short objects and
arrays on one line and larger structures indented:

```sh
python scripts/format-formal-json.py
python scripts/format-formal-json.py --check
```

The formatter processes tracked JSON under `formal/`, preserves object order and
checks that parsing its output produces the original data. It changes formatting,
never gate expectations. Native evidence still binds exact input-file hashes;
use fresh receipts after formatting rather than reusing old input bindings.

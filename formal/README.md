# Source proof library

This is the project's primary formal proof interface. Canonical sources are
organized by contract under `source/assertions`, `source/operations`, `source/collections`
and `source/expressions`. `source/abi` holds shared ABI proofs; `foundations` holds
reusable memory, sequence and cache facts. Every package has a complete import
closure and an explicit native verification policy.

```sh
python3 formal/tools/bootstrap_adapters.py --fetch
python3 formal/tools/check.py
python3 formal/tools/query.py --contract Assertions --kind lemma --show
python3 formal/tools/status.py
python3 formal/tools/readiness.py
```

The checker needs Python, this library and the current public claim ledger. The 469 canonical files preserve
3,474 original declaration identities and 45 additional helper declarations.
Contract declaration indexes describe canonical interfaces; they are not public claims.
The registry contains 132 proof packages and four generation intermediates.
[Claim mapping rules](CLAIMS.md) describe the integration.
`claims.json` connects the current `docs/claim-evidence.json` IDs and wording to
reviewed theorem mappings. All claims initially remain unmapped; historical
mappings and migration statuses have been removed. These are inventory counts,
not proof completion percentages.

## Verification

Install Dafny 4.11.0, Z3 4.12.1 and solc 0.8.36 into the expected `proof-tools`
paths. Native runs use two cores, manual lemma induction, isolated assertions and
a 30-second per-obligation limit. Output directories must be fresh.

```sh
python3 formal/tools/verify.py concat --output /tmp/fresh-concat
python3 formal/tools/verify.py concat --output /tmp/fresh-concat --run
python3 formal/tools/review.py concat --evidence /tmp/fresh-concat --output /tmp/fresh-concat-review.json
python3 formal/tools/campaign.py --output /tmp/fresh-library-campaign
```

The runner snapshots complete source closures, producer scripts and descriptors,
and binds source, tool and evidence hashes. Review checks the exact commands,
all method/lemma batches, zero audits, full formatting and snapshot identity.
The fixed-point accuracy proofs retain the original caller domains and mathematical
error bounds. A proved postcondition hint supplies denominator well-formedness
without adding a caller premise.

Passing native gates does not establish production-source correspondence or
exact-bytecode equivalence. No historical native acceptance is transferred to
this branch.

## Source generation

Restricted generators and frozen AST gates are self-contained under `generators`.
Thirteen Operations families are configured: scalars, environment, byte bounds,
word matching, ASCII, binary log, checked power, decimal digits, decimal rendering,
decimal units, UTF-8, integer root and raw call. Other families remain pending.
They require the repository's Solidity sources and pinned npm dependencies.

```sh
python3 formal/tools/generate.py original-operations-scalars --output /tmp/fresh-scalar-generation
python3 formal/tools/review_generation.py original-operations-scalars --evidence /tmp/fresh-scalar-generation --output /tmp/fresh-scalar-review.json
```

Independent review replays the pinned compiler and frozen generator, checks
compiler settings and mapping, and compares every canonical declaration
interface and body. Restricted translation, memory/decoder behavior and resource
premises remain explicit. Fault gates and independent source acceptance are
separate requirements.

## Historical proofs and provenance

Earlier source trees, migration variants, bytecode proofs and campaign evidence
remain on [PR #3](https://github.com/BlossomLabs/Assertions/pull/3), branch
`codex/formal-proofs-pr`, at export commit
`4e53bac7`. Some selected implementations and
receipts were local work beyond that commit; their original path/hash provenance
is preserved, and their working tree remains intact.

`preservation.json` binds the exported canonical proof bodies and interfaces.
`canonical-sources.json` retains artifact provenance needed to audit preservation.
Public claim coverage uses only the current mappings in `claims.json`.

The library remains under verification. `status.py` and `readiness.py` report
current evidence; absence of evidence stays pending. Proof sources, generators
and frozen gates are tracked, while native evidence and compiler outputs remain
local/CI artifacts. Production contracts and deployment artifacts are unchanged.

## Layout and evidence

```text
formal/
  source/        Contract models, source proofs, declaration indexes and AST gates
  bytecode/      Future exact-runtime proof packages
  foundations/   Shared mathematical, word, sequence and memory facts
  bridges/       Future source-to-bytecode representation proofs
  tools/         Uniform verification, generation and independent review
```

Package descriptors, provenance bindings and current claim mappings live at the
root alongside this guide. `bytecode/` and `bridges/` are intentionally empty
proof scaffolds; they grant no proof credit.

`docs/claims.md` remains the public claims ledger. This library supplies precise
specifications, premises and evidence links; inventories and declaration counts
do not create public claims. Halmos properties stay under `contracts/tests/` and
provide separate EVM evidence with their recorded bounds and exclusions. Source
theorems, exact-runtime correspondence, Halmos runs, concrete tests and mutation
results must remain separately identifiable.

## Ignored generated adapters

The 126 `*.generated.dfy` adapters are untracked. Before checking or verifying a
clean checkout, run `python3 formal/tools/bootstrap_adapters.py --fetch`. The
manifest pins their historical save commit and both archived and relocated
SHA-256 hashes. Bootstrap restores those artifacts and rewrites only includes;
it refuses edited files and verifies every expected byte. The historical save
must be available on the remote branch before a fresh clone can fetch it.

Artifact bootstrap is distinct from production AST generation. Thirteen
Operations families support fresh compiler/generator replay; other families still
need that generation coverage. Restoring an adapter grants no proof credit.

# Source proof library

This is the project's primary formal proof interface. Canonical sources are
organized by contract under `source/assertions`, `source/operations`, `source/collections`
and `source/expressions`. `source/abi` holds shared ABI proofs; `foundations` holds
reusable memory, sequence and cache facts. Every package has a complete import
closure and an explicit native verification policy.

```sh
python3 formal/tools/check.py
python3 formal/tools/query.py --contract Assertions --kind lemma --show
python3 formal/tools/status.py
python3 formal/tools/readiness.py
```

The checker needs only Python and this library. The 469 canonical files preserve
3,474 original declaration identities and 21 additional helper declarations.
The contract indexes retain 3,481 provenance records, including seven duplicate
original adapter identities. The registry contains 132 proof packages and four
generation intermediates. Its 106 retained ledgers preserve premises and
qualifications; all 863 exact declaration references resolve uniquely. These are
inventory counts, not proof completion percentages.

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
`9de93eb4ad3241f6a6a507c6d015c9de7fedc492`. Some selected implementations and
receipts were local work beyond that commit; their original path/hash provenance
is preserved, and their working tree remains intact.

`preservation.json` binds the exported canonical proof bodies and interfaces.
`canonical-sources.json`, contract claims and retained ledger indexes record
original and selected implementation hashes as provenance. They are not runtime
dependencies: day-to-day library checks, queries and native verification do not
load the historical trees.

The library remains under verification. `status.py` and `readiness.py` report
current evidence; absence of evidence stays pending. Proof sources, generators
and frozen gates are tracked, while native evidence and compiler outputs remain
local/CI artifacts. Production contracts and deployment artifacts are unchanged.

## Layout and evidence

```text
formal/
  source/        Contract models, source proofs, claim indexes and AST gates
  bytecode/      Future exact-runtime proof packages
  foundations/   Shared mathematical, word, sequence and memory facts
  bridges/       Future source-to-bytecode representation proofs
  tools/         Uniform verification, generation and independent review
```

Package descriptors, provenance bindings and claim-ledger indexes live at the
root alongside this guide. `bytecode/` and `bridges/` are intentionally empty
proof scaffolds; they grant no proof credit.

`docs/claims.md` remains the public claims ledger. This library supplies precise
specifications, premises and evidence links; inventories and declaration counts
do not create public claims. Halmos properties stay under `contracts/tests/` and
provide separate EVM evidence with their recorded bounds and exclusions. Source
theorems, exact-runtime correspondence, Halmos runs, concrete tests and mutation
results must remain separately identifiable.

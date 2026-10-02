# Canonical source proof library

Start here instead of selecting a `migration-v*` directory by name. Canonical proof sources live under `src/assertions`, `src/operations`, `src/collections`, `src/expressions`, `src/abi` and `src/foundations`. `registry.json`
selects source packages; `contracts/<name>/claims.json` indexes complete preserved
logical interfaces and implementation hashes. Original-file/symbol identity is
stable across implementation replacements. Shared ABI has its own index because
all four contracts consume it.

Run from the repository root:

```sh
python3 formal/source/library/check.py
python3 formal/source/library/check.py --list
python3 formal/source/library/verify.py concat --output /tmp/fresh-concat-evidence
# Inspect the plan first; execute with --run and a fresh output directory.
```

The checker validates registry mapping hashes, current original and implementation
hashes, declaration kinds, and complete logical interfaces. It does not run a
solver or grant proof acceptance. Native verification must use each package's
complete import/declaration closure and retained acceptance rules.

## Package layers

Each package keeps mathematical definitions and reusable facts separate from
source execution adapters and correspondence arguments. Existing package files
retain their original names (`Model`, `Semantics`, `Properties`, generated control
or source adapters, and `Connection`/`Refinement`). Canonical files preserve the selected proof bodies; index entries retain their
original identities and provenance. Each package has its own complete import closure.

`accepted-conditional-source` means the original explicit source premises remain;
`native-passed-correspondence-pending` means native proofs passed but full source
acceptance is unfinished; `native-incomplete` means a complete passing closure is
missing. None grants exact-bytecode credit.

## Shared foundations

Foundations under `src/foundations` provide total-map and sequence
memory framing, point updates, replacement spans, flattening and memo order.
Consumers retain explicit representation bridges. Immutable implementation
versions and evidence remain retained; the canonical package selection can change
only with a fresh complete-interface mapping and appropriate verification.

## Completion requirements

The registry now covers eight restructured families plus 128 original source
package roots. It retains 3,481 provenance records representing 3,474 canonical original
declarations, plus 21 additional helper declarations. There are 461 original
files and 106 retained ledgers reconciled in `original-inventory.json`. Of the
136 descriptors, 132 are proof packages and four are generation intermediates;
the intermediates are retained as generator output rather than runnable packages.
Original package status is unrecertified; these counts are not accepted public
claims or proof-completion percentages. The conventional source selection still
requires review against ledger-referenced historical alternatives. A finished library requires:

1. Resolve original ledger references, templates and generated adapters into one
   authoritative package inventory, without counting historical alternatives.
2. Assign every active declaration and public claim to a contract or shared
   foundation, retaining original assumptions, errors and resource domains.
3. Complete native closures, source generation/correspondence, fault gates and
   independent acceptance for each package.
4. Maintain the uniform `verify.py` entry point for each selected package with
   explicit tools, resource limits, immutable output and dependency hashes.
5. Publish shared interfaces and explicit source/bytecode representation bridges.

The old source proofs, migration implementations and retained evidence remain
preserved. The library is the stable navigation and interface boundary; its
completion is not implied by index generation.

Package descriptors live under `packages/<id>/package.json`. They bind all selected implementations and recursively included dependencies, classify proof layers, and enumerate sufficient verification roots. `check.py` rejects omitted implementations, unbound imports, unreachable files or changed interfaces. `verify.py` snapshots complete closures, uses pinned native tools with original limits, runs proof/audit/format gates, and binds source/tool/evidence hashes. Passing these native gates is separate from source acceptance.

## Canonical implementation paths

`canonical-sources.json` binds selected original/restructured implementations to canonical files. Only include paths change; every complete declaration interface and body is compared byte-for-byte. `packages/<id>/canonical.json` binds the resulting complete dependency closure. The uniform runner uses canonical descriptors by default. Fresh native verification is required after relocation, and does not inherit source acceptance automatically. Contract claim indexes link directly to canonical files and consolidate seven duplicate provenance records into 3,474 canonical original declarations.

Canonical concat has fresh native evidence in `evidence/native/concat-relocation-v1`: 307 rows, zero audit findings, formatting clean and source/snapshot/tool hashes unchanged. The archived manifest retains its actual `/tmp` execution paths as provenance; the preserved evidence is not rewritten. Canonical ABI has independently reviewed native evidence in
`evidence/native/abi-relocation-v1`: 393 declarations and 24,298 passing batches.
`status.py` also recognizes hash-identical subclosures covered by these reviews,
and identifies the covering package without attributing its full batch count to
the smaller package. Source correspondence acceptance remains separate.

## Using the library

Find a contract's lemmas and their complete assumptions:

```sh
python3 formal/source/library/query.py --contract Assertions --kind lemma --search frame --show
python3 formal/source/library/status.py
```

Inspect a native plan, execute it with a fresh output directory, then independently
review the result:

```sh
python3 formal/source/library/verify.py concat --output /tmp/new-concat-proof
python3 formal/source/library/verify.py concat --output /tmp/new-concat-proof --run
python3 formal/source/library/review.py concat --evidence /tmp/new-concat-proof --output /tmp/new-concat-review.json
python3 -m unittest discover -s formal/source/library/tests -v
```

`review.py` reparses CSVs/logs, requires all lemma/method declarations to have
passing batches, verifies complete import coverage, zero audits, formatting and
current source/snapshot/tool/evidence hashes. A test removes an entry's actual
proof batches while leaving a green summary and confirms rejection. Review
results explicitly distinguish native verification from source acceptance.

`foundations/registry.json` publishes shared interfaces and transitive consumers;
`dependency-graph.json` records every direct canonical include. Use those links
when updating a foundational fact or constructing a bytecode representation
bridge. Do not infer bytecode equivalence from source-library success.

## Retained claim ledgers

`claim-ledgers.json` retains the 106 source ledgers, their claims, assumptions,
partial-claim qualifications and evidence references. Its 863 exact qualified
declaration references all resolve uniquely to canonical files and owning proof
packages. This is navigation into preserved claims; historical verdicts remain
unrecertified and do not establish canonical source acceptance. Prose is retained
verbatim and is not interpreted as a declaration reference.

Validate the ledger index against current sources and ledger hashes:

```sh
python3 formal/source/library/ledger_index.py --check
```

## Current canonical native closures

Each row has a fresh complete native run and independent CSV, command, audit,
format and hash review under `evidence/native` and `evidence/reviews`. These
counts measure declarations and verification batches, not public claim coverage.

| Package | Declarations | Passing batches |
| --- | ---: | ---: |
| concat | 31 | 307 |
| replace-suite | 84 | 1,388 |
| word-memory | 52 | 634 |
| word-windows | 82 | 1,079 |
| constraints | 32 | 300 |
| expressions-recursive | 29 | 523 |
| core-raw | 149 | 1,220 |
| abi | 393 | 24,298 |

Closures overlap, so their declaration and batch counts must not be summed into
a library completion percentage. Use `status.py` for current hash-bound coverage.
Source generation, fault gates and source acceptance remain separate obligations.

## Full-library verification and claim readiness

`campaign.py` plans maximal uncovered complete closures, then runs and reviews
them sequentially. Failed closures retain their evidence and do not gain credit.
The initial remaining-closure plan covers 104 packages with 39 distinct runs.

```sh
python3 formal/source/library/campaign.py --output /tmp/fresh-library-campaign
python3 formal/source/library/campaign.py --output /tmp/fresh-library-campaign --run
python3 formal/source/library/readiness.py
```

`readiness.py` connects retained ledger references to current native coverage.
Even complete coverage of every named declaration leaves independent source
correspondence, semantic faults and retained premises to review. It does not
interpret unnamed or prose claims as verified.

New native manifests also bind and preserve producer scripts, the canonical
descriptor, registry and Python identity. Independent review checks the exact
proof/audit/format commands, roots, solver and resource policy, including every
format input. Older evidence without producer snapshots is explicitly identified
as such in its review; it retains its original provenance.

## Fresh adapter generation

The uniform `generate.py` supports 13 Operations adapter families: scalars,
environment, byte bounds, word matching, ASCII, binary log, checked power,
decimal digits, decimal rendering, decimal units, UTF-8, integer root and raw call. Each has fresh generation evidence and an
independent compiler/generator replay under `evidence/generation` and
`evidence/reviews`. It
stages the restricted generator and AST templates into a fresh directory, uses
the pinned compiler, preserves source inputs and compiler output, and compares
every generated declaration interface and body with the canonical adapter.
Original generators and proof sources remain read-only. `status.py --json`
reports generation evidence independently from native coverage. Other adapter families
still need their generation configuration and dependency review.

```sh
python3 formal/source/library/generate.py original-operations-scalars --output /tmp/fresh-scalar-generation
```

Generation correspondence is one source gate; it grants neither independent
source acceptance nor native or exact-bytecode credit by itself.

Independent generation review:

```sh
python3 formal/source/library/review_generation.py original-operations-scalars --evidence /tmp/fresh-scalar-generation --output /tmp/fresh-scalar-generation-review.json
```

The review checks frozen input hashes, pinned tool identities, exact compiler
source contents and output replay, generator replay, compiler settings, mapping,
and complete canonical declaration interfaces and bodies. A regression test
changes compiler settings and rehashes the evidence; the independent review
still rejects it.

Adapter formatting uses each canonical dependency closure and preserves relative
include paths in fresh staging. Dependencies may live in sibling packages; the
staging function rejects paths that would escape its evidence directory.
Generation and replay compare every complete adapter declaration, while native
proofs separately establish the properties of the imported mathematical models.

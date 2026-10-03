# Source proof library

This is the project's primary formal proof interface. Canonical sources are
organized by contract under `source/assertions`, `source/operations`, `source/collections`
and `source/expressions`. `source/abi` holds shared ABI proofs; `foundations` holds
reusable memory, sequence and cache facts. Every package has a complete import
closure and an explicit native verification policy.

```sh
python3 formal/tools/bootstrap_adapters.py --fetch
python3 formal/tools/bootstrap_evm.py --fetch
python3 formal/tools/check.py
python3 formal/tools/query.py --contract Assertions --kind lemma --show
python3 formal/tools/status.py
python3 formal/tools/readiness.py
```

The checker binds the canonical files, pinned foreign semantics and the current
public claim ledger. The original 3,474 declaration identities and 3,481 indexed
logical interfaces remain preserved. New adapter and bridge declarations have a
separate helper inventory. `check.py` prints current file and package counts;
`canonical-sources.json` retains the original export provenance.
Contract declaration indexes describe interfaces; they are not public claims.
[Claim mapping rules](CLAIMS.md) describe the integration.
`claims.json` connects the current `docs/claim-evidence.json` IDs and wording to
reviewed theorem mappings. All claims initially remain unmapped; historical
mappings and migration statuses have been removed. These are inventory counts,
not proof completion percentages.

## Verification

Run `bootstrap_evm.py --fetch` to restore checksummed Dafny 4.11.0, bundled
Z3 4.12.1, solc 0.8.36 and locked Python dependencies under `proof-tools/`.
The installer needs Python with pip and network access on its first run. It
refuses modified installs and publishes staged downloads only after hash checks. Native runs use two cores, manual lemma induction, isolated assertions and
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
  bytecode/      Conditional helper windows and exact compiler runtime bindings
  foundations/   Shared mathematical, word, sequence and memory facts
  bridges/       Source-equation refinements and conditional execution bridges
  dependencies/  Pinned upstream semantics, generic patch bundle and tool locks
  migrations/    Original interfaces, claim-ledger hashes and replacement theorems
  tools/         Uniform verification, generation and independent review
```

Package descriptors, provenance bindings and current claim mappings live at the
root alongside this guide. The DafnyEVM packages grant only the evidence scope
established by fresh verification and review; runtime capture alone grants no
bytecode correctness credit.

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

## DafnyEVM adoption

`dependencies/dafnyevm/lock.json` pins upstream `evm-dafny` and `DafnyCrypto`
commits. `generic.patch` contains only reusable interpreter modernization,
word/arithmetic/serialization proofs, memory-copy contracts, instruction summaries
and explicit backend injection. It has no Assertions selectors or program counters.
Apply it in a separate upstream checkout; bootstrap restores that checkout under
ignored `proof-tools/dafnyevm`. Assertions adapters and program-specific proofs
live under `foundations/Evm*`, `bridges/dafnyevm` and `bytecode/dafnyevm`.
The clean native closure excludes the optional crypto adapter and t8n driver;
their older cryptographic admission debt does not become accepted semantics.

Seven source models reuse generic wrapping words, signed division/remainder,
bitwise operations, serialization, full-word loads and sequence copying.
`migrations/dafnyevm.json` binds each changed declaration to a theorem in
`SourceRefinement.dfy`. Checks compare every original interface to the frozen
Git baseline and reject lost declarations, narrowed premises or weakened
conclusions. Mathematical heap domains, checked Solidity panic behavior and
independent ABI equations remain explicit. Logical shifts retain their original
source equations; this adoption does not claim a new universal shift bridge.
All 326 public IDs, wording, mappings and existing evidence remain unchanged.

```sh
python3 formal/tools/verify_evm.py --output /tmp/fresh-evm-adoption
python3 formal/tools/verify_evm.py --output /tmp/fresh-evm-adoption --run
python3 formal/tools/review_evm.py --evidence /tmp/fresh-evm-adoption --output formal/evidence/reviews/fresh-evm-adoption.json
FORMAL_NATIVE_EVIDENCE=/tmp/fresh-evm-adoption/native python3 -m unittest discover -s formal/tests -v
python3 formal/tools/campaign.py --migration --output /tmp/fresh-affected-source
```

The unified run verifies the complete `dafnyevm-adoption` closure with the normal
30-second policy, requires independent native review, replays scalar AST generation,
recaptures the current compiler runtime, compiles the reviewed interpreter snapshot
and compares 46 helper cases and four mutants against locked py-evm Cancun.
Fifteen generic arithmetic/memory cases and rejection probes also run. Independent
adoption review recompiles the runtime and interpreter and reruns the concrete cases.
Callbacks fail if a cryptographic backend is unexpectedly used. Unsupported smoke
opcodes, step limits and empty native result sets fail the gates.
The evidence fault tests also remove an entire refinement's result rows, alter
verification limits and tamper with snapshots while rebinding artifact hashes;
independent review must still reject each corrupted receipt.

The first/address success proofs start at explicit helper PCs and require adequate
gas, stacks, valid jump destinations and memory representations. Runtime binding
is conditional compiler-bytecode evidence, not deployed-runtime or public-entry
correctness. There is no complete Assertions proof, full Cancun opcode claim,
Prague/Osaka support claim or cryptographic proof. The Java compatibility build
uses the optional concrete adapter separately from clean native verification.

`--affected-source` additionally requires the full affected legacy source campaign.
Its acceptance is separate: older pending source obligations must be repaired and
reviewed, rather than hidden or inherited from inventory counts. `SourceClosure1.dfy`
collects the complete affected source roots without duplicate import verification.

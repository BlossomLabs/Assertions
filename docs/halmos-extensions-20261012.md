# Halmos coverage extensions, 2026-10-12

The complete fresh baseline passed all 209 properties: 189 from the preceding
campaign and 20 additional properties. None failed or remained incomplete. The
concrete gates passed 637 Foundry tests and 753 Hardhat tests (646 Solidity,
107 Node); two optional fork tests were skipped because their RPC was unset.
Full Solidity formatting passed. Production Solidity is unchanged. Four test
harnesses add the new obligations and six concrete tests exercise their ABI
geometries on a real EVM.

## Reviewed claim coverage

| Claim | Extension | Displayed scope |
|---|---|---|
| C85 | `check_extendedValidityLeafConstraints`, `check_extendedValidityOrWordConstraints`, `check_extendedValidityOrOrderedRanges`, `check_extendedValidityOrReversedRanges`, `check_extendedValidityTwoWordConstraints`, `check_extendedValidityBalances`, `check_extendedValidityMalformedFetchers` | 3 fetchers; ≤2 constraints |
| L70 | `check_extendedScalarSlotTypes`, `check_extendedCompoundSlotTypes`, `check_extendedByteSlotEncodings`, `check_extendedNestedSlotOffsets` | selected ABI families; n≤2 |
| L71 | `check_extendedReductionWindowBounds` | n≤4: 0/3 windows |
| L72 | `check_extendedReductionWidths` | n≤4; 12 reply widths |
| L74 | `check_extendedWordCallerRoutes`, `check_extendedDirectValueCallerRoutes`, `check_extendedGraphValueCallerRoutes` | all callback entries; fixed graphs |
| L75 | `check_extendedScalarResultTypes`, `check_extendedCompoundResultTypes`, `check_extendedByteResultEncodings`, `check_extendedRawWordPairs` | n≤2; scalar/compound cases |

C85, L70, L74 and L75 remain partially verified. L71 and L72 have larger displayed
bounds; L73 retains its enum-field scope and was freshly revalidated. E50 retains
its concrete evidence. Each statement keeps its existing ID and exact wording;
predecessor records and earlier receipts remain unchanged.

See [the ledger](claims.md) and [per-claim evidence](claim-evidence.md) for the
precise case families. A bound is evidence scope, not a percentage of contract
correctness. No arbitrary-length induction, Dafny, cryptographic or exact
production-runtime credit follows from these results.

## Reference and rejection checks

Solidity's independent encoders define canonical scalar, array, tuple and byte
values. Calldata-capture callbacks accept raw arguments, so their own typed
decoders cannot hide missing slot validation. Raw-return callbacks expose dirty
values to Collections' output validation, including a bad second result after a
valid first. Mutated fields and nested offsets are located with sentinel scans
rather than recomputed using AbiCodec's layout equations.

Caller cases use caller-returning and context-testing targets for all callback
entry points. Graph cases optionally evaluate their Call node through a
successful TryOrElse boundary. They assert caller context and output behavior;
they do not prove general cache reuse or failed-attempt rollback.

Range references state ordered bounds explicitly. A visited reversed range is
an ordinary failure, rather than a false OR leaf that permits later alternatives.
The first combined exploratory expectation missed this distinction; Halmos found
counterexamples, and concrete regression calls reproduce the specified rejection.
The combined corrected property and its first split leaf property timed out.
Separate OR obligations and the explicit equivalent bound-order predicate resolve
the proof without restricting the symbolic words or raising solver limits. The
exploratory failed/incomplete receipts remain under the ignored probe directory
and receive no proof credit.

Halmos has no concrete gas model. Ordinary-failure validity properties exclude
its symbolic exhaustion artifact; exact reserved-signal propagation and the
concrete gas sweeps retain their separate evidence.

## Mutation and evidence audit

All 18 targeted final-snapshot mutants produced valid counterexamples. They
change signedness, fixed-byte and dynamic padding, array/tuple word validation,
component envelope error routing, nested offsets, caller results, positional
constraint reads, native balances, balance-encoding length, the third window,
97-byte reply acceptance, fourth-element error context and raw sign-bit acceptance.
Mutants run in an isolated scratch worktree. Compilation failures, invalid
counterexamples, timeouts and loop truncation do not count as kills. This is a
targeted campaign, not a new exhaustive Gambit pass.

The evidence audit checks all 209 inventory entries against their result JSONs,
requires nonzero successful paths and zero truncated loops or execution errors,
and compares source identity across concrete, symbolic and final mutation runs.
It also binds the producer and compiler configuration hashes. Implication scope
is the reviewed mapping above, not a result inferred from inventory counts.

The preceding [189-property campaign](halmos-claims-20261012.md), its receipts and
its 14 targeted mutants remain retained. An exploratory mutation run against the
pre-final reference predicate also remains local; the final 18-mutant run binds
the exact current snapshot.

## Provenance and reproduction

Tools remain Halmos 0.3.3, Yices 2.6.4, Forge 1.5.1 at
`b0a9dd9ceda36f63e2326ce530c10e6916f4b8a2`, and solc 0.8.36 with optimizer 200,
Cancun and the repository's Foundry configuration. The baseline uses `--loop 70`,
`--default-bytes-lengths 0,1,31,32,33,64,65`, two solver threads, four coordinator
workers and a 900-second per-property watchdog. Solver defaults and per-property
annotations are unchanged. Literal fixtures cover the added return widths above
65 bytes independently of the default symbolic byte-input lengths.

The parent revision is `6a497132c59731535fa405162d0212bccec66f2f`; the dirty-tree
source hashes identify the full proof snapshot. Generated results, logs, patches
and snapshots stay local or in CI artifacts.

- [Complete run](verification/halmos-extensions-20261012/run.json)
- [Baseline manifest](verification/halmos-extensions-20261012/manifest.json)
- [Concrete gates](verification/halmos-extensions-20261012/checks.json)
- [Evidence audit](verification/halmos-extensions-20261012/review.json)
- [Final mutations](verification/halmos-extensions-mutations-final-20261012/mutations.json)

Receipt SHA-256 bindings:

- Baseline manifest: `6500efa404e6e5debc2e15247ce1d882ff95101792ffb79c0dee01ba9aa41c92`
- Concrete gates: `300c2a8e5a931fb2f6a2651c1e9f0bf19e5b0071064bbf7c5811c94fd1ccb9ba`
- Final mutations: `c1cd31703ee4927a704dbb500d3fdc9f75293e10863b414ea3d4d7efabcfca8f`
- Evidence audit: `2c4c13bc86845bea0897804b169cf9d06bb4e8590166c91d5b714332e7ea3c10`

Added proof-source SHA-256 bindings:

- `contracts/tests/ClaimCallerRoutesSymbolic.t.sol`: `b55c6894db43887a1c5131579a900ecf4e8f7a92a1c8e9878fe860aa2367b163`
- `contracts/tests/ClaimReductionBoundsSymbolic.t.sol`: `817dda59f1b7e739fdb90f9ae385fcb08afcff04f4216c16611ae36d98b1e901`
- `contracts/tests/ClaimTypeFamiliesSymbolic.t.sol`: `a8d365df93ee362e704992fbca6ad83038a5281c5fd0386b286e694d2d8f1901`
- `contracts/tests/ClaimValidityFamiliesSymbolic.t.sol`: `d13081b78e4a794f69c4b113ef2efcf3d4aa9879190f19942e8fbd1c05068648`

To reproduce with the pinned tools, finish Solidity edits and formatting, then
run the concrete gates before producing a fresh baseline:

```sh
forge fmt --check
forge build
forge test
pnpm test
python3 scripts/verify-claims.py --output docs/verification/fresh-halmos-extensions --workers 4
```

Retain concrete-check receipts for the same source hashes before refreshing
labels. A clean clone must rerun or retrieve the local/CI evidence; the hashes in
this report are bindings and cannot reconstruct a receipt.

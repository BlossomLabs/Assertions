# Bounded Halmos claims campaign, 2026-10-12

The fresh baseline passed all 189 properties: the previous 177 plus 12 new
properties for C85 and L70–L75. No property failed or remained incomplete. The
concrete gates passed 631 Foundry tests and 747 Hardhat tests (640 Solidity and
107 Node); two optional fork tests were skipped because their RPC was unset.
Full Solidity formatting passed. Production Solidity is unchanged; the only
Solidity additions are the two proof harnesses below. E50 retains its concrete
cache evidence and receives no new symbolic credit.

## Reviewed obligations and bounds

| Claim | New properties | Symbolic scope |
|---|---|---|
| C85 | `check_claimValidityIsResolution`, `check_claimValidityOrdinaryFailure`, `check_claimValidityReservedSignal` | one STATIC_CALL; ≤1 EQ |
| L70 | `check_claimSlotsMatchingAndDifferent`, `check_claimBinarySlots`, `check_claimConstantsBeforeTraversal` | uint8/bool slots; n≤2 |
| L71 | `check_claimReduceMultipleWindows` | n≤3: one window; n≤1: two |
| L72 | `check_claimReduceResultWidth` | n=3; six reply widths |
| L73 | `check_claimReduceEnumDecoder` | uint256 enum fields; n≤1 |
| L74 | `check_claimWordCaller`, `check_claimValueAndGraphCaller` | n=2; fixed Call graph |
| L75 | `check_claimRawAndTypedWords` | n=1; bool/uint8/address |

C85, L70, L74 and L75 remain **partially verified**: their selected call shapes
or type families do not establish the entire statement. L71–L73 display their
bounds explicitly. The [claim evidence](claim-evidence.md) records each property’s
premises, exclusions and concrete support. No statement or retired ID was renamed
or rebound by this campaign.

The callback harness uses independent calldata, raw-word and caller oracles.
Result-width cases include an accepted 32-byte control and rejected widths
0, 1, 31, 33 and 64 at each of three element positions in every reduction mode.
Unselected elements return zero; the comparisons force every mode to reach the
selected element without earlier exits or sum overflow. The enum harness encodes
whole raw calls with numeric fields, so rejection must occur in Collections’ ABI
decoder rather than in an enum cast in the test.

Halmos has no concrete gas model. C85’s ordinary-failure and failed-constraint
properties exclude the symbolic gas artifact explicitly; its reserved-signal
property must propagate that signal without excluding the path. Actual gas
exhaustion remains covered by the concrete gas sweeps. These results provide
bounded EVM evidence, with no Dafny, cryptographic or exact deployment-bytecode
credit.

## Validation and provenance

All 14 targeted source mutants produced valid counterexamples: missing input,
bound-slot, constant and output validation; accepted wide replies; incorrect
error element; skipped second window; extended Reduce and Cmp enums; incorrect
caller results in word and graph calls; narrow checks imposed on raw words;
validity based on returned truth; and swallowed reserved signals. Mutants ran
in an isolated scratch worktree. Compiler failures and incomplete runs were not
counted as kills. This is a targeted check, not a new exhaustive Gambit campaign.

The evidence audit compared every result JSON with its inventory entry, required
nonzero successful paths and zero truncated loops or execution errors, and checked
source identity across the symbolic, concrete and mutation runs. It also checked
the baseline runner and compiler configuration hashes. This audit validates run
provenance; the reviewed mapping above determines which claim each result covers.

Tools: Halmos 0.3.3, Yices 2.6.4, Forge 1.5.1 at
`b0a9dd9ceda36f63e2326ce530c10e6916f4b8a2`, and solc 0.8.36 with optimizer 200,
Cancun and the repository’s Foundry settings. The baseline uses `--loop 70`,
`--default-bytes-lengths 0,1,31,32,33,64,65`, two solver threads and a 900-second
per-property wall watchdog. Solver defaults and per-property annotations remain
unchanged. The coordinator used four workers.

The source revision is `6a497132c59731535fa405162d0212bccec66f2f`; dirty-tree source
hashes, rather than that commit alone, identify the added harnesses. The previous
[2026-10-08 run](gas-pass-checks.json) and every predecessor record remain unchanged.
Generated manifests, outputs, logs, mutation patches and snapshots stay local or
in CI artifacts under the ignored verification directories.

- [Complete run](verification/halmos-claims-20261012/run.json)
- [Baseline manifest](verification/halmos-claims-20261012/manifest.json)
- [Concrete checks](verification/halmos-claims-20261012/checks.json)
- [Evidence audit](verification/halmos-claims-20261012/review.json)
- [Targeted mutations](verification/halmos-claims-mutations-20261012/mutations.json)

Receipt SHA-256 bindings:

- Baseline manifest: `76defa6bd291a93ccf53dec183382abfd500ca7dd72524537f69a47613d2943c`
- Concrete checks: `b3ab4c67cba3254ff018813511f4de1c52e1d819217b71df6fc11a263ab2a6d0`
- Targeted mutations: `39dceb0572091c5dab607461bde065639ce6c00542f42016d3262da2cdda9238`
- Evidence audit: `68a02e40dbdf84d024d7a3ef8589ba3659a1d331d8458bdb125ef085f9074905`

Proof-source SHA-256 bindings:

- `contracts/tests/ClaimCallbacksSymbolic.t.sol`: `51e06a3607e265f5d42c98d5d50fa1956576b1a18c719e37389652948196be80`
- `contracts/tests/ClaimControlSymbolic.t.sol`: `9fc816ddbf8ce58fad6bfc11fd6f692c7c82074abf7b2ceecfe93ed4df34040f`

## Reproduction

Install the pinned Halmos version (`uv tool install halmos==0.3.3`) and Forge
1.5.1, then run the concrete gates before the baseline. Finish all Solidity
edits, including formatting and comments, before recording a run.

```sh
forge fmt --check
forge build
forge test
pnpm test
python3 scripts/verify-claims.py --output docs/verification/fresh-halmos-claims --workers 4
```

Use a fresh output directory and retain concrete-check receipts for the same
source snapshot before refreshing labels with `scripts/refresh-claims.py`.
A clean clone must rerun or retrieve the local/CI artifacts; it must not invent
receipts from the hashes in this report.

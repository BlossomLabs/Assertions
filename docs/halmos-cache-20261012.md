# Bounded Halmos cache campaign, 2026-10-12

The complete fresh baseline passed all **220 properties**, including eleven new
cache properties. None failed or remained incomplete. Concrete gates passed
642 Foundry tests and 758 Hardhat tests (651 Solidity, 107 Node); two optional
RPC tests were skipped. Full Solidity formatting passed. Production Solidity is
unchanged: the only Solidity addition is `ClaimCacheSymbolic.t.sol`.

E50 now has bounded symbolic evidence for selected cache geometries. E41 and L60
also have bounded evidence for fresh caches between invocations. **All three
remain partially verified.** Their exact statements and IDs are unchanged, as
are all 331 active claim identities and eight retained predecessor records.
Passing properties are not a count of fully proved claims.

## Reviewed obligations

| Claim | Properties | Scope |
|---|---|---|
| E50 | `check_cacheSharedNodeReuse` | One Call leaf shared by two Tuple references; bytes32 or a 33-byte bytes payload |
| E50 | `check_cacheSuccessfulGuardAdopts`, `check_cacheSuccessfulGuardPreservesParent` | TryOrElse and IsValid success; adoption of new values and preservation of earlier parent entries |
| E50 | `check_cacheFailedGuardReexecutes`, `check_cacheFailedGuardPreservesParent` | TryOrElse and IsValid ordinary failure; cold work executes again, previously cached parent work remains reusable |
| E50 | `check_cacheNestedSuccessfulAdoption`, `check_cacheOuterFailureDiscardsInnerSuccess` | Two successful nested guards; inner success followed by outer failure |
| E50 | `check_cacheRepeatedFailedAttempts`, `check_cacheOnlyValidatedResultsReused` | Two failed attempts followed by a direct use; unrestricted returned word validated as uint8 before reuse |
| E41 | `check_cacheSeparateEvaluations`, `check_cacheSeparateCollectionCallbacks` | Two evaluations through evaluate/evaluateEncoded; two mapValues callbacks |
| L60 | `check_cacheSeparateCollectionCallbacks` | Two mapValues callback invocations, each sharing its own leaf twice |

These are selected Call, Tuple, TryOrElse and IsValid geometries, with at most
nine nodes and guard depth two. Words remain unrestricted. Dynamic leaves
return canonical bytes payloads of length 33, crossing the word and padding
boundary. Ordinary failure comes from dirty uint8 literals or returned words.
This campaign does not quantify over every graph of these sizes, every node or
descriptor family, arbitrary-length traversal, or arbitrary external targets.
Solidity's independent `abi.encode` defines the expected result encodings.

General graph/cache invariants require induction. No Kontrol, DafnyEVM, Certora,
native source, cryptographic, compiler-correspondence or deployment proof was
added. Earlier concrete evidence and the retired E11/E17/E18 statements remain
retained with their original run provenance.

## Call-count observer and assumptions

Halmos 0.3.3 does not implement Foundry's exact `expectCall` counter. The test-only
`ClaimCacheObserver` therefore advances `vm.warp` once per observed leaf call.
The test environment's timestamp survives a reverted subcall, allowing the
property to count work discarded by a failed guard. A separate external read
observes the counter, avoiding compiler reuse of a block field within a frame.

Expressions and its imported AbiCodec/ERC8211 closure do not read the ghost
clock. The observer returns the supplied word or its canonical bytes payload;
the clock is used only to observe execution counts. Five concrete sample tests
independently cross-check these counts with Foundry's exact `expectCall`,
including reverted attempts, both guard kinds, dynamic results and separate
callback invocations. Two observer fault controls remove each leaf's tick and
must fail the symbolic count assertions.

This is explicit test instrumentation, not a deployable stateful callback or an
EVM gas model. Halmos's pinned observer handlers are snapshotted and hashed with
the evidence. Ordinary-failure properties exclude only an exact propagated
`SubcallOutOfGas` outcome: Halmos's independent symbolic gas readings can invent
exhaustion on these paths. Successful-graph properties require success without
that exclusion. Concrete gas sweeps retain their separate evidence. Sharing is
not claimed equivalent to duplicated gas-sensitive or caller-sensitive reads.

## Mutations and evidence audit

All **eight production cache mutants** produced valid counterexamples: ignored
readiness, missing readiness writes, lost cached values, discarded successful
value adoption, discarded readiness adoption, cleared parent cache on failure,
invented ready entries after failure, and skipped result validation. Both
observer fault controls were killed too, for ten targeted checks in total.
Mutations ran in the dedicated `.review-cache-mutants-20261012` scratch worktree.
Compilation failures, invalid models, timeouts and truncated loops are not
counted as kills. This was not an exhaustive Gambit campaign.

A separate evidence checker compares the compiler-produced ABI property inventory
with all 220 results, checks nonzero successful paths, zero truncated loops and
zero execution errors, and verifies source identity across concrete, symbolic
and mutation runs. It binds raw result/log hashes, producer hashes and compiler
configuration, and retains complete source snapshots. Every source from the
preceding baseline is byte-identical; only the new test harness was added.
The audit establishes run provenance; the table and assumptions above define
the claim coverage.

The [preceding 209-property campaign](halmos-extensions-20261012.md), its 18
targeted mutants, and all earlier receipts remain unchanged. Exploratory cache
receipts remain in the ignored probe directory and are not substituted for the
fresh complete baseline.

## Provenance and reproduction

Tools: Halmos 0.3.3, Yices 2.6.4, Forge 1.5.1 at
`b0a9dd9ceda36f63e2326ce530c10e6916f4b8a2`, and solc 0.8.36 with optimizer 200,
Cancun, no via-IR and the repository's Foundry configuration. The baseline uses
`--loop 70`, byte lengths `0,1,31,32,33,64,65`, two solver threads, four workers
and a 900-second per-property watchdog. Solver defaults and per-property
annotations are unchanged. The final complete run lasted from
20:46:49 to 20:55:44 UTC on 2026-10-12.

The parent revision is `6a497132c59731535fa405162d0212bccec66f2f`; dirty-tree
source hashes identify the full proof snapshot. Generated evidence stays local
or in CI artifacts:

- [Complete run](verification/halmos-cache-20261012/run.json)
- [Baseline manifest](verification/halmos-cache-20261012/manifest.json)
- [Concrete gates](verification/halmos-cache-20261012/checks.json)
- [Evidence audit](verification/halmos-cache-20261012/review.json)
- [Targeted mutations](verification/halmos-cache-mutations-20261012/mutations.json)
- [Reviewed claim mappings](verification/halmos-cache-20261012/claims.json)

Receipt SHA-256 bindings:

- Baseline manifest: `d101d26d0ba74581b5ce6d6a56ba18b65dcf8f90efa173a1948f3bcbc75f48c3`
- Concrete gates: `1672d395ce4188e42e47e18881c52f834f2265fade7a2c8b0941ff1ab204756f`
- Targeted mutations: `03ddb37294cf40d89a1c8857c3c5726d9ecfcc591887da7b773cad854606fb0b`
- Evidence audit: `e13c8ecc376dbb8e98d13bde7934b810e9f4ef4c6c83ad0d6ebc6cb41f6b5156`
- Complete run: `25e4265fa43fa04c70db2c8cfd3c35a701f7005100ee074c3fd14df11c98a6f6`

Proof-source SHA-256:
`contracts/tests/ClaimCacheSymbolic.t.sol` —
`1751901b46367f0ac407a2262526f3eef8f2250f7f36f45772a6e9fcebf26802`.

Finish every Solidity edit and formatting change, then reproduce with fresh
output directories and concrete gates before the baseline:

```sh
forge fmt --check
forge build
forge test
pnpm test
python3 scripts/verify-claims.py --output docs/verification/fresh-halmos-cache --workers 4
```

Preserve all predecessor receipts. A clean checkout must rerun the campaign or
retrieve its local/CI artifacts; report hashes cannot reconstruct a receipt.
Halmos executes compiled EVM bytecode, but deployment equivalence still requires
separate artifact matching.

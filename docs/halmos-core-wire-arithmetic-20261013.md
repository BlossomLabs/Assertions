# Halmos core, wire, ordering and arithmetic campaign, 2026-10-13

The fresh complete baseline passed **307 properties**, including **22 new
properties**. None failed or remained incomplete. Concrete gates passed **678
Foundry tests** and **794 Hardhat tests** (687 Solidity, 107 Node); two optional
RPC tests were skipped. Full Solidity formatting passed. Production Solidity
and every Solidity source from the preceding baseline are byte-identical.
The four new harnesses contain twelve real-EVM sample tests.

**Fourteen unchanged claims gained partial symbolic coverage:** C2, C4, C17,
C19, C21, W5, W6, W15, L4, L5, O1, O2, O3 and O75. No claim received a full label
in this campaign. The ledger now contains **157 formally verified, 93 partially
verified, 75 tested, three partially tested, two scope limitations and one
environment assumption**: 331 active statements and eight retained retired
identities. Property counts remain separate from claim counts.

## Reviewed obligations

| Group | Claims | Added scope |
|---|---|---|
| Core resolution and errors | C2, C4, C17, C19, C21 | Single EQ through RAW, STATIC_CALL, native/token BALANCE and all legal paramType values; 0/1/2 EQs on two-word resolve; three predicate entries; direct and one/two nested failure frames; reason lengths 0/3/4/32/33/64/65 |
| Wire positions and ranges | W5, W6, W15 | Two-word RAW/STATIC GTE/LTE; single-word native/token balances; canonical bytes33 offset/length/payload; signed/unsigned range references of exactly 64/96/128 bytes |
| Callback ordering | L4, L5 | Three-element Any/All range/bytes/word folds and word reductions; typed any/all/find; first-callback exit and later failure at index 1/2; one-element foldWords with six literal overlap geometries in 132 bytes |
| Arithmetic boundaries | O1, O2, O3, O75 | All input pairs for unsigned/signed add/sub; zero divisors; all dividends with selected unit/power-of-two divisors; selected manual panic paths compared with caught compiler reverts |

The harnesses are
[`ClaimArithmeticBoundariesSymbolic.t.sol`](../contracts/tests/ClaimArithmeticBoundariesSymbolic.t.sol)
(9 properties), [`ClaimCoreConstraintsSymbolic.t.sol`](../contracts/tests/ClaimCoreConstraintsSymbolic.t.sol)
(5), [`ClaimWireBoundarySymbolic.t.sol`](../contracts/tests/ClaimWireBoundarySymbolic.t.sol)
(4) and [`ClaimCallbackOrderingSymbolic.t.sol`](../contracts/tests/ClaimCallbackOrderingSymbolic.t.sol)
(4). [Per-claim evidence](claim-evidence.md) displays exact scopes and remaining
gaps. The retained coverage audit distinguishes these obligations from prior
result-only exit checks and range properties that merely permitted stricter
rejection.

## Oracles, observations and limits

Unsigned add/sub use independent wrapping arithmetic and carry/borrow conditions.
Signed add/sub use operand/result sign bits to identify overflow. Both require
complete success output or exact Panic(0x11), so reference overflow cannot discard
a failing path. O1 remains partial because its multiplication statement is not
newly proved.

Unsigned division/remainder value checks use independent shifts/masks for divisors
1, 2, 256, 2^128 and 2^255. Signed checks use magnitude, sign reconstruction and
shifts/masks for divisors ±1, ±2, ±256 and ±2^128, including MIN/-1 quotient
overflow. All four zero-divisor entrypoints require Panic(0x12). Arbitrary
nonzero divisors remain outside these value properties.

Manual panic equivalence covers all rpow operands with base zero, all expWad
inputs at/above 135305999368893231589, and signed magnitude overflow through
mulDiv(MIN,-1,1) in all three rounding modes. External compiler-oracle failures
are caught and explicitly asserted before comparing the full panic bytes.
Successful rpow/expWad/mulDiv arithmetic and general signed magnitude inputs
receive no new symbolic credit.

Core checks compare complete constraint and CallFailed context, including the
resolving frame's target/calldata. Predicate-only batches install code at address
zero to make an erroneous constructed call observable. Ordinary-failure
properties exclude reserved input reasons and symbolic SubcallOutOfGas outputs
using explicit Keccak digest-inequality assumptions, subject to Halmos's hash
abstraction. Exact reserved-signal propagation is a separate property with no
such exclusions. These checks do not establish actual exhaustion: gasleft is a
fresh symbol in Halmos and the concrete gas tests retain their separate scope.

Fetched constraints judge raw ABI words, including the bytes33 offset and length.
Both signed and unsigned trailing-byte properties require the pinned Biconomy
runtime to accept the selected ordered range, then require Assertions to accept
64 bytes and reject 96/128 with exact InvalidConstraintData context. Bounds
contain the actual word and trailing words are symbolic. Arbitrary lengths,
malformed bounds and other dynamic return shapes remain outside the new scope.

Early-exit checks require exact successful output and one observed callback,
while later callbacks would fail if visited. A test-only ghost clock observes
even reverted attempts, read through a separate external getter. Foundry's exact
expectCall independently cross-checks sample counts. The pinned Halmos observer
implementation is retained and matched to the installed sources. The production
closure does not read this clock; the instrumentation supplies no deployable
stateful callback or gas-sensitive read guarantee.

The window receiver compares every calldata byte without hashing against six
independent literal expected streams. Half-word overlaps distinguish the supplied
element-window order; other bytes and the selector must remain intact. A changed
final byte must be rejected, including the receiver's final partial word.
These cases do not establish arbitrary windows, template lengths or traversals.

Halmos executes compiled EVM bytecode. Expected success is asserted after a
low-level call, and expected failures compare full bytes. Every accepted result
has nonzero successful paths, zero execution errors and zero truncated loops.
Discarded reverts, finite loops and absent gas modeling remain critical limits.
Native Dafny verification, source/compiler correspondence, runtime correspondence,
concrete tests, mutations and Halmos remain separate evidence layers. Deployment
equivalence still requires matching deployment artifacts to the executed code.

## Targeted faults and receipt audit

All **47 fault checks** produced valid counterexamples: **45 production mutants
and two observer controls**, with no survivors or incomplete results. They
include unchecked add/sub, accepted zero divisors, swapped quotient/remainder,
wrong signed rounding/sign, removed magnitude guards, corrupted panic bytes,
skipped constraints, lost fetched values, wrong assertion/entry/error context,
wrapped reserved signals, skipped ABI headers, accepted range tails, continued
callbacks, reversed/omitted stamps and writes outside the windows. Observer
controls remove a clock tick or make the receiver always accept.

Mutations ran in three new isolated scratch worktrees. Compile errors, timeouts,
invalid models and truncated loops do not count as kills. This is a targeted
campaign, not an exhaustive mutation pass. The independent receipt audit checks
compiler ABI inventory, all 307 raw results, valid countermodels, tool/compiler
settings, producer hashes and identical source/configuration snapshots across
the concrete, symbolic and mutation runs.

The initial 22-property probe remains exploratory evidence. One preliminary
concrete campaign stopped at a harness stack limit before starting Halmos; its
receipt is retained separately. The accepted campaign used a new directory after
the final harness refactor. No retained receipt was overwritten.

## Provenance and reproduction

Tools: Halmos 0.3.3, Yices 2.6.4, Forge 1.5.1 at
`b0a9dd9ceda36f63e2326ce530c10e6916f4b8a2`, solc 0.8.36, optimizer 200, Cancun,
no via-IR. The accepted Hardhat run used `/usr/local/bin/node` v26.10.0 and retains
the executable hash. Global bounds are loop 70, default dynamic byte lengths
0/1/31/32/33/64/65, two solver threads, four workers and a 900-second per-property
watchdog. Explicitly constructed fixtures have their displayed sizes, including
132-byte callback templates. Solver defaults and existing annotations are unchanged.

Baseline UTC interval: `2026-10-13T00:02:37.862394+00:00`–`2026-10-13T00:15:02.365263+00:00`. Parent revision:
`6a497132c59731535fa405162d0212bccec66f2f`; dirty-tree source hashes identify the actual verified bytes.
Generated evidence stays local or in CI artifacts.

| Receipt | SHA-256 |
|---|---|
| [Baseline manifest](verification/halmos-core-wire-arithmetic-accepted-20261013/manifest.json) | `78b974f3fc9984f5f994d0027d7f379a04284b225138cb543986e9fce98be572` |
| [Concrete gates](verification/halmos-core-wire-arithmetic-accepted-20261013/checks.json) | `aafa444f54c3fde7cd52ec90da01402a092ccc4fc7ccccaa88e9b39e3ac55765` |
| [Targeted mutations](verification/halmos-core-wire-mutations-20261013/mutations.json) | `fa3fbdf7b104c45e1e6dc2b1dbe1116e50272727463ad86320a3c32d99f80a0f` |
| [Evidence audit](verification/halmos-core-wire-arithmetic-accepted-20261013/review.json) | `957fbdadddd648fef9279a80820795e702d610dd6dba96d63143b2d1bad81e35` |
| [Complete run](verification/halmos-core-wire-arithmetic-accepted-20261013/run.json) | `d48a89e96eadb236cf1b39f428531f1af582633270c043d6cab5f6b23cea9d5b` |
| [Reviewed mappings](verification/halmos-core-wire-arithmetic-accepted-20261013/claims.json) | `14958a57323dcb92a50a1d0ac2bf0e6d6d057d1b6d53ee91e4f767e2ea9288ee` |

| Added proof source | SHA-256 |
|---|---|
| ClaimArithmeticBoundariesSymbolic.t.sol | `35ec3be492edac43d1e8285e2649dbc0e2ac8d922a07b259f17b0923c04ac758` |
| ClaimCoreConstraintsSymbolic.t.sol | `3ebbd59fb6d37775a7e78d373d8543da48bf2d1fb8eca6348e3a51456911b57c` |
| ClaimWireBoundarySymbolic.t.sol | `330810f0ed601b1f8f09833031643aa705f71bc520399a5436b81f8e1e41f573` |
| ClaimCallbackOrderingSymbolic.t.sol | `0c588792a4c4eb44d6db61ed98f29dd3baa2d3d4f7ed3c1ee446a682c28c8ab5` |

Finish Solidity edits and formatting before concrete gates, then use a fresh
evidence directory:

```sh
forge fmt --check
forge build
/usr/local/bin/node node_modules/hardhat/dist/src/cli.js compile
forge test
/usr/local/bin/node node_modules/hardhat/dist/src/cli.js test --no-compile
python3 scripts/verify-claims.py --output docs/verification/fresh-halmos-core-wire --workers 4
```

Verify the Node test count before accepting the concrete run. Review raw receipts
and mappings before refreshing labels. After refresh, run
`python3 -B scripts/test-claim-ledger.py` and
`python3 -B scripts/render-claims.py --check`; post-ledger checks receive their own
fresh receipt.

The [preceding 285-property campaign](halmos-word-navigation-20261013.md), older
reports, receipts and both dirty working trees remain preserved. No native run,
induction theorem, full EVM conformance or deployed-bytecode correctness was
added. E50 and general cache/traversal invariants remain partial and need induction.
The canonical source library still needs reconciliation with the newer ledger
without transferring historical proof credit.

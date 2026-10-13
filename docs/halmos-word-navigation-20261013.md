# Halmos word, navigation and callback campaign, 2026-10-13

The complete fresh baseline passed **285 properties**, including **34 new
properties** in all four proposed groups. None failed or remained incomplete.
Concrete gates passed **666 Foundry tests** and **782 Hardhat tests** (675
Solidity, 107 Node); two optional RPC tests were skipped. Full Solidity formatting
passed. Production Solidity and every Solidity file from the preceding baseline
are byte-identical. Four new harnesses contain eleven concrete sample tests.

Evidence was extended for **27 unchanged claims**. Eight previously tested claims
now have full labels within their recorded Halmos scope: **O6, O7, O29, O30, O31,
O32, O34 and L31**. The other nineteen retain partial labels. The ledger has
**157 formally verified, 79 partially verified, 89 tested, three partially
tested, two scope limitations and one environment assumption**: 331 active
statements, with eight retired identities retained. Property counts and claim
counts remain separate.

## Reviewed obligations

| Group | Claims | Scope |
|---|---|---|
| Word operations | O6, O7, O29–O32, O34 | Full uint256/int256 input words; both min/max and distance overloads; ten comparison entrypoints; AND/OR/XOR/complement; every uint256 shift count and index; every output bit |
| Exact boundaries | C6, C28, W19, L31 | One batch entry with three zero-TARGET positions; empty navigation with payload lengths 0/1/31/32/33/64/65 and arbitrary 32-byte descriptor; empty OR at position zero/one; all invalid raw FoldExit words through all three enum-bearing entrypoints |
| Navigation and encoding | C29, C33, C35–C37, C41, C44, A21–A24, O70–O72 | Selected static/nested dynamic terminals, exact dirty-word offsets, fixed/dynamic three-element array indices, two-component tuple index refusal, six LEN/PAYLOAD shapes, selected tuple assembly and exact component errors |
| Callback cache freshness | E41, L60 | Four-node Call/Select graph through eight additional callback entrypoints: word/value filters, word/value folds, word reductions and any/all/find predicates; folds n=0..3, other cases n=2; early exits and within-invocation sharing |

The added harnesses are
[`ClaimWordSemanticsSymbolic.t.sol`](../contracts/tests/ClaimWordSemanticsSymbolic.t.sol)
(11 properties), [`ClaimBoundaryCasesSymbolic.t.sol`](../contracts/tests/ClaimBoundaryCasesSymbolic.t.sol)
(4), [`ClaimNavigationEncodingSymbolic.t.sol`](../contracts/tests/ClaimNavigationEncodingSymbolic.t.sol)
(15) and [`ClaimCacheRoutesSymbolic.t.sol`](../contracts/tests/ClaimCacheRoutesSymbolic.t.sol)
(4). [Per-claim evidence](claim-evidence.md) and the retained
[reviewed mappings](verification/halmos-word-navigation-20261013/claims.json)
name each property and its exact exclusions and remaining gaps.

The word properties quantify over the complete fixed-width domains; they do not
depend on sampling small operands. Signed order and distance use the independent
unsigned coordinate `word XOR 2^255`. Returned extrema must be input members
and satisfy both bounds. Distance must reconstruct the higher coordinate;
wrapping reference addition prevents a faulty output from overflowing the
oracle and discarding its path. Comparisons require exact canonical boolean
bytes. Bit truth tables and index translations specify every output bit,
including sign filling and shift counts at or above 256. Each call must succeed
and return exactly one word. This adds no full-precision multiplication,
division, modular arithmetic or approximation proof.

L31 checks decoder refusal, not successful fold behavior. Its fixed other ABI
fields are encoded as one complete call. Extending the enum with a fourth
member reaches the body and changes the outcome, distinguishing enum rejection
from a malformed ABI fixture. Resource and callback/window guarantees remain
separate.

## Bounded geometry and observations

Navigation and tuple assembly use independent solc encodings. Fault offsets and
raw callback window locations are found by scanning unique markers in reference
fixtures. Valid array indices are literal cases; invalid indices remain full
int256 symbols, excluding final LEN/PAYLOAD sentinels, whose semantics are
tested separately. The added cases do not establish arbitrary descriptor
families, nesting, lengths or general error-priority rules. LEN's truncated
dynamic controls require its selected-word error before type refusal; PAYLOAD's
unsupported dynamic controls require refusal before that read.

The callback graph shares one leaf as its condition and selected branch. The
observer must execute once in each visited callback, and independently again
on the next invocation. Expected outputs also vary with the supplied elements.
Raw word-template and typed value routes are exercised. Together with the prior
mapValues case, nine callback entrypoints have selected freshness evidence.
E41 and L60 remain partial; E50's general cache invariant still requires
induction.

Call counts use the pinned test-only ghost clock, read through a separate
external observer. Foundry's exact `expectCall` independently cross-checks the
four callback sample tests. The zero-TARGET property installs observer code at
address zero, so an incorrect call cannot pass silently as a code-less-address
noop. This instrumentation does not represent deployable stateful callbacks,
gas-sensitive read equivalence or a gas model. The fixed production closure
does not read the ghost clock.

The new properties add no ordinary-failure gas-artifact exclusions. Earlier
baseline properties retain their documented exclusions. Halmos's discarded
reverts and loop truncation remain critical limits: success is asserted
explicitly, expected failures compare full revert bytes, and every accepted
result has nonzero successful paths, zero execution errors and zero truncated
loops.

## Mutations and evidence audit

All **48 targeted fault checks** produced valid counterexamples: **46 production
mutants and two observer controls**, with no survivors or incomplete results.
They include every comparison entrypoint, swapped extrema, signedness and
distance faults, bit-operator swaps, wrapped shift/index counts, zero-target
calls, empty-path validation, OR context, enum extension, terminal truncation,
narrow validation, index normalization/refusal, LEN/PAYLOAD ordering, component
errors, a lost bytes envelope, lost cache readiness and callback binding/stamps.
Observer controls omit a callback tick or invent a zero-address count.

Mutations ran in three new isolated scratch worktrees. Compile errors, timeouts,
invalid countermodels and truncated loops are not counted as kills. This was
not an exhaustive Gambit campaign. A separate audit compares the compiler's ABI
inventory with all 285 raw results, validates mutation countermodels and artifact
hashes, and confirms identical Solidity bytes across concrete, symbolic and
mutation runs. It retains complete source/configuration snapshots and producer
bindings. The preliminary 34-property run remains exploratory evidence; the
fresh complete baseline establishes the current labels.

## Provenance and reproduction

Tools: Halmos 0.3.3, Yices 2.6.4, Forge 1.5.1 at
`b0a9dd9ceda36f63e2326ce530c10e6916f4b8a2`, solc 0.8.36, optimizer 200, Cancun,
no via-IR. Hardhat used `/usr/local/bin/node` v26.10.0; its executable hash is
retained in the concrete receipt. Bounds are `--loop 70`, byte lengths
`0,1,31,32,33,64,65`, two solver threads, four workers and a 900-second property
watchdog. Solver defaults and per-property annotations are unchanged. UTC
execution was 2026-10-12 22:56:07–23:08:05, on 2026-10-13 in Europe/Madrid.

Parent revision: `6a497132c59731535fa405162d0212bccec66f2f`; dirty-tree source
hashes bind the actual snapshot. Generated receipts remain local or in CI
artifacts. No retained receipt was overwritten.

| Receipt | SHA-256 |
|---|---|
| [Baseline manifest](verification/halmos-word-navigation-20261013/manifest.json) | `030159f0ac2c8aafbdbd517f969c07e39bfb5e97c81b10fc4e70d3006e8b8753` |
| [Concrete gates](verification/halmos-word-navigation-20261013/checks.json) | `7a7b53d8379384edbae7aceaa0abdce39ac202e2db65be0a03bef5b089a35173` |
| [Targeted mutations](verification/halmos-next-mutations-20261013/mutations.json) | `1bb1ce833155c32622905d98eaa8b835c0ce172f865d907aceea1c51385d2fec` |
| [Evidence audit](verification/halmos-word-navigation-20261013/review.json) | `c74fc2dd0904e321383bf22434b2d51b3b13aae92a5cf2936ab24345bfce4d4a` |
| [Complete run](verification/halmos-word-navigation-20261013/run.json) | `30e32349dadd931a52026175893128416bcdd2850a5148e06f3bad45917158b6` |
| [Reviewed mappings](verification/halmos-word-navigation-20261013/claims.json) | `f01ca5cf0fcc6e5665d3c5dd1fe6794022a0e86b85ab608f212b719e2c8ff8f3` |

| Added proof source | SHA-256 |
|---|---|
| ClaimWordSemanticsSymbolic.t.sol | `91dde1eff7758da95ac0467b70a895c274ee46ad68565325e79a94eda04c8789` |
| ClaimBoundaryCasesSymbolic.t.sol | `4fdb19b68aca708140d91929a4fa22df0ff088239369da486a14292458aba70d` |
| ClaimNavigationEncodingSymbolic.t.sol | `0af355b3a5d96e37f3e24364ac264b7565c4490ef24661c957b242cf91d62e2d` |
| ClaimCacheRoutesSymbolic.t.sol | `e8ed1f5c2b4236da4dd0e5653587dd25d2807f65c793d1cb95535b19baa1c667` |

Finish all Solidity edits and formatting before concrete gates, then use fresh
output directories:

```sh
forge fmt --check
forge build
/usr/local/bin/node node_modules/hardhat/dist/src/cli.js compile
forge test
/usr/local/bin/node node_modules/hardhat/dist/src/cli.js test --no-compile
python3 scripts/verify-claims.py --output docs/verification/fresh-halmos-word-navigation --workers 4
```

Confirm the complete Node test count. After review/refresh, check identities and
labels with `python3 -B scripts/test-claim-ledger.py` and
`python3 -B scripts/render-claims.py --check`; post-ledger regressions receive a
separate fresh receipt.

The preceding [251-property behavior baseline](halmos-behavior-20261013.md),
[cache campaign](halmos-cache-20261012.md), all older receipts and both dirty
working trees remain preserved. Native Dafny/DafnyEVM, source/compiler
correspondence, runtime correspondence, concrete tests and Halmos remain
separate evidence layers. No native run, induction proof, full EVM conformance
or deployed-bytecode correctness was added. Deployment equivalence still needs
artifact matching. The source library still needs reconciliation with this
newer ledger, without carrying historical proof credit forward.

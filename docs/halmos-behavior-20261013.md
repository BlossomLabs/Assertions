# Bounded Halmos behavior campaign, 2026-10-13

The complete fresh baseline passed **251 properties**, including **31 new
properties** across all eight proposed behavior groups. None failed or remained
incomplete. Concrete gates passed **655 Foundry tests** and **771 Hardhat tests**
(664 Solidity, 107 Node); two optional RPC tests were skipped. Full Solidity
formatting passed. Production Solidity is unchanged. Four test harnesses and
thirteen concrete sample tests were added.

Evidence was extended for **21 unchanged claim statements**. Eighteen retain
partial labels; C81, C82 and O11 cover narrow empty-input or decoder boundaries
within their displayed scope. The ledger retains 331 active identities, eight
retired identities, their original statements and prior evidence. Its current
labels are 149 formally verified, 62 partially verified, 114 tested, three
partially tested, two scope limitations and one environment assumption. Passing
properties are not a count of fully proved claims.

## Reviewed obligations

| Group | Claims | New scope |
|---|---|---|
| Resolve-once construction | C24 | `gather` and `get`, zero through three independent operands, including repeated entries; bytes32 or canonical 33-byte bytes leaves; `get` target resolved once |
| Unreachable and unread graph data | E7, E10, E38 | Four-node admission/reachability cases; three malformed unused types; fixed two-node encoded payload with two independent values for one unread length word; six leading-header refusals and one consumed-field wrapper |
| Unread descriptor text and visited errors | C38 | Two independent tails of length 0, 1, 4 or 8; parentheses excluded; six visited syntax faults, before empty or valid data |
| Controls and callback errors | C66, E15, L33 | Six core attempt shapes; five-node TryOrElse/IsValid graphs; symbolic revert reasons of length 0, 3, 4, 32 or 33; two-element word folds and typed predicates with early/late faults; five exact reserved-signal routes |
| Target, caller and descriptor errors | C8, C57, C59 | All dirty upper 96-bit address values with a fixed lower address and four TARGET positions; `read`/`get` with one word and `chain` with one hop; four malformed one-argument `get` descriptors |
| Nested type validation | L35, E8, L70, L75 | Selected `uint8[][]` and `(uint8[],bytes[])` encodings; offsets, counts, trailing bytes, narrow words and nested padding; cold Literals; zero/one-element slots and two-element map/fold results |
| Executor and batch boundaries | C1, C81, C82, C83 | One executor storage write and EQ assertion; three ordered predicate entries; empty batches through both message overloads; empty unconstrained RAW_BYTES for every legal paramType; one successful word/bytes-returning batch call |
| Invalid enum words | O11, E39 | All raw Rounding words above 2 in both enum-bearing overloads; all raw Kind words above 10 in an otherwise valid one-node graph |

The handwritten properties are in
[`ClaimConstructionSymbolic.t.sol`](../contracts/tests/ClaimConstructionSymbolic.t.sol)
(10), [`ClaimUnreadSymbolic.t.sol`](../contracts/tests/ClaimUnreadSymbolic.t.sol)
(7), [`ClaimControlErrorsSymbolic.t.sol`](../contracts/tests/ClaimControlErrorsSymbolic.t.sol)
(6) and [`ClaimNestedTypesSymbolic.t.sol`](../contracts/tests/ClaimNestedTypesSymbolic.t.sol)
(8). [Per-claim evidence](claim-evidence.md) and the retained
[reviewed mappings](verification/halmos-behavior-20261013/claims.json) name the
individual properties, earlier supporting cases, exclusions and remaining gaps.

These are selected geometries and descriptor families. No induction over
arbitrary graphs, operand trees, cache histories or traversal lengths was added.
E50, E41 and L60 retain their preceding bounded cache evidence and partial
labels. C85, L70, L74 and L75 remain partial; L71–L73 retain explicit bounds.
E39 does not gain a universal error-priority guarantee: its property gives other
graph fields valid controls and does not establish that Kind rejection precedes
descriptor or reference admission errors. O11 supplies decoder evidence, not
arithmetic verification.

## Oracles, observers and failure paths

Expected ABI values and callback calldata come from independent solc encodings,
not codec pack/unpack round trips. Error positions are found by scanning
sentinel words in reference fixtures. Success obligations use low-level calls
and explicitly require `ok`; expected failures assert complete revert bytes.
The unread-field properties compare independently symbolic alternatives while
holding locating headers and selected data fixed. Descriptor parentheses and
layout-defining structure are outside the unread-tail assumption.

The construction observer advances the test-only ghost clock once per leaf
call. Its external counter can observe work in reverted subcalls. The fixed
Assertions/Expressions/AbiCodec/ERC8211 closure does not read that clock.
Foundry's exact `expectCall` independently cross-checks concrete call counts.
This instrumentation has the same pinned handler assumptions as the
[cache observer](halmos-cache-20261012.md#call-count-observer-and-assumptions).
It does not model deployable callback state or gas-sensitive read equivalence.

The executor property separately observes real EVM storage rollback: from zero
storage, an unrestricted mark survives a successful or caught assertion, and
rolls back when failure propagates. It preserves C1's mandatory same-transaction
assertion and propagation premises; it does not quantify over arbitrary
executors. The ghost counter is not used as a storage rollback oracle.

Ordinary failed-subcall cases explicitly exclude only the propagated symbolic
`SubcallOutOfGas` artifact, where Halmos's independent gas symbols can invent
exhaustion. Exact reserved-marker properties never exclude that path and require
the marker to propagate through the core, both expression guards and both
callback routes. Actual exhaustion remains covered by separate concrete gas
tests. Halmos has no gas model and discards reverting or truncated paths; the
retained audit checks nonzero successful paths, zero execution errors and zero
loop truncations for every accepted property.

## Mutations and retained evidence

All **35 targeted fault checks** produced valid counterexamples: **32 production
mutants**, **one executor fault control** and **two observer fault controls**.
They exercise duplicated/shared resolutions, caller relay, dirty target context,
descriptor refusal, empty boundaries, failed constraints, eager admission and
evaluation, unused-field reads, decoder wrappers, guard truth, reserved-marker
handling, callback context, enum extension, nested word/padding validation and
trailing data. The caller relay preserves destination and exact calldata while
changing caller identity. The executor control swallows a required failure; the
observer controls omit a word tick or double a bytes tick.

Mutations ran in three dedicated scratch worktrees. Compilation failures,
timeouts, invalid countermodels and truncated loops are not counted as kills.
This was a targeted campaign, not an exhaustive Gambit pass. A separate evidence
checker compares compiler-produced ABI inventory with all 251 raw results,
audits mutation countermodels, binds artifact/log hashes, and confirms the same
Solidity bytes in concrete, symbolic and final mutation runs. Every Solidity
source from the preceding cache baseline is byte-identical; only the four new
harnesses were added.

Earlier probes, an interrupted larger descriptor-tail experiment and formatter
regressions caught by the concrete samples remain retained without proof credit.
Failed full-driver receipts also remain retained: Node 24.14.0 hit a V8 clone
deserialization exception in the combined Hardhat run, although its isolated
107-test Node run passed. The accepted combined run used the existing
`/usr/local/bin/node` **v26.10.0**, SHA-256
`ab9c8eecf9f82d6693cdc3accced17034065c8d96213b0aa76a7e803d20ae1da`.
This records observed outcomes without claiming a root cause for the driver
failure. No Solidity edit followed the accepted concrete gates.

## Provenance and reproduction

Tools: Halmos 0.3.3, Yices 2.6.4, Forge 1.5.1 at
`b0a9dd9ceda36f63e2326ce530c10e6916f4b8a2`, and solc 0.8.36, optimizer 200,
Cancun, no via-IR. The run uses `--loop 70`, byte lengths
`0,1,31,32,33,64,65`, two solver threads, four workers and a 900-second
per-property watchdog. Solver defaults and per-property annotations are
unchanged. UTC execution was 2026-10-12 22:10:56–22:20:25, corresponding to
2026-10-13 locally in Europe/Madrid.

Parent revision: `6a497132c59731535fa405162d0212bccec66f2f`. Dirty-tree source
hashes bind the complete snapshot. Generated evidence remains local or in CI
artifacts; handwritten proof sources, report and ledger are retained in the tree.

| Receipt | SHA-256 |
|---|---|
| [Baseline manifest](verification/halmos-behavior-20261013/manifest.json) | `5b12f74f6a7456adc2058ac76d1274dfd274b36d6287ac491c12ebd33c0836bc` |
| [Concrete gates](verification/halmos-behavior-20261013/checks.json) | `882d53905c9a5a17e390b934db8159f9a85bf047513ddd07b1867f3e0e2bc87f` |
| [Targeted mutations](verification/halmos-behavior-mutations-final-20261012/mutations.json) | `0d311020e2d0e222243ea7f3b138023b177d3dca21b1f5e8299902daac11a86c` |
| [Evidence audit](verification/halmos-behavior-20261013/review.json) | `eb1e10922e8e771024eb4c10e0590499d6bc969bf29ad2b2369942f7ac82a8a4` |
| [Complete run](verification/halmos-behavior-20261013/run.json) | `e46aabada8182d65a466407114c22ddf4466ffd71160cd29e6244384c5c7ca40` |
| [Reviewed mappings](verification/halmos-behavior-20261013/claims.json) | `7f86153962ae48eccfff1eab21ba7ca4356d70c9bd416644b45ab6e2b2ab4b7f` |

| Added proof source | SHA-256 |
|---|---|
| ClaimConstructionSymbolic.t.sol | `8e9381b21ce1cc82646048bc6522456d825c004f06a3c390fb0af3a78165a62d` |
| ClaimUnreadSymbolic.t.sol | `594f3a98ec460d76021c2c07a6cb2e5bec6a86e749d8f9fd43fa2c51d6bdef0c` |
| ClaimControlErrorsSymbolic.t.sol | `787ab7ee989c8c58155bf18f9bbeea1c3fbc4a1a394c9cda0d57dcc44210c32a` |
| ClaimNestedTypesSymbolic.t.sol | `9b1027ae5b8b358b61e516231536c309483ba93ff0beed5f3e3310730f9132dd` |

Finish every Solidity edit and formatting change before concrete gates and a
fresh baseline. The accepted commands were:

```sh
forge fmt --check
forge build
/usr/local/bin/node node_modules/hardhat/dist/src/cli.js compile
forge test
/usr/local/bin/node node_modules/hardhat/dist/src/cli.js test --no-compile
python3 -B scripts/test-claim-ledger.py
python3 scripts/verify-claims.py --output docs/verification/fresh-halmos-behavior --workers 4
```

Confirm the Node test count; a zero-test run supplies no fuzzer credit. After
review and refresh, check identities and labels with
`python3 -B scripts/test-claim-ledger.py` and
`python3 -B scripts/render-claims.py --check`. Post-ledger checks have their own
fresh receipts and never rewrite the accepted concrete/proof receipts.

The [220-property cache campaign](halmos-cache-20261012.md), earlier reports,
native Dafny/DafnyEVM receipts and both preserved working trees remain intact.
No new native verification, source/compiler correspondence, runtime
correspondence, Kontrol or Certora proof was added. Halmos executes compiled EVM
bytecode under its symbolic model; full EVM conformance and public-contract or
deployed-bytecode correctness do not follow. Deployment equivalence still needs
separate artifact matching. A clean checkout must rerun the campaign or retrieve
its retained local/CI artifacts; hashes cannot reconstruct missing receipts.

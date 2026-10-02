# Mutation testing, 2026-09-26 (second pass)

A Gambit pass over the four contracts and `AbiCodec`, to find behaviour that no
test or proof pins. It reruns the first pass of the same day after the source
changed under it: the fixed-length cap, the zero-length refusal, the OpenZeppelin
`Math` swaps, the word-at-a-time search and ProbeCall's operand type. Every
surviving mutant was either killed by a new test or classified as equivalent,
with the reason recorded below.

## Method

- **Generator:** Gambit (`cargo install --locked --git
  https://github.com/Certora/gambit.git`), solc 0.8.36 with the optimizer and
  `evmVersion` cancun, remapping `@openzeppelin/contracts/` and `forge-std/` to
  `node_modules`, one `gambit mutate --filename <source>` per file at commit
  `8cb9a0a`. It produced 4,497 mutants that compile: Operations 1,503, AbiCodec
  1,020, Collections 944, Assertions 895, Expressions 135. Operations has fewer
  than the first pass (1,964) because its hand-written `mulDiv`, `sqrt`, `log2`
  and modular inverse are now OpenZeppelin's.
- **Stage 1:** each mutant against `forge test --fail-fast` in ten persistent
  scratch worktrees, each warmed by one build so a mutant recompiles only what
  it touches. A mutant that fails to compile would be recorded apart, not as a
  kill; none did.
- **Stage 2:** each stage-1 survivor against the Halmos suites relevant to its
  contract, cheapest first, stopping at the first failure (every suite for an
  `AbiCodec` mutant, since all four contracts compile it in), then against the
  Node fuzzers (`math-fuzz`, `string-fuzz`, `compose-fuzz`, `collection-codec`,
  `nav-encode-fuzz`, `erc8211-differential`).
- **Gap tests:** for each stage-2 survivor that changes behaviour, a concrete
  test in `contracts/tests/MutationGaps.t.sol`, then a sweep of every survivor
  against that file. A test only counts once the mutant it targets fails it.

## Results

| Stage | Killed | Surviving |
|---|---|---|
| 1. Solidity tests | 4,375 | 122 |
| 2. Halmos (26) and Node fuzzers (35) | 61 | 61 |
| Gap tests (`MutationGaps.t.sol`, 2 new tests) | 2 | 59 |

All 59 remaining mutants are equivalent: no input distinguishes them from the
original, they change only gas, or they sit in code that could not run (three of
those lines were deleted after the pass). The kill rate is 98.7% of all mutants
and 100% of the non-equivalent ones. Stage 1 left 122 survivors against the
first pass's 659: the no-panic suites and the first pass's gap tests do most of
that work.

## What the gap tests pinned

- **Operations #937, `contains`:** its last start position is
  `s.length - needle.length`. `_matchesAt` now compares words straight from
  calldata, so a start past that bound would compare the zero padding after `s`
  and find `hex"6200"` in `"ab"`. The byte loop it replaced reverted out of
  bounds there, which is why the first pass never saw this.
  (`test_containsStopsAtTheLastWholeWindow`)
- **Collections #416, `mapValues`:** the up-front parse of `outputType`, so a
  malformed output type fails on an empty input too, before any result is
  validated against it. (`test_mapValuesRefusesAMalformedOutputTypeOnEmptyInput`)

## Resolved since the first pass

The first pass's open finding, a fixed size whose footprint overflows reverting
with `Panic(0x11)`, was fixed by `d3ff4c3`: `typeShape` caps every fixed length
and static footprint at 2^32 - 1 and reverts `InvalidTypeDescriptor`.
`validateComponent`'s overflow guard, which that finding made unreachable
(first pass #791, #802, #805; this pass #789, #803), is now deleted.

## Equivalent mutants, by reason

Ids are Gambit's, per contract, for this pass.

- **Code that cannot run (deleted after the pass):**
  - AbiCodec `validateComponent` #789, #803: the footprint overflow guard, since
    `typeShape` caps every footprint;
  - Assertions `_checkConstraint` #253: its final `InvalidOrConstraint` branch,
    since nested ORs are refused before any leaf is evaluated and a top-level
    OR has its own branch, so only `LTE_SIGNED` reaches the last line.
- **Redundant guards covered by a later check that reports the same error:**
  - AbiCodec `typeShape` #2, #5, #40 and `suffixStart` #153: callers pass a
    validated descriptor and a limit within it;
  - `slice` #289, #292 (its callers bound first);
  - `body` #331, and #610, #616, #617 on the string length bound, where the
    padded-length check on the next line refuses the same inputs at the same
    offset and the mutated bound still keeps `n + 31` from overflowing;
  - Assertions `_returnDynamic` #425, #427, #428, #431, #432 (the padded-length
    guard catches the same inputs);
  - `_navLength` #288, `_navPayload` #369 and `_navigate` #623 (the empty path
    is checked twice).
- **Identities on every valid input:**
  - the tuple loop bound `e - 1` versus `e`, because the closing `)` stops the
    scan: `body` #496, #497, #554, #603, #604;
  - `checkWords` #167: `suffixes` from `end == limit` returns what skipping it
    does;
  - the `n == 5 || n == 6` fast path, `typeShape` #17;
  - `-48` versus `%48` on digits: AbiCodec #241, #366, Assertions #671,
    Operations #1426, #1469;
  - `_unzipPair` #824, #832, where `head` is 0 whenever they run;
  - `contains` with an empty needle through the general path, Operations #930;
  - `formatUnits` with 0 decimals through the general path, Operations #1165;
  - `expWad`'s zero cutoff moved by one (Operations #211): the full formula
    rounds to 0 there too.
- **Gas only:**
  - `body` #686: the masked padding word only decides whether to run the byte
    scan, and the scan checks exactly the padding bytes;
  - Collections `_callValue` #925, #928: re-checking the target's code on every
    application instead of once (it cannot change between staticcalls);
  - `replace` #1039: an oversized match array.
- **Redundant assignments:** `sortValues` #507 and `sortWords` #301, #302
  (`takeA` is already false there); `_applyWords` #684, #697 (map mode never
  reads `kept`).
- **Memory past the output:** `assemble` #858, #885, #886: the extra header
  words and oversized copies land where later component copies overwrite them,
  or past the end of the output.
- **Two routes to the same result:** the modexp precompile threshold and routing,
  Operations #1 to #4, #1249, #1250, #1251, #1253, and `mulmod` already
  reducing the base (#1246).

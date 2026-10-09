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

## reduceWords and the word-engine reads, 2026-10-08

A targeted pass over what changed in Collections after the pass above:
`reduceWords`, `_reduce`, `_stampElements`, `_domainElem` and
`_checkElementWindows`.

- **Generator:** `gambit mutate --filename contracts/Collections.sol --functions
  reduceWords _reduce _stampElements _domainElem _checkElementWindows`, same
  compiler settings as above: 93 mutants. Gambit does not mutate inline
  assembly, where the comparison mask, the window stamping and the byte read
  live, so 17 more were written by hand: each term of the mask dropped, less
  and greater swapped, the truth normalisation removed, the count overwritten
  instead of added, five entries of the comparison table swapped, the stamp
  loop stopping after one window or stepping two, and the offset, window and
  byte reads fixed at index 0.
- **Stage 1:** each mutant against `forge test --fail-fast` in four scratch
  worktrees. 108 of 110 killed.
- **Gap tests:** two, in `MutationGaps.t.sol`, each checked against its mutant.
  - `_checkElementWindows` reading the first offset for every window survived
    one of two runs: only a fuzz case caught it.
    (`test_everyElementWindowIsBounded`)
  - `_domainElem` reading byte 0 for every index survived: no Solidity test
    folded over bytes that differ. (`test_foldBytesVisitsEveryByte`)
- **Equivalent:** `_reduce` #81, `hit & run.stop` as `hit * run.stop`: both are
  0 or 1.

Stage 2 (Halmos and the Node fuzzers) was not run for this pass.

## The gas pass, 2026-10-08

A targeted pass over what the gas pass changed: `AbiCodec`'s `shape`, the
one-word validation fast path, the single-pass `tupleLayout` and the one-pass
`assemble`; Collections' `_callValue`, `_validateResult` and `_prepareCallback`;
Expressions' `_address` and `_arguments`; Operations' `_foldCase` and
`_parseDigits`.

- **Generator:** `gambit mutate --functions` over those functions, same compiler
  settings as above: 694 mutants, of which the 403 in `AbiCodec.body` were left
  out (the pass changed it only mechanically, `requireValue(cond, ...)` to
  `if (!cond) fail(...)`), leaving 291. Most of the new code is inline assembly,
  which Gambit does not mutate, so 63 more were written by hand: each fast-path
  name answered wrongly or matched without its length, each range check dropped
  or off by one, the layout arrays under-allocated or mis-stored, every term of
  `assemble`'s head, tail, prefix and free-pointer arithmetic, the selector copy
  short or misplaced, each bound of the case fold, and each term of the digit
  loop.
- **Stage 1:** each mutant against `forge test --fail-fast` in six scratch
  copies. 314 of 354 killed.
- **Stage 2:** the eleven survivors that change behaviour against the Node
  fuzzers, then the Halmos suites for their contract (every suite for an
  `AbiCodec` mutant). The Node fuzzers killed five (the checked digit loop and
  the three case-fold mutants); six passed everything.
- **Gap tests:** five, in `MutationGaps.t.sol`, each checked against its
  mutants in a sweep of every survivor.
  - `_foldCase` stepping two words, stopping after the first, or letting a
    non-ASCII byte carry into the byte before it: no Solidity test folded more
    than one word or put a non-ASCII byte beside a boundary character.
    (`test_caseFoldCoversEveryWordAndSparesNonAscii`)
  - `_parseDigits`: the unchecked loop taking ":" as a digit survived every
    stage. Operations #24 and #28 are older code the pass uncovered: inputs of
    up to 77 digits no longer reach the checked loop, so its own non-digit
    refusal was only pinned by the fuzzers.
    (`test_parseUintRefusesNonDigitsOnBothPaths`)
  - AbiCodec #24 and #27, `word`'s bounds check: an array encoding that ends
    after its envelope word panicked instead of reverting `InvalidValue(32)`.
    (`test_unpackRefusesAMissingCount`)
  - Collections #42 and #44, the second slot of a binary callback declared
    with other text than the input type: neither its binding nor its
    validation was pinned, by any stage.
    (`test_secondSlotOfAnotherTypeIsBoundAndValidated`)
  - `tupleLayout` with a quarter of its capacity survived every stage: no
    descriptor in the tests was dense enough to fill the arrays. The same test
    showed the capacity's `+ 1` was never used, and it was removed, which also
    lets the test kill the layout without its length words.
    (`test_tupleLayoutHoldsTheDensestDescriptor`)
- **Equivalent or unobservable**, 28:
  - **A fast path switched off or narrowed**, falling through to the general
    path with the same result: AbiCodec #2, #50, #72, #565, Operations #11, #13,
    and the one-word check ignoring the descriptor's length (it then only ever
    matches `bool`).
  - **A larger allocation:** AbiCodec #509, #511, #513 and the doubled
    capacity. AbiCodec #505, #506 and #508 are `limit / 2`, now the source.
  - **Code no production caller reaches:** AbiCodec #47, the static branch of
    the shape-parsing `validate` overload.
  - **Work repeated, same result:** Collections #31, #34, #35 (the target
    checked on every application) and #37, #43 (a same-typed slot validated
    again).
  - **Memory nothing reads:** `assemble` without the zero word after the
    frame, without zeroing the lead (the frame and the selector overwrite all
    of it) or with an unrounded free pointer.
  - **Outside the pass:** Operations #1 to #5, the modexp threshold constant,
    equivalent as recorded above.

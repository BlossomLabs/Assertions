# Merged periphery size spike

Question: can `Operators` and `CollectionOperators` ship as one contract under the
24,576-byte EIP-170 limit, using source simplification and compiler settings only?

Answer: yes, with via-IR and one Yul optimizer step removed. The legacy pipeline
cannot get there without dropping functions. This is a historical experiment, not the active build. The merge and custom
optimizer settings were reverted; production keeps separate Operators and
CollectionOperators under the original compiler settings. Only selected
behavior-preserving source simplifications remain. The measurements below were taken on the
`merge-probe` worktree from the same sources.

All sizes are deployed runtime bytes from solc 0.8.36, Cancun. "Merged" below is a
probe contract inheriting both bases; the split columns are the bases alone.

## Compiler settings, original sources

| Pipeline | runs | Metadata | Merged | Operators | Collections |
|---|---:|---|---:|---:|---:|
| legacy | 200 | kept | 30,630 | 23,737 | 13,825 |
| legacy | 1 | kept | 30,036 | 23,396 | 13,631 |
| via-IR, default steps | 1 | kept | 27,501 | 21,668 | 12,329 |
| via-IR, default steps | 1 | stripped | 27,447 | 21,614 | 12,275 |
| via-IR, minus `F` | 1 | stripped | 25,263 | 20,538 | 10,788 |
| via-IR, minus `F` and `i` | 1 | stripped | 26,265 | 21,189 | 11,582 |
| via-IR, minus `F`, memory-safe assembly | 1 | stripped | 25,080 | 20,095 | 10,788 |

`F` is the Yul `FunctionSpecializer`. solc 0.8.36's default sequence (read from the
binary) is

```
dfDvulfnTUtnIfxa[r]EscLMVcul [j]Trpeulxa[r]cLvifMCTUca[r]LSsTFOtfDnca[r]IulcscCTUtvifMx[scCTUt] TOntnfDIulvifMjmul[jul] VcTOcul jmul
```

and the specializer clones every private function that is called with a literal
argument: `_parseUnits(.., signed)`, `prepareCallback(cb, binary)`,
`assemble(.., array)`, `callValue`/`predicate`, `requireValue`, `AbiCodec.word`.
Dropping the single `F` saves 2,184 bytes on the merged probe. Removing the
`FullInliner` (`i`) as well makes things worse. `revertStrings: strip` and
`evmVersion: prague` change nothing. Stripping the CBOR metadata is worth 54 bytes
and is not needed.

The Operators assembly blocks were not annotated `memory-safe`, so via-IR emitted
no memoryguard and could not spill stack variables to memory; one alternative step
sequence failed with stack-too-deep in `_parseUnits`. Every block was checked
before annotating: they write only inside caller-sized buffers, shrink a length
word, use scratch space `0x00..0x3f`, or terminate with `return`/`revert`. The
legacy pipeline ignores the annotation, so legacy bytecode is unchanged by it.

## Source changes, then the real merge

Operators.sol:

- `_wordCount(s)` (alignment check plus count) and `_calldataWord(s, i)`
  (`calldataload`) replace the per-function `s.length % 32` checks and
  `s[i*32:i*32+32]` slices in the word family, `_applyWords`, `foldWords` and
  `_domainElem`; `reverseWords`, `zipWords`, `unzipWords` write through `_setWord`.
- `sqrt` seeds Newton from `1 << (_log2(x) >> 1)` instead of its own bit ladder
  (the OpenZeppelin form; seven iterations remain exact).
- `toLower`/`toUpper` share `_foldCase(s, low, high)` (XOR `0x20`).
- `parseUint`/`parseInt` share `_parseDigits(s, start)`; error cases are unchanged.
- `hashPairSorted` swaps then hashes once.
- `contract Operators is CollectionOperators`.

CollectionOperators.sol: the bottom-up merge sort keeps its comparison sequence
but the pass loop moved into `mergePass` and the callback into `compare`, so the
seven-field `SortCursor` struct is gone. A binary insertion sort was tried first:
450 bytes smaller still, but 49 comparator calls instead of 32 on the descending
16-element benchmark (971,596 gas against 717,526), so it was reverted.

Final sources, the `Operators` column now being the merged contract:

| Pipeline | runs | Metadata | Operators (merged) | Collections alone |
|---|---:|---|---:|---:|
| via-IR, minus `F` | 1 | kept | 23,953 | 10,612 |
| via-IR, minus `F` | 200 | kept | 23,997 | 10,638 |
| via-IR, minus `F` | 1 | stripped | 23,899 | 10,558 |
| via-IR, default steps | 1 | kept | 26,681 | 12,463 |
| legacy | 1 | kept | 28,304 | 13,405 |
| legacy | 200 | kept | 28,884 | 13,599 |

Headroom at the profile in `hardhat.config.ts` (via-IR, minus `F`, runs 200,
metadata kept): 579 bytes. The largest remaining bodies are `AbiCodec.typeShape`
(1,489) and `AbiCodec.body` (1,415); AbiCodec was left untouched because the core
shares it.

## Gas

`pnpm hardhat run scripts/measure-collection-gas.ts`, descending int256 values,
transaction estimates including intrinsic and calldata gas. The two "original"
columns differ only by compiler profile; the two via-IR columns differ only by
sources.

| Operation | n | legacy 200, original | via-IR minus `F` runs 1, original | via-IR minus `F` runs 1, final | via-IR minus `F` runs 200, final |
|---|---:|---:|---:|---:|---:|
| packArray | 1 | 32,836 | 34,768 | 34,504 | 34,489 |
| packArray | 4 | 49,016 | 53,756 | 53,216 | 53,183 |
| packArray | 16 | 113,858 | 129,830 | 128,186 | 128,081 |
| sortValues | 1 | 63,614 | 71,896 | 70,714 | 70,675 |
| sortValues | 4 | 137,322 | 162,399 | 158,012 | 157,907 |
| sortValues | 16 | 580,707 | 717,526 | 692,128 | 691,615 |
| foldValues | 1 | 86,701 | 99,746 | 98,598 | 98,541 |
| foldValues | 4 | 149,174 | 177,349 | 175,400 | 175,280 |
| foldValues | 16 | 399,384 | 488,093 | 482,940 | 482,568 |

So via-IR itself costs 12 to 21 percent on the collection loops, `runs` makes no
difference, and the source trims recover 1 to 4 percent. Word-level numbers from
the `numeric-gas` lines of `pnpm test` (legacy 200 original, then via-IR final):
unsigned `mulDiv` 23,460 both; signed `mulDiv` 23,460 then 23,844; `parseUnits`
26,207 then 26,297; `formatUnits` 26,626 then 26,706.

## Verification

- `pnpm test` under the via-IR profile, final sources: 410 passing (323 Solidity,
  87 Node). The OperatorsGas size assertion now checks the merged contract.
- `CollectionOperators.t.sol` deploys the merged `Operators` and casts it, so its
  13 tests reach every collection function through the merged dispatcher.
- The same suite on the untouched snapshot under the legacy profile: 410 passing.

## Reproduce

```
node scripts/probe-size.mjs --nomerge --viaIR --runs 200 --steps "<sequence without F>"
node scripts/probe-size.mjs --nomerge --viaIR --runs 1 --nocbor --steps "..." --attr Operators
node scripts/probe-size.mjs --runs 200            # legacy, production settings
```

`--attr` prints per-function sizes from `functionDebugData` entry points.

## If this is adopted

- Both hardhat profiles carry the custom sequence; the string is part of the
  bytecode contract and belongs next to the solc pin.
- `export-deploy-artifact.mjs`, the website checker, the SDK addresses and the
  runtime fixtures all assume three contracts; CREATE2 addresses change.
- The collection callback ABI and errors are unchanged, so EVML compile faces
  need only the new address.

# Static suffix traversal and word-copy correspondence

This milestone extends the existing recursive ABI work at its descriptor
interface. It does not replace the independent recursive model or claim that
the complete descriptor parser has been verified.

`generate.py` checks the **complete** typed AST skeleton of production
`AbiCodec.suffixes`, including both loops, pre/postincrements, guards, the
unchecked block and the returned pair. It translates the arithmetic expressions
from the AST. The per-digit arithmetic is factored into the separately verified `Digit`
method. Each unchecked uint256 arithmetic operation is reduced modulo
`2^256`; the proof establishes the mathematical result on the stated domain.
Unexpected control flow fails generation. Splitting the inner loop into
`ReadSuffix` and normalizing its preincrement condition are explicit trusted
translation steps. `byteAt`'s complete Yul byte-projection skeleton is checked.

The independent syntax specification permits any finite list of `[digits]`
suffixes, arbitrary leading zeros and any number of digits. Every count must be
positive and at most `2^32-1`, and their product must have the same bound.
There is no selected recursion or loop-unrolling bound. An empty suffix list
returns product 1. The surrounding descriptor may have arbitrary prefixes and
suffixes: the scan stops at the specified limit or the first non-`[` delimiter.

The source-derived `Suffixes` returns exactly the syntax extent and the product
of its counts. `WrapShape` connects that product with the head footprint of
nested fixed arrays in the existing algebraic ABI model. The wrapping order is
explicit: `T[2][3]` is three values of type `T[2]`.

`WordCopies` composes this result with the existing source-derived word checker.
The generator checks the complete non-tuple `checkWords` branch against that
composition. Given the classified static base name, it establishes the descriptor end,
static footprint, acceptance of precisely the canonical words, and the exact
first offending word offset, including zero repetitions and arbitrary in-bounds
byte positions. Opaque/full-width words preserve their deliberate unrestricted
behavior. The separate word-classifier SMT and padding-mask gates remain
mandatory dependencies, verified by retained evidence and matching source hashes.

The [retained baseline](../evidence/descriptor-traversal-final/manifest.json) passes
**91 lemmas, 25 proof methods and 388 verification batches**, with zero errors,
timeouts or audit findings, and all six EVM tests. It rechecks the complete
included Dafny dependency graph. These counts include the earlier 279 batches;
the milestone adds nine lemmas, four methods and 109 batches. The 107
word-classifier queries and 32 padding-mask obligations are reused from the
unchanged passing word baseline after verifying its evidence integrity and
matching source hashes; they were not re-executed in this run.

The [final mutation report](../evidence/descriptor-traversal-final-mutations/mutations.json)
records **all four source faults detected**, each by an explicit semantic proof
failure and at least one EVM test failure, with all six tests accounted for.
There are no timeouts or source drift in the final campaign.

## What is still assumed

- `typeShape` has established the accepted static suffix grammar and product
  bound. This milestone proves the consuming suffix scanner, **not** the parser
  that establishes those preconditions or rejection of malformed descriptors.
  The later [typeShape milestone](../shape/README.md) now derives these premises
  from every successful static non-tuple parse. The [parser successor](../parser/README.md) additionally characterizes acceptance and exact reference outcomes, including arithmetic panics.
- The caller has selected a static base type; dynamic `bytes`/`string` bases
  do not belong to this scalar interface even though `wordRule` returns kind 0
  for those spellings. `wordRule` supplies the classified rule and name end. Its retained SMT proof
  covers classification; mapping that result into this typed interface remains
  part of the trusted composition/translation boundary.
- This milestone's word interface requires an in-allocation origin even for
  zero words. The [recursive tuple successor](../tuples/README.md) adds a
  zero-run specialization that makes no value reads and permits origins beyond
  the allocation. Tuple cursor arithmetic must still fit uint256; that premise
  and its near-maximum counterexample are explicit.
- The successor proves recursive tuple enumeration and first/repeated-copy
  scheduling, including exact first-invalid offsets. The [connection successor](../connection/README.md)
  connects static validation to canonical acceptance and proves `suffixStart`
  and body head preparation. The recursive dynamic-body connection, other
  error contexts and bytecode induction remain separate obligations.

## Reproduce

Use the existing pinned Dafny 4.11.0, bundled Z3 4.12.1 and solc 0.8.36:

```sh
python3 formal/abi/descriptor/verify.py \
  --dafny /path/to/dafny/dafny --solc /path/to/solc \
  --word-evidence formal/abi/evidence/abi-codec-words-complete/manifest.json \
  --output /tmp/abi-descriptor-baseline

python3 formal/abi/descriptor/mutations.py \
  --dafny /path/to/dafny/dafny --solc /path/to/solc \
  --baseline /tmp/abi-descriptor-baseline/manifest.json \
  --output /tmp/abi-descriptor-mutations
```

Outputs must be fresh directories. The verifier checks every included proof
file, inventories declarations and native CSV results, audits soundness escapes,
checks generated-file freshness, verifies dependency evidence integrity and
source identity, runs six isolated EVM tests, and checks formatting. It records
versions, executable/source hashes, source snapshots, commands, bounds, outcomes
and logs. Timeouts and unsupported paths remain incomplete. No production
Solidity or deployment artifacts need to change for this proof milestone.

The EVM oracles use the unmodified production library and independent expected
counts/solc encodings. They cover multi-digit and leading-zero suffixes, 130
leading zeros, 24 suffixes, maximum fixed count with zero repetitions, static
tuples, narrow bytes and booleans, arbitrary-position repeated values, and exact
bad-word offsets. These examples do not establish general tuple correspondence.

Four mutations alter actual Solidity: initial product zero, radix eleven,
incorrect digit origin, and adding rather than multiplying suffix counts.
Each must translate successfully, fail a named previously passing proof through
a semantic failure, and fail at least one EVM oracle with all six tests accounted
for. Timeouts or rejected translation never count as detection.

## Retained attempts

The [first combined baseline](../evidence/descriptor-suffixes/manifest.json)
passed. The [following attempt](../evidence/descriptor-suffixes-complete/manifest.json)
exposed insufficiently explicit output-span bounds while checking the
`WordCopies` postconditions. It is retained as failed proof-harness verification,
not a Solidity counterexample. The current theorem states the output-span bound
explicitly; its input bound was only reassociated algebraically, not weakened.

The [first mutation attempt](../evidence/descriptor-suffix-mutations/mutations.json)
records three detected faults and a radix-eleven solver timeout. The timeout is
incomplete and is not counted as detection. The [isolated retry](../evidence/descriptor-suffix-mutations-complete/mutations.json)
also retains that timeout. The current baseline separately verifies the actual
per-digit arithmetic in `Digit`; the digit-origin and radix mutations target
that same previously passing universal statement. The full loop invariant is
retained, all proof dependencies are rechecked, and the 30-second limit remains.
The [intermediate span-bound baseline](../evidence/descriptor-suffixes-verified/manifest.json)
remains as passed evidence before the per-digit factoring.

The [isolated per-digit attempt](../evidence/descriptor-traversal-mutations/mutations.json)
found the explicit radix witness but also timed out on a separate postcondition
obligation; its strict campaign result remains incomplete. The final campaign
uses the baseline's per-method grouping: `Suffixes` retains assertion isolation,
while `Digit` checks its universal postcondition and reachable witness together.
No assertion is removed and the solver time limit remains 30 seconds.

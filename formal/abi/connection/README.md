# Static validation and descriptor-to-body connection

This milestone connects the parsed descriptor, its actual narrow-word rules,
and the source-derived static validator to the independent recursive ABI
validator. It also proves `suffixStart` and the descriptor/count/head preludes
of `body`. The recursive dynamic-body walk remains a separate obligation.

## Established properties

`TypeOf` preserves each recognized narrow-word rule, instead of erasing static
names to `Opaque` as the earlier head-shape model does. `ModelType` proves that
its types are well formed, have the parsed head widths and satisfy recursive
`ShapesFit`. Opaque names still admit every word, matching the codec's grammar.

`StaticWalk` proves that the independent validator's traversal of any accepted
static descriptor agrees with the flattened word-rule scan. Induction covers
nonempty tuples and positive fixed arrays at arbitrary finite nesting and
count, including nested narrow and opaque leaves. This removes the earlier
static-word interface assumption for these types.

`StaticEntrypoint` calls the source-derived parser and `ValidateStatic`. For
any descriptor accepted as static and any byte sequence whose length fits
uint256, acceptance is equivalent to the existence of a well-typed,
representable value whose independent canonical encoding equals those bytes.
There is **no assumed value-span bound**: the source length guard proves the
exact footprint or rejects at offset zero. After that guard, the earlier
`checkWords` theorem establishes the first invalid word's offset. Static
success returns normally; this is not a theorem that every return value is true.

The new body preparation proofs establish:

- `SuffixStart` returns exactly the reference reverse-digit scan's opening
  bracket or malformed-byte position on its safe-index domain. `ArraySpan`
  derives that domain, the successful bracket position and the element span
  from accepted array syntax, including arbitrary leading zeros.
- `FixedCount` recovers the parsed decimal count. Each checked intermediate
  arithmetic operation fits; no chosen digit-length unrolling bound is used.
- `ParsedArrayHead` uses the actual parser and source head-bound kernel to
  obtain the element shape and exact bounded footprint. Missing count words,
  out-of-range origins and hostile counts return the documented value offset.
- `ParsedTupleHead` enumerates every parsed field in `body`'s first pass and
  either obtains the exact sum of their head sizes or rejects at the body origin.
  Each addition/multiplication is justified by the source's remaining-data guard.

## Source connection and limits

`generate.py` checks complete solc AST skeletons for `suffixStart`,
`validateStatic`, all `validate` dispatch overloads and `body`, in addition to
its predecessors' parser and word-traversal gates. It translates the initial
suffix position, digit tests, opening-byte test, static length condition,
decimal update and first tuple-pass cursor update from the actual source.
The proof uses these expressions through separately verified methods.
The full `body` AST gate detects drift; it does **not** prove the unmodeled
branches merely because their syntax matches.

Remaining obligations include the dynamic array element loop, the second tuple
pass, recursive body dispatch, dynamic single-value envelope/extent composition,
and their caller arithmetic bounds. In particular, a successful zero-count
array head does not by itself establish the conservative `base + 32*elementWidth`
bound required by the earlier tuple scanner theorem. That bound must be derived
or the zero-count contract refined before claiming the whole dynamic walk.
`tupleLayout`'s separate assembly enumeration is also still open.

Outcomes model the default `ContextKind.Value` route. Other component/callback
error contexts and public caller integration beyond the stated static dispatch
are separate. The solc AST, restricted Python translator, loop/recursion
factoring, memory/calldata projection, Dafny/Boogie/Z3 and the independently
source-checked whitelist interface are trusted. Valid nonwrapping data layout
and sufficient gas, stack and allocation resources are assumed. There is no
unbounded-resource or compiler-correctness theorem and no new arbitrary-geometry
bytecode proof. No axioms, unchecked proof bodies or termination escapes are added.

## EVM oracle and fault sensitivity

Twelve EVM tests use solc `abi.encode` for nested static tuples/fixed arrays,
empty and nonempty arrays of static tuples, dynamic fixed arrays with long
leading-zero counts, and mixed dynamic tuple bodies. They also check every
static word and first-error precedence, wrong lengths, hostile/missing counts,
unaligned origins and descriptor subspans. Suffix positions use an independent
forward scan; malformed-byte positions use scanned sentinels.

Seven isolated actual-source mutations alter the suffix starting position,
either digit boundary, the opening byte, the static length conjunction,
decimal base or tuple-head cursor. Each must produce both a semantic failure
in its named proof obligation and an EVM test failure. All twelve tests must
be accounted for in each mutant. Timeouts and translation rejection cannot
count as detecting a mutation.

## Reproduce

```sh
python3 -B formal/abi/connection/verify.py \
  --dafny /path/to/dafny/dafny --solc /path/to/solc-0.8.36 \
  --tuple-evidence formal/abi/evidence/tuple-traversal-complete/manifest.json \
  --word-evidence formal/abi/evidence/abi-codec-words-complete/manifest.json \
  --output /tmp/abi-connection-baseline

python3 -B formal/abi/connection/mutations.py \
  --dafny /path/to/dafny/dafny --solc /path/to/solc-0.8.36 \
  --baseline /tmp/abi-connection-baseline/manifest.json \
  --output /tmp/abi-connection-mutations
```

Use fresh output directories. Every file in the proof dependency graph is
inventoried and verified as its own entrypoint; all included contracts have
checked bodies in the same baseline. The runner retains per-module native CSV
and logs, source snapshots/hashes, tool versions/hashes, commands, bounds,
assumptions, EVM test names/counts, source-generation freshness, prior-evidence
integrity, the whitelist mapping, bitvector gates, soundness audit and formatting.
The solver limit remains 30 seconds per batch with a 900-second outer graph
budget. Counts overlap earlier baselines and must not be added together.

## Retained baseline

The [complete baseline](../evidence/connection-static-heads/manifest.json) passes
**148 lemmas, 61 proof methods and 2,764 verification batches** across all
32 dependency files. All twelve EVM tests, three bitvector gates, prior-evidence
integrity, whitelist mapping, source-generation freshness, formatting and audit
checks pass, with zero errors, timeouts, audit findings or source drift.
The production source hash matches the existing ABI/Halmos release candidate.
This milestone changes proof, test-oracle and documentation files only.

The [mutation campaign](../evidence/connection-static-heads-mutations/mutations.json)
passes **7/7**. Every fault produces a semantic proof failure and an observed
EVM failure, with all twelve tests accounted for per mutant and no timeouts or
source drift. The earlier six parser and five static-traversal mutations remain
separate retained evidence; these campaigns target eighteen actual-source faults
in total, rather than eighteen disjoint claim proofs.

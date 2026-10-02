# Array/tuple cursors and recursive composition

The combined ABI baseline passes **79 lemmas, 16 proof methods and 260 verification
batches**, plus all 32 bytes-padding mask queries. This includes the earlier
model and bytes/string work: this milestone adds 11 lemmas and 11 methods.
All nine aggregate source mutations are detected by semantic verification
failures, with no mutation timeouts. The full soundness audit has zero findings.

This is a **compositional proof with source-derived cursor kernels**, not full
translation of `AbiCodec.body`, `typeShape`, `checkWords` or compiled bytecode.
The [separate runtime proof](../bytecode/README.md) checks the exact Hardhat
Collections bytecode for explicitly enumerated geometries. This milestone
originally left production unchanged. Its regenerated kernels are included in
the later [ABI repair baseline](../evidence/abi-codec-words-complete/manifest.json),
which covers the descriptor-boundary and trailing-offset fixes under the same
composition assumptions. The separate Kontrol project is unchanged.

## What the inductive proof establishes

`generate.py` extracts selected typed AST statements from the actual array and
tuple branches of `AbiCodec.body`. The seven generated methods retain checked
arithmetic, panic outcomes and rejection conditions:

| Generated method | Selected source behavior |
|---|---|
| `ArrayHead` | Bound count by remaining bytes/32/element words before multiplication; compute the entire head. |
| `TupleHeadStep` | Bound each field width against the remaining bytes; advance the head size. |
| `ArrayPosition` | Compute the element position using index, word width and the factor 32. |
| `ArrayOffset` | Require the array element offset word to equal the next tail position. |
| `TupleOffset` | Require the dynamic tuple field offset to equal the next tail position. |
| `ArrayTailAdvance` | Compute the child address and advance the array tail by the validated child extent. |
| `TupleTailAdvance` | Compute the child address and advance the tuple tail by the validated child extent. |

Their contracts prove exact results/error offsets and absence of arithmetic
panics under explicit interval and child-extent preconditions. Proof hints are
proved lemmas and assertions. There are no axioms, `assume` statements or skipped
bodies. `ArrayHead` isolates its assertions to help the solver; none is omitted.

`CursorSemantics.dfy` proves the division/product equivalence behind the hostile
count guard, intermediate-product and position bounds, list/prefix head sums,
the static extent contract, and composition of recursively parsed field results.

`Refinement.dfy` then composes those kernels:

- `TupleHead` proves the two-pass tuple's head sizing, including early rejection
  when the head cannot fit.
- `Scan` maintains head/tail interval bounds and equality to the independent
  `WalkFields` over the remaining fields. Uniform arrays additionally use the
  actual source position formula. Dynamic fields use the corresponding source
  offset check and tail update.
- `ComposedWalk` recursively handles tuples, fixed arrays, dynamic arrays,
  bytes/string and scalar interfaces. It equals the independent model `Walk`,
  including on rejected inputs. Arrays of static children and empty dynamic
  arrays are included.
- `CanonicalAggregate` connects the composed walker to `Validate` and the
  existing canonical encoding theorem: acceptance is equivalent to existence of
  a representable well-typed value whose encoding is exactly the input.

The proof uses induction over all finite algebraic types and input sequences,
subject to `ShapesFit` and `uint256` input-length bounds. There is no selected
nesting, array-length or iteration-unrolling bound. This does not imply that
arbitrarily large inputs execute within EVM resource limits.

## Interfaces that remain open

1. **Descriptor parsing and traversal.** `ShapesFit` requires a well-formed
   algebraic type and recursively representable `HeadWords`. The later [typeShape milestone](../shape/README.md) maps successful recursive
   text parses to well-formed shapes and establishes `ShapesFit`, including fixed
   counts and tuple widths. The [parser successor](../parser/README.md) now proves grammar acceptance completeness and exact reference outcomes. The [connection successor](../connection/README.md) proves `suffixStart`, array preparation and the first tuple head pass; the recursive dynamic-body connection remains open. The descriptor
   cursors and loop-control normalization are hand-written composition, not
   hidden parts of the AST translation.
2. **Static word validation.** The scalar case uses the independent model's
   `CanonicalWord`/`Walk` interface. Replacing `checkWords`'s static bulk scan with
   recursive typed children is conditional on its agreement with that interface.
   The later word milestone proves classification and the uniform word scanner;
   the [descriptor milestone](../descriptor/README.md) additionally proves the
   validated fixed-suffix scanner and non-tuple word-copy composition. The [tuple successor](../tuples/README.md) adds recursive static tuple/copy traversal and its narrow-rule mapping. The [connection successor](../connection/README.md) proves that flattened static traversal agrees with the independent recursive validator and establishes static canonical acceptance. Its integration through every dynamic-body call site remains open.
3. **Complete source connection.** Selected kernels are source-derived;
   `ComposedWalk` and `Scan` are a proved typed composition, not an automatically
   translated copy of the entire Solidity function. A theorem that the original
   descriptor-driven control flow implements this composition remains open.
4. **Errors and resources.** Kernels retain precise offsets, but the composed
   walker collapses aggregate failures to `Rejected`. It does not establish all
   aggregate error positions or callback/tuple-component error contexts. The
   prior bytes-memory/MLOAD interpretation, trusted translator/Dafny/Z3, and
   sufficient-gas assumptions remain. Memory allocation, stack limits, physical
   pointer arithmetic and compiler correctness are outside the proof.

Consequently this milestone must not turn a ledger row for the entire Solidity
validator, parser or arbitrary compiled-bytecode execution into `PROVED`.

## Reproduce and inspect

Use the existing `../toolchain.json` (Dafny 4.11.0, bundled Z3 4.12.1, two workers,
explicit induction, 30 seconds per batch), solc 0.8.36 and a fresh output directory.
First run the [bytecode evidence runner](../bytecode/README.md), then:

```sh
python3 formal/abi/aggregate/verify.py \
  --dafny /path/to/dafny/dafny \
  --solc /path/to/solc-0.8.36 \
  --bytecode-evidence /tmp/abi-bytecode/manifest.json \
  --output /tmp/abi-aggregates

python3 formal/abi/aggregate/mutations.py \
  --dafny /path/to/dafny/dafny \
  --solc /path/to/solc-0.8.36 \
  --baseline /tmp/abi-aggregates/manifest.json \
  --output /tmp/abi-aggregate-mutations
```

The runner verifies **every included model and proof file**, including the older
examples, generated source and source-to-model composition. It checks generation
freshness, all mask queries, declaration/result counts, soundness audit, the
independent viem fixture, formatting and the retained bytecode/concrete gate.
Source snapshots, hashes, compiler AST/mappings, commands, versions, bounds and
native CSV results are retained. Unknown syntax, missing results, failures,
timeouts or source drift cannot receive a passed status.

The [full baseline](../evidence/aggregate-complete/manifest.json) and
[nine-mutation report](../evidence/aggregate-mutations/mutations.json) were copied
without alteration from their original temporary run directories; the logged
commands preserve those original paths. The baseline's copied bytecode gate is
the initial ten-property snapshot of the same canonical runtime. The expanded
[twelve-property runtime baseline](../evidence/bytecode-aggregates-final/manifest.json)
is retained separately; its runtime hash is identical.

Mutations alter copied Solidity and regenerate the AST-derived kernels. They
remove either head/count guard, alter head width or element stride, omit either
offset comparison, or add one to either child extent. Each target passed in the
complete positive run. Only an explicit semantic failure in that target counts;
parser errors, translation rejection and timeouts do not. Live Solidity is
never edited. The bytecode suite independently catches both guard removals,
both offset removals and the tuple-width mutation on a concrete EVM as well.

The later [tuple milestone](../tuples/README.md) closes recursive static `checkWords` traversal. The [connection successor](../connection/README.md) adds static canonical acceptance, `suffixStart` and body head preparation. Next is the recursive dynamic-body connection. Unbounded bytecode induction requires
a separate proof; it is not obtained by increasing a symbolic loop bound.

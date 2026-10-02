# Value-sort merge loops with comparison traces

This package proves the merge suffix of `sortValues` under explicit faithful
comparison-result and value-array projections. It does not yet instantiate those
observations with concrete callback/prepared-state histories or compose public
admission, so it adds no completed public entry.

The independent specification uses recursive `Merge`, `Pass` and `Sort` functions.
An environment receives the complete prior comparison trace plus a request naming
both current array positions and original occurrence IDs. Its answer may depend
on history, may choose either side, or may fail with arbitrary exact bytes.
`Prepend` drops partial output when propagating failure. This specifies both
comparison order and the first propagated failure without assuming consistency.

The generated adapter gates the complete `sortValues` AST and lowers the merge
suffix's guards, drain choices, cursor/destination loops, width/start loops and
reference swaps. The actual comparison block is represented by one faithful
signed-decision/error observation; the completed comparator package will provide
its concrete implementation in the next composition step. The copied input,
scratch array and each assignment are projected to sequences of original IDs;
these must faithfully preserve the corresponding element bytes. Initial scratch
uses a sentinel ID, and every destination is overwritten before the buffer is
read as a subsequent source. Allocation and bytes[] pointer/memory projection
remain explicit premises.

`MergeRange` maintains exact equality between the written prefix plus the
recursive remaining merge and the initial reference outcome. `Pass` extends this
to adjacent runs; `Sort` extends it through width doubling and buffer swaps.
`Extends` certifies every added row against the environment at its exact prior
trace. `Stopped` requires all preceding decisions to succeed and a failure, if
any, to be the final observed decision. Empty/singleton sorting has no comparison.

Success always yields a permutation of all distinct original occurrence IDs.
Ordering is separate: `Coherent` requires every recorded decision to agree with
one relation on IDs, and the existing sorting proof requires that relation to be
a total preorder. Under both conditions the result is globally sorted and ties
retain strictly increasing original indices. Coherence of a trace implies
coherence of all its prefixes, so the conditional invariant survives each merge
and pass. No coherence or determinism is assumed for arbitrary supplied callback
observations. An inconsistent-choice example still proves a successful reversed
permutation; a later-failure example pins current indices `(0,2)` with occurrence
IDs `(1,3)` after two earlier comparisons.

`CountRoom` requires `32*n < 2^256`, as needed for a representable source array
frame. This derives safety of source cursor increments, span expressions, starts
that overshoot the count and doubled widths. The recursive specification itself
uses arbitrary finite natural domains. Faithful array/observation projection,
valid memory, adequate allocation/execution resources, source translation and
compiler semantics remain explicit; Dafny, Boogie, Z3 and pinned solc AST output
remain trusted. Compiler loop-optimization metadata is omitted from the syntax
gate; actual loop expressions and source arithmetic safety are checked separately.

The retained driver checks all new native declarations, reused ABI/sorting
source/tool/evidence hashes, zero audit findings, source regeneration and
formatting. Six actual EVM fixtures cover tagged stable duplicates, both drain
directions, empty/singleton paths, inconsistent-comparator permutation and later
failure context/calldata. Three isolated source faults invert right-run draining,
compare an exhausted run, or skip sorting passes; each must pass translation and
fail both proof and EVM checks. A timeout alone is never a detected semantic fault.

```sh
python3 formal/collections/value-sort-trace/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/value-sort-trace/evidence/observed-merge-suffix
```

The retained manifest determines completion/counts. Actual callback-state and
admission composition, complete public `sortValues`, remaining Collections
families and exact bytecode stay open. No complexity, gas, deployment or
historical-performance claim is made.

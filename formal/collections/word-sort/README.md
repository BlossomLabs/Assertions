# Unsigned word sort source connection

This package connects the complete `Collections.sortWords` source body to an
independent stable merge specification and to the actual word-memory helpers.
It handles arbitrary finite input lengths under the explicit premises below.
The retained manifest, rather than this document, determines proof completion.

`generate.py` compiles the actual source with pinned solc, gates the complete
function signature and body against the reviewed AST structure, and translates
the merge guards and comparator operator. The fixed structure maps alignment
rejection, input copy, zero scratch allocation, the three nested loops, reference
swaps and counter updates. `UnalignedWords`'s selector and uint256 argument schema
come from that compilation. The generated adapter must reproduce byte-for-byte.
This restricted translation and its review remain trusted.

`Representation` assigns each source occurrence an original index, and relates
those ghost indices to actual big-endian words in byte memory. Its reads and
writes invoke the completed `_wordAt`/`_setWord` source connection. Writes preserve
the source frame and update exactly one scratch word. Initial scratch indices
use an out-of-domain sentinel representing zero; every destination is overwritten
before the scratch buffer becomes the source for a subsequent pass.

`MergeRange` lowers the actual two-cursor loop, including exhausted-run decisions,
left-biased unsigned comparison, postincrement selection and destination writes.
Its invariant relates the written prefix and remaining runs to independent
recursive `Merge`. `Pass` preserves completed runs and doubles their width.
`SortWords` swaps both physical buffer references and their ghost sequences,
terminates, and preserves exactly the original occurrence multiset. The unsigned
key relation satisfies the total-preorder laws; final output is globally sorted
and equal values retain strictly increasing original occurrence indices.

`Connection.Run` exposes exact alignment rejection bytes, output length,
word-multiset permutation, unsigned sortedness and stable occurrence order.
Natural counter lemmas derive uint256 safety from the finite byte-frame bound,
including increments, doubled widths, and starts that may overshoot the count.
There is no fixed input-count cap in the theorem.

## Explicit boundary and trust premises

The decoded input length fits uint256. For aligned inputs, the source copy and
allocation are projected to an existing input bytes frame and zero-filled scratch
frame of equal length, with disjoint complete memory extents and total memory
length below 2^256. This is a faithful compiler allocation/copy premise, not a
proved allocator. Return ABI serialization, compiler error encoding, sufficient
execution resources, source translation and the EVM load/store interpretation
remain explicit. Within these premises, helper writes preserve frame separation;
no comparator determinism assumption is needed for unsigned word comparison.
Dafny, Boogie, Z3 and pinned solc AST/schema output remain trusted. Exact compiled
bytecode verification is a separate unfinished track.

The driver checks reused ABI, mathematical sorting and word-memory evidence,
verifies every local declaration, requires zero audit findings and formatting,
and runs eight actual `sortWords` EVM fixtures. The fixtures cover empty/single,
first/last, odd runs, full-width unsigned values, duplicate keys, multiple passes,
unaligned rejection, power-of-two sizes and both run-drain directions. Two
isolated source faults (descending comparison and inverted right-exhaustion)
must pass source translation and then fail the merge proof and EVM suite.
Timeouts alone never count as semantic fault detection.

```sh
python3 formal/collections/word-sort/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/word-sort/evidence/unsigned-word-source
```

This package does not establish `sortValues`, callback comparators, the remaining
Collections families, complexity bounds, gas measurements, deployment facts or
historical performance claims.

# Exact Assertions constraint leaf bytecode

This package covers the complete internal `_checkConstraint` helper at PC10646
of the frozen 20,049-byte Assertions runtime, SHA256
`84ab614cb3395df4575bfb525e3278273361a7b7b75289d5b12dd13518b91903`.
Collections, Operations and Expressions are excluded.

An independent declarative specification fixes the eight non-OR wire kinds,
their exact reference widths, signed and unsigned order, predicate result and
exact InvalidConstraintData/InvalidConstraintRange bytes. Twenty-two exhaustive
symbolic partitions execute every reached instruction, shared decoder, actual
byte memory load/store, caller return and physical error serializer. Concrete
representatives guide generation but are absent from theorem premises. A
decreasing certificate index constructs finite actual-step traces without an
execution bound or discarded path. The helper's two actual caller continuation
labels, 7993 and 8035, are frozen full-runtime instruction boundaries.

The internal representation premises describe the caller stack and actual
physical memory. Caller decoding, allocation, OR structure and the outer
constraint loop must discharge them. This package therefore contributes an
internal composable theorem; it does not establish any complete public ABI
entry or whole-contract verification. `_resolve`, `_judge`, raw boundaries,
external observations, recursion and public serializers remain separate work.
Supplied jump destinations must be real instruction boundaries in the full
runtime. Adequate execution resources and the reviewed EVM subset remain
explicit trusted premises; this is not a gas theorem.

Generation and retained verification:

```sh
python3 -B formal/bytecode/assertions-resolution/generate.py \
  --output formal/bytecode/assertions-resolution --dafny /path/to/dafny
python3 -B formal/bytecode/assertions-resolution/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --node /path/to/node --cores 4 --output /new/evidence/directory
```

The retained manifest inventories all native declaration results from the full
include closure, zero audit, exact generation and runtime reproduction, source
and tool hashes, 28 complete EVM helper fixtures and three semantic faults.
Only a passed current manifest supports a passed package claim; development
console output does not replace retained evidence.

# Physical word-length mask development

`Mask.dfy` proves the actual machine bitwise expression
`BitAnd(32*n+31, BitNot(31)) == 32*n` for every natural n below 2^59.
It separates bit-vector concatenation and masking from natural-number remainder
uniqueness and the machine Word conversion. All helper lemmas have bodies.
`Scalar.dfy` proves the exact 256-bit NOT-31 pattern.

This is a development mathematical instruction foundation. It does not admit a
public entry, prove allocation/control/return execution, or add public bytecode
coverage. Reached resource and representation premises remain explicit in users
of this foundation; no gas, deployment or performance claim follows.

The first snapshot is preserved: all 110 executed batches passed, but its module
filter also selected an included scalar namespace, so the declaration inventory
correctly rejected the extra results. V2 uses distinct namespaces and complete
per-module filters; only a terminal passing manifest is development evidence.

`development/foundations-v2` passed 99 obligations with unchanged inputs: 11 for
the scalar pattern and 88 for the mask and its helper lemmas. This is development
evidence, separate from public runtime retention.

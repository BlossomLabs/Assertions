# Exact recursive ABI validation outcomes

The independent specification in `Spec.dfy` returns an exact outcome rather than
only an acceptance predicate. It covers arbitrary finite arrays and tuples,
static word validation, dynamic offsets, byte/string padding, trailing data and
the inherited checked-arithmetic panic paths. Rejection offsets remain absolute
in the original byte array, and traversal stops at the first failure.

`generate.py` strengthens the previously verified source adapters for recursive
bodies, static/dynamic wrappers, cached validation and error-byte receipts.
The changes add postconditions, loop invariants and proof-only lemma/reveal calls, rename modules/imports and
select the required declarations. Reverse erasure checks that the retained
control is identical to the prior source translation; the mapping records every
edit and the source hashes. Previous evidence files are not modified.

`Connection.Deterministic` composes two actual source-validator receipts on the
same descriptor and value. Both equal the specification's exact encoded receipt,
including rejection bytes. This supplies a deterministic rejection function for
later whole-run Expressions composition; this package alone does not complete
that composition.

Source translation, ABI/memory projection, representable input lengths and
resource premises remain explicit. CursorRoom is required when ruling out
arithmetic panic in receipt composition. No physical-gas or exact-bytecode claim,
and no new EVM or production source-fault campaign, is made here.

Run `verify.py` with explicit `--dafny`, `--solc` and a fresh `--output` directory.
It checks unchanged transitive dependencies, generated control erasure, native
proof declaration coverage, audit results, formatting and input/evidence hashes.
A specification or a development run is not a retained passing baseline.

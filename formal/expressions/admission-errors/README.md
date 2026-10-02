# Exact admission-error bytes

Prepare composes the source-proved admission procedure with explicit error-byte
serialization. It reverts exactly when the independent admission specification
rejects, emits the selector plus independent ABI argument frame for that exact
error, and preserves every encoded field when decoded back as a word. Accepted
shape metadata passes through unchanged.

The field-width premise is derived from the Solidity input representation:
result index, graph length, reference values and descriptor lengths fit uint256.
There is no small fixed graph/list bound. Mutually recursive parser lemmas bound
all reachable descriptor rejection offsets by the descriptor length, including
nested tuple fields and suffixes. Admission induction then establishes that
InvalidNode, InvalidReference, InvalidTypeDescriptor and Panic fields fit without
truncation. The original admission theorem supplies rejection order and exact
first-failure locations; this package preserves those locations in ABI bytes.

Selectors and signatures are checked against the pinned production solc AST.
Seven EVM tests exercise full-width result/reference fields, descriptor-before-
reference and arity-before-later-descriptor ordering, unreachable and nested
malformed descriptors, and standard panic serialization. The panic test checks
compiler arithmetic-panic bytes, not physical reachability of an admission
width overflow. No new actual-source fault campaign is claimed for this
composition; the source admission and codec baselines retain their own scope.

Standard custom-error/Panic ABI encoding, the existing source translation,
faithful decoder/memory projections and sufficient resources remain assumptions.
This does not verify the compiler's encoder bytecode, guarded-frame provenance,
evaluateEncoded's self-call/error wrapper, or complete public entrypoint
composition. Those remain separate from the exact admission-error connection.

The baseline retains native declaration results, source/tool/artifact hashes,
selector checks, EVM test names/results and a zero-findings proof audit.

# Tuple layout correspondence

`Scan.dfy` specifies the bytewise depth/comma scan and proves that nested
descriptors preserve its depth and contribute the right number of top-level
components. `Count.generated.dfy` connects the source Yul arithmetic, including
modular uint256 operations and stray-close precedence, to that scan.

`Layout.generated.dfy` connects the remaining `tupleLayout` branches to
`Spec.dfy`, using the already proved source parser for component boundaries and
shapes. `Canonical.dfy` proves valid tuple descriptors produce the expected
spans, dynamic flags, widths and total head size. `Soundness.dfy` reconstructs
an admissible tuple descriptor from every successful result. These are the
premises used by the [construction proofs](../construction/README.md).

The proofs retain empty-tuple rejection, malformed input positions and checked
head-size arithmetic. Fresh array allocation is projected to sequences under
the documented resource/memory assumptions. The complete source AST is gated,
and its scan arithmetic and head-size expression are translated.

The [complete construction baseline](../evidence/production-abi-correspondence/manifest.json)
passes every module in the dependency graph: 187 lemmas, 102 proof methods and
7,579 batches across 54 modules, plus 40 EVM tests. All three layout faults
(depth, component count and head size) are detected by proofs and EVM tests in
the [nine-fault campaign](../evidence/production-abi-faults/mutations.json).
Source correspondence does not imply unlimited gas, stack or allocation capacity.

# Fold accumulator update and early exit development

Every actual instruction from callback helper return16553 through accumulator MSTORE256 and the canonical early-exit checks is retained in five generated controls. Never, when-nonzero and when-zero modes cover every full-word callback result; continuing advances the full index to16484, while breaking reaches16664 with the unchanged caller index. Accumulator update occurs before either outcome.

`Memory.dfy` proves exact physical accumulator update and preservation of neighboring run words. The index increment premise follows from a reached index less than the full-word total and introduces no independent restriction on Range count. Generated files and mappings are produced only by `generate.py`; never hand-edit them.

Finish owner files before capture. The development driver freezes all source/tool inputs, regenerates controls byte-identically, verifies complete selected modules and native/declaration inventory, audits and rechecks current inputs. Selected imports remain assumed. Full callback/guards/errors, raw/domain/stamping, finite unbounded iteration, scalar return and complete retained native/physical/mutation/checker evidence remain mandatory. No gas, deployment, performance or compiler-correctness claim.

V2 preserves all original helper domains and postconditions. The arbitrary disjoint word frame is proved bytewise through zero-filling loads even beyond allocated memory, instead of calling a helper that requires an allocated full word. The failed V1 native snapshot is preserved; no production change.

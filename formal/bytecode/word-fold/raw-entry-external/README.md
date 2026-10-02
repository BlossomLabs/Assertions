# Raw fold decoder external-frame composition

This candidate lifts complete PC-zero range/bytes/words decoder outcome traces into the reached external-observation machine. The checked pure trace excludes copy and external opcodes; old returndata and the arbitrary observation cursor stay unchanged, including on an exact empty compiler REVERT. The successful state is the actual body entry with all decoded fields and the current selector/outer continuation.

Selected imports assume the complete decoder and routing leaf contracts. No later callback/resource/body/terminal claim is inferred. Fresh complete included native evidence, complete fold body/callback/early-exit/error/output proofs, finite physical cases, semantic faults and independent retained checking remain required before public coverage. Representation, sufficient reached resources and truthful reached observations stay explicit; no gas, deployment or performance claim.

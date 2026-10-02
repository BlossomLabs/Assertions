# Operations checked signed arithmetic exact-bytecode development

This isolated package prepares complete `add(int256,int256)` and `sub(int256,int256)` PC-zero paths. Source admission covers every finite word pair using the signed mathematical sum or difference fitting within [-2^255,2^255). Nonfitting outcomes use physical overlapping Panic(17) writes and REVERT(0,36); fitting outcomes serialize the exact two's-complement mathematical result. The compiler combines signed-comparison Boolean flags rather than choosing separate operand-sign paths; both signs were extracted independently and have identical reached symbolic states.

The finite representation, opcode interpreter/extraction, raw three-projection calldata, fresh memory and sufficient reached resources are explicit. Entire native, retained and independent evidence remains open. Concrete receipts do not count public coverage, and no gas/deployment/performance claims follow.

Selected development passed1168 positive native obligations, both compiler Boolean-OR operand orders, all four actual signed-overflow JUMPI guard checkpoints, and two genuine native semantic faults; captured inputs/tools were unchanged. Signed negative bounds are explicitly int. The inherited mutation error-log string was corrected before starting fresh retention; no runtime/math/admission changed.

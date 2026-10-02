# Word apply target admission

The generator pins both mapWords/filterWords selectors, the current Collections runtime and every reached instruction of the positive-code target helper atPC15859. It includes the actual low160-bit mask, EXTCODESIZE, code-size branch and return to callerPC12334. The frame consumes exactly one truthful CodeSize(target,size) observation at its current cursor; arbitrary memory, lower stack and caller-local returndata are preserved. The self address remains an explicit EVM context parameter. Requested and forwarded gas are separate later observations.

Preparation only: native verification is pending. The target is canonical from raw decoding, and the positive code-size assumption describes this success path only. Nonempty source admission, codeless-target error, empty target skipping, template copy, callbacks, output and complete retained public evidence remain separate obligations. Adequate resources and faithful external observations are required. No gas, deployment or performance claim follows. Regenerate through generate.py; never hand-edit generated files.

The V1 development snapshot is preserved. The V2 generator places checked PUSH decoding before its fetch assertions, isolates the canonical address AND in `MaskOpcode.dfy`, and explicitly connects the EXTCODESIZE result to the external-frame step before widening destinations. These are proof-harness repairs, with the same positive truthful code-size premise and reached runtime instructions.

V2 preserves 501 native rows: the mask bridge passed; three sequence-form bridge obligations in the generated external frame failed. V3 explicitly equates the flat reached stacks with the grouped stacks in the imported checked leaf contracts before application. No premises or runtime instructions change.

V3 preserved its complete failed snapshot: AND now passed and only the EXTCODESIZE grouped-stack equality bridge failed (two ordinary failed obligations). V4 adds the checked sequence append identity as an explicit local leaf.

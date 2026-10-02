# Descriptor suffix rejection development

The four generated owners start at the actual post-footprint suffix guard PC 14481 and preserve all lower stack words through the full InvalidTypeDescriptor(q) packet and terminal REVERT. They cover reaching the descriptor limit, a wrong closing byte, uint32 length or footprint overflow, and nonempty zero length. `Scalar.dfy` derives the overflow guard from mathematical operand bounds through the exact full-width OR operation.

`development/static-v1/results.json` records exact generation, complete resolution and zero audits for all five owners. `development/physical-v1/results.json` verifies all 24 reached guard rejections among 60 complete PC-zero EVM receipts: four at limit, six wrong closing bytes, eight overflows and six nonempty zero lengths, totaling 1,562 exact guard instructions.

The preceding scanner and footprint calculation must still derive this frame; these guards do not yet prove complete rejecting recursive parser semantics. Original offset/length and cursor below 2^64, a represented lower frame, aligned fitting memory and a correct free pointer remain explicit. Full native closure, complete codec/public connections, meaningful faults and retained independent acceptance remain open. No public coverage is assigned.

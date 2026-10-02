# Operations concatenation source correspondence

The complete `concat` body and actual `_copy` helper AST are gated. Source-derived sizing/writing controls and compound size expressions drive both loops. A recursive join specification independently fixes output order, separators and length; native invariants connect every counted part and positional write to that specification, with checked uint256 size overflow preserved.

The helper's CALDATACOPY length and destination are source-derived, including Yul's wrapping address additions. Its primitive memory update is projected through a proved arbitrary-memory frame theorem, then connected to the caller's array writes. The output header and every memory byte outside the allocated data span remain unchanged. The internal helper's mathematical postcondition is proved rather than assumed.

The domain covers all finite arrays and constituent/delimiter lengths representable in uint256, with no sampling or loop/fuel bound. Where arithmetic sizing succeeds, successful sized output allocation, aligned nonwrapping allocation/free-pointer frames, default initialization and faithful memory/calldata projections are explicit resource/representation premises. Allocation/resource failures are outside that premise. Checked source arithmetic, CALDATACOPY opcode semantics, decoded input and exact outer ABI/Panic serialization are also explicit; restricted AST lowering is reviewed conditional correspondence, not certified Solidity translation.

Retention requires every native declaration/result and tool/input/AST/selector identity, zero audit, both concrete EVM fixture tests and two compiler-admissible semantic mutations rejected by native helper/caller semantics and EVM. Exact bytecode, gas, deployment and performance remain separate.

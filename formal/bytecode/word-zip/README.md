# zipWords exact-bytecode development

Physical PC-zero route, both raw bytes operands, alignment and equal-count admission, actual allocation and interleaved original-word stores. The current runtime selector is `1008e959`; wrapper PC 499 and body PC 1846. Physical output stores occur at PCs 2237 and 2253. The raw allocation-size guard at PC 2034 must cover oversized doubled payloads explicitly.

Development snapshots, EVM observations and helper proofs are separate from retained public-entry evidence. No bytecode coverage is counted before a full retained run and independent current-evidence checker pass. Faithful representation, instruction scanning, opcode interpreter, fresh-memory and adequate reached-resource premises must remain explicit. These proofs make no gas, deployment or performance claim.

The successful memory model uses an arbitrary finite count below 2^58, derived from the doubled allocation-size guard; it is not a fixture limit. Input slices may overlap. Every original `a` word and then original `b` word must be preserved in order.

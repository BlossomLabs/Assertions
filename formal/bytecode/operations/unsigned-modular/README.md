# Operations unsigned modular exact-bytecode development

This isolated package prepares all-word `addMod(uint256,uint256,uint256)` and `mulMod(uint256,uint256,uint256)` correspondence from actual PC zero through scalar RETURN or overlapping physical Panic(18) REVERT. Zero/nonzero modulus guards cover all third operands. ADDMOD and MULMOD are specified using unbounded natural intermediate arithmetic, without wrapping at 2^256. Raw rejection covers nonzero call value, short selector, and the complete assigned three-word head.

The runtime is compiler bound; instruction bytes, valid JUMPDESTs, calldata projections, memory serialization and reached resources are explicit. Native development, full retained evidence and independent checker remain open. Concrete receipts alone do not count public coverage. No gas, deployment, performance, compiler-correctness or consensus claims are inferred.

Selected development checks passed: 866 positive native obligations, 82 covered declarations and two genuine ADDMOD/MULMOD semantic-fault rejections. Mathematical operations use the unbounded intermediate sum/product before modulus; zero modulus reaches the exact Panic18 physical serialization. Inputs/tools unchanged. Full retained public native graph and independent evidence remain open.

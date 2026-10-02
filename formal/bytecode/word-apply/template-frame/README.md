# Template-copy output frame

Development byte-level frame proofs connect the actual output heap free pointer and fitting bounds to the template-copy leaf. They preserve every earlier output byte (except the updated allocator pointer at64..96) and copy the exact template bytes, even for overlapping raw source/template calldata. Native and retained include-graph checks remain pending. No public coverage, gas/deployment/performance claim.

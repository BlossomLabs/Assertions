# Physical callback payload packing

Preparation models the actual callback MCOPY from template payload to the current free-memory region followed by the zero padding MSTORE. Constructive byte projections show the call input equals the stamped payload, while original bytes below free and the stored free pointer are preserved. Fitting finite memory and pointer arithmetic are explicit. Opcode/gas/call observations, native checks and full retained public graph remain open; no public coverage/gas/deployment/performance claim.

The first selected memory run terminated with four ordinary failures: two byte-preservation lemmas called a whole-word load frame, which unnecessarily required32 disjoint bytes from each protected byte. The owner now proves the individual byte frame constructively over expansion and store slices. It preserves the original byte predicates and all memory bounds. V1 is preserved; a fresh local native run and full include-graph retention are required.

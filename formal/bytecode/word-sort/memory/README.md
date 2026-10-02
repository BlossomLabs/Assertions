# sortWords two-buffer memory development

Physical original-occurrence frames for output at 128 and scratch at 160+32*n, with independent full-size headers and preserved free pointer 192+64*n. Sentinel occurrence n denotes zero scratch padding before a pass writes it. Reads and single-word stores preserve the other buffer, both length headers and the free pointer. Fully original output IDs connect to exact original calldata byte blocks.

This memory model does not substitute for actual allocation, calldata copy, helper opcodes, merge selection or pointer-swap execution. Those connections and retained full-entry evidence remain open. Fitting calldata/word count, valid buffer IDs and rounded memory frames are explicit; resources and reviewed extraction/interpreter remain conditional. No public-bytecode coverage increment.

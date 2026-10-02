# Physical packArray raw-head admission fixtures

Ninety-one complete actual EVM calls: sixteen independently encoded canonical array results in both directions and seventy-five malformed packArray descriptor/array-head frames. The malformed paths cover every calldata-head size4..67, full-width offset bounds, missing length words, descriptor-span failures, array-count limits and count-times32 head-tail failures including the two-slot one-word-short boundary. Ordered error priority is preserved.

Every rejected path is compared instruction by instruction with its compiler-bound generated mapping and exact empty REVERT bytes. Successes compare mapped routing/decoders and complete terminal memory with an independent canonical ABI encoder. These finite geometry receipts are development checks; no universal native, compiler-correctness or public-entry credit follows. Fitting representation/resources and reviewed interpreter premises remain explicit.

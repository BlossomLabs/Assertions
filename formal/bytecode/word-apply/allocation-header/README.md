# Word apply output header allocation

The generator pins both public selectors and the current runtime. The extracted physical allocator starts at PC12273 after the checked count and source-length admission. It writes the source byte length at output pointer128, rounds the allocation to32-byte words, and writes the updated free pointer at64. The empty branch reaches PC12319 directly; the nonempty branch reaches the actual zero-fill CALLDATACOPY at PC12311. The model admits every count below2^59 and arbitrary remaining decoded fields and lower stack prefix. Fresh memory comes from the physical public prefix.

These files are proof preparation, with no native results or public coverage claimed. Zero filling, target checks, callbacks, full output, and retained public evidence remain open. Representation, adequate resources and later external observations remain explicit premises; there is no gas, deployment or performance claim. Regenerate through generate.py; never hand-edit generated files.

The failed V1 development snapshot is preserved. The V2 generator computes the fitting-stack bound over both pre-instruction states and the final endpoint; the last nonempty DUP requires 18 slots above the arbitrary lower prefix. The public connection already reserves this bound.

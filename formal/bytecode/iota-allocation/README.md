# iotaWords physical allocator composition development

The owned generator pins the complete current Collections runtime and the eight
actual post-copy instructions from PC 5615 to the loop entry at PC 5623.
`Engine.dfy` connects both header-allocation branches and the actual zero-padding
CALLDATACOPY to the exact initial loop heap. Empty inputs take the compiler's
copy-free path. The trace uses the copy-aware instruction semantics, with a
proved lift of successful traces from the smaller interpreter subset.

The symbolic count is restricted by the proved compiler allocation guard below
2^59, and calldata length is a representable Word. Memory footprints, adequate
reached resources, faithful interpreter/instruction-scanning semantics and
physical observation projection remain explicit. This is development proof;
full raw-entry and retained verification, audit, EVM and semantic-fault evidence
remain open. No gas, deployment or performance claim follows.

# Scalar comparison exact-bytecode development

Ten assigned Operations comparison entries have complete generated successful
instruction paths and raw nonpayable/short-selector/short-argument rejection
paths. All uint256 argument words are symbolic. Signed entries interpret their
words through exact two's complement; independent integer relation formulas give
canonical Boolean results encoded as one 32-byte word. Arbitrary trailing
calldata is admitted under fitting calldata length below 2^64 and sufficient
reached execution resources. Native closure, actual EVM receipts, semantic binary
faults, retained evidence and independent checking remain open. No public coverage
is inferred from generated files or complete conditional source proofs.

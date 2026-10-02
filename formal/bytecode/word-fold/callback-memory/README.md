# Fold callback memory frames

The callback completion proofs compose physical template packing, free-pointer update,32-byte receipt header and actual returned bytes copy. They preserve every old byte at or above96 below the current free pointer and every whole allocated word there, including all six FoldRun slots. Actual free pointer becomes free+64; memory may expand. No unchanged-memory assumption across callback execution.

Selected native imports assumed; complete fold loop and public retention remain required before coverage.

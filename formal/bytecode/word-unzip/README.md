# unzipWords exact-bytecode development

This package develops the exact current `Collections.unzipWords(bytes,uint256)` runtime proof. It is not retained public evidence, and does not increase the admitted bytecode coverage.

`Memory.dfy` models physical output headers and stores at PC 6282. For every finite fitting aligned input and lane zero or one, it proves that the output preserves precisely the original words at indices `2*i + lane`, in order. Lane zero receives the extra word when the input count is odd. The mathematical filling loop has rank `laneCount - index`; the actual compiled loop connection remains open.

The input and output are represented by mathematical byte sequences, and memory is a fresh arena beginning at 128. Adequate resources and faithful interpreter/observation premises remain explicit. Raw ABI decoding, alignment and invalid-lane rejection, actual allocation, actual loop control, physical serialization, complete EVM fixtures, semantic bytecode faults and retained evidence still need to be connected. No gas, deployment or performance claim follows from these development checks.

`inspect.mjs` observes the canonical runtime in an in-process EVM. Those observations identify the compiler path and store location; they are not themselves formal proofs. `development-run.py` snapshots selected modules and their include closure before verifying them.

The PC-zero routing prefix passed 1,694 native obligations in `development/prefix-v1/`. The first memory snapshot is preserved: it failed two well-formedness preconditions for the lane-count function; V2 states lane validity before evaluating that function. These development checks do not establish retained public evidence.

The corrected memory model passed 363 native obligations in `development/memory-v2/`, with its inputs unchanged during verification. This proves geometry, exact physical store effects, original-byte preservation and the mathematical loop; actual compiled loop composition remains open.

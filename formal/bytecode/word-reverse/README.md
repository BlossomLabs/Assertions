# reverseWords exact-runtime development

The current complete raw-entry theorem is entry/Root.dfy. It composes exact
PC-zero dispatch, exhaustive raw bytes decoding, actual alignment/count/guard,
physical allocation and zero calloc, arbitrary finite reverse-word iteration,
original-byte preservation, actual MCOPY, ABI head/byte length and physical
RETURN. Every fitting malformed decoder class yields empty REVERT; admitted
unaligned bytes yield exact UnalignedWords(length). Accepted loose offsets,
unused dirty padding, overlapping empty heads and trailing bytes are admitted.

Development native results: Memory 287, prefix 1498, accepted decoder 3192,
raw rejection/boundary graph 9564, loop helpers/segments 7223 and engine 326,
physical allocation 4425, reverse heap connection 45, loop-to-return composition
69, and body admission/complete raw entry 3487. Shared bytes-return memory and
controls passed 345 and 4160. Logs and frozen source snapshots are under each
package's development/ directory; earlier failed snapshots remain preserved.
Sixty-six complete EVM fixtures and all three semantic single-byte fault
preflights passed. The faults change reverse indexing, ABI head or final status;
each translates successfully, fails a native output postcondition and contradicts
an independent EVM outcome. No timeout, parser or precondition failure counts.

The retained packet is prepared in ../word-reverse-entry/. Its full current
include graph, tool/dependency closure, canonical runtime reproduction, fresh
native inventories, zero audit, complete EVM receipts, mutations and independent
checker still must pass before public coverage. Representation, faithful runtime
scanning/interpretation and observations, fresh memory and adequate reached
resources remain explicit. Count below 2^59 is derived from fitting raw length
below 2^64 and word alignment, without a fixture/fuel cap. No gas, deployment,
complexity, performance or whole-contract claim. Never edit generated files.

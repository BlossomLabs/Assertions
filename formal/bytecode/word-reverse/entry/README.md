# Complete reverseWords raw-entry development

Root.dfy composes exact PC-zero dispatch and the exhaustive raw bytes decoder
with the whole compiled body. Body.dfy composes actual alignment/remainder and
count/division helpers, allocation guard, physical header/calloc, arbitrary finite
reverse-word loop, actual MCOPY, ABI byte length and physical RETURN. Unaligned
inputs produce the physical UnalignedWords error bytes; fitting malformed raw
frames produce empty REVERT. The accepted count bound follows from the raw bytes
length below 2^64 and alignment. Loose offsets, unused dirty padding and arbitrary
trailing bytes remain admitted whenever the actual decoder admits them.

The full development graph must pass native checks before retained complete EVM
receipts, canonical runtime reproduction, zero audit, exact inventories and
semantic bytecode faults. No public coverage follows from these development files.
Representation, faithful scanning/interpreter and observations, fresh memory and
adequate execution/allocation/stack resources remain explicit. No gas, deployment,
performance or whole-contract claim. Never edit generated files directly.

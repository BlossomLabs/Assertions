# Shared aligned bytes-return development

The memory theorem accepts any byte sequence of length count*32, with count
below 2^59. It proves the physical ABI head, byte length, actual MCOPY at PC
20967, trailing zero word, and RETURN at PC 498 preserve that exact payload.
The generated controls scan the pinned runtime and parameterize the stack
selector and payload. They reach the same shared serializer used by iotaWords
and reverseWords. Native memory development passed 345 obligations and actual serializer controls
passed 4160 obligations, with stable snapshots. Complete public-entry
integration and retained evidence remain open.

Representation, fitting memory footprints, faithful interpretation and runtime
scanning, external observations and adequate reached resources remain explicit.
This package adds no public-entry coverage or gas, deployment or performance
claim. Generated files are rebuilt by generate.py, never edited directly.

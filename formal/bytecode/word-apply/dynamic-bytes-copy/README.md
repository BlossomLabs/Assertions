# Arbitrary-length compiled ABI bytes copy

The actual shared helper20951 writes a length header, executes MCOPY for exactly the source length, zeroes padding, computes the rounded tail end and returns to the supplied physical JUMPDEST. Source and destination addresses are parameterized, with arbitrary bytes and length, including zero. No word-alignment of the length or destination is required: CallbackFailed uses misaligned free+196 tails and arbitrary revert reasons.

Explicit resource premises require finite aligned memory below2^70, a represented source header/full byte span, destination after that span, fitting output footprint and stack. The helper preserves all earlier memory, the source header/payload and the free-pointer word. The final tail is the exact ABI length/payload/zero-padding sequence. Memory functions describe actual stores and MCOPY; generated controls pin every instruction byte. No returnPC can be invented: it must be a real JUMPDEST in the bound runtime.

Selected development jobs assume imported contracts; full CallbackFailed packet/caller/raw composition, fresh included graph, EVM/semantic faults and independent retention remain open. No public coverage or deployment/gas/performance claim. Never hand-edit generated controls; generate.py owns them.

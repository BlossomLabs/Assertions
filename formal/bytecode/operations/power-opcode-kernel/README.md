# Checked-in preparation for the reached EXP opcode

Execution.dfy extends the immutable signed-multiply EVM machine only for opcode 0x0a. Its base is the top stack word and exponent the next word; its result is the independently defined unbounded power reduced modulo 2^256. Memory remains unchanged, two words are replaced by one, and stack underflow produces Bad. Ordinary instructions delegate to the original reviewed machine.

The modular binary kernel's meaning theorem is a required native dependency, rather than an external observation assumption. Adequate reached execution resources and faithful calldata/environment projections remain explicit. Current native mathematical/kernel closure, every public raw class, generated instruction traces, complete physical receipts and semantic mutation/independent checking remain open. No public bytecode, gas, deployment or performance claim is made.

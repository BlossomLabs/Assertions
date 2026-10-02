# Exact offsets-array stride

The shared mapWords/filterWords compiler decoder bounds the array count below2^64 before executing SHL5 atPC20736. The checked target is the exact result count*32, its below2^69 bound and the derivation count<2^59 from a fitting raw array tail. Counts beyond the uint64 guard must be rejected before this opcode; no fixture-sized count cap replaces compiler admission.

The constructive conversion dependency supplies the small integer round trip and reverse bitvector cast. The widening and shift claims remain native checked lemmas. Complete current decoder paths must connect the actual guard, header, stride and tail comparison before public coverage. Finite fitting calldata/memory, reviewed reached-opcode interpretation and adequate resources remain explicit. No gas, deployment or performance claim.

Finish owner files before snapshots; preserve failed runs. This is a development kernel, not public entry evidence.

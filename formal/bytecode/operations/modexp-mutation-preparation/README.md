# Modular-power semantic fault preparation

Development only; native baseline/mutation and retained public checks have not
run. No bytecode coverage is recorded.

The candidate changes exact instruction 9399 from MULMOD (0x09) to ADDMOD (0x08).
The isolated modular-power interpreter supports both normatively, so the future
native check compares intended arithmetic rather than rejecting an unsupported
opcode. `generate.py` gates the current nine complete Operations modular-power
ASTs, checks instruction boundaries and pins the one-byte candidate SHA.

The baseline-covered physical checkpoint is fixture UU-5, ordinal 5: the reached
stack updates accumulator 1 with factor 2 modulo 17. The intended result 2 becomes 3;
the complete public candidate returns 3. All 122 candidate physical receipts were
independently replayed opcode by opcode, including stack, byte memory, sixteen
exact faithful MODEXP observations and physical RETURN/REVERT packets. Forty-two
intended outcomes differ, with raw rejection packets unchanged. This finite
campaign does not imply universal correctness.

`Witness.generated.dfy` has passed resolution and a zero-finding audit only.
The baseline native witness and the matching ordinary native postcondition
failure remain required. Never edit generated files directly. No precompile,
cryptographic, gas, deployment or performance proof is inferred.

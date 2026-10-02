# Exact square-root scaling and correction

The generator extracts both complete reached paths from the current runtime: the eight-instruction initial three-halves scaling and fifteen-instruction final quotient/comparison/subtraction. Both preserve the actual prefix and memory and retain every machine step, including the actual JUMPI and internal JUMP destinations.

Scaling receives the independently proved seed bound. Correction receives the independently proved final estimate in the root or root-plus-one range. These are explicit caller premises; the package does not assume public square-root correctness. Development evidence is separate from complete raw entry, iteration composition, physical return and retained mutation evidence.

Use `generate.py` and `format-generated.py`; never edit generated controls. The verifier inventories the full13-module native dependency graph and retains source/tool/compiler hashes and byte-identical generation. Reviewed extraction, normative integer EVM interpretation, finite fitting words and reached resources remain explicit. No gas, deployment or performance claim.

# iotaWords physical serializer development

`generate.py` binds the complete current Collections runtime identity and every
reached instruction in the actual dynamic bytes serializer, from PC 518 through
RETURN at PC 498. The symbolic count retains the allocation-derived bound below
2^59; it is not limited to fixture counts. `Memory.dfy` proves the exact head,
length, original payload copy, trailing zero store and returned memory window.
`MaskOpcode.dfy` isolates the actual alignment instruction. The generated control
uses the copy-aware interpreter and finite traces, including actual MCOPY.

This is development evidence. Full raw-entry composition and retained native,
audit, EVM and semantic-fault evidence remain required before public coverage.
Fitting representations, sufficient reached execution resources, faithful
interpreter and instruction-scanning semantics, and physical observation
projection remain explicit. No gas, deployment or performance claim follows.

V1/V2/V3 terminal failed development snapshots are preserved. V2 passed every
actual transition but failed the long trace's initial-state postcondition. V3
proved the trace with explicit head invariants; one subtraction transition
then timed out. `SubOpcode.dfy` isolates the actual end-minus-start opcode: its
preliminary native check passed 14 obligations, and the revised generated
caller passed 49. All components are rechecked in the full retained graph.

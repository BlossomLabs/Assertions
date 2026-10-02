# iotaWords actual-loop development

The generator pins the complete canonical runtime identity and actual reached
instructions for one symbolic loop-body cycle and the equality-bound exit.
The body uses the physical Output heap invariant; the index and count are not
bounded by a fixture or fuel count, but retain the compiler allocation-derived
count representation below 2^59. A whole-loop rank/trace composition is required
before this package can support a full entry theorem. This is development proof,
not public retained runtime evidence. Adequate resources, valid Word/Byte and
faithful interpreter/observation/scanning premises remain explicit; no gas,
deployment, performance or unconditional resource claim follows.

`development/paths-v1` passed 1,371 obligations with stable inputs: 835 body
and 536 exit obligations. `Engine.dfy` composes arbitrary finite cycles with the
rank n-index and exact actual-step trace length 14+21*n, reaching the serializer
entry with the completely filled physical heap. Its native check is separate;
full entry/allocator/serializer and retained evidence remain open.

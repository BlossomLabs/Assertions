# Actual bytes serializer over arbitrary heap

The hand-written memory model starts from an arbitrary aligned caller heap, its actual free-memory header, the output length header at128 and exact payload at160. The free pointer is aligned, lies beyond the input payload, and its complete serializer footprint fits the stated representation bound. The caller must derive these premises; no fixed canonical heap or zero unused capacity is assumed.

The generated control extracts all75 actual shared serializer instructions from PC518 through RETURN at498, including the complete MCOPY and padding store. It binds reached opcode bytes and jump destinations to the current Collections runtime. The model emits the canonical dynamic bytes offset, byte length and exact payload. Resource and external-observation conditions remain explicit in caller composition; no gas, deployment or performance claim.

This is a development package. Full included native checking, raw entry/error/loop composition, EVM fixtures, semantic mutations and independent retained evidence are required before public coverage. Generated files are produced only by generate.py.

The preserved predecessor serializer-v1 has six local proof-precondition errors from applying whole-word load frames to individual bytes. This isolated repair uses a separately checked physical byte frame with identical serializer inputs, output theorem and runtime. It changes no production contract or machine semantics. The predecessor is still live and remains frozen.

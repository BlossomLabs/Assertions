# Operations exact reached opcode kernels

Binary.dfy proves actual ADD and SUB transitions from the reviewed isolated
Operations word machine for arbitrary stack prefix and byte memory. The kernel
preserves all memory exactly, and leaves modulo-2^256 result semantics explicit.
This factoring reduces solver expansion of symbolic memory while retaining the
same actual opcode Step relation. The Word machine remains an explicit reviewed
trusted interpretation boundary, not a source or compiler correctness theorem.
A kernel alone adds no public bytecode coverage.

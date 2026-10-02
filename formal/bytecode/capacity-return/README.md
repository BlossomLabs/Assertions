# Physical bytes return with retained allocation capacity

This development package proves the current shared serializer for an aligned payload whose output length is at most its allocated capacity. The free-memory pointer records the capacity, while the bytes header records the selected output length. Physical stores, MCOPY and final RETURN must be proved from actual reached instructions.

The earlier retained bytes-return package remains immutable. This package adds no public coverage before a complete public-entry retained run and independent checker. Reviewed extraction, opcode interpretation, finite fitting memory and adequate reached resources remain explicit; no gas, deployment or performance claim follows.

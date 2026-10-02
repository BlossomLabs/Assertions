# zipWords physical output connection development

Both original input slices and their interleaved physical heap connect to the shared immutable aligned bytes serializer. The output contains exactly twice the input word count, with actual MCOPY and terminal RETURN slices. Representation, faithful opcode interpretation, fresh-memory and adequate reached-resource assumptions remain explicit. This is development proof work, pending whole raw-entry retained closure and independent checking.

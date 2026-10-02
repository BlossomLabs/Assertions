# Actual ordered memory-word read

Owned generation extracts the current uniqueWords `_wordAt` instructions from PC 3833 through physical MLOAD at 3844 and the actual return jump to 6836. Arbitrary fitting indices and rounded caller memory preserve the exact memory frame and load the original retained word. Public body composition must derive these bounds and the original-word heap relation; no source helper or memory-read correctness axiom is used.

Development checks add no retained public-entry coverage. Full loop composition, original-index selection, raw admission, actual allocation/serialization and reached resource premises remain required.

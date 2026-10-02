# sortWords physical setWord helper

The owned generator pins every actual instruction of the shared setWord helper at PC3847, returning to the reached sortWords PC3860. Both physical buffer bases are admitted through a generic pointer and fitting word index. The helper writes the chosen word to the exact payload slot and returns with the arbitrary caller stack prefix intact. Its terminal memory is the actual EVM Store result.

Development only. The body must establish buffer geometry and compose disjoint byte frames and stable original occurrence IDs. Complete public bytecode, gas and performance remain open. Never edit generated files; freeze package inputs before verification.

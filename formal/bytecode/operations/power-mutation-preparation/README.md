# Integer power mutation preparation

The single-byte candidate changes actual EXP opcode PC21115 to MUL. Fixed witness ordinal10 reaches this opcode with base3/exponent31 and ideal result617673396283947. The same independent result postcondition is retained for baseline and candidate generation. The entire physical call and every stack/memory transition must be independently replayed; a fixed checkpoint alone does not establish a complete public theorem.

These files are preparation. Native baseline and candidate matching gates, complete entry/loop connections and fresh retained independent checking remain open. No public bytecode coverage or gas/deployment/performance claim is made.

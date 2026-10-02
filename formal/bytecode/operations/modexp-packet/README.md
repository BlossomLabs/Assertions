# Physical MODEXP packet preparation

Prepared development statements; static resolution and audits passed, native
checks have not run and no public bytecode credit is recorded.

The six actual request words are `[32,32,32,base,exponent,modulus]`, written to
successive 32-byte positions. The finite resource frame requires an aligned
reached heap at least 96, an aligned memory sequence containing the free-memory
header, and a fitting heap plus 192 bytes. The full raw entry establishes the
actual heap value separately; these conditions are explicit helper premises.

The intended statements preserve the header, bind exact mathematical packet
loads to the physical STATICCALL snapshot, and connect a full 32-byte output
write to the original reply bytes while preserving every disjoint memory byte.
No precompile internals, faithful-reply premise, gas or performance claim is
inferred from memory construction. Actual compiled store/call opcode traces and
complete public error/return connections remain separate required checks.

`verify-development.py` snapshots the complete 13-module dependency graph,
freshly verifies every owned declaration and audits each file, retaining all
input/tool hashes and any failed required gates. It remains unlaunched.

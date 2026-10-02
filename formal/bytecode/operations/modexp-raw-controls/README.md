# Four modular-power raw entry prefixes

Prepared development controls; no native pass and no public bytecode credit.

`generate.py` gates the complete compiler ASTs of all four `powMod` overloads and
five relevant helpers, and binds the exact current runtime instruction boundaries.
It emits sixteen complementary paths: nonzero call value, fewer than four raw
bytes, a selected signature with fewer than 100 bytes, or its admitted decoded
prefix. Accepted prefixes load all three full words and reach the actual body
PC (4610, 8791, 5210 or 2990), preserving the compiler return continuation.
Trailing bytes are permitted. Empty rejections execute the physical REVERT.

The fitting raw frame has fewer than 2^64 bytes. Self and observations remain
parameters; no external observation is consumed by these prefixes. Later bodies,
inverse errors, precompile receipts, modular loops and physical serializers remain
required proofs. Faithful MODEXP reply assumptions remain explicit in the separate
execution module; this package does not prove the precompile or gas behavior.

The complete development driver snapshots and freshly verifies all 29 included
modules, regenerates all sixteen controls and compiler gates, audits each owned
file and checks current input/tool hashes. It has not been launched. `Admission.dfy` composes all sixteen paths into a PC-zero theorem for each selected signature; no arithmetic body or successful physical return is claimed here. Generated
files must be regenerated through the owner, never edited directly.

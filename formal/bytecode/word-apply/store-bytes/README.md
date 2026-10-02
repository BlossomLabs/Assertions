# Exact byte frame of a physical word store

The hand-written lemma proves each represented byte outside the actual32-byte MSTORE window remains unchanged, including a final byte with no complete32-byte load available. It uses the existing physical expansion and store definitions. Word-load preservation is a separate property.

This is a development component and must be included in a fresh native retained graph before any public bytecode coverage claim. Adequate resources and represented indices remain explicit; no gas, deployment or performance claim.

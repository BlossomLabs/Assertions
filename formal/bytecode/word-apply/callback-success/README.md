# Exact 32-byte successful callback receipt

Preparation extracts the full compiled path PC16948 to12484 for a successful 32-byte receipt. Actual RETURNDATASIZE, allocation/free pointer update, header MSTORE, RETURNDATACOPY, success/length branches, result MLOAD and helper cleanup are tracked. The arbitrary returned word is decoded from all 32 bytes; previous returned bytes are not substituted.

The theorem admits arbitrary lower stack and fitting finite caller memory/free pointer. The successful exact-32 receipt is one branch; wrong length, ordinary callback failure and out-of-gas signaling remain separate required paths, not assumptions on the completed public theorem. Actual callback observations are established upstream. Native and full retained closure remain open; no public/gas/deployment/performance claims. Generated files come only from generate.py.

The selected V1 run completed and is preserved: Memory285 passed; Scalar had one literal-mask timeout and the return-copy transition lacked an explicit grouped/flat stack identity. The owner now uses the already-checked general alignment mask at n=2 and a constructive sequence append lemma. The generated module has a distinct name so its symbol filter cannot accidentally include memory/scalar modules. Same physical64 instructions, input domain and exact output; fresh selected checks required.

The preceding complete selected run is preserved. Remaining ordinary transition failures were literal flat/grouped stack identities that a general concatenation lemma did not expose. Fixed-length constructive sequence lemmas and explicit frame identities are added through handwritten owners/generator; no bytecode, bounds or output changes. Fresh success-v3 native checks required.

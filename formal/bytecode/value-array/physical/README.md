# Array codec physical development fixtures

Sixteen complete actual EVM calls compare packArray and unpackArray independently against canonical ABI encodings from viem, never a pack/unpack round-trip. The accepted entry mappings are checked against reached stack and memory, and final returned bytes are checked against the physical RETURN slice. Descriptor grammars, malformed raw frames, errors, resources and arbitrary finite loops remain open for native proof and retention. No public coverage follows from these finite checks.

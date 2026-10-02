# Concrete Assertions error and bytes[] serialization

`generate.py` compiles the production sources for fresh AST/ABI output and binds
all 27 custom-error selectors, argument types and enum orders. Compiler-provided
`errorSelector` values are used directly. The standard `Panic(uint256)` selector
is recorded separately as a compiler ABI rule.

`Errors` maps every constraint, resolver, core, probe, codec and navigation
failure to its concrete selector and ordered ABI arguments. Shape proofs check
all mappings against the generated signature types. Bare decode reverts remain
empty; the reserved exhaustion signal remains exactly four bytes. Successful
codec results are never certified as errors. The independent ABI frame model
constructs dynamic offsets, lengths and padding. Signed-field and bytes4 lemmas
pin two's-complement interpretation and left alignment.

`GatherCanonical` proves the concrete bytes[] encoder equals the existing
independent ABI encoder for any finite list of byte sequences, including empty
lists and empty elements. `Bounds.GatherValidated` additionally proves that the
independent validator accepts the result and recovers the original values under
ABI representability. This replaces the prior arbitrary gather serializer.
`Connection.Encoding` supplies concrete functions for all previous wire slots;
`Compose` uses them across the complete seventeen-entry recursive public model.

Wire certification also checks `Bounds.TreeFits`: representable error fields,
ABI frame lengths and canonical array returns at every child, as well as the
existing source readiness and complete self-call coverage conditions. Mathematical
values outside these bounds are not silently certified after word truncation.
These are explicit representability premises, not physical gas guarantees.

Source-adapter correspondence and faithful compiler ABI encoding/decoding,
caller/static/gas context, memory and sufficient local resources remain premises.
This package instantiates the wire functions; it does not prove compiler
correctness or unbounded physical execution. No new EVM or production source-fault
campaign is claimed. The retained driver checks generation, native declarations,
dependency hashes, audit, formatting and unchanged inputs.

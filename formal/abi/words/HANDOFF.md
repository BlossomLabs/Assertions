# Production repair and proof limits

`contracts/lib/AbiCodec.sol` now requires seven bytes inside `[s,limit)` before
selecting the seven-byte full-width fast path. A `bytes3` descriptor followed by
ASCII `2` outside its span therefore retains its narrow-word check. The fix
does not assume zero calldata padding.

`contracts/tests/AbiWordBoundaries.t.sol` promotes the failure into the normal
test suite. Both tests sweep every possible following byte: a dirty value must
revert with exact `InvalidValue(64)`, and a canonical value must be returned
unchanged. Removing the production guard in an isolated copy makes the rejection
test fail while its canonical-value control passes.

The source-derived proof files were regenerated after the final Solidity and
NatSpec edits. [The fixed-source baseline](../evidence/abi-codec-words-complete/manifest.json)
passes all 107 new SMT obligations, 32 prior mask obligations, 279 Dafny batches,
the audit and four exact-runtime EVM tests. [The aggregate runtime gate](../evidence/abi-codec-bytecode-final/manifest.json)
passes 12 symbolic properties and catches five mutations. The original failed
baseline and isolated candidate remain separate historical evidence.

The formerly stale `tupleLayout("()")` NatSpec now documents
`InvalidTypeDescriptor(1)` and caller-level empty-list handling. The bundled
`validateDynamic` correction reports `32 + walked extent` for trailing bytes;
`unpack` is unchanged. The bytes/string baseline and ten source mutations
include the exact offset, with the old constant-32 mutation detected. The shared
`AbiCodec.sol` edit changes metadata in all four importing contracts; artifact
and SDK synchronization must cover all four. Final Collections runtime size is
24,560 bytes, leaving 16 bytes below EIP-170. Replacement addresses are CREATE2
predictions, not public-chain deployment observations.

The [descriptor milestone](../descriptor/README.md) adds validated static suffix
traversal and non-tuple `checkWords` composition. The [typeShape milestone](../shape/README.md)
now establishes grammar and model shapes for every successful recursive parse.
The [parser](../parser/README.md) and [tuple](../tuples/README.md) successors now cover grammar acceptance, exact reference outcomes and recursive static tuple/copy traversal. The
whole-validator correspondence and arbitrary-geometry
bytecode induction remain separate open obligations. In particular, the name-classifier's trusted relocation
to descriptor-relative calldata coordinates presumes nonwrapping valid descriptor
addresses; neither it nor the source loop certificates prove EVM memory allocation,
gas behavior or compiler correctness.

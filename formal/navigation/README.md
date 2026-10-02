# Navigation correspondence

This package connects `Assertions.nav` and its navigation helpers to an
independent typed selection specification, using the ABI correspondence proofs.
The authoritative execution status, individual results and source hashes are in
[`evidence/navigation-correspondence/manifest.json`](evidence/navigation-correspondence/manifest.json).
A declaration or generated file alone is not evidence of a successful run.

The input boundary is the bytes returned by `_resolve`. The source gate checks
that exactly one `_resolve(a, "", 0, 0)` call is the first statement and has no
catch. Arbitrary external producers and the full operand resolver remain
separate verification obligations. The concrete oracle includes failed operand
constraints before empty-path and sentinel dispatch.

The canonical root is a return tuple's **body**, without the extra single-value
envelope that `abi.encode(aDynamicTupleAsOneArgument)` would add. A nonempty
ordinary path returns the selected value's single-value encoding. Empty paths
return the original bytes without inspecting the descriptor. `LEN` and `PAYLOAD`
are terminal modes, not ordinary indices when they appear last. The all-input
source model also preserves the implementation's acceptance of tuple-root
array descriptors such as `(uint8,bool)[2]`.

| Layer | Principal declarations |
|---|---|
| Independent typed selection, negative array indices and mode meanings | `NavigationModel.Select`, `Query`, `Terminal` |
| Actual canonical head/offset reads at arbitrary finite nesting | `NavigationLayout.ChildLocation`, `Follow` |
| Signed/unsigned normalization, exact word bounds and error fields | `NavigationKernels.ReadWord`, `NormalizeIndex` |
| Descriptor spans, array steps, tuple scans and rejection order | `NavigationCursorSource.ArrayStep`, `TupleStep`; `NavigationTraverseSource.Navigate` |
| Canonical selected locations and refusal of invalid paths | `NavigationCanonical.PathCanonical`, `PathRefused` |
| LEN/PAYLOAD footprint policy and wrong-mode ordering | `NavigationModeSource.LengthAt`, `PayloadAt` |
| Static narrow-word scans, exact first dirty byte and dynamic codec delegation | `NavigationTerminalSource.StaticAt`, `BytesExtent`; `NavigationDynamicSource.Extent`, `CodecExtent` |
| Raw return bytes, independent of previous output-memory contents | `NavigationReturnSource.DynamicReturn`, `StaticReturn` |
| Empty paths and final mode/value dispatch | `NavigationSource.NavResolved` |
| End-to-end canonical query against the independent specification | `NavigationCorrespondence.CanonicalQuery` |

`CanonicalQuery` covers invalid selections as refusal and all three terminal
modes. Its plain-value path must have no terminal mode sentinel; valid canonical
paths satisfy that automatically, as `PathHasNoMode` proves. Its sufficient
arithmetic budget is
`|data| + 32 * 2^32 * |descriptor| < 2^256`, with uint256 descriptor/path lengths
and int256 path entries. This discharges the codec's zero-copy cursor budget and
output-size arithmetic without a fixed recursion, tuple-arity or array-count
cap. The source models retain checked panic paths outside this sufficient budget.
The full-width `_normalizeIndex` helper includes `Panic(0x11)` for a negative
index with count `2^255`; actual navigation callers bound counts before invoking
it. This is not a universal no-panic or gas guarantee.

For malformed input, navigation follows selected offsets without checking
unvisited siblings or the whole parent frame. LEN bounds the available payload
or element heads, without traversing array tails or validating narrow words.
PAYLOAD only bounds the requested bytes and accepts an unpadded payload. Whole
returned values undergo canonical validation. The proof retains these different
policies instead of imposing globally canonical input on every successful call.

Navigation's own error fields and ordering are specified directly. Codec
`InvalidValue` byte offsets and checked panics propagate through `FromCodec`
without rewriting their fields; the recursive codec implementation is the
source-connected dependency. The independent ABI validator characterizes
acceptance and returned values, not a separate recursive error-position oracle.
Concrete malformed nested-value examples additionally pin the error bytes.

The trusted boundary is the pinned solc AST, restricted Python translation and
full structural gate, the byte-object memory projection, and Dafny/Boogie/Z3.
The generator ignores compiler source-location annotations, retaining executable
AST fields and statement order. Its padding-mask normalization is checked by 32
bitvector queries from the actual navigation expression. Valid nonwrapping,
disjoint physical memory and adequate gas, stack and allocation are environmental
assumptions. This package does not prove compiler correctness, deployed bytecode
for arbitrary geometry, external producer correctness or unlimited-resource
execution. Production Solidity and deployment artifacts are unchanged.

## Reproduce

Use the tool versions in `../abi/toolchain.json` and the pinned solc 0.8.36:

```sh
python3 -B formal/navigation/verify.py \
  --dafny /path/to/dafny \
  --solc /path/to/solc-0.8.36 \
  --abi-evidence formal/abi/evidence/production-abi-correspondence/manifest.json \
  --output /tmp/navigation-baseline

python3 -B formal/navigation/mutations.py \
  --dafny /path/to/dafny \
  --solc /path/to/solc-0.8.36 \
  --output /tmp/navigation-faults
```

The baseline inventories every current navigation declaration and its complete
Dafny dependency closure. ABI modules may be reused only with identical
transitive input hashes, tools, solver arguments and successful complete native
results; their original logs and provenance are copied into the new evidence.
Navigation modules run afresh. The runner retains source snapshots, native CSV
results, compiler AST input/output, commands, versions, bounds, mask queries,
format/audit results and the exact nonzero Forge test inventory. Failures,
timeouts and missing results prevent a passed baseline.

The fault campaign mutates actual Solidity in isolated snapshots. Each supported
fault must pass source translation, fail its named semantic proof without a
timeout, and fail a designated real EVM test. All remaining oracle tests must be
accounted for. Rejected source generation is an incomplete mutation result,
never a successful proof kill.

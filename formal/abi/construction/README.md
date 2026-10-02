# Production ABI construction and splitting correspondence

This successor connects the independent ABI specification to the production
`AbiCodec.sol` tuple layout, cached/component validation, error contexts, frame
assembly, tuple encoding, array packing and unpacking. The dependency graph also
includes the descriptor parser, word-rule classifier interface, static traversal
and complete recursive dynamic validation.

The [complete baseline](../evidence/production-abi-correspondence/manifest.json)
**passes: 187 lemmas, 102 proof methods and 7,579 verification batches across
54 modules**, with all 40 independent EVM tests passing. The separate
[source-fault campaign](../evidence/production-abi-faults/mutations.json)
detects all nine Solidity mutations through both semantic proof failures and
EVM test failures. These results complete the source connection under the
contracts and trusted translation described below.

The earlier `production-abi-connection` run remains unsuccessful history. It
detected a translator defect that assigned the static and dynamic head updates
by AST visitation order. Solc serializes `falseBody` before `trueBody`; the
translator now selects those named branches explicitly. The production Solidity
was unchanged, and the corrected generated assembly passes the complete baseline.
`production-abi-verified` remains incomplete: an inverse proof timed out and the
graph exhausted its outer budget. Factoring its size argument into
`RoomForSmaller` made the affected module pass without changing the theorem or
solver limits. `production-abi-complete` records the first successful full graph;
`production-abi-final` and `production-abi-correspondence` retain subsequent
runner/generator checks with strictly validated module reuse. Counts overlap
across these baselines and must not be added.

The earlier `production-abi-mutations` campaign is also retained as incomplete:
eight faults were detected, but an older translator gate refused the context
fault before its proof ran. The final campaign isolates the actual `requireValue`
helper with `generate.py --context-only`. That mode emits only the context module,
with its own AST gate; it does not claim whole-validator correspondence for the
altered source or bypass the normal full-generation gates. The context theorem
and EVM oracle both detect the fault in the final campaign.

## The connection

- `../layout/` proves the raw tuple-layout scanner, exact component spans,
  cached shapes and total head size. Its acceptance and witness theorems connect
  every accepted layout to an admissible tuple descriptor, including the
  rejection of `()` at position 1.
- `Validation.dfy` proves the cached overload under its real caller contract:
  the supplied dynamic flag and width belong to the descriptor.
- `Context.generated.dfy` models the exact error fields. The generator audits
  every context use in the validators: context is only forwarded to the known
  callees, and `requireValue` alone consumes it. Context therefore changes the
  terminal value-error constructor, preserving decisions, parser failures and
  arithmetic panics.
- `Component.generated.dfy` retains envelope and length errors and the exact
  component index. Static multiplication overflow is explicit; it does not
  assume that every bare tuple is bounded to 32-bit width.
- `Memory.dfy` proves byte-exact bounded replacement, copy, store and slice.
  `Assembly.generated.dfy` maintains the partially filled head and tail, proves
  both spans of every copy, and produces exactly the independent `Frame`.
- `Tuple.generated.dfy` validates every component before assembly and connects
  the result to the independent tuple body. `Pack.generated.dfy` connects the
  source parser and per-value validation to the independent array encoder.
- `Unpack.generated.dfy` checks the envelope, count, static words, offsets,
  recursive bodies and exact consumption. Its extracted and rewrapped values
  equal the independent encodings of the mathematical array elements.
- `Endpoints.dfy` preserves malformed-descriptor outcomes at the public library
  entrypoints. `Inverses.dfy` proves both source-composed inverse directions:
  unpacking a packed list recovers that list; packing an unpacked canonical
  array recovers its original bytes.

## Scope and trust

These are inductive source-correspondence proofs with no chosen nesting,
component-count or loop-unrolling bound. They retain uint256 arithmetic and
explicit panic outcomes. The inverse theorems use a sufficient arithmetic budget
of the relevant encoded size plus `32 * 2^32 * |descriptor| < 2^256` to discharge
zero-copy cursor requirements. Ordinary construction also requires its output
size to fit. These conditions do not promise that physically impossible
allocations can succeed.

Gas, stack, allocation success and valid nonwrapping physical memory/calldata
layout remain environmental contracts. Cached shapes and tuple plans must match
their descriptors; the source parser and layout entrypoints supply these facts.
An arbitrary forged internal cache is outside that contract.

The pinned solc AST, restricted Python translation, loop factoring and projection
from Solidity objects to byte sequences remain trusted. In that projection,
MSTORE writes a big-endian word and MCOPY copies the requested bytes; the proofs
establish object-relative bounds. They do not verify the Solidity compiler,
allocator or EVM implementation. The separately retained compiled-bytecode
checks cover their listed concrete geometries, not arbitrary-depth bytecode
induction. The source hash in every manifest identifies which production source
the correspondence covers.

The mathematical validator decides by parsing words, offsets and bodies. It is
not defined as equality to the encoder. Its independent soundness/completeness
theorems are verified in the same graph. The EVM oracle uses solc `abi.encode`
and independently scanned sentinels rather than a pack/unpack round trip.

## Reproduce

Use the repository's pinned Dafny 4.11.0, Z3 4.12.1 and solc 0.8.36:

```sh
python3 -B formal/abi/construction/verify.py \
  --dafny /path/to/dafny/dafny \
  --solc /path/to/solc-0.8.36 \
  --dynamic-evidence formal/abi/evidence/dynamic-body-verified/manifest.json \
  --output /tmp/production-abi-connection

python3 -B formal/abi/construction/mutations.py \
  --dafny /path/to/dafny/dafny \
  --solc /path/to/solc-0.8.36 \
  --baseline /tmp/production-abi-connection/manifest.json \
  --output /tmp/production-abi-mutations
```

The baseline verifies every module body once with the existing two-worker,
30-second batch limit and 900-second graph budget. It inventories every lemma,
method and definition; retains native batch results, commands, versions, source
snapshots and hashes; checks source generation, the inherited word-SMT evidence,
audit and formatting; and requires all 40 declared EVM tests to pass.

For an incremental recheck, `--reuse-evidence /path/to/manifest.json` can reuse
independently successful modules from a completed run. Reuse requires identical
transitive Dafny source hashes, executable hashes, toolchain and actual verifier
arguments. Each reused module retains its original command/log and a link to
the hashed baseline; changed, failed or timed-out modules execute again. Source
generation, audit, formatting and all EVM oracles always execute again. An
incomplete parent run keeps that status; only its individually successful,
unchanged modules qualify for reuse.

The mutation campaign runs in isolated snapshots. It changes layout depth/count
and head size, context indices, component width, assembly size/head/tail updates
and unpack's static slice width. Each case must cause an assertion failure in
its named source-connected proof and a failing EVM test. All 24 construction
oracle tests must be accounted for on every mutant. Translation rejection,
timeouts, source drift and missing results remain incomplete.

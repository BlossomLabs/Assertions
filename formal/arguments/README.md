# Canonical argument construction and get

This package connects `Assertions.get` and `_encodeArguments` to ordered operand
resolution and the source-connected ABI codec. It strengthens the codec tuple
loop's contract to identify the first rejected component. The retained
[baseline](evidence/get-arguments/manifest.json) and
[source-fault campaign](evidence/argument-faults/manifest.json) record executions.
Production Solidity is unchanged.

`ArgumentsSource.PrepareSource` resolves the target, checks its first word as a
clean address, and then resolves each argument exactly once in increasing order.
The independent recursive `ArgumentsModel.Prepare` uses the previously proved
resolver and collection semantics. It preserves the exact first error and call
history. Target errors use operand 0; argument i uses operand i+1. All argument
resolution precedes descriptor parsing and canonical value validation.

`ArgumentsSource.EncodeSource` proves the exact exception for descriptor `()`
with no values: it returns empty bytes without invoking the grammar, whose
ordinary empty tuple is invalid. Other inputs use the actual parsed layout.
Malformed descriptors and layout arithmetic panics retain their errors. Counts
are checked before component values. `ArgumentsTuple.TupleChecked` strengthens
the source-connected tuple loop: a component error names the first invalid
component, every prior component validated, and count/length/envelope fields
retain their exact values. Checked panics remain distinct. On a nonpanic path,
encoding succeeds exactly when every input is the canonical single-value
encoding of its declared field. Success produces the independent ABI model's
canonical tuple body, with no extra outer envelope.

`ArgumentsSource.Get` returns a ghost encoding receipt produced by the proved
encoder, rather than assuming an encoder outcome supplied by a caller. The
receipt records descriptor witnesses and the actual codec result. `GetPost`
connects ordered preparation, that encoder contract, and `Finish`: preparation
failure skips encoding and the final call; codec failure propagates unchanged
without a final call; successful encoding supplies selector plus canonical tuple
body to the proved static-call helper. Its raw success bytes or exact call error
then propagate. Receipt fields and model error namespaces are proof artifacts,
not additional runtime fields or error wrappers.

Canonical validity and tuple bytes use the independent recursive ABI model.
Recursive invalid-value byte offsets remain receipts from the source-connected
codec helper, not a second independent recursive offset oracle. Component
indices, first-failure order, count/length/envelope fields, descriptor errors and
propagation are established by the composing proofs. Unknown descriptor names
retain the codec's existing uninterpreted-word semantics; no broader claim about
solc recognizing such names is made.

## Source connection and limits

`generate.py` gates the complete normalized AST of `get`, `_encodeArguments` and
both `AbiCodec.tuple` overloads, plus error/wire declarations. Compiler-allocated
AST overload candidate IDs are normalized while preserving candidate counts,
overload definitions, call names and argument structure. It translates the
argument index, empty-value count condition, tuple count guard and component
index from the actual AST. The remaining control flow and helper composition
are reviewed template translations, with unsupported structure changes rejected.
The strengthened tuple loop follows the gated source loop and calls the proved
component validator and assembler. Normal verification does not bootstrap gates.

The AST, templates, restricted expression translator, memory projection and
Dafny/Boogie/Z3 are trusted. Typed calldata, actual decoder/external observations,
representable descriptor/argument/value lengths, total value size and all
intermediate memory arithmetic, nonwrapping disjoint memory, and sufficient
local gas/stack/allocation are explicit premises. Return/error serialization and
compiler correctness are separate. External observations are history-indexed;
repeated requests need not be deterministic. This is not a universal resource,
recursive tree, graph-equivalence or exact-bytecode theorem.

New Arguments declarations run afresh. The complete dependency closure is
reused only after transitive source hashes, tool hashes, complete successful
native/declaration results and retained artifact hashes match the completed ABI
and core baselines. Copied dependency manifests retain provenance and original
commands; linked logs/artifacts are audited again by the evidence checker.
Failures, timeouts, missing rows and changed inputs prevent a passed result.

Ten EVM tests compare mixed static/dynamic arguments with solc, verify caller
identity and exactly-once fetching, and pin target/argument/codec/call failure
precedence and exact bytes. Four real Solidity faults cover argument indices,
the empty-tuple exception, count validation and component indices. Each must
translate successfully, fail a semantic proof without timeout and fail its
specified EVM regression. Finite EVM examples supplement the arbitrary finite
list/type proofs; they do not replace them. No gas-performance claim is made.

```sh
python3 -B formal/arguments/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/get-arguments
python3 -B formal/arguments/mutations.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/argument-faults
```

The full goal remains in `../verification-plan.json`. Recursive self-call trees,
Expressions, Collections and exact compiled bytecode remain separate work.

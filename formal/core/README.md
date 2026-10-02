# Core raw-value primitive correspondence

This package connects `resolve`, `gather`, `pick`, `read`, `chain` and `cond`, plus
`_rawWord` and `_asAddress`, to an independent ordered value/history model. It
composes the resolver/constraint proofs. The authoritative run status is in
[`evidence/core-raw-primitives/manifest.json`](evidence/core-raw-primitives/manifest.json);
[actual-source faults](evidence/core-raw-faults/manifest.json) must fail both the
named proof and a designated EVM test.

This is one part of the full Assertions objective. `get`, the guarded probes
(`orElse`, `isValid`, `revertData`), composition with navigation and recursive
self-call/tree correspondence remain separate work. Expressions, Collections
and exact compiled-bytecode verification also remain open. The full inventory
is in `../verification-plan.json`; this package does not narrow that objective.

## Theorems

- `ResolveRaw` preserves the internal resolver's exact raw bytes/error and call
  history with context (empty message, entry 0, parameter 0).
- `CollectValues`/`Gather` resolve arbitrary finite operand lists in order,
  return each raw value in its corresponding slot, and stop on the first error.
  `CollectionLength` proves the exact output count. The loop's growing prefix
  represents initialized slots in Solidity's preallocated array. Source-level
  gather returns a list; solc's external `bytes[]` serialization is concretely
  checked against `abi.encode(expected)` and remains part of compiler trust.
- `WordAt`/`PickWord` implement independent signed word selection. Negative
  indices count from the complete-word count, partial trailing bytes are ignored,
  and invalid indices retain the requested signed index and byte length.
  Representable byte length bounds the word count below 2^255, so checked
  negation/subtraction and word offsets cannot overflow on accepted paths.
  Operand constraint errors precede index errors.
- `ReadSegments` resolves the target first, then each full byte segment in
  operand order, prepends the selector, calls the clean target address, and
  returns the raw call result. Target context is operand 0; segments are i+1.
  `SegmentStep`, `EmptySegments` and `ConcatAppend` establish the equivalence
  between incremental concatenation and collecting then concatenating values.
- `CallChain` rejects an empty chain before resolving the start. Each non-final
  call supplies the next target's first word; a dirty address is reported at
  hop i+1. The final call's result is returned without address interpretation.
  The induction has no fixed hop bound and propagates the exact first failure.
- `Cond` resolves and checks its condition first, then only its selected branch.
  Any nonzero first word selects the then-branch, not only canonical bool 1.
  Short conditions fail. Winning branch contexts are 1 and 2 respectively.

Histories retain attempted calls and native balance reads from the resolver
model. Repeated requests need not produce identical external observations. The
proof does not replace gas/context-dependent calls by deterministic functions of
just target and calldata.

## Source connection and limits

`generate.py` uses pinned solc 0.8.36 and checks the full normalized AST of the
eight source functions, error declarations and wire vocabulary. Address guards,
negative-index arithmetic, read operand indices and chain hop indices are
translated from actual AST expressions. The remaining control flow, raw memory
returns, allocation and slot writes are pinned against the reviewed structure.
Unsupported structure drift rejects; verification never bootstraps a new gate.
The resolver/constraint dependency sources are included and verified afresh.

The hand-written control-flow template, restricted translator, solc AST and
byte/array memory projection are trusted. Valid, disjoint, nonwrapping memory,
representable intermediate byte lengths/address arithmetic, typed calldata and
sufficient local gas/stack/allocation are environmental premises. Selectors have
four bytes in actual Solidity. `PickWord` explicitly requires a representable
resolved length and int256 index. Resource failures outside these premises are
not modeled as ordinary predicate failures. External and decoder observations
must match the execution, as documented by the resolver proof. Error embedding
in `CoreError.Base` is a model namespace, not a new on-chain wrapper. Compiler
correctness, physical error/return serialization and deployed bytecode remain
separate from these source theorems. Dafny/Boogie/Z3 are trusted.

The EVM oracle checks raw returns, caller identity, dynamic `bytes[]` output,
partial word tails, int256.min, unusual calldata segment boundaries, branch
laziness, exact operand/hop indices and rejection precedence. Its finite tests
are not substituted for the arbitrary finite list proofs. No gas, deployment or
historical performance claim is made.

## Reproduce

With the existing pinned Dafny/Z3 distribution and solc 0.8.36:

```sh
python3 -B formal/core/verify.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/core-raw-primitives
python3 -B formal/core/mutations.py \
  --dafny /path/to/dafny --solc /path/to/solc-0.8.36 \
  --output /tmp/core-raw-faults
```

The runners retain source snapshots, native proof rows, declaration inventories,
compiler inputs/output, tool hashes, exact commands, audit/format results and
complete EVM test inventories. Missing results and timeouts never count as
passed. A mutation must pass translation, fail the named semantic method without
a timeout and fail its designated concrete test; other tests are accounted for.
Production source is untouched.

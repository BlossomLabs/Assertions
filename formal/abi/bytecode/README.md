# Exact-runtime ABI checks

The [final baseline](../evidence/bytecode-aggregates-final/manifest.json) passes
**12 symbolic properties** against the exact canonical Hardhat **Collections
runtime**, including its metadata. All five planted source faults produce valid
symbolic counterexamples and concrete EVM failures. Every property has a nonzero
successful path count, no blocked paths, no counterexamples on the baseline and
no bounded-loop warnings. The concrete test executes every listed geometry.

These are compiled-bytecode results for **declared finite ABI geometries**, with
all values of their symbolic input words covered. They are not an unbounded
array/tuple bytecode theorem or a compiler-correctness proof. The separate
[Dafny composition proof](../aggregate/README.md) covers arbitrary finite typed
recursion but has additional source-interface assumptions. The two results must
not be silently combined into a stronger end-to-end theorem.

## Runtime identity and oracle

`verify.py` checks every canonical compiler input source against the worktree,
recompiles the exact Hardhat JSON input with solc `0.8.36+commit.8a079791`, and
requires byte-for-byte equality with `Collections.json`'s deployed bytecode.
It installs those exact bytes in the isolated test EVM using `vm.etch`.
It does not substitute a newly compiled Collections test contract or assert that
the predicted address is deployed. The retained runtime is 24,557 bytes; its
hash, artifact/build-input hashes and compiler settings identify the result.

The harness calls `unpackArray` through low-level `staticcall`. Successful cases
must actually succeed and return the expected bytes. Rejections cannot disappear
as reverted test paths. Canonicality compares against independent solc
`abi.decode` followed by `abi.encode`, because decoding alone accepts some
noncanonical layouts. Comparisons check exact bytes, without relying on hash
collision freedom. Bounds failures also pin exact `InvalidValue` offsets.

The machine-readable [property inventory](properties.json) is required to match
all `check_*` declarations exactly and is copied into each result's scope.

| Property family | Scope |
|---|---|
| Static fixed-array elements | `uint8[2][]`, count 0/1/max, two arbitrary 256-bit words. |
| Mixed tuple elements | `(uint8[2],string)[]`, one element, five tight/loose/truncated/trailing/backward layouts, arbitrary scalar and payload words. |
| Two dynamic elements | `string[]`, two two-byte strings, tight/loose/backward/trailing layouts, arbitrary payload words. |
| Hostile counts | Both outer `uint8[]` and inner `uint8[][]` counts: every uint256 count greater than two with only two body words. |
| Truncated tuple head | One arbitrary available word where the tuple requires three head words; rejection at the tuple start. |
| Correct returned values | Two `(uint8,bytes)` elements; `uint8[][]` with inner lengths 0 and 2; one `bytes[2]` element. Payloads are two bytes. |
| Dynamic fixed-array offsets | One `bytes[2]` element with a tight or backward second offset; arbitrary payload words. |
| Empty arrays | Zero elements with static aggregate, mixed tuple and dynamic fixed-array element descriptors. |
| Envelope/trailing failures | One arbitrary uint8 element with a top offset of 64 or one trailing byte. |

There are three separately counted returned-value properties and two hostile
count properties, giving twelve in total. These declarations are the coverage
boundary, not representative samples for a universal geometry claim.

## Reproduce

Use Halmos **0.3.3**, **Yices 2.6.4**, the pinned solc, Forge and the repository's
canonical Hardhat artifact. The runner records the Yices binary hash/version,
Halmos launcher hash, branching Z3 version, compiler identity, all commands and
native per-property results. The retained run uses optimizer 200 and Cancun.

```sh
python3 formal/abi/bytecode/verify.py \
  --solc /path/to/solc-0.8.36 \
  --yices /path/to/yices-smt2 \
  --output /tmp/abi-bytecode
```

Use a new output directory. The loop bound is 70 and the assertion solver limit
is 30 seconds. The outer watchdog is 300 seconds per symbolic invocation. A
bounded loop, unsupported/blocked path, timeout, missing property, zero successful
paths or source/artifact drift cannot pass. SMT queries, models, compiler inputs,
compressed compiler outputs, exact runtime bytes, source snapshots and concrete
logs are retained. Only valid counterexample models count for mutations.

The five mutations remove the array count guard, tuple head guard, array offset
check or tuple offset check, or replace a tuple field's word width with one word.
Each is recompiled with the canonical compiler input in an isolated copy, checked
by its named symbolic property, and required to fail the concrete EVM harness.
Nothing modifies live contracts, canonical artifacts or deployments.

The earlier [ten-property run](../evidence/bytecode-aggregates/manifest.json) and
[initial twelve-property run](../evidence/bytecode-aggregates-complete/manifest.json)
are retained as historical successful runs. The final run adds per-property
scope records and stricter native model/path accounting. Their frozen source
snapshots identify the exact harness/runner used; the current files are newer.

The [ABI repair rerun](../evidence/abi-codec-bytecode-final/manifest.json) applies
all twelve properties and all five mutations to the final repaired Hardhat
runtime (24,560 bytes), including the bundled trailing-offset source change.
It retains the same finite geometries and solver settings.

Halmos's gas model, EVM implementation, cheatcodes and solver toolchain are
trusted. Gas exhaustion, arbitrary calldata shapes, resource availability,
deployment observation and equivalence of the entire compiler to the Dafny
model remain outside these properties.

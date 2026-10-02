# Exact sumWords runtime evidence

This package retains the actual current `Collections.sumWords(bytes)` instruction
path from PC zero to physical RETURN or REVERT. It imports the reached opcode
model and proof connection in `../scans/raw-decoder/Connection.dfy`. Generated
instruction certificates are produced by the generators in `../scans` and its
`raw-decoder` directory; never edit generated files directly.

The native root admits zero call value, a compiler-bound sumWords selector, and
calldata size from four through 2^64-1. It partitions raw bytes frames into five
malformed decoder classes or accepted frames. Accepted frames may contain loose
offsets, absent bytes padding and trailing bytes. The actual body checks alignment,
executes an unbounded finite checked word sum, and emits either its 32-byte result,
`UnalignedWords(length)` or `Panic(0x11)`. Every raw malformed class physically emits
an empty revert. Nonzero call value and short calldata use the independently
checked immutable physical-rejection package; other selectors remain separate.

The theorem uses actual calldata loads, rounded byte memory, reached checked
arithmetic/slice/read helpers, error stores and final return/revert slices. It
makes no source-to-bytecode, gas, deployment, performance or resource-availability
claim. Runtime extraction, instruction-boundary scanning, the reviewed reached EVM
interpreter, faithful observations, adequate reached resources and the proof/EVM
toolchains remain explicit trusted premises. Calldata size at least 2^64 is outside
this native root's stated representation. No external call occurs in this path.

`verify.py` snapshots the finished package and all proof/runtime/source/tool inputs,
checks its retained dependency before and after, reproduces all three canonical
runtime byte strings with the pinned compiler, regenerates certificates byte for
byte, and verifies every declaration of each file in the complete root include
graph. Per-module native inventories avoid hiding unverified dependency symbols.
A zero-finding root audit and 24 complete physical EVM fixtures are required.

Three one-byte semantic faults change checked addition to subtraction, reverse the
raw tail comparison, or change the panic argument from 17 to 18. Each must preserve
the expected semantic oracle, regenerate its actual instruction certificate, fail
a baseline-covered native postcondition, and produce a contradictory fixed EVM
receipt. Generation, type, precondition and timeout failures do not count as fault
detection. Failed runs remain preserved; a correction requires a new evidence
version. A live run is never restarted because observation polling times out.

Run with the pinned Dafny and solc paths, for example:

```sh
python3 -B formal/bytecode/word-sum/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/bytecode/word-sum/evidence/physical-raw-entry-v3
```

Development results, concrete fixtures and mutation preflight are not retained
public evidence. Public coverage changes only after this retained verifier and a
current evidence checker both pass. Whole-contract exact bytecode verification
for Assertions, Expressions and Collections remains incomplete.

The first retained attempt preserved under `evidence/physical-raw-entry-v1`
failed isolated formatter include resolution after its dependency and runtime
identity checks passed. Generators now format syntax through stdin while restoring
the exact include lines; retention still resolves and checks the actual graph.

The second retained attempt (`physical-raw-entry-v2`) preserved stable inputs,
zero audit findings, 24 baseline receipts and three semantic detections, but failed
format consistency, decoder shift obligations and one trace-join timeout. The
third package uses resolved-include syntax formatting, a separately proved decoder
constant, and explicit slice geometry. Existing shared selector proofs stay intact.

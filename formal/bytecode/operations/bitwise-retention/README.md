# Retained Operations bitwise exact-bytecode package

`verify.py` retains the complete raw bitAnd, bitOr and bitXor graphs only after
all owner files and generated controls are complete. It snapshots the exact
canonical Operations compiler/input closure, isolated proof/generator files,
reviewed shared verifier helpers and tool versions/digests. Fresh native runs
cover every included module and declaration separately, with no position filter;
audits must report zero findings. Every generated file is reproduced through its
owner and deterministic formatting before evidence proceeds.

The proof composes PC-zero global nonpayable and short-selector rejection,
assigned-selector short-argument rejection, arbitrary all-word successful
argument decoding, the actual bitwise opcode, physical MSTORE/MLOAD frame and
exact 32-byte RETURN. Arbitrary trailing calldata is admitted. Raw zero-padded
calldata windows derive the loaded projections, rather than assuming decoded
arguments. The finite representation requires calldata length below 2^64 and
adequate reached execution resources. Unknown selectors and other Operations
public bodies are outside this package.

Evidence requires 27 complete local exact-runtime successful physical receipts,
32 complete raw empty-revert receipts, and three single-byte semantic opcode
mutations. Each mutant preserves instruction geometry, retranslates against the
independent expected result, fails a baseline-proved semantic native assertion
without timeout/type/parser failures, and produces actual EVM wrong-answer
counterexamples. Compiler failures, synthetic proof-only changes and unrelated
assertion failures do not count. A failed or incomplete snapshot is retained;
polling timeouts never authorize restarting live verification.

Dafny/Boogie/Z3 and reviewed extraction/opcode/testing tooling remain trusted.
Gas costs/availability, deployment, performance, whole-compiler correctness and
source-only inference are separate claims. The independent checker and public
ledger may be added only after the complete retained package passes.

The preserved V1 campaign timed out on all three final encoded-result native
faults. Selected V2 actual-word general checkpoints also timed out on the native
faults, although all three baseline checkpoints passed. The prepared replacement
campaign checks an additional baseline-covered actual MSTORE128 word theorem
under the explicit counterexample arguments (123,456), matching physical fixture
ordinal4. The wide all-word public entry theorem and general actual-word checkpoint
remain in the complete native graph; only the fault counterexample is specialized.
No replacement retained run or public bitwise count is claimed yet.

Selected V4 checked the isolated constructive conversion kernel (112 obligations),
constant witness results, all three specialized baseline word
checkpoints, and genuine native postcondition failures for all three semantic
mutants without timeouts. The campaign records (123,456) and physical ordinal4
explicitly and requires that matching contradictory complete EVM receipt. The three general all-word checkpoints passed in selected V2 baseline checks. These
selected checks remain development only until a fresh whole retained run passes.

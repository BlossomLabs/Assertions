# Stable public word uniqueness

This package targets `uniqueWords` at the decoded ABI source boundary. Public
coverage is added only after retained evidence passes.

Independent `Model.Keep` refers to original input positions: unordered mode
selects precisely first occurrences; ordered mode selects starts of equal-word
runs. `Selected` and `Project` specify stable indices and original full-width
words. Membership, strict index order and unordered value uniqueness are proved.
Ordered mode trusts grouping and can retain nonadjacent duplicates. Equivalence
of modes requires the explicit `Grouped` predicate; no such premise restricts
ordinary calls.

`generate.py` gates the complete compiler AST, including fixed slices, lazy
last-word checks, read/write arguments and increments, and extracts control and
shrink expressions into `Control.generated.dfy` from `Control.template.dfy`.
Never hand-edit generated files.

`Source` connects the actual retained `_wordAt` and `_setWord` proofs to the
physical retained prefix. Its unordered scan checks exactly that prefix; ordered
mode checks the last retained word only when nonempty. The buffered-word scan is
proved equivalent to original-prefix membership, and the ordered last retained
word is the previous input word. Successful output shrink is an actual physical
header store with proved modular no-wrap and outside-frame preservation.
`Connection.Run` reconstructs exact output bytes, stable original positions,
unordered uniqueness and conditional grouped-mode equivalence.

Premises are decoded ABI fields, faithful source/compiler/calldata/context/memory/
allocator/outer ABI projections, trusted load/store interpretation, sufficient
successful allocation/execution resources and Dafny/Boogie/Z3. Only aligned input
requires the allocated frame. Allocator/OOG failure, malformed external ABI,
exact compiled bytecode, gas, complexity, deployment and performance are separate.

`verify.py` snapshots/hashes all inputs, regenerates controls, checks complete
retained dependency source/tool/native/declaration/artifact closure and performs
fresh all-local native verification, zero escape audit and format checks. Five
real EVM fixtures cover empty/alignment behavior, unordered stable first words,
ordered runs with ungrouped repeats, full-width grouped-mode equivalence, all
identical/distinct payloads and exact shrink. Three semantic source mutations
invert retention, skip the last retained word in scanning or halve the output
length. They must translate and fail both a recorded source assertion covered by
the full native baseline and real EVM fixtures; timeouts never count as detection.

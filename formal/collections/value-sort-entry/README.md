# Public sortValues source composition

`Connection.Run` composes the actual source admission prefix with the concrete
source merge suffix for the same `Collections.sol` hash. It starts from decoded
raw callback fields and values, rather than assuming an admitted prepared state.

The resulting theorem establishes:

- Binary preparation, input type parsing and complete prevalidation precede every
  comparison, even for empty/singleton input. Failures preserve the first rejected
  input index and exact source error bytes.
- Every reached comparison has a source-produced receipt, current merge positions,
  original occurrence operands, prepared state and full low-level history.
  Callback failure or an invalid result length immediately terminates sorting.
- Successful output contains every input occurrence exactly once and retains its
  canonical bytes value. Global sortedness and original-index stability require
  decisions coherent with a total preorder; arbitrary callbacks need not satisfy
  that condition.
- Empty/singleton input skips comparisons only after admission, without requiring
  a valid target. `TrivialBudget` discharges its continuation resource premise.

`Model.Judge` is the independent sequential outcome specification. `Budget`
requires resources only following successful admission and then uses the finite
comparison envelope from `value-sort-execution`. It does not assume successful
callbacks. `Project` explicitly maps occurrence IDs back to original values.

This is conditional source semantics at the decoded ABI boundary. Retained full
function AST gates cover admission, comparator and merge fragments; compiler and
translation fidelity, bytes-array/value/copy/scratch representations, memory,
outer ABI serialization, adequate resources and faithful external observations
remain premises. Exact compiled bytecode and performance claims remain separate.

Run `verify.py` with pinned Dafny/solc and a fresh output directory. It snapshots
and hashes inputs, checks the complete retained dependency closure, verifies all
local declarations, audits proof escapes, and replays the eight admission and
six merge EVM fixtures. Their source-fault campaigns remain retained dependencies;
this composition does not claim a new mutation campaign.

# Public value predicate searches

Targets `indexOfValues`, `anyValues`, `allValues`, `findValues` and `_findValue`.
Evidence is conditional source composition at the decoded ABI boundary. Read the
retained manifest for actual run results; development checks alone add no public
coverage. Exact compiled bytecode remains a separate incomplete track.

`Spec.dfy` independently consumes canonical-input validation and strict predicate
observations in original index order. It returns the first decisive index or
`uint256.max`, or the exact first failure. `Rows` records only the reached prefix:
no later value validation or callback follows a decisive predicate or failure.
IndexOf/any/find seek true; all seeks false. Full scans return max. Empty any is
false and empty all true; empty indexOf/find return max, while callback preparation
and descriptor/needle admission still run.

`Source.dfy` projects the complete compiler-gated wrappers and actual loop guards,
input indices, predicate conditions, decisive/sentinel returns and boolean
wrappers. `generate.py` gates the entire four public ASTs and `_findValue`,
retaining every original predicate operand/mode/context even where its result is
lowered to a truth symbol. Public operation selectors come from solc's method
identifiers. Edit `Control.template.dfy`, then regenerate; never hand-edit
`Control.generated.dfy`.

`Entry` invokes actual raw callback preparation before unary descriptor shape or
binary needle validation. `Engine.Step` calls the retained canonical input,
bound-callback and strict callback-result adapters. `Engine.Run` threads the actual
prepared arguments/target-check flag and low helper histories. `Trace` connects
each reached original index to its actual validation/binding/call/result receipts;
`TraceFacts` equates the consumed actual-record count with the independent high
helper rows. `Connection.Run` composes those adapters with the compiler-derived
source loop and wrappers, including early-stop/empty/sentinel results.

The candidate occupies callback slot `first`; indexOf's needle occupies `second`.
Each reached call uses the compiler-bound public operation selector, original
candidate index and `other=0`. Bound component validation, direct tuple or
expression wire construction, lazy target checking, actual staticcall return,
exhaustion propagation, ordinary failure wrapping and strict one-word 0/1 results
retain their existing source-connected helper proofs. A validation failure has no
callback receipt; prepared state persists across successful continuing steps.

External observations are explicit arbitrary history-sensitive receipts. They may
depend on calldata, caller, history or gas. Environment replay/splicing is restricted
to consumed disjoint history windows. There is no assumption of stable truth values
or agreement between separately executed public entries. Cross-entry relational
claims would require an explicit observation-coherence premise.

Representation and resources remain explicit: faithfully decoded finite ABI
strings/bytes/arrays, representable uint256 input/pointer/argument/packet footprints,
codec cursor room, compiler checked arithmetic/context/calldata/copy/memory
projections, successful allocation/outer serialization and sufficient execution.
Raw admission budgets include rejecting inputs. Recursive budgets require resources
only after admission and along continuing executions; neither acceptance nor a
predicate truth is assumed. Logical traces/arrays do not establish physical
compiler allocation, return serialization, exact bytecode, gas, asymptotic
complexity, deployment or performance.

`verify.py` freezes all package files first, verifies complete identical transitive
dependency/tool/artifact/native/declaration closure, regenerates the AST projection,
verifies every local native declaration with isolated assertions, audits for proof
escapes, checks formats, executes seventeen real EVM fixtures and runs five source
mutations in separate retained snapshots. A mutation must translate and fail a
native semantic assertion covered by the baseline plus a real EVM fixture. Solver
timeout/inconclusive results never count as detection. Poll a live verifier to
completion; a polling timeout is not a reason to restart it.

```sh
python3 -B formal/collections/value-search/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/value-search/evidence/public-predicate-searches
```

# Abstract map/filter/fold traversal foundation

This package supplies an independent recursive specification and imperative-loop
refinement for the value traversals. It is explicitly **not yet a Solidity
source-correspondence proof**. Source gates, prepared callbacks, ABI validation,
external calls, predicate canonicality, output memory and wire construction
remain connection obligations.

The specification orders preparation before input shape checks. Map also checks
the output descriptor, while fold validates its initial accumulator. Every
visited input validates before its callback. Map and fold validate callback
results before continuing; filter consumes its predicate result and retains the
original input value. Helper failure propagates immediately without a later
request. Empty inputs still run admission but make no callback application.

`Loops.Run` refines the recursive specification for arbitrary finite lists and
history/context-indexed helper observations. Its continuation invariant tracks
the accumulated output prefix, current accumulator and current helper state.
`Properties.TailFacts` proves map length, fold shape, filter's strictly increasing
original-position witness, and the exact consecutive prefix of callback indices
reached before success or failure. `Connection.Run` combines admission and loop
properties: successful traversal visits 0 through n-1 exactly once; failure
cannot invoke a later element out of order. Context histories retain every
validation/application event. These are helper-application requests, including attempts
that may reject before an EVM staticcall; they are not concrete opcode counts.
A failing context is a ghost receipt, not a claim
that a reverted frame commits memory changes.

The environment's state token abstracts the complete helper context. It does
not assume that callback results are deterministic across different histories.
The eventual source adapters must faithfully instantiate every helper event,
its state transition, error and result. In particular, predicate truth is not
claimed to follow from arbitrary raw bytes here; Collections' canonical 0/1
check belongs to the pending predicate adapter.

Only the existing ABI byte type/sequence foundation is reused by identical
source/tool/artifact hashes. The retained driver records native declarations,
audit, formatting and unchanged inputs. No EVM/source-fault or physical-resource
claim is made. This is one foundation toward all 29 public Collections entries,
not a reduction of that scope.

# Encoded expression entrypoint

The pinned normalized evaluateEncoded AST is gated together with the graph/node
wire members, enum order and evaluate/evaluateGuarded selectors. Its source
adapter explicitly distinguishes malformed decoder output from a decoded graph.
Malformed data reverts bare without a self-call; accepted data is encoded into
an evaluate self-call with the supplied parameter array and wrapper index zero.

The outgoing calldata specification uses independent ABI frames for the graph,
all eleven node kinds, dynamic node fields, reference arrays and parameter bytes.
It proves the evaluate selector and argument-head offset, and that this request
does not target the forbidden guarded selector. Source ABI encoding and the
actual decoder outcome remain projection premises, including for noncanonical
input encodings accepted by Solidity. Inputs meet explicit word, selector and
encoded-length conditions and sufficient local resources.

The source-proved call receipt is composed to preserve successful raw returndata,
encode ordinary failures as NodeCallFailed(0, self, exactCalldata, exactReason),
and propagate sampled exhaustion or the reserved signal unchanged. The model
also retains the source helper's missing-code branch. WithReturn connects a
successful receipt to the source-proved raw-return memory tail under its valid
bytes-object premise. It does not add another ABI bytes envelope.

Six EVM tests cover malformed graph/enum data, parameterized dynamic success,
empty graphs, all node wire kinds and variable dynamic-field geometry, exact
wrapped error fields and reserved-signal propagation. A separate encoder builds
head/tail offsets and padded fields manually for calldata comparisons. One
actual Solidity fault changes wrapper index zero to one; it must translate and
fail both the semantic wrapper theorem and its named exact-byte EVM test.

Actual self-call observations still need provenance from recursive evaluation
in the correct call frame. This package does not equate arbitrary environment
observations with the complete graph theorem, prove compiler/decoder bytecode,
or infer context-independent behavior of view targets. It records exact routing
under those observations; guarded tuple/cache ABI and final frame composition
remain separate obligations.

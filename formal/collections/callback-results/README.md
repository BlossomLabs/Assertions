# Callback predicate and exhaustion results

This package connects the complete gated Solidity `_predicate` and
`_rejectOutOfGas` bodies to independent byte-level specifications. Predicate
postprocessing receives the **actual `_callValue` return/revert receipt** as a
premise. Callback preparation, binding, argument construction, target checks and
the call itself remain pending source connections.

`Judge` accepts exactly `Word(0)` and `Word(1)`, rather than defining acceptance
using the source's numeric comparison. The source adapter checks length, reads
the word, rejects values above one and returns equality with one. Codec byte/word
round trips connect these two formulations for every byte sequence. A failed
call propagates before any predicate validation. Invalid results carry the
original operation, both indices and target. `ErrorWire` proves the fixed ABI
layout and field round trips under explicit context bounds; the error selector
is checked against fresh solc AST metadata.

`RejectOutOfGas` matches the exact four-byte reserved signal or the source's
sampled gas threshold. Longer payloads sharing the signal prefix do not trigger
the signal branch. The mathematical theorem covers every natural gas sample;
production observations must be faithful uint256 source samples. This is a
conservative classification, not proof that each rejected call exhausted gas.

`PredicateReply` projects these outcomes into the existing traversal reply
algebra, proving canonical truth and exact error bytes. It does not yet
instantiate traversal state or history: those belong to the supplied call
receipt. Predicate result interpretation makes no new external call.

Translation trust includes the restricted expression translator, reviewed
control-flow lowering, accurate word/bytes4 memory reads, canonical solc ABI,
valid disjoint representable memory and sufficient local resources. The full
AST structure preserves the delegated call's arguments and both error contexts;
selected guards, word offset and truth/gas expressions are translated. The
verifier never bootstraps its structural gate.

The retained baseline checks native obligations and declaration coverage,
zero audit findings, formatting, fresh AST/generated equality, unchanged inputs
and identical transitive dependency/tool/artifact hashes. Seven EVM fixtures
cover zero/one, noncanonical words, incorrect lengths and exact callback failure
bytes. A separate source-fault campaign requires three real Solidity changes to
pass the source gate and fail both a semantic proof and a designated EVM test;
parser/type errors, source rejection and timeouts do not count as kills.

The complete Collections helper composition and exact compiled-bytecode track
remain open. No gas measurement, deployment or performance claim is added.

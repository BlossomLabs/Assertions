# Recursive oracle agreement and trace extension

EvaluateStable proves that changing an oracle away from the request/history
pairs used by a recursive evaluation preserves its entire Result: value or
error, cache and request history. It covers arbitrary finite backward-reference
graphs, arbitrary starting caches and histories, lazy selection, guarded attempts,
address checks before other arguments, and ordered argument traversal. It does
not require the two oracles to agree on requests that are not executed.

The proof follows the existing recursive specification with mutually recursive
Evaluate, Body and Gather lemmas. Separate history-growth lemmas establish that
every child request sequence remains a prefix of the enclosing sequence even
when its failed-attempt cache is discarded. The existing source refinement
connects that specification to translated recursive control under its recorded
assumptions; this package does not introduce another source translation.

ReplayExtension proves that extending a trace and its receipt sequence preserves
all old request/history responses. Append constructs the next receipt by calling
the proved primitive dispatcher, maintaining Covered and ValidTrace.
AppendPreservesEvaluation then proves that this actual constructed extension
leaves any prior evaluation whose history lies within the old trace unchanged.
These lemmas provide the preservation step needed to assemble recursive child
traces incrementally without assuming a complete oracle in advance.

Recursive construction of an entire matching trace is still outstanding. Append
requires the actual next request to meet the dispatcher eligibility conditions,
including representability, canonical inputs and faithful external observations.
Actual frame provenance, validation-error observations, guarded call boundaries,
public entrypoints and exact compiled bytecode remain separate obligations.
The replay fallback outside its trace is mathematical totalization only. Oracle
agreement is an explicit equality premise, not an assumption that EVM view calls
are deterministic; graph/tree substitution still needs its call-context premise.

This is proof-only composition. Retained dependency source, tool, artifact and
native declaration results are audited; no new EVM test or source fault campaign
is claimed.

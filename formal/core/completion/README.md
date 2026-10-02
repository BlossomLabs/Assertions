# Assertions source correspondence: final connection

The completed connection covers all 35 explicitly declared Assertions function
bodies and all 17 public ABI entries, including both judge overloads and the
compiler-generated LEN/PAYLOAD getters. `audit.py` compares the current solc AST
with the complete source-function coverage matrix, checks retained native proof
results and source/artifact hashes, and records every requirement in
`requirements.json`. The public ABI inventory separately checks full signatures,
outputs, mutabilities and proof-case mappings.

`AssertionsCompletion.AssertParam` connects the actual constructed source receipt
to the independent resolver/constraint specification. Success is equivalent to
fetch success, enough complete words, and every positional constraint accepting.
Success returns empty bytes. Failure returns the exact serialized resolver error,
including the original constraint context and indices. Both message overloads
are covered, with PARAM fixed for the default form.

`AssertionsCompletion.AssertBatch` connects the actual receipt to the independent
ordered batch specification. Success is equivalent to evaluating every entry
successfully. The returned evaluated prefix contains only successes before its
last entry; on failure, that last entry is failed and its exact encoded error
propagates. No later entry appears in the evaluated prefix. The default message
is COMPOSABLE. Empty batches succeed. Entry/operand routing, validation order and
first-failure context are established by the linked resolution proofs.

Both methods construct through the complete public-entrypoint and concrete-wire
composition. Parent self-call observations come from actual child source-adapter
receipts, not assumed successful results. Every reached self-call must have one
matching history/request site, and unused children are rejected. Children have
independent frame environments. Successful bytes[] returns use the canonical
encoder and independent validator; all error namespaces map to compiler-bound
selectors and argument layouts. Public getters have exact signed values, ABI
words and empty histories. General decoder rejection produces an empty revert.

The certification flag is exact: it is `Complete && TreeFits`. These conditions
require readiness throughout, complete finite self-call coverage, unique sites
and representable error fields/returns. The methods also describe uncertified
mathematical executions; those are not claims about resource-adequate EVM runs.

The precise production interpretation requires admitted zero-value frames
executing the modeled Assertions code in matching caller/static contexts;
faithful compiler ABI decoder/getter/encoder behavior; truthful external-code,
call, balance and sampled-gas observations; reviewed AST/template translation;
nonwrapping, disjoint memory; representable intermediate arithmetic; and adequate
local gas, stack and allocation. Repeated calls need not be deterministic.
Get/navigation invalid recursive byte offsets are actual source receipts; the
caller proofs do not claim a separate independent offset oracle for every such
error. Exact constraint and first-failing-component indices remain proved.

This closes Assertions source correspondence under those explicit premises.
It does not prove compiler correctness, arbitrary physical recursion/resources,
or exact deployed bytecode. Gas measurements, deployment observations and
historical performance retain their own evidence. No new EVM or source-fault
campaign is claimed by this proof-only final composition. Expressions and
Collections, and the exact-bytecode track, retain their separate milestones.

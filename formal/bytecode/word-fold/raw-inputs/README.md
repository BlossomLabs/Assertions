# Raw fold input preparation

These fields describe the current seven ABI heads and raw dynamic spans. The
candidate admission keeps compiler-permitted loose, shared and overlapping tails;
it imposes no canonical padding or tail order. Range count and initial accumulator
retain the full uint256 domain. Calldata length and dynamic lengths have the
explicit finite representation bound below2^64. The element-window count bound
comes from its fitting encoded span.

The predicates are candidates for the actual ordered compiler decoder. Proving
their mathematical helper properties does not prove that the decoder accepts or
rejects them. Both decoders, complete enum and dynamic-tail rejection, body checks,
allocation/copy, loop, observations, errors and final scalar return remain required.
The selected helpers assume included contracts; fresh whole-graph retention and an
independent checker are necessary for public coverage. No gas, deployment or
performance claim.

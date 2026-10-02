# Shared proof foundation

The coordinator maintains this versioned library and [registry](registry.json). Run
`python3 formal/foundations/check-registry.py` before using a published package.
The packages prove mathematics and model adapters; they grant no additional
exact-bytecode or whole-contract coverage.

Published interfaces are immutable. Consult the registry before duplicating a
memory, copy, encoding, overflow or prefix-sum proof. Request shared additions
from the coordinator; keep contract-specific bridges in the consuming lane.
A different machine representation requires a proved bridge, even when its
functions have the same names. Read each lemma's exact preconditions.

A new version requires complete native declaration and minimal import closure
coverage, zero audit findings, source/tool identities and retained logs. Preserve
failed versions. Notify all consumers, let running snapshots drain, and rerun
changed consumer closures before acceptance. Mathematical reuse does not waive
runtime generation, full replay or matching fault gates for bytecode claims.

Published: generic copy/padding; aligned expansion bridge; arbitrary byte and
span store frames; snapshot copy span/word frames; fixed 32-byte word round trip;
unsigned addition overflow; integer sequence prefix sums and bounds.

Upstream sources are quarantined as `.dfy.txt`, with Git blob and SHA256 identity,
license and audit inventory. They are not imported wholesale. See
[the assessment](DAFNYEVM-ASSESSMENT.md).

`v1/StoreExtent.dfy` exports allocation-only `Length` and `Aligned` facts without
byte encoding or load conclusions. Length accepts arbitrary memory alignment;
Aligned requires the old length to be a multiple of 32.

`v4/EnvironmentStep.dfy` supplies an additive ADDRESS/CALLER profile on the
unchanged Scan State/Fetch aliases. Consumer account bridges must establish
`Accounts(self,caller)` (160-bit addresses) and faithful invocation observations.
`LiftLegacy` requires no environment instruction on reached legacy states.
The profile preserves stack-overflow rejection and finite trace composition;
physical opcode and contract acceptance remain consumer obligations. Foundation
v1 is frozen; new helpers use fresh version directories to preserve conservative
consumer support inventories.

`v5/ProductOrder.dfy` exports natural-number product nonnegativity and
monotonicity. Its complete one-file closure verifies both lemmas; consumers
retain responsibility for deriving word bounds from their existing domains.

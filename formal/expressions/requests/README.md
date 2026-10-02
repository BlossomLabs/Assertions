# Recursive primitive request contracts

This package strengthens the existing recursive source-control proof without
changing its control statements or its exact functional refinement theorem.
The mechanical generator adds proof contracts, invariants and assertions to
the retained source lowering and checks the result. Dependency audits verify
that lowering's current production AST gate and retained native evidence.

Every request in a completed evaluation history satisfies Typed:

- Leaf requests have no child arguments and name Literal, Parameter or Resolve.
- Address requests carry the validated first referenced value of Call/ProbeCall.
- Finish requests carry every validated child in exact reference order; Call
  and ProbeCall have already passed the clean-address specification.
- Boolean requests carry exactly the success bit of IsValid.
- GuardFailure requests carry a byte-valued failed-attempt error.

Failure results remain byte-valued too, while the original canonical-cache,
extension, footprint, lazy-control and exact-result properties are preserved.
The source scalar address adapter discharges the clean-address receipt contract.
All error-byte adapters meet the generic byte-payload requirement by construction.

The theorem still takes an explicit primitive oracle satisfying Receipts.
Its complete construction from every primitive adapter is **not** discharged
here, nor are all resource budgets, Probe's bytes-decoder binding or call-frame
composition. Initial request history must belong to this same graph. This is
proof instrumentation, not a new EVM implementation or bytecode theorem; original
source test/fault evidence is reused with its original scope, and no new EVM
campaign is claimed.

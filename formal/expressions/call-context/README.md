# Guarded cache injection counterexample

The retained [counterexample](evidence/cache-injection/manifest.json) demonstrates
that `msg.sender == address(this)` is not enough to establish that a guarded
cache came from `_tryEvaluate`.

An ordinary, admitted expression uses a Call node targeting its own Expressions
contract with `evaluateGuarded` calldata. Literal nodes supply a second graph and
an arbitrary initial cache. The call has Expressions as msg.sender, passes the
self check, and returns the supplied ready value without evaluating or validating
the inner node. The oracle supplies `0xff` for an inner `uint256` node whose
literal value is 7. It verifies the exact ABI output and decodes the returned
value/cache to confirm the supplied bytes were used.

The outer Call node declares the raw return body as a fixed array of unrestricted
uint256 words, so its own canonical validation legitimately passes. This is not
a bypass of that outer value validation, nor evidence that a failed guard writes
into its parent's cache. It contradicts the stronger claim that outside users
cannot supply a guarded cache through any route. The direct caller check alone
proves only direct authorization behavior.

The source cache-transition theorems remain conditional on valid caches and
successful evaluator receipts. Do not discharge those conditions from the
self-caller check alone. Closing this indirect call path, checking compatibility,
and regenerating/reverifying affected source and deployment evidence remain an
open obligation. The full goal is not complete.

The manifest's status is `counterexample-confirmed`, not a proof of cache
isolation. It retains the exact source snapshot, test, compiler/tool hashes and
EVM output. Production code has not been changed by this reproduction.

# Guarded entry and returned cache

The full evaluateGuarded AST is gated, including NotSelf's selector/signature,
the cache wire shape, authentication before cache access, and the initial-cache
copy before evaluation. The source adapter composes the existing canonical
recursive evaluator. Foreign callers are rejected with their exact address;
self callers use explicit valid-cache, matching-descriptor and graph premises.

Successful return parameters contain bytes and Cache in a standard ABI argument
frame, without an enclosing single-tuple offset. The independent ABI model
proves that adding the canonical single-value offset yields a validating tuple
whose decoded projection is exactly the result and all four original cache
arrays. The recursive Fits predicate records representability; it is not an
unbounded allocation claim or a proof of compiler ABI bytecode.

Try constructs its successful receipt from that actual canonical attempt result,
then applies the source-proved _tryEvaluate cache transition. Success adopts the
proved extended cache; failure keeps the original cache even though the attempt
may have built partial values. Caller gas samples and exact failure bytes choose
ordinary failure versus the source exhaustion predicate. Covered retains the
attempt's primitive eligibility conditions, including caught failed work.

Valid self-frame provenance is not inferred merely from sender equality. The
separate dispatch-boundary theorem establishes the typed guard origin; its full
connection to every recursive frame and validation rejection remains open.
Source/ABI/call-transition/memory and sufficient-resource premises remain
explicit. This package does not assert a physical gas bound or complete compiled
bytecode equivalence.

Six EVM tests cover foreign authentication before invalid cache access, warm and
dynamic full-cache return tuples, validation failure, and real public guarded
success/fallback. Forge prank supplies self as caller only for direct ABI tests.
One actual Solidity fault substitutes zero for the denied caller; translation
must succeed and the semantic error postcondition and named EVM test must fail.

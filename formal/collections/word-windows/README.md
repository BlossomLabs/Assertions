# Word template windows

This package connects four complete helpers to an independent byte specification:
`_checkWindows`, `_checkElementWindows`, `_stampWindows`, `_stampElements`.

Admission checks the accumulator first, then element offsets in list order.
`ScanFacts` identifies the first bad offset. Short templates reject even an empty
element list. Source errors encode exactly the offending offset and template
length; the proof's stage/index labels are ghost metadata, not additional error
fields. Maximal uint256 offsets do not force an overflowing addition in the
actual subtract-then-compare source check.

`Patch` specifies each byte independently using the last covering write.
`Last` and `Outside` prove overlap precedence and untouched-byte preservation.
`Overwrite` shows that rewriting the same ordered windows with new values is
equivalent to applying the new writes to the pristine original template. This
supports reusing the calldata allocation across fold iterations.

The source adapter translates the actual conditions, loop guards, compiler error
selector and modular Yul addresses. It proves admitted addresses do not wrap,
updates physical finite byte memory through the retained Store semantics, and
preserves the bytes header and memory outside the payload. Duplicate offsets and
partial, unaligned overlaps are allowed. Accumulator writes happen first.

Premises include faithful Solidity bytes frame/copy/allocation, uint256 sizes and
values, sufficient execution resources, trusted source/compiler/ABI serialization
and memory interpretation, and Dafny/Boogie/Z3. Complete word callback execution,
fold/map/filter verdicts and public entry-point composition remain open.

`verify.py` snapshots inputs, checks the complete retained ABI/word-memory proof
closure, regenerates the source adapter, verifies every new declaration, audits
for proof escapes and checks formatting. Seven EVM fixtures cover error ordering,
maximal/boundary offsets, overlap, unchanged bytes and repeated writes. Three
isolated mutations (strict end comparison, shifted accumulator address and skipped
last write) must pass translation and fail both the native source proof and EVM
fixtures. No new public entry, compiled-bytecode, gas or performance claim follows.

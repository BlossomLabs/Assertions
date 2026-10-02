# Unsigned division and remainder raw entries (preparation)

The generator binds both selectors and every reached instruction byte for
four complementary paths: nonzero-divisor scalar success and zero-divisor
`Panic(0x12)` for each public operation. The intended result is natural-number
quotient or remainder. Every finite word and arbitrary trailing calldata is
admitted under the explicit raw representation and reached resource premises.

The zero-divisor paths model the compiler's overlapping MSTORE0 and MSTORE4
writes and the actual REVERT(0,36). The memory model rounds expansion to whole
words. `PanicStores` connects the two writes to independently specified panic
selector plus 32-byte error code; it is prepared but not yet native verified.

Generated files are owned by `generate.py`. The package resolves; native
verification, retained evidence and independent ledger checking remain open.
No public coverage is claimed.

Development physical preflights passed 24 scalar success, four exact panic,
and 24 empty raw rejection receipts. Each DIV/MOD one-byte mutation produced
nine wrong actual outputs. These finite fixtures do not substitute for the
open native graph, retained campaign or independent checker.

# Public claims and library proofs

`docs/claim-evidence.json` defines current claim IDs, wording and existing test or
Halmos evidence. `formal/claims.json` binds exactly that inventory and wording.
It does not copy historical coverage. Declaration indexes under
`source/declarations/` support theorem navigation, not public claim counting.

Run `python3 formal/tools/readiness.py --claim C3 --json` to inspect a claim.
`check.py` rejects missing or extra IDs and changed wording. Reconcile changed
claims by reviewing their obligations and invalidating affected mappings before
updating the recorded wording; never carry coverage forward by ID alone.

To propose a source mapping, add a `sourceProofs` entry with `coverage` (`partial`
or `full`), an explicit `obligation`, `assumptions`, `mappingReview: "pending"`,
and a nonempty `theorems` list. Each theorem binds `declaration` (canonical
`file::symbol`) and `fullSha256` (the complete parsed declaration hash).
Set `mappingStatus` to `mapped`. The checker validates the identities and hashes;
it does not decide that the theorems imply the public claim.

Mappings remain pending until independent implication review, native evidence,
production-source correspondence and required fault gates are established.
Bytecode evidence additionally needs an exact-runtime bridge and its own review.
No acceptance mechanism is implemented here yet; adding mappings never upgrades
public evidence labels. Shared foundation lemmas are dependencies of claim proofs
and do not introduce public claims.

DafnyEVM adoption preserves the exact public ledger and mapping inventory through
`migrations/dafnyevm.json`. A proved replacement equation preserves a source model's
logical meaning; it does not upgrade public evidence. Native adoption, source
correspondence, fault tests, conditional helper execution and deployed/runtime
correctness remain separate evidence types.

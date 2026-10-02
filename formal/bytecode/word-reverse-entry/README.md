# reverseWords retained exact-bytecode package preparation

The root proof is ../word-reverse/entry/Root.dfy. This runner retains its
complete include graph, exact native inventories, zero audit, canonical solc
runtime reproduction, 66 complete EVM instruction/memory receipts, and three
semantic single-byte faults. Those faults preserve the independent reversed-byte,
ABI head and successful return oracles; generation rejection or solver timeout
never counts as detection.

Every package file and included input must be finished before the retained
snapshot. Live runs keep all inputs frozen and must never be restarted for an
observation timeout. Development proofs and fixtures add no public coverage.
Only after retained evidence and the independent checker pass may a ledger and
coverage update count reverseWords. Representation, interpretation, scanning,
observations and reached resource assumptions are explicit in proof-spec.json.
No gas, deployment, performance or whole-contract claim.

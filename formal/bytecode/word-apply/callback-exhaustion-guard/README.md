# Callback exhaustion guard

The actual helper starts at16107, calls the checked division helper at23562,
observes GAS at16136, then refuses when gasAfter<=gasBefore/63 or an exact
four-byte receipt equals0xd271060e. A longer receipt with that prefix passes
the signal test. The guard selects the local packet at16171 or returns to17017
for ordinary CallbackFailed construction.

`inspect-paths.py` inventories six preserved physical map/filter failure,
exact signal and longer signal-prefix paths. It checks their branch verdicts,
instruction bytes, final error family and all input hashes. This reuses existing
EVM traces; it neither runs a new EVM nor establishes a native theorem. Low-gas
geometries, exact ordinary4-byte/empty failures and nonzero trailing memory
still need retained physical coverage. GAS observations are conditional inputs;
instruction counts are not gas-cost measurements.

Full native control extraction/observation binding, dynamic CallbackFailed
serialization, raw first-failure composition and fresh included retention
remain open. No public bytecode coverage or deployment guarantee is claimed.

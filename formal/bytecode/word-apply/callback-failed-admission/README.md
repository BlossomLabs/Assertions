# Actual receipt to CallbackFailed serializer admission

The checked admission derives both represented dynamic source windows from the actual packed callback/full receipt memory: original stamped calldata remains below the allocation, while empty reasons use the zero-slot96 header and nonempty reasons use the exact allocated returndata copy. The current free-pointer word and finite aligned memory are derived from the actual receipt helpers. The final combined serialization footprint is an explicit resource premise; it makes no gas-cost/sufficiency or deployment claim.

This memory admission alone proves no public/raw branch. Full compiled packet/guard/caller/raw connections and fresh included/physical/semantic/independent retention remain mandatory for coverage.

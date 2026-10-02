# Exact compiled Newton update controls

The generator binds all six actual square-root Newton update paths to current runtime instruction boundaries, immediates and jump destinations. Each path retains every actual instruction and a complete step trace, including the first update's extra stack item and the preserved caller prefix. The prefix's original input is the value reached by the actual DUP operation.

The unsigned machine result includes actual word reduction. `SemanticResult` connects it to the independent unbounded integer Newton update when the caller supplies the no-wrap premise. The separate checked mathematical and word kernels establish fitting bounds; complete public composition must use those bounds rather than assume the final root.

This is development evidence only. Public raw admission, initial scaling, six-stage composition, final correction, physical receipt, retained semantic mutation and independent checking remain required. Representation, reviewed interpreter/extraction and adequate reached resources are explicit. There is no gas, deployment, performance or cryptographic claim.

Generate through `generate.py`, then format with `format-generated.py`. Never edit generated files. `verify-development.py` snapshots the complete 17-module dependency graph and every owner/tool/compiler input, regenerates files and checks every owned declaration with exact-file filters. The complete native graph is queued after the checked seed connection; retain its manifest for the actual terminal outcome.

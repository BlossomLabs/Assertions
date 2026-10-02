# Fold physical stamp invocation development

The owned generator extracts every reached current-runtime instruction from16512 to19449, after domain selection and before `_stampWindows`. It retains both actual accumulator-offset/value MLOADs at224/256, the complete caller stack and the actual16536 return address. No memory write occurs in this slice. `Invoke.generated.dfy` and its mapping are generated only by `generate.py`; never edit them directly.

Complete owner files must precede capture. `development-run.py` freezes its complete included and owner input graph, regenerates and compares byte-identically, then verifies every selected declaration and native assertion, audits and rechecks all inputs/tools. Imported contracts remain assumed in selected development checks.

Representation and sufficient reached resources remain explicit. No source, fixture or selected proof alone earns public bytecode coverage; whole raw iteration, stamping, callbacks, guards, errors, early exit, scalar terminal, retained native graph, physical replay, semantic mutations and independent checking remain required. No gas, deployment, performance or compiler-correctness claim.

V2 explicitly requires allocated FoldRun memory geometry:320 bytes present and32-byte alignment. This makes each actual run-field MLOAD expansion a no-op. The original failed invocation proof remains preserved; its two errors concerned unchanged memory after reads224/256, not a contract counterexample. Only the owned generator changes these proof admissions and module names; statements retain the complete physical instruction trace.

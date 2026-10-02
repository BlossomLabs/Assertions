# Shared map/filter raw decoder development

The owner `generate.py` gates the exact Collections runtime hash and both compiler-bound selectors, then emits every reached opcode of nine later raw decoder rejection paths and the successful 286-step shared decoder path. Concrete values select paths for extraction only; generated theorems quantify over every fitting calldata value in their ordered admission class. The five earlier source-head/tail rejection classes remain in `../raw-source-rejections`.

Admission permits loose, misaligned, overlapping and shared tails and dirty bytes outside the selected fields. It requires the compiler's actual 64-bit head/count/length limits and all checked spans, with no canonical ABI encoding premise. Accepted return PCs are the two actual wrappers, 784 and 1050. The decoder returns source offset/length, canonical target, template offset/length and offsets-array offset/count while preserving arbitrary memory and the lower stack prefix. The accepted count is below 2^59 as a consequence of its checked 32-byte span, not an extra admission restriction.

`Inputs.dfy` owns the ordered field predicates. `Scalar.dfy` explicitly connects the compiler's actual AND operand order to canonical address admission. The array-stride module connects actual SHL5 to count*32 for every admitted uint64 count. Supporting leaf contracts must be verified as part of the eventual complete retained include graph; a selected development run alone does not establish that graph.

Generate only through the owner:

```sh
python3 -B formal/bytecode/word-apply/raw-decoder/generate.py --output formal/bytecode/word-apply/raw-decoder
```

Finish all package files before snapshotting development runs. `development-run.py` records commands, snapshots, native CSV inventories and unchanged hashes using the normal 30-second obligation limit and two cores. Never modify owners or includes during a live run. Physical complete-entry observations are separately under `../observations`. The application body, external-observation/resource connections, public retained verifier, mutation campaign and public bytecode coverage remain open.

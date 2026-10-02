# Complete constant getter bytecode

This package proves reached-instruction properties for Assertions.LEN() and
Assertions.PAYLOAD(). Public-bytecode completion requires a passed retained
`verify.py` manifest, not development logs. The whole-contract bytecode goal
remains open even after these two entries pass.

`generate.py` reads the exact full current Assertions runtime and its frozen
compiler selector inventory. It follows each getter from PC zero to RETURN,
including the dispatcher, actual constant construction, signed-add helper guards,
stack rearrangements, physical big-endian memory stores/loads and returned bytes.
Every taken jump is checked against the full runtime instruction boundaries.
Each emitted byte certificate constrains every reached opcode/immediate and jump
destination byte. The theorem admits arbitrary values of all other runtime bytes;
the EVM interpretation still requires the declared jump destinations to be actual
instruction boundaries, checked by scanning the pinned full runtime. This is not
a claim that arbitrary changes to unused bytes preserve jump validity. A runtime hash
binds the certificate's extraction to the canonical artifact. This trusted
extraction/scanning boundary does not assert compiler or serializer correctness.
Generated files must only change by rerunning the generator.

The admitted environment is call value zero, calldata size at least four, and a
loaded first word whose high four bytes equal the selected getter selector.
Calldata size and the lower 28 word bytes remain arbitrary. Nonzero call value,
short input and unknown selector rejection belong to the separate dispatcher
package. The generator chooses the admitted concrete path, but a native lemma
for every reached instruction must prove that choice valid for the entire
admitted symbolic environment. The composition executes the entire certified path
as a finite sequence of actual `Step` calls; no input path is dropped at an execution
cut-off. `Step`, `Matches` and reachable-state predicates stay opaque in composition
and are revealed only inside individual instruction lemmas. This preserves the
instruction semantics while avoiding redundant whole-path case splitting.

`Machine.dfy` models the reached EVM instructions and a byte-sequence memory,
initially empty/zero, expanded by actual MSTORE/MLOAD/RETURN. Reached expansions
are at aligned offsets, and the proofs bound memory by 160 bytes and stack by the
derived complete-path maximum (LEN five words, PAYLOAD eleven). Word serialization round trips and disjoint store frames are
proved separately. Adequate reached execution resources, fresh call memory,
truthful environment opcodes, the reviewed EVM opcode interpretation and trusted
Dafny/Boogie/Z3 remain explicit. No compiler/allocator/outer-serializer projection
is substituted for executed bytecode behavior.

Before completion, require native coverage of every declaration, zero audit,
current exact runtime identity and hashes, full EVM return/memory fixtures and a
semantic bytecode mutation campaign against frozen expected constants. A timeout
or translation error does not detect a mutation. Development failures and their
exact inputs must be preserved. Do not edit frozen inputs or restart a live run
just because polling times out.

`verify.py` snapshots the finished package, canonical compiler jobs/artifacts and
current project/library inputs. It independently reproduces all three full current
runtimes, regenerates both certificates, inventories every native declaration and
checks proof/audit/format results. Its twelve full-call EDR fixtures retain memory
and stack traces. Mutations reduce LEN's shift by one bit and change PAYLOAD's
increment to two; each must translate and fail a baseline-covered exact-return
postcondition and an actual EVM return check. Source, proof-tool and concrete-tool
hashes are checked again at completion. No retained inputs may change afterwards.

No gas, deployment, performance, complexity, unconditional resource safety or
whole-contract semantic claim follows from this package.

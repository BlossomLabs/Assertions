# DafnyEVM reuse assessment

Inspected upstream commit `e2e52e86d6623d48d0849f5ce1664f88c8f0e547`.
The retained source inventory checks selected files against the pinned Git tree;
upstream verification was not rerun. Apache-2.0 attribution is retained in ports.

The highest-value reusable work is [memory expansion and framing](https://github.com/Consensys-Incorporated/evm-dafny/blob/e2e52e86d6623d48d0849f5ce1664f88c8f0e547/src/dafny/core/memory.dfy)
and [generic copying](https://github.com/Consensys-Incorporated/evm-dafny/blob/e2e52e86d6623d48d0849f5ce1664f88c8f0e547/src/dafny/util/arrays.dfy).
Selective ports avoid importing Int and its external crypto/math dependency.
The local bridge and all imported local dependencies have fresh or exact-identity
retained complete native evidence: memory/copy 90 batches across seven files;
word arithmetic/totals 39 batches across three files (the Getter dependency is
shared between these totals). All are passed with zero audit findings.

| Consumer | Reuse now / bridge next | Contract-specific obligations remain |
| --- | --- | --- |
| Assertions primitives | Selected-window copy, store/copy frames, fixed word encoding | Lazy selection and trace composition |
| Assertions resolution | Error-packet framing, record heap preservation, decoder subspans | Wire verdicts, OR/resolver composition |
| Collections | Copy/zero-fill/overlap frames, seq<int> prefix sum bounds; prove child-span projection | Recursive descriptor grammar and traversal |
| Operations | Code/slice copying and fixed words/overflow; bridge its independent machine datatype | Signed arithmetic, specialist math and entry composition |
| Expressions | Store-chain byte/span frames and preserved word reads; composite Context allocator bridge next | Graph cache, lazy evaluation and call context |
| Coordinator | Navigation, ABI serialization, allocation/error packets and shared parser arithmetic | Recursive child construction and public integration |

Expansion conventions differ: upstream Expand takes an inclusive address, while
our Expand takes an exclusive extent. The verified correspondence requires a
positive extent and an already word-aligned memory length. Zero extent has a
separate lemma. Unaligned memory `[7]` provides a proved counterexample to an
unconditional bridge. Existing local machine definitions remain intact.
Snapshot overlap and zero-padding are modeled by the copy adapters; instruction
semantics still require lane-specific machine bridges and boundary conditions.
The fixed-width word round trip uses the existing local Getter proof rather than
claiming that variable-length natural encoding is an ABI word encoding.

Trust exclusions: the retained inventory records 33 flagged source lines.
Int contains an explicit bitvector conversion axiom and disabled reverse encoding;
AND/XOR, quadratic gas and monotonicity, MODEXP, fork facts and transition helpers
have disabled verification. OverflowCheck, Loopy, increment, optimization and
simulation examples also contain disabled proofs or assumptions. Memory/Arrays
import Int, which imports external submodule math/option: a wholesale import
needs a separate complete dependency audit. AddOverflowNSC was selectively
adapted without importing its surrounding example file. No disabled or axiomatic
upstream theorem has been accepted into this foundation.

No interpreter migration is planned. This foundation supplies reusable lemmas,
not contract parser/resolver/cache correctness or additional exact-bytecode credit.
Workers must use immutable published interfaces in future proof versions and
verify their representation bridges and complete consumer dependency closures.

# Operations exact-bytecode verification

Current independently checked coverage is **55/92 public entries**, across twenty-two retained packages. The other 37 remain open. The separate conditional source track covers 92/92; it does not establish opcode correspondence. Both owner and parent independent checks passed each counted package against the current canonical compiler job, runtime, full native/declaration graph, snapshots and evidence/tool hashes, regeneration, fresh physical replay and matching semantic instruction faults.

`identity.py` reproduces the current canonical runtime using its exact pinned compiler job without modifying artifacts. `inventory.py` binds all 92 public signatures/selectors to actual dispatcher JUMPDESTs and scans runtime instruction boundaries. Inventory is not semantic verification.

| Checked retained package | Public entries | Native obligations | Declarations |
| --- | ---: | ---: | ---: |
| [absolute-difference](../../../docs/verification/operations-absolute-difference-bytecode.json) | 2 | 29,415 | 903 |
| [account-environment](../../../docs/verification/operations-account-environment-bytecode.json) | 2 | 25,460 | 809 |
| [address-environment](../../../docs/verification/operations-address-environment-bytecode.json) | 2 | 8,150 | 320 |
| [byte-at](../../../docs/verification/operations-byte-at-bytecode.json) | 1 | 64,424 | 1,507 |
| [byte-length](../../../docs/verification/operations-byte-length-bytecode.json) | 1 | 28,217 | 828 |
| [bitwise](../../../docs/verification/operations-bitwise-bytecode.json) | 3 | 22,540 | 743 |
| [comparison](../../../docs/verification/operations-comparison-bytecode.json) | 10 | 70,550 | 2,192 |
| [environment](../../../docs/verification/operations-environment-bytecode.json) | 8 | 21,422 | 726 |
| [hash-bytes](../../../docs/verification/operations-hash-bytes-bytecode-v4.json) | 1 | 52,635 | 961 |
| [hash-pair-sorted](../../../docs/verification/operations-hash-pair-sorted-bytecode.json) | 1 | 18,553 | 549 |
| [indexed-environment](../../../docs/verification/operations-indexed-environment-bytecode.json) | 2 | 14,248 | 486 |
| [log2](../../../docs/verification/operations-log2-bytecode.json) | 1 | 16,771 | 575 |
| [minmax](../../../docs/verification/operations-minmax-bytecode.json) | 4 | 50,587 | 1,540 |
| [shifts](../../../docs/verification/operations-shifts-bytecode.json) | 4 | 28,453 | 928 |
| [signed-arithmetic](../../../docs/verification/operations-signed-arithmetic-bytecode.json) | 2 | 31,066 | 959 |
| [signed-multiply](../../../docs/verification/operations-signed-multiply-bytecode.json) | 1 | 22,489 | 724 |
| [signed-division](../../../docs/verification/operations-signed-division-bytecode.json) | 2 | 30,667 | 958 |
| [sqrt](../../../docs/verification/operations-sqrt-bytecode-v3.json) | 1 | 102,879 | 944 |
| [unsigned-arithmetic](../../../docs/verification/operations-unsigned-arithmetic-bytecode.json) | 2 | 26,740 | 866 |
| [unsigned-division](../../../docs/verification/operations-unsigned-division-bytecode.json) | 2 | 26,658 | 853 |
| [unsigned-modular](../../../docs/verification/operations-unsigned-modular-bytecode.json) | 2 | 25,627 | 822 |
| [unsigned-multiply](../../../docs/verification/operations-unsigned-multiply-bytecode.json) | 1 | 14,318 | 497 |

Hash(bytes) is independently checked: 52,635 native obligations, 961 declarations, 67 zero audits, 22 mathematical hash returns, 16 raw rejections and one matching native/physical SHA3-to-ADD semantic fault. A fresh parent checker on 2026-10-02 reproduced compiler identity, generated graphs, physical baseline and semantic fault. Coverage counts the exact distinct signature union, never obligation or fixture counts.

The explicit user instruction on 2026-10-02 resumed native work after the previous scheduling hold. Existing incomplete runs remain preserved. Sqrt has a fresh complete 46-module retained verification at `sqrt-retention-v3/evidence/raw-entry-resume-v1`; ByteAt's 65-module retained package and both independent checkers passed: 64,424 native obligations, 1,507 declarations, 65 zero audits, 28 exact returns, 36 exact index errors and 16 raw rejections. Its matching native/physical MCOPY-to-CALLDATACOPY control passed. The isolated checker correction and both logs are retained in `docs/verification/operations-byte-at-independent-v1`; all frozen proof inputs remain unchanged. Sqrt passed all 46 owners and both independent checks: 102,879 native obligations, 944 declarations, 46 zero audits, 158 exact returns, nine raw rejections and one matching native/physical semantic fault. Its independent checker path bindings, checked ledger and both logs are retained in `docs/verification/operations-sqrt-independent-v3`. Signed modular V4 has an isolated terminal RETURN timeout in AddModSCase7.Advance287; a separate value/serialization proof repair is being checked without modifying frozen V4 inputs. These active development and retention runs add no public entries.

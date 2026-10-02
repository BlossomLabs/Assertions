# Raw sumWords bytes decoder — development

The generated paths cover five mutually exhaustive malformed-frame classes for
calldata sizes from four through 2^64-1: incomplete argument head, offset above
the compiler's 64-bit limit, incomplete length word, length above that limit,
and payload extending beyond calldata. Each path starts at the actual sumWords
wrapper PC 585 and ends at physical empty REVERT, preserving the input memory.
`Admission.dfy` proves the partition and equivalence of its Accepted class with
the parent decoder's named admission. `Connection.dfy` composes actual PC-zero
routing, each rejection path or the checked body/return/error path.

Everything here is development. All five path jobs passed 9,459 obligations with
unchanged inputs. Partition and full raw entry composition passed their component
checks. The first complete parent closure had five selector-shift timeouts and zero
audit findings; its failed evidence remains preserved. The same shift is now
isolated in a proved definition, with both physical error paths passing.
Authoritative snapshots, logs and input hashes are under:
- `development/rejections-v1/manifest.json` (all five raw paths).
- `development/admission-v1/manifest.json` (36 native obligations).
- `development/connection-v1/manifest.json` (67 native obligations).
- Parent `development/accepted-sum-closure-v1/manifest.json` (failed complete graph).
- Parent `development/errors-v7/manifest.json` (3,122 passed obligations).

`evm-traces.mjs` passed ten complete physical rejection fixtures, including
single-byte head/length/tail boundaries and full-width offset/length overflow.
The current results are in `/tmp/bytecode-scan-raw-evm-v1`; retain them with source,
tool and artifact hashes before any public evidence claim.

Next: retain a fresh whole raw Connection include graph,
audit and dependency/native/regeneration inventory. Extend the retained verifier
and semantic bytecode fault campaign, preserving independent expected results.
No ledger or public coverage update is allowed from these development runs.
Representation remains explicitly restricted to fitting 64-bit calldata sizes;
reviewed reached EVM interpretation/instruction scanning, faithful observations,
fresh memory and sufficient reached resources remain premises. No gas, deployment,
performance, source-to-whole-bytecode or unconditional resource-safety claim.

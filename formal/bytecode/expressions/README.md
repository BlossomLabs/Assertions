# Expressions exact-bytecode workspace

The three public entries are `evaluate`, `evaluateEncoded`, and
`evaluateGuarded`. No completed exact-bytecode public-entry credit is claimed.
The retained source-correspondence packages prove conditional composition under
explicit ABI, memory, call-context and resource premises; they are separate from
physical runtime closure.

`inventory-20261002-v2.json` audits all 29 source-connection ledgers. Their retained
manifests say passed and their native tool and retained evidence hashes match.
Every manifest has current input drift, principally consolidated runner/common
script changes; several AST/validation JSON files have formatting drift but are JSON-equivalent to their retained snapshots. The production
Expressions source remains identical to the retained source identity. These
historical manifests must not be promoted to current-input passes by editing
receipts. Regenerate the inventory with
`proof-workspace/work/expressions/inventory-current.py` into a fresh file.

`identity-20261002/identity.json` reproduces the complete current canonical
Expressions runtime, including metadata, from current solc inputs. Its SHA-256
is `1085082ba1e19b0967431c8b7b0a79ce4f60b8df851b91b6e6194324b3feade7`.
Identity alone is no semantic proof. The fresh compiler functionDebugData
preparation locates `_address` at PC 5440.

The first physical class is `_address` with `length != 32`.
`generate-address.py` extracts all 39 actual reached instructions, including the
physical `InvalidNode(index)` writes and shared REVERT. `AddressConnection.dfy`
compares their result to an independent selector-plus-word ABI specification.
The frame requires a rounded nonwrapping bytes object, valid stack and return
label, physical free-memory pointer and sufficient reached resources. There is
no physical gas theorem or unconditional resource guarantee.

`evm-address-traces.mjs` checks exact returned bytes and every reached PC,
complete operand stack and whole reached memory against the generated mapping.
Four canonical tuple/array target fixtures enter the length rejection through
the public evaluator on a real EVM. Three physical semantic faults change the
selector, index operand and error extent; each must regenerate, fail the named
native `RejectLength` theorem and fail the independent EVM error expectation
while its own generated mapping still faithfully replays all physical states.

`verify-address.py` snapshots the full include closure, reproduces the runtime,
regenerates sources, checks every native declaration, audits, formats, runs full
physical fixtures and checks matching faults. Only a passed fresh manifest plus
independent coordinator review establishes completed physical-class evidence.
Development CSVs/logs and preparations are retained diagnostics, not accepted
closure receipts.

```sh
source proof-env.sh
python3 -B formal/bytecode/expressions/verify-address.py \
  --dafny "$DAFNY" --solc "$SOLC" --node /usr/local/bin/node \
  --output /fresh/expressions-address-length
```

Remaining obligations retain the full objective: all admitted recursive
node/cache paths, exact decoder/validator/memory/allocator bodies, resolver and
static/self-call context, guarded adoption/rollback/resource propagation,
physical returns/errors and complete composition of all three public entries.
Shared resolver, ABI and dispatcher dependencies are coordinator-owned.

The complete `_address` helper is now independently accepted at
`evidence/whole-address-20261002-v2/manifest.json`; coordinator review lives at
`proof-workspace/work/coordinator-continuation-20261002-v12/address-independent-v2/whole-address-review.json`.
The closure has 754 declarations and 22,850 distinct native batches (22,897
retained records, including repeated identical dependency facts). It covers the
39-instruction length rejection, 169-instruction dirty-word rejection and
274-instruction clean return, including every default Context allocation,
span-check and word-load instruction. Five public evaluator fixtures replay
complete stacks and byte memory; three regenerated runtime faults fail native
semantic postconditions and independent physical expectations while their own
mappings replay faithfully. Public-entry credit remains zero.

`complete-development-20261002-v8a/ConnectionV2.dfy` independently specifies each
of the six Context stores and links each generated memory stage through a small
native lemma. Opaque functions bound solver contexts; their defining equations
are proved, not assumed. Earlier timeouts and the failed detached-regeneration
candidate remain immutable diagnostics. `retain-whole-address.py` checks all
current native receipts, complete identical dependency inventories and hashes,
canonical runtime reproduction, exact regeneration within its full relative
include graph, audit, format, full physical fixtures and matching faults.

The next guard preparation is `public-call-preparation-20261002/instructions.json`
for `_checkPublicCall` at PC6375. Its ADDRESS opcode requires the coordinator's
additive environment profile; the accepted Scan.Step/State/Fetch identities must
remain unchanged. Shared environment and trace bridges are prerequisites for
physical guard credit. New Context reuse must bridge the exact allocation writes
to the published shared frame library before replacing accepted consumers.

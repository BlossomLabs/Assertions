# Public-function proof library

Each public Solidity signature has an entry in [catalog.json](catalog.json). A function receives bytecode coverage only when its public-entry theorem and its complete imported closure verify against the pinned production runtime. Shared lemmas, concrete executions and existing source evidence are reported separately.

The first obligations are the two `Operations.add` overloads, under [contracts/Operations/add](contracts/Operations/add). The unsigned public-entry theorem has passed a focused native check; its complete closure and independent acceptance remain pending. The signed theorem is incomplete. Addition is partial coverage of claim O1; subtraction and multiplication remain pending. The catalog contains all 141 public signatures. [claims.json](claims.json) freezes the 326 existing claim identities and wording, and binds the unchanged public evidence ledger.

Generic machine proofs live in the maintained [BlossomLabs interpreter fork](https://github.com/BlossomLabs/evm-dafny/pull/1). The dependency lock records its published revision, original upstream provenance, complete installation hashes and accepted clean-core closure. DafnyCrypto stays pinned to its latest upstream revision. Optional crypto adapters and legacy example proof debt are excluded from the clean closure.

Runtime literals, compiler outputs, installed tools and verification receipts are generated artifacts. Earlier proof campaigns and their receipts remain in their original branches and workspaces. They are provenance, not dependencies of this alternative.

## Scope

The addition obligations start at PC 0, with the complete Operations production runtime, canonical 68-byte calldata, empty stack and memory, call value zero, an arbitrary injected backend, and sufficient gas. They relate actual bounded interpreter execution to independent unbounded integer and ABI equations. Constructor execution, malformed calldata, nonzero call value and insufficient gas are outside the initial scope.

Use Dafny 4.11.0 and Z3 4.12.1, two cores and a 30-second limit per isolated obligation. Failures and timeouts remain failures. Generated facts and partial block proofs supply no completed public-function credit.

## Development

Run `python3 formal/tools/bootstrap.py --fetch` on a clean checkout. Bootstrap stages the published fork and its pinned crypto dependency, validates every bound source hash and publishes the installation atomically. It refuses modified or incomplete installations.

Capture the exact Hardhat production artifacts with `python3 formal/tools/capture.py`, then generate PUSH-aware runtime boundary obligations with `python3 formal/tools/runtime_facts.py`. These commands require the production artifacts from the pinned compiler configuration. Capture checks the full runtime, including metadata, and the compiler/source bindings. Generated Dafny facts still require native verification.

The unified command interface provides integrity, signature-selected verification, independent review and catalog status reporting. Its negative tests pass; real public-entry acceptance remains pending. Direct development runs are diagnostic evidence only. Neither public-entry addition theorem is accepted yet. The unsigned focused pass supplies no complete-closure credit.

```sh
python3 formal/tools/verify.py --check
python3 formal/tools/verify.py --status
python3 formal/tools/verify.py --signature 'Operations.add(uint256,uint256)' --output formal/.generated/native --run
python3 formal/tools/verify.py --review formal/.generated/native --output formal/.generated/review
python3 formal/tools/verify.py --fault formal/.generated/native --review-evidence formal/.generated/review --output formal/.generated/faults
```

Native verification partitions the complete imported closure into bounded processes, with the same isolated-obligation policy. Review reconstructs the complete partition schedule, regenerates runtime constants from bound bytes, reproduces solc output, and reruns every native partition. Missing partitions, missing correctness results, changed theorem premises and stale producer/source bindings fail review.

Native fault checks require a verified, independently reviewed baseline. They regenerate runtime constants and byte bindings for isolated arithmetic, overflow-branch and return-length mutations, retain the unchanged specifications and proof sources, and require native correctness failures. Timeouts, parsing failures and an already failing baseline supply no mutation credit. These native checks remain pending until the public-entry proofs pass.

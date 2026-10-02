# History-scoped traversal environments

This package proves the abstract composition mechanism needed to turn concrete
per-iteration receipts into a single traversal environment. It introduces no new
Solidity or bytecode correspondence by itself.

`Splice(earlier,later,cut)` uses the earlier environment for queries strictly
before the history-length cut and the later environment at or after it. Every
traversal `Ask` appends exactly one request. Thus subsequent admission/iteration
queries cannot revisit an earlier history length, even when environment state
tokens change arbitrarily.

`StepReplay` and `AdmissionReplay` require observation agreement only over the
actual reached history window. They preserve both reply and state, including
failure at the first, second or third request. They do not require agreement on
requests that are skipped after failure. `TailReplay` extends this equality
inductively over arbitrary finite remaining input sequences.

`JoinStep` composes one local iteration with its future tail without replacing any
of the iteration's observations. `JoinAdmission` does the same for admission and
the loop. A local failure remains the complete failure; future observations are
never reached. Successful iteration results are combined with the tail using the
reference's `Prepend`, which discards earlier map outputs when the tail fails.

A `Row` records its start context, incoming accumulator, local environment and
outcome. `Chain` requires exact Step correspondence and exact context/accumulator
threading; it ends at the first failure or at the end of the input. `Assemble`
constructs one environment for an arbitrary finite row chain. It proves that the
whole Tail returns exactly the collected row outcome and that every row's reached
history window retains all its original observations. The empty-chain fallback is
not observed. A row chain may contain failures; no successful-helper assumption
is needed.

The concrete iteration package can supply these rows, but constructing the entire
concrete chain with source preparation and its resource premises, then applying
the public source-loop correspondence, remains work for the next layer. These
lemmas do not establish that arbitrary supplied rows are concrete source receipts.
Dafny/Boogie/Z3 and the abstract traversal definitions remain trusted. No EVM,
source-fault, exact-bytecode, deployment or performance result is claimed.

The retained driver checks the identical ABI arithmetic and abstract traversal dependencies, native
coverage for every local lemma/method, formatting and a zero-finding audit.

```sh
PATH=/home/sem/.foundry/bin:$PATH python3 formal/collections/environment/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/environment/evidence/history-scoped-assembly-v2
```

The first retained attempt (`history-scoped-assembly`) stopped before local proof
execution because its dependency list omitted the ABI arithmetic provenance for
Frames.dfy. It remains incomplete and is not counted as evidence. The corrected
`history-scoped-assembly-v2` run is the candidate baseline.

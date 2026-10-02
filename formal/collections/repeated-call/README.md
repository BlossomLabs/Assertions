# Repeated source callback attempts

This package composes the completed concrete `_callValue` proof across arbitrary
finite sequences of caller-supplied operand/context steps. It connects persistent
prepared state, first-failure stopping and target-cache reuse to the actual source
helper, rather than assuming successful helper observations.

`Run` constructs one record per attempted step. Each record carries the incoming
prepared state and complete event history, the environment instantiated with
actual component receipts/concrete encoders, and the source call outcome. `Chain`
requires the next attempt to use exactly the preceding outcome's prepared state
and history. `At` exposes this correspondence for every reached step index,
including the exact operation/index/other context chosen by the caller.

Every record except possibly the last succeeds. Failure stops the sequence at
that record; a sequence with no failure attempts every step. Successful callbacks
leave canonical arguments and a checked target flag. The layout stays fixed.
An initially unchecked nonempty sequence checks the target once, while a cached
or empty sequence adds no target checks. This holds even if the external code
observation would change on a later history. At most one external call occurs per
attempt; a wholly successful sequence makes exactly one per step. History is
preserved as a prefix throughout.

The overwrite lemma proves that binding a new step replaces all substitution
slots, so resource bounds on final argument packets survive previous argument
updates. `Room` checks representable context/operand/packet sizes, component
widths and CursorRoom for every proposed step. It does not assume those operands
are canonical: their actual source validation may fail. Bounds can include
unreached steps. Code existence and external call/gas outcomes remain faithful
functions of the accumulated history, target and calldata.

The entry point assumes an accepted tuple and canonical constants outside the
replacement slots. Raw preparation is proved separately. The steps are supplied
by the caller: this package does not choose traversal operands, feed callback
returns back as fold accumulators, apply map/fold result validation, or interpret
predicate results. Those policy/validation connections and the complete public
traversal entry points remain open, as do outer error-packet bounds. Source
translation, compiler ABI, context/offset projections, physical memory/resources
and Dafny/Boogie/Z3 remain trusted.

The retained proof-only driver checks identical dependency sources, tools,
artifacts and native evidence, local declaration coverage, formatting and a
zero-finding audit. There is no new EVM fixture, mutation campaign, exact-bytecode,
deployment or performance claim.

```sh
PATH=/home/sem/.foundry/bin:$PATH python3 formal/collections/repeated-call/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/repeated-call/evidence/repeated-source-callbacks
```

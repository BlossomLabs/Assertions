# Assertions primitive body certificates

These certificates follow the exact canonical Assertions runtime through real body
instructions. They cover 35 helper-bounded paths: condition preparation and lazy
selection, raw-return serialization, resolve/pick/read/chain setup, gather allocation
and element preparation/store/exit, and orElse/isValid result and fallback routing.
The gather allocation theorem composes the physical header stores and an arbitrary
number of initialization iterations using a decreasing count invariant. It imposes
no fixture count bound.

`GuardSpec.dfy` states independent boolean, raw-byte return, operand-index, array-slot,
and error-byte specifications. `GatherAllocation.dfy` states the independent physical
array header/pointer image. `ExternalLift.dfy` preserves EVM observation history and
returndata across scan-only traces in the Assertions external-frame machine. Return
labels are checked against full-runtime instruction boundaries, including the caller
return label; a byte that happens to equal JUMPDEST inside PUSH data is insufficient.

This package proves **body segments and allocation only**. It does not claim public
entry completion. Actual calldata decoders, operand resolution, staticcall/self-call
encoding and execution, constraint/gas rejection, read concatenation, chain iteration,
gather resolution and its bytes[] public-return serializer still require native
composition. The 28 complete EVM fixtures and three semantic mutation receipts are
concrete validation. The mathematical initializer proof does not infer arbitrary
behavior from those fixtures.

The reviewed instruction models, exact artifact/compiler identity, finite physical
memory, represented input frame, truthful EVM observations, adequate execution
resources, and pinned Dafny/Boogie/Z3 toolchain remain explicit premises. No total gas
availability or whole-contract claim is made. Collections, Operations and Expressions
are excluded from the formal include closure.

Run the complete include closure against a fresh immutable snapshot:

```sh
python3 -B formal/bytecode/assertions-primitives-control/verify.py \
  --dafny /home/sem/assertions-tools/dafny/dafny \
  --solc /home/sem/assertions-tools/solc-0.8.36 \
  --node /home/sem/assertions-tools/node-v24.14.0-linux-x64/bin/node \
  --jobs 2 --output formal/bytecode/assertions-primitives-control/evidence/20261002-v1
```

Each module is checked natively, including every generated instruction lemma and its
trace assembly. The ledger requires native declaration/obligation coverage, generation
identity, audit, formatting, full EVM receipts, semantic mutation failures, and stable
input/tool hashes. Failed or unfinished checks remain retained and fail the ledger.

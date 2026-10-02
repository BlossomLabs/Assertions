# Signed modular arithmetic: O13 and O14

`SignedMod.dfy` proves the signed `addMod` and `mulMod` source-correspondence
model for **every** triple of `int256` inputs. Addition and multiplication in
the specification use unbounded mathematical integers. The modulus may be
negative or `int256.min`; zero modulus returns the modeled `Panic(0x12)`.

This is **not a formal Solidity-to-model translation or a compiled-bytecode
proof**. The four modeled function bodies are manually related to the source.
Full-width differential tests separately exercise the compiled implementation.
Neither matching hashes nor passing tests closes that formal correspondence gap.

## Specification and proof obligations

For nonzero `m`, let `d = abs(m)` and let `q` be `n / d` truncated toward zero.
The result is `n - d*q`, with `n = a+b` or `a*b`. Division/remainder in the proof
language are not implicitly assumed to use Solidity's signed convention.

| Lemma | Obligation |
|---|---|
| `WordIdentity` | Signed decoding after 256-bit wrapping preserves every int256 value. |
| `MagnitudeCorrect` | The actual unchecked `-(v+1)`/cast/`+1` sequence equals mathematical absolute value, including `int256.min`. |
| `SignedMagnitudeCorrect` | The actual cast/unchecked-negation sequence returns the requested sign or modeled Panic(0x11) at the exact representability boundary. |
| `RemainderRule` | Truncating division gives a remainder with the numerator's sign and magnitude below the positive divisor. |
| `RestoreRemainder` | Remainder magnitude below `abs(m) <= 2^255` makes signed restoration safe. |
| `AddCorrect` | Equal-sign addition and both opposite-sign subtraction branches equal the independent specification. |
| `MulCorrect` | Magnitude multiplication and XOR sign restoration equal the independent specification. |
| `CompleteOutcomes` | Zero modulus always produces Panic(0x12); every nonzero modulus succeeds with an int256 result. |
| `ProductDoesNotWrap` | A direct full-width witness detects reducing the product to 256 bits before taking the remainder. It calls no other lemmas. |
| `FullWidthWitnesses` | Fixed extreme operands exercise addition overflow, multiplication overflow, mixed signs, minimum modulus and zero modulus. |

No `assume`, unproved axiom, disabled verification, loop bound, gas exclusion,
or narrowed arithmetic input range is used. `MulCorrect` splits sign cases and
isolates assertion batches to control nonlinear solver work. The 30-second
limit applies to each batch; timeouts cannot be recorded as proofs.

## Connection to the implementation

The model follows these four functions in `contracts/Operations.sol`:

- `_magnitude` -> `MagnitudeImpl`
- `_signedMagnitude` -> `SignedMagnitudeImpl`
- signed `addMod` -> `AddImpl`
- signed `mulMod` -> `MulImpl`

Unchecked signed/unsigned casts and arithmetic are explicitly modeled modulo
2^256. ADDMOD/MULMOD are modeled with unbounded intermediates. Solidity checks
zero modulus before those opcodes and before `%`; the EVM opcodes by themselves
return zero for zero modulus. The model combines the zero checks into one branch
because all preceding magnitude calculations are total for typed inputs.

`test/signed-mod.test.ts` compares raw return/revert bytes with an independent
JavaScript BigInt oracle on the deployed Hardhat artifact. It checks the Cartesian
product of 11 boundary values, generated full-width operands, minimum values in
all argument positions, and exact 36-byte Panic(0x12) data. Default CI execution
makes 4,952 calls; the retained verification run uses 4,096 generated cases per
operation, totaling 11,096 calls across six tests.

The checks assume valid ABI calldata, sufficient gas, and the configured compiler
and local EVM. They do not make deployment, gas-bound, or compiler-correctness
claims. Production Solidity and deployment artifacts are not changed by this work.

## Reproduce

Use the [Dafny 4.11.0 release](https://github.com/dafny-lang/dafny/releases/tag/v4.11.0)
with its Z3 4.12.1 binary. The verification runner checks the Dafny version;
both runners select Z3 4.12.1 explicitly. The local installation
used for this run was `/tmp/assertions-dafny-4.11.0/dafny/dafny`.

```sh
python3 formal/signed-mod/verify.py \
  --dafny /path/to/dafny \
  --output /tmp/signed-mod-verification

python3 formal/signed-mod/run-mutations.py \
  --dafny /path/to/dafny \
  --output /tmp/signed-mod-mutations

pnpm exec hardhat test nodejs test/signed-mod.test.ts
```

The verification runner refuses to overwrite a retained manifest, rejects source
drift during the run, checks that the Hardhat artifact was compiled from the
recorded Operations source, requires all ten lemmas and every assertion batch
to pass, and rejects zero-test EVM runs. `--runs` and `--seed` change concrete
sampling only, never the quantified proof domain.

Mutation runs use disposable copies and leave the shared source untouched. A
passing isolated baseline is required before contract mutants count as killed.
Timeouts and compilation failures are incomplete results. The wrapped-product
model mutation uses `ProductDoesNotWrap` as an independent counterexample check;
all lemmas are verified together in the positive baseline.

## Evidence and remaining gap

[Retained evidence](../../docs/verification/signed-mod/manifest.json) includes
source hashes, solver/compiler versions, compiler inputs, artifact identity,
commands, per-lemma outcomes and concrete counts. The companion
`source-correspondence.json` records the exact reviewed Solidity bodies.
`mutations/` retains the final negative controls. `mutations-discovery/` preserves
an earlier wrapped-product negative-control timeout, superseded by the direct
witness; it is never counted as a completed proof or killed mutation.

O13/O14 may cite a proved full-domain mathematical model and passing full-width
implementation tests. Formal model-to-source/bytecode equivalence remains open.

## Implementation-level follow-up

The [Kontrol harness](kontrol/README.md) checks the exact canonical Hardhat runtime.
Both zero-modulus properties are now proved for every int256 operand pair, with
exact Panic(0x12) data. Kontrol refutes the corresponding compiled mutants that
accept zero modulus. General nonzero-result properties are tracked separately;
unfinished explorations and SMT errors do not count as proofs.

`Reference.dfy` models the assembly oracle and proves its equivalence to the
independent mathematical specification. Its full run, including the original
lemmas, verifies 101 assertion batches. The Yul-to-Dafny semantic mapping remains
manually reviewed; this is not a certified cross-tool translation.

The [combined report](../../docs/verification/signed-mod/kontrol-summary.json)
accounts for all four bytecode properties, reference proofs and negative controls.
Initial runs, continuations, solver errors, snapshots and compressed proof graphs
are retained separately. The original evidence above remains unchanged.

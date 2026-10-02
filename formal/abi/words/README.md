# Word classification and static-word scans

This milestone found and fixed a **real counterexample in the production source
and exact Hardhat Collections runtime**. The failed original baseline is retained
alongside the isolated candidate and the fresh, passing fixed-source baseline.
The fix bounds the full-width name match before selecting its rule.

## Finding: `bytes3` can be mistaken for `bytes32`

`wordRule` loads a full calldata word before matching the full-width names. If a
six-byte descriptor is `bytes3` and the following calldata byte is ASCII `2`, the
seven-byte fast path matches `bytes32`. Its later bounds check resets the rule
to opaque, rather than trying the narrow `bytes3` rule. `scanName` then correctly
returns the six-byte name, but the rule remains unrestricted.

This is reachable through `Collections.unpackArray`: Solidity's external decoder
allows a nonzero byte in the descriptor's calldata padding. An array containing
the numeric word `1` is invalid for `bytes3` (its low 29 bytes must be zero).
With ordinary descriptor padding it reverts `InvalidValue(64)`. Change only the
first padding byte to `0x32`, leaving the descriptor length equal to six, and the
same runtime accepts it and returns that dirty word.

The universal classification query keeps bytes past the declared limit arbitrary.
It is not restricted to zero padding. `name-length-6` produces a SAT countermodel,
and `testDescriptorPaddingCannotDisableBytes3Rule` fails on a real EVM. The test
sweeps all 256 possible following bytes and must reject the dirty value each time.

The [isolated repair](repair.py) established that bounding the seven-byte fast
path closes the counterexample. The production change applies the same guard,
documents why calldata padding matters, and corrects the stale empty-tuple
NatSpec before regenerating artifacts. The same re-cut corrects
`validateDynamic` to name the first trailing byte (`32 + walked extent`), leaving
`unpack` unchanged; the [bytes/string proof](../source/README.md) checks that exact
error position. The retained
[candidate patch](../evidence/words-candidate/candidate.patch) records the minimal
proposal separately from the final source. The repaired
Collections runtime is **24,560 bytes**, 16 bytes below EIP-170; it is a compiled
artifact, not an observed public-chain deployment.

## Proof boundary

`generate.py` obtains a solc 0.8.36 typed AST. `yul.py` interprets a deliberately
restricted Yul subset as 256-bit SMT expressions, rejecting unsupported syntax.
There are 107 new obligations:

- One obligation proves the width-digit loop cannot reach a fifth visit. Four
  visits are therefore exhaustive, not an assumed input/loop bound.
- Eight cases cover every lowercase/digit name of lengths 1 through 8. Another
  covers every name of length at least 9. Bytes surrounding names and uint256
  limits remain symbolic. The independent whitelist has 96 narrow names:
  `uint8..uint248`, `int8..int248`, `bytes1..bytes31`, `address`, `bool`, `function`.
  Everything else, including full-width names, is opaque. The actual `scanName`
  fallback is connected separately.
- Ninety-six obligations compare the actual `checkRule` switch with independent
  range or divisibility conditions for every 256-bit value at every recognized
  width. No word values are sampled or restricted.
- One obligation checks the actual scanner's character predicate for all bytes.

`Scanners.generated.dfy` contains loop certificates for `scanName` and `checkRule`.
Generation checks their **entire Yul control-flow skeletons** before normalizing
the two predicates proved by SMT. These are restricted, trusted normalizations,
not a general verified Yul compiler. `ScanNameMeaning` proves maximal scanning at
arbitrary finite lengths. `CheckRun` proves acceptance exactly when every word
is canonical and reports the first offending word's precise byte offset. It
covers zero words and opaque rules too. `ScalarWalk` connects the single-word
kernel to the existing independent `Walk` model for classifier-reachable rules.

The combined Dafny entry includes all prior model, bytes/string and aggregate
proofs: **82 lemmas, 21 proof methods, 279 successful verification batches**.
The earlier 32 padding-mask SMT obligations are also rerun. The fixed source
passes the classification gate as well. The retained failure describes the
pre-fix source; it has not been rewritten as a success.

Trusted boundaries remain explicit: solc AST, the Python translators, the finite
rule-to-model mapping, Dafny/Boogie/Z3, big-endian in-bounds memory reads and
relocation to descriptor-relative calldata origin. Error outcomes model
`ContextKind.Value`; other context wrappers are not proved here. Data lengths and
bounded spans fit uint256. Gas, memory allocation and compiler correctness are
outside the source theorem. The EVM tests independently check compiled code, but
do not turn the source theorem into an unbounded bytecode proof.

Still open: recursive `typeShape`/suffix parsing, descriptor-driven static tuple
and array traversal in `checkWords`, the complete function-level connection to
typed recursion, and arbitrary-geometry compiled-bytecode verification. The
older aggregate composition keeps its explicit scalar interface assumption;
this milestone supplies a replacement kernel but does not silently substitute
it through an unproved parser interface.

## Evidence and reproduction

- [Original-source baseline](../evidence/words-baseline/manifest.json): **failed**;
  106/107 new SMT obligations pass, one has a countermodel; the EVM padding
  regression fails. All 279 Dafny batches pass under their stated interfaces.
- [Isolated repaired candidate](../evidence/words-candidate/manifest.json): all
  107 new SMT obligations, 32 earlier mask obligations, 279 Dafny batches, the
  audit, four EVM tests, formatting and EIP-170 pass.
- [Final fixed source](../evidence/abi-codec-words-complete/manifest.json): the same complete
  gate passes against the actual repaired source and exact regenerated Hardhat
  runtime. [Compiled aggregate checks](../evidence/abi-codec-bytecode-final/manifest.json)
  additionally pass all 12 symbolic properties and detect all five mutations.
- [Interrupted combined proof](../evidence/abi-codec-words-timeout/interpretation.json):
  278 batches passed and one timed out. The native CSV calls a timeout `Failed`;
  the raw report is retained and the interpretation explicitly records
  **incomplete**, with no established counterexample. The final rerun uses the
  same proof bounds and solver settings.
- [Mutation evidence](../evidence/words-mutations/manifest.json): eight planted
  faults on the repaired baseline, each requiring a SAT countermodel in its
  named obligation and an EVM assertion failure. Removing the proposed guard is
  one of these faults. Translator rejection and timeouts do not count.

The four proof-harness EVM tests sweep descriptor padding, all narrow-width boundaries, signed
boundaries, canonical values and deliberately opaque names. Test counts and names
are checked. The baseline runtime must exactly match Hardhat's artifact after
recompilation with its recorded settings. Candidate results are separately
labelled and never substituted for that baseline.
Two focused padding regressions are also in the normal production suite at
`contracts/tests/AbiWordBoundaries.t.sol`; removing the production guard makes
the rejection regression fail while the canonical-value control passes.

Use the pinned Dafny/Z3 pair in `../toolchain.json`, solc 0.8.36 and a Python
environment with `z3-solver==4.12.6` (used only to build SMT terms; proofs run in
pinned Z3 4.12.1). Output directories must be fresh:

```sh
python3 formal/abi/words/verify.py \
  --dafny /path/to/dafny/dafny --solc /path/to/solc \
  --smt-python /path/to/python-with-z3 \
  --output /tmp/words-fixed
# The repaired source must pass. Historical failures remain in the evidence.

# The following candidate/mutation commands operate on the pre-fix source.
# Use the retained pre-fix snapshot; the live source already contains the fix.
python3 formal/abi/words/verify.py \
  --dafny /path/to/dafny/dafny --solc /path/to/solc \
  --smt-python /path/to/python-with-z3 --candidate-fix \
  --output /tmp/words-candidate

python3 formal/abi/words/mutations.py \
  --solc /path/to/solc --solver /path/to/dafny/z3/bin/z3-4.12.1 \
  --smt-python /path/to/python-with-z3 \
  --candidate-evidence /tmp/words-candidate/manifest.json \
  --output /tmp/words-mutations
```

Manifests retain source revision and working-tree hashes, the actual analyzed
snapshot (different for the candidate), compiler inputs/output, exact runtime,
tool versions/hashes, SMT queries/countermodels, native Dafny CSV results, logs,
commands, assumptions, outcomes and nonzero test counts. No failed or incomplete
gate receives a passed status. Successive baseline counts overlap and must not
be added together.

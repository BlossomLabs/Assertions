# Compiled word map/filter development observations

The owned harness executes the exact compiler-bound Collections runtime from PC
zero on the in-process Hardhat EVM. Independent ordered byte overwrites specify
callback inputs; callback outputs specify positional mapping or original-word
filtering. Complete outer and inner RETURN/REVERT slices, callback counts,
targets, success flags and full returndata are checked. The harness records
actual GAS, EXTCODESIZE and STATICCALL observations, and raw decoder PC routes.

These are development observations, not completed public bytecode evidence.
Raw admission, fitting representation, target/window checks, template allocation,
stamping, errors, loops and serializers still need actual instruction proofs and
a complete retained current-input graph, zero audit, semantic mutations and an
independent checker. External context/history faithfulness and adequate reached
resources remain explicit; no gas-sufficiency or deployment claim follows.

Run from the repository root:

```sh
node formal/bytecode/word-apply/observations/evm-traces.mjs --output /tmp/word-apply-compiled-observations-v1
```

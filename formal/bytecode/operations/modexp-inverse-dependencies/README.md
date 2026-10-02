# Modular-inverse dependency binding preparation

Supplementary complete source/compiler AST gate for the actual OpenZeppelin5.6.1 Math.invMod, its Math.ternary call, and SafeCast.toUint(bool). Parameters, visibility, mutability, return declarations and entire bodies are bound to the current source bytes and compiler job. This source binding is distinct from exact compiled-bytecode trace proof. Finite-word coefficient wrapping, Euclidean-loop invariants, zero/modulus-one behavior and missing-inverse error serialization remain required bytecode work. No public credit.

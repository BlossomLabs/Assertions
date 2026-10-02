# Operations expWad and lnWad conditional source evidence

This package connects both complete public source bodies at the decoded `int256`
boundary to an independent, exact **finite-word quantized rational kernel** in
`Model.dfy`. `rational-oracle.py` is a separate generic Horner implementation; it
reads no Solidity. Its 20 pinned boundary and ordinary-input vectors are checked
against the actual Solidity EVM fixtures, including exact custom error arguments
and Panic(17) payloads.

This is an implementation-level specification of the rational approximations.
Equality to the real exponential or logarithm, mathematical approximation error
bounds, monotonicity, positivity and an inverse-approximation bound are **open**.
The source NatSpec's inverse-approximation description is not promoted to a
proved analytic theorem. In particular, wrapping multiplication, signed
truncation, arithmetic floor shifts and unsigned output scaling are part of the
specified observable finite-word result, rather than omitted ideal arithmetic.

`Bounds.dfy` proves the scaled exponential interval, rounded range reduction,
positive logarithm normalization into [2^96, 2^97), and strictly positive actual
rational denominators throughout each admitted domain. Interval/Horner proofs
account for every signed product and output wrap at each denominator step. Thus
neither division-by-zero nor a hidden arithmetic panic is assumed absent.
`Control.template.dfy` contains complete source control and factored connections;
`generate.py` gates complete public ASTs, error declarations, compiler-bound
selectors and actual `_panic`/OpenZeppelin `Math.log2` callees, and translates every
actual arithmetic initializer and update. It regenerates and requires identical
full-mul-div inherited controls. The complete reached binary-log and panic source
proof graph is freshly verified in every retained run. No internal helper's
mathematical postcondition is merely assumed.

Do not edit generated controls, mapping or AST inventory. Edit the template or
generator, then regenerate with the pinned compiler. Semantic campaigns compile
and translate a changed exponential denominator coefficient and logarithm offset;
each must fail a native semantic witness without parser/type errors or timeouts
and also fail the actual Solidity result fixture. Such failures are sensitivity
evidence, not a certified translator correctness proof.

The correspondence premises remain explicit: trusted compiler AST and reviewed
source lowering, decoded operand representation, faithful finite-word primitives
and source control, compiler error/return ABI serialization, adequate physical
memory/gas/stack, and trusted Dafny/Boogie/Z3. There is no precompile or external
world premise for this family. Exact runtime bytecode, gas, deployment and
performance evidence are separate.

Retained evidence is generated only after all package files are complete. The
verifier freezes source/tool/include closure, runs regeneration, the full native
inventory with isolated assertions, audit, formatting, independent vectors,
concrete EVM fixtures and semantic source faults, then checks unchanged inputs.
The independent checker rechecks source/snapshot/evidence/tool hashes, inventories,
receipts, semantic failures and current generation. A running or development
result does not add public coverage. Failed development and retained snapshots
are preserved.

# Modular exponentiation mathematical foundation

Prepared, unverified development work; no public bytecode coverage.

`Model.dfy` independently defines unbounded natural power and a finite binary
modular multiplication loop. Its statements connect every finite exponent,
including modulus one and exponent zero, to the mathematical residue.
`Connection.dfy` connects that specification to the separately explicit
faithful MODEXP reply premise. The premise is conditional on successful exact
32-byte replies to the actual 192-byte input packet; the precompile algorithm
itself is not proved.

Compiler-bound admission, exact opcode paths, error receipts and serialization
remain separate required proofs. There are no gas, deployment, performance or
cryptographic claims. Ordinary native checks, full dependency inventories and
retained public evidence have not yet run.

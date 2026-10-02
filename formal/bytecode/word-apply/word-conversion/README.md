# Constructive word conversions

The owned generator emits exact integer/bitvector round-trip lemmas for every unsigned value fitting8,16,32,64,128 or256 bits. Each doubled width splits the integer into quotient/remainder halves, constructs a bitvector with those halves, proves its numerical value, then uses the reverse conversion to identify the original cast. This avoids asking the solver to establish a large integer-to-bitvector round trip in one step. Every helper remains a checked lemma; there are no assumed conversion rules, axioms or increased time limits.

Generated files belong to generate.py. Development evidence is not a public compiled-entry proof. The raw address decoder and its complete retained include graph must still verify this module and all callers. No gas, deployment or performance claim.

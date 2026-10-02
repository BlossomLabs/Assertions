# Raw address decoder kernel

The exact compiler path at PC 22108 applies the low-160-bit mask, then compares
the masked word with the original raw head. `Mask.dfy` proves the masked word
is below 2^160 for every word, is unchanged for every canonical address, and
equals the original exactly when that address is canonical. The actual AND
step and preceding SHL/SUB mask construction stay explicit. Both accepted and
noncanonical empty-revert decoder branches remain required.

V1 attempted an unnecessary full remainder/concatenation bridge and failed
native bitvector conversion and timeout obligations. Its evidence is preserved.
V2 checks the exact predicate used by the compiler for every raw address word.

This isolated development kernel does not establish public entry coverage.

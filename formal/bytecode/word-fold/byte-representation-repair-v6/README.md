# Fold source byte representation

The generated constructive unsigned bitvector bridge and handwritten recursive byte decode proof establish SHR248(CALLDATALOAD(offset)) equals the actual raw byte at every existing offset. The32-byte load may extend beyond calldata and zero fill; the lemma requires only the first byte. The source theorem includes the final declared byte, arbitrary fitting loose offsets and all reached indices. No domain narrowing or independent32-byte-fit assumption.

Selected native imports are assumed during development. Complete fold admission, callbacks, resource guards, iteration, output and included retained graph with physical and mutation checks remain required before public coverage.

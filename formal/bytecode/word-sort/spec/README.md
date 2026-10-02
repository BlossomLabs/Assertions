# sortWords original occurrence specification

Independent unsigned comparison over complete original calldata words, sorting original occurrence IDs with stable tie order. The separately proved pure merge-sort/range lemmas establish a sorted permutation of all original IDs. Big-endian encode/decode inversion proves the payload preserves every selected original 32-byte block exactly.

This development mathematical specification does not yet connect actual compiled merge loops, memory or entry paths and grants no public bytecode coverage. The actual connection must prove finite ranks, physical left-first equality decisions, original-word stores and pointer swaps under explicit fitting memory and reached resources.

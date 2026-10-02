// SPDX-License-Identifier: MIT
// Fitting actual merge-word address arithmetic; no memory/callee postcondition assumption.
include "../../scans/Machine.dfy"
module BytecodeSortMergeScalar {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  lemma Address(out: S.Word, index: S.Word)
    requires out < 0x20000000000000000 && index < 0x800000000000000
    ensures out+32+index*32 < 0x40000000000000000
    ensures ((out+((index*32)%G.Modulus()))%G.Modulus()+32)%G.Modulus() == out+32+index*32
  {}
  lemma Increment(index: S.Word)
    requires index < 0x800000000000000
    ensures (1+index)%G.Modulus() == index+1
  {}
  lemma Difference(a: S.Word, middle: S.Word)
    requires a <= middle
    ensures (middle+G.Modulus()-a)%G.Modulus() == middle-a
    ensures (middle+G.Modulus()-a)%G.Modulus() == 0 <==> a == middle
  {}
}

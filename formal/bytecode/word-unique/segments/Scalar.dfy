// SPDX-License-Identifier: MIT
include "../../copy/Memory.dfy"
include "../../scans/Machine.dfy"
module BytecodeUniqueLoopScalar {
  import S = BytecodeScanMachine
  import C = BytecodeCopyMemory
  import G = BytecodeGetterMachine
  lemma NoExpand(mem: seq<S.Byte>, index: S.Word)
    requires 160+index*32+32 <= |mem| && S.Round32(|mem|) == |mem|
    ensures S.Expand(mem,160+index*32+32) == mem
  { C.RoundedMonotone(160+index*32+32,|mem|); }
  lemma Different(last: S.Word, word: S.Word)
    requires last != word
    ensures ((last as nat)+G.Modulus()-(word as nat))%G.Modulus() != 0
  {
    if last > word {
      assert 0 < (last as nat)-(word as nat) < G.Modulus();
    } else {
      assert 0 < (last as nat)+G.Modulus()-(word as nat) < G.Modulus();
    }
  }
}

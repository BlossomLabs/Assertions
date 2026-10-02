// SPDX-License-Identifier: MIT
include "../../scans/Machine.dfy"
module BytecodeApplyStoreByteFrame {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  lemma Outside(mem: seq<S.Byte>,offset: S.Word,word: S.Word,j: nat)
    requires j < |mem| && (j < offset || offset+32 <= j)
    ensures S.Store(mem,offset,word)[j] == mem[j]
  {
    var expanded := S.Expand(mem,(offset as nat)+32);
    assert |expanded| >= |mem| && |expanded| >= offset+32;
    assert expanded[j] == mem[j];
    assert G.Grow(expanded,offset+32) == expanded;
  }
}

// SPDX-License-Identifier: MIT
include "../../scans/ErrorBytes.dfy"
module BytecodeZipErrorMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  lemma Mismatch(mem: seq<S.Byte>, countA: S.Word, countB: S.Word)
    requires |mem|%32 == 0
    ensures S.Store(S.Store(S.Store(mem,128,0x1b10636a00000000000000000000000000000000000000000000000000000000),132,countA),164,countB)[128..196] == G.Encode(0x1b10636a,4)+G.Encode(countA,32)+G.Encode(countB,32)
  {
    var header: S.Word := 0x1b10636a00000000000000000000000000000000000000000000000000000000;
    ER.PhysicalError(mem,128,0x1b10636a,header,countA);
    var first := S.Store(S.Store(mem,128,header),132,countA);
    var last := S.Store(first,164,countB);
    R.StoredWord(first,164,countB);
    assert S.Expand(first,196)[..|first|] == first;
    assert last[128..164] == first[128..164];
    assert last[164..196] == G.Encode(countB,32);
  }
}

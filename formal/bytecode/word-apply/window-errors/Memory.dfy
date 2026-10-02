// SPDX-License-Identifier: MIT
include "../../scans/ErrorBytes.dfy"
module BytecodeApplyWindowErrorMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  lemma Error(mem: seq<S.Byte>,offset: S.Word,length: S.Word)
    requires |mem|%32 == 0
    ensures S.Store(S.Store(S.Store(mem,128,0x1a0d83de00000000000000000000000000000000000000000000000000000000),132,offset),164,length)[128..196] == G.Encode(0x1a0d83de,4)+G.Encode(offset,32)+G.Encode(length,32)
  {
    var header: S.Word := 0x1a0d83de00000000000000000000000000000000000000000000000000000000;
    ER.PhysicalError(mem,128,0x1a0d83de,header,offset);
    var first := S.Store(S.Store(mem,128,header),132,offset);
    var last := S.Store(first,164,length);
    R.StoredWord(first,164,length);
    assert S.Expand(first,196)[..|first|] == first;
    assert last[128..164] == first[128..164];
    assert last[164..196] == G.Encode(length,32);
  }
  lemma Layout(offset: S.Word,length: S.Word)
    ensures |S.Store([],64,128)| == 96
    ensures |S.Store(S.Store([],64,128),128,0x1a0d83de00000000000000000000000000000000000000000000000000000000)| == 160
    ensures |S.Store(S.Store(S.Store([],64,128),128,0x1a0d83de00000000000000000000000000000000000000000000000000000000),132,offset)| == 192
    ensures |S.Store(S.Store(S.Store(S.Store([],64,128),128,0x1a0d83de00000000000000000000000000000000000000000000000000000000),132,offset),164,length)| == 224
    ensures S.Load(S.Store([],64,128),64) == 128
    ensures S.Load(S.Store(S.Store([],64,128),128,0x1a0d83de00000000000000000000000000000000000000000000000000000000),64) == 128
    ensures S.Load(S.Store(S.Store(S.Store([],64,128),128,0x1a0d83de00000000000000000000000000000000000000000000000000000000),132,offset),64) == 128
    ensures S.Load(S.Store(S.Store(S.Store(S.Store([],64,128),128,0x1a0d83de00000000000000000000000000000000000000000000000000000000),132,offset),164,length),64) == 128
  {
    var header: S.Word := 0x1a0d83de00000000000000000000000000000000000000000000000000000000;
    var m0 := S.Store([],64,128);
    var m1 := S.Store(m0,128,header);
    var m2 := S.Store(m1,132,offset);
    R.StoredWord([],64,128);
    R.StoredWord(m0,128,header);
    R.StoredWord(m1,132,offset);
    R.StoredWord(m2,164,length);
    R.StoredFrame(m0,128,header,64);
    R.StoredFrame(m1,132,offset,64);
    R.StoredFrame(m2,164,length,64);
  }

}

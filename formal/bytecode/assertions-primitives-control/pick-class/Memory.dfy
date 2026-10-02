// SPDX-License-Identifier: MIT
// Selected complete word is projected from original calldata, independent of _rawWord.
include "Spec.dfy"
include "../cond-class/Memory.dfy"
module AssertionsPickMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsRawResolveMemory
  import R = BytecodeScanRepresentation
  import Z = AssertionsGatherArrayResult
  import Q = AssertionsPrimitiveScalar
  type Word = S.Word
  type Byte = S.Byte
  lemma Selected(mem: seq<Byte>,free: Word,offset: Word,length: Word,index: Word,data: seq<Byte>)
    requires M.Fits(mem,free,offset,length,data) && Q.Inside(length,index)
    ensures S.Load(M.Construct(mem,free,offset,length,data),Q.WordOffset(free,length,index)) == S.DataWord(data,offset+32*Q.Wanted(length,index))
  {
    hide S.Load(); hide S.DataWord(); hide G.Decode(); hide M.Construct();
    M.Built(mem,free,offset,length,data); Q.IndexFacts(length,index);
    var image := M.Construct(mem,free,offset,length,data);
    Q.OffsetFacts(free,length,index,image);
    var wanted := Q.Wanted(length,index);
    assert 32*wanted+32 <= length;
    Z.Read(image,free+32+32*wanted); R.WordProjection(data,offset+32*wanted);
    Z.Slice(image,free+32,free+32+length,32*wanted,32);
    Z.Slice(data,offset,offset+length,32*wanted,32);
    assert image[free+32+32*wanted..free+64+32*wanted] == image[free+32..free+32+length][32*wanted..32*wanted+32];
    assert data[offset+32*wanted..offset+32*wanted+32] == data[offset..offset+length][32*wanted..32*wanted+32];
  }
}

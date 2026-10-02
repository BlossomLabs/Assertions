// SPDX-License-Identifier: MIT
// Original calldata first word and byte payload of the physical RAW result object.
include "../../assertions-resolution/raw/Memory.dfy"
include "../gather-public/serialization/Result.dfy"
module AssertionsCondMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = AssertionsRawResolveMemory
  import R = BytecodeScanRepresentation
  import Z = AssertionsGatherArrayResult
  type Word = S.Word
  type Byte = S.Byte
  lemma First(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>)
    requires M.Fits(mem,free,offset,length,data) && length >= 32
    ensures S.Load(M.Construct(mem,free,offset,length,data),free+32) == S.DataWord(data,offset)
  {
    hide S.Load(); hide S.DataWord(); hide G.Decode(); hide M.Construct();
    M.Built(mem,free,offset,length,data);
    var image := M.Construct(mem,free,offset,length,data);
    Z.Read(image,free+32); R.WordProjection(data,offset);
    assert image[free+32..free+64] == image[free+32..free+32+length][..32];
    assert data[offset..offset+32] == data[offset..offset+length][..32];
  }
  lemma Payload(mem: seq<Byte>, free: Word, offset: Word, length: Word, data: seq<Byte>)
    requires M.Fits(mem,free,offset,length,data)
    ensures G.Grow(M.Construct(mem,free,offset,length,data),free+32+length)[free+32..free+32+length] == data[offset..offset+length]
  {
    hide M.Construct(); M.Built(mem,free,offset,length,data);
    assert G.Grow(M.Construct(mem,free,offset,length,data),free+32+length) == M.Construct(mem,free,offset,length,data);
  }
}

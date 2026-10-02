// SPDX-License-Identifier: MIT
include "Output.dfy"
include "../scans/Representation.dfy"
module BytecodeIotaAllocationMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import O = BytecodeIotaOutput
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  import R = BytecodeScanRepresentation
  function Head(count: nat): seq<S.Byte>
    requires count < 0x800000000000000
  { S.Store(S.Store(S.Store([],64,128),128,count*32),64,O.Extent(count)) }
  lemma HeadBytes(count: nat)
    requires count < 0x800000000000000
    ensures |Head(count)| == 160
    ensures Head(count) == O.Heap(count,0)[..160]
  {
    R.StoredWord([],64,128);
    R.StoredWord(S.Store([],64,128),128,count*32);
    R.StoredWord(S.Store(S.Store([],64,128),128,count*32),64,O.Extent(count));
    assert S.Expand([],96) == seq(96,j => 0);
    assert S.Store([],64,128) == seq(64,j => 0)+G.Encode(128,32);
    var first := S.Store([],64,128);
    assert S.Expand(first,160) == first+seq(64,j => 0);
    var second := S.Store(first,128,count*32);
    assert second == first+seq(32,j => 0)+G.Encode(count*32,32);
    assert Head(count) == seq(64,j => 0)+G.Encode(O.Extent(count),32)+seq(32,j => 0)+G.Encode(count*32,32);
    forall j: nat {:trigger Head(count)[j]} | j < 160
      ensures Head(count)[j] == O.Heap(count,0)[j]
    {}
  }
  lemma ZeroPayload(count: nat, data: seq<S.Byte>)
    requires count < 0x800000000000000 && |data| < G.Modulus()
    ensures C.Calldata(Head(count),160,|data|,count*32,data) == O.Heap(count,0)
  {
    HeadBytes(count);
    O.Aligned(count);
    var after := C.Calldata(Head(count),160,|data|,count*32,data);
    C.Size(Head(count),160,S.Window(data,|data|,count*32));
    assert |after| == O.Extent(count);
    C.Frame(Head(count),160,S.Window(data,|data|,count*32));
    forall j: nat {:trigger after[j]} | j < O.Extent(count)
      ensures after[j] == O.Heap(count,0)[j]
    {
      if j >= 160 { C.CalldataValue(Head(count),160,|data|,count*32,data,j-160); }
      else { assert after[j] == Head(count)[j]; }
    }
  }
  lemma ActualCopy(code: seq<S.Byte>, count: nat, prefix: seq<S.Word>, value: S.Word, data: seq<S.Byte>)
    requires |code| > 5614 && code[5614] == 0x37
    requires count < 0x800000000000000 && |data| < G.Modulus() && |prefix| <= 1021
    ensures M.Step(code,{},S.Running(5614,prefix+[count*32,|data|,160],Head(count)),value,data) == S.Running(5615,prefix,O.Heap(count,0))
  {
    HeadBytes(count);
    O.Aligned(count);
    ZeroPayload(count,data);
    M.CalldataStep(code,5614,prefix,Head(count),160,|data|,count*32,value,data);
  }
}

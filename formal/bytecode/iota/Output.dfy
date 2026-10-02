// SPDX-License-Identifier: MIT
// Development physical heap invariant for an iota payload; no entry claim.
include "../copy/Machine.dfy"
module BytecodeIotaOutput {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  type Byte = G.Byte
  type Word = G.Word
  function Extent(count: nat): nat { 160+count*32 }
  function Heap(count: nat, filled: nat): seq<Byte>
    requires count < 0x800000000000000 && filled <= count
  {
    seq(Extent(count),j requires 0 <= j < Extent(count) =>
      if 64 <= j < 96 then G.Encode(Extent(count),32)[j-64]
      else if 128 <= j < 160 then G.Encode(count*32,32)[j-128]
      else if 160 <= j && (j-160)/32 < filled then G.Encode((j-160)/32,32)[(j-160)%32]
      else 0)
  }
  lemma ZeroEncoding(width: nat)
    ensures G.Encode(0,width) == seq(width,j => 0)
    decreases width
  {
    if width > 0 { ZeroEncoding(width-1); }
  }
  lemma Aligned(count: nat)
    ensures S.Round32(Extent(count)) == Extent(count)
  {}
  lemma Advance(count: nat, filled: nat)
    requires count < 0x800000000000000 && filled < count
    ensures S.Store(Heap(count,filled),160+filled*32,filled) == Heap(count,filled+1)
  {
    var before := Heap(count,filled);
    var offset := 160+filled*32;
    Aligned(count);
    C.RoundedMonotone(offset+32,Extent(count));
    assert S.Expand(before,offset+32) == before;
    var next := S.Store(before,offset,filled);
    assert next == before[..offset]+G.Encode(filled,32)+before[offset+32..];
    forall j: nat | j < Extent(count)
      ensures next[j] == Heap(count,filled+1)[j]
    {
      if offset <= j < offset+32 {
        assert 0 <= j-offset < 32;
        assert (j-160)/32 == filled;
        assert (j-160)%32 == j-offset;
        assert next[j] == G.Encode(filled,32)[j-offset];
      } else {
        assert next[j] == before[j];
        if j >= 160 {
          assert (j-160)/32 != filled;
          assert ((j-160)/32 < filled) == ((j-160)/32 < filled+1);
        }
      }
    }
  }
  lemma Header(count: nat, filled: nat)
    requires count < 0x800000000000000 && filled <= count
    ensures S.Load(Heap(count,filled),64) == Extent(count)
    ensures S.Load(Heap(count,filled),128) == count*32
  {
    assert Heap(count,filled)[64..96] == G.Encode(Extent(count),32);
    assert Heap(count,filled)[128..160] == G.Encode(count*32,32);
    G.RoundTrip(Extent(count),32);
    G.RoundTrip(count*32,32);
  }
  lemma WordAt(count: nat, filled: nat, index: nat)
    requires count < 0x800000000000000 && filled <= count && index < count
    ensures S.Load(Heap(count,filled),160+index*32) == (if index < filled then index else 0)
  {
    var offset := 160+index*32;
    var chunk := Heap(count,filled)[offset..offset+32];
    forall j: nat {:trigger chunk[j]} | j < 32
      ensures chunk[j] == G.Encode(if index < filled then index else 0,32)[j]
    {
      assert chunk[j] == Heap(count,filled)[offset+j];
      assert (offset+j-160)/32 == index && (offset+j-160)%32 == j;
      if index >= filled { ZeroEncoding(32); }
    }
    assert Heap(count,filled)[offset..offset+32] == G.Encode(if index < filled then index else 0,32);
    G.RoundTrip(if index < filled then index else 0,32);
  }
  lemma StoreEffect(code: seq<Byte>, count: nat, filled: nat, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires |code| > 5642 && code[5642] == 0x52
    requires count < 0x800000000000000 && filled < count && |prefix| <= 1022
    ensures M.Step(code,{},S.Running(5642,prefix+[filled,160+filled*32],Heap(count,filled)),value,data) == S.Running(5643,prefix,Heap(count,filled+1))
  {
    M.Delegate(code,{},S.Running(5642,prefix+[filled,160+filled*32],Heap(count,filled)),value,data);
    reveal S.Step();
    Advance(count,filled);
  }
  ghost method Fill(count: nat) returns (mem: seq<Byte>)
    requires count < 0x800000000000000
    ensures mem == Heap(count,count)
  {
    var filled: nat := 0;
    mem := Heap(count,0);
    while filled < count
      invariant filled <= count && mem == Heap(count,filled)
      decreases count-filled
    {
      Advance(count,filled);
      mem := S.Store(mem,160+filled*32,filled);
      filled := filled+1;
    }
  }

}

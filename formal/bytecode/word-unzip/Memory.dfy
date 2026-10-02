// SPDX-License-Identifier: MIT
// Physical lane stores, including the extra original word in lane zero.
include "../copy/Machine.dfy"
include "../scans/Representation.dfy"
module BytecodeWordUnzipMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  import R = BytecodeScanRepresentation
  type Byte = S.Byte
  type Word = S.Word
  function Count(n: nat, lane: nat): nat
    requires lane <= 1
  { if lane == 0 then (n+1)/2 else n/2 }
  function Extent(n: nat, lane: nat): nat
    requires lane <= 1
  { 160+Count(n,lane)*32 }
  lemma Geometry(n: nat, lane: nat, index: nat)
    requires lane <= 1 && index < Count(n,lane)
    ensures 2*index+lane < n
    ensures Count(n,lane) <= n
    ensures n%2 == 0 ==> Count(n,lane)*2 == n
    ensures n%2 == 1 ==> Count(n,0) == Count(n,1)+1
  {}
  predicate Admitted(n: nat, filled: nat, lane: nat, start: Word, data: seq<Byte>) {
    lane <= 1 && n < 0x800000000000000 && filled <= Count(n,lane) &&
    |data| < G.Modulus() && start+n*32 <= |data|
  }
  function Heap(n: nat, filled: nat, lane: nat, start: Word, data: seq<Byte>): seq<Byte>
    requires Admitted(n,filled,lane,start,data)
  {
    seq(Extent(n,lane),j requires 0 <= j < Extent(n,lane) =>
      if 64 <= j < 96 then G.Encode(Extent(n,lane),32)[j-64]
      else if 128 <= j < 160 then G.Encode(Count(n,lane)*32,32)[j-128]
      else if 160 <= j && (j-160)/32 < filled then
        G.Encode(S.DataWord(data,start+(2*((j-160)/32)+lane)*32),32)[(j-160)%32]
      else 0)
  }
  function Payload(n: nat, lane: nat, start: Word, data: seq<Byte>): seq<Byte>
    requires lane <= 1 && Admitted(n,Count(n,lane),lane,start,data)
  {
    seq(Count(n,lane)*32,j requires 0 <= j < Count(n,lane)*32 =>
      data[start+(2*(j/32)+lane)*32+j%32])
  }
  lemma EncodeDecode(bytes: seq<Byte>)
    ensures G.Encode(G.Decode(bytes),|bytes|) == bytes
    decreases |bytes|
  {
    if |bytes| > 0 {
      EncodeDecode(bytes[..|bytes|-1]);
      assert G.Decode(bytes)/256 == G.Decode(bytes[..|bytes|-1]);
      assert G.Decode(bytes)%256 == bytes[|bytes|-1];
      assert bytes == bytes[..|bytes|-1]+[bytes[|bytes|-1]];
    }
  }
  lemma ZeroEncoding(width: nat)
    ensures G.Encode(0,width) == seq(width,j => 0)
    decreases width
  { if width > 0 { ZeroEncoding(width-1); } }
  lemma Header(n: nat, filled: nat, lane: nat, start: Word, data: seq<Byte>)
    requires Admitted(n,filled,lane,start,data)
    ensures S.Load(Heap(n,filled,lane,start,data),64) == Extent(n,lane)
    ensures S.Load(Heap(n,filled,lane,start,data),128) == Count(n,lane)*32
  {
    assert Count(n,lane) <= n;
    assert Heap(n,filled,lane,start,data)[64..96] == G.Encode(Extent(n,lane),32);
    assert Heap(n,filled,lane,start,data)[128..160] == G.Encode(Count(n,lane)*32,32);
    G.RoundTrip(Extent(n,lane),32); G.RoundTrip(Count(n,lane)*32,32);
  }
  lemma Advance(n: nat, i: nat, lane: nat, start: Word, data: seq<Byte>)
    requires Admitted(n,i,lane,start,data) && i < Count(n,lane)
    ensures S.Store(Heap(n,i,lane,start,data),160+i*32,S.DataWord(data,start+(2*i+lane)*32)) == Heap(n,i+1,lane,start,data)
  {
    var before := Heap(n,i,lane,start,data);
    var offset := 160+i*32;
    assert S.Round32(Extent(n,lane)) == Extent(n,lane);
    C.RoundedMonotone(offset+32,Extent(n,lane));
    assert S.Expand(before,offset+32) == before;
    var after := S.Store(before,offset,S.DataWord(data,start+(2*i+lane)*32));
    assert after == before[..offset]+G.Encode(S.DataWord(data,start+(2*i+lane)*32),32)+before[offset+32..];
    forall j: nat {:trigger after[j]} | j < Extent(n,lane)
      ensures after[j] == Heap(n,i+1,lane,start,data)[j]
    {
      if offset <= j < offset+32 {
        assert (j-160)/32 == i && (j-160)%32 == j-offset;
      } else {
        assert after[j] == before[j];
        if j >= 160 {
          assert (j-160)/32 != i;
          assert ((j-160)/32 < i) == ((j-160)/32 < i+1);
        }
      }
    }
  }
  lemma WordAt(n: nat, filled: nat, lane: nat, start: Word, data: seq<Byte>, index: nat)
    requires Admitted(n,filled,lane,start,data) && index < Count(n,lane)
    ensures S.Load(Heap(n,filled,lane,start,data),160+index*32) ==
            (if index < filled then S.DataWord(data,start+(2*index+lane)*32) else 0)
  {
    var offset := 160+index*32;
    var word := if index < filled then S.DataWord(data,start+(2*index+lane)*32) else 0;
    var chunk := Heap(n,filled,lane,start,data)[offset..offset+32];
    forall j: nat {:trigger chunk[j]} | j < 32
      ensures chunk[j] == G.Encode(word,32)[j]
    {
      assert (offset+j-160)/32 == index && (offset+j-160)%32 == j;
      if filled <= index { ZeroEncoding(32); }
    }
    assert chunk == G.Encode(word,32);
    G.LoadProjection(Heap(n,filled,lane,start,data),offset);
    assert G.Grow(Heap(n,filled,lane,start,data),offset+32) == Heap(n,filled,lane,start,data);
    G.WordPower(); G.RoundTrip(word,32);
  }
  lemma OriginalBytes(n: nat, lane: nat, start: Word, data: seq<Byte>)
    requires lane <= 1 && Admitted(n,Count(n,lane),lane,start,data)
    ensures Heap(n,Count(n,lane),lane,start,data)[160..] == Payload(n,lane,start,data)
  {
    var bytes := Heap(n,Count(n,lane),lane,start,data)[160..];
    forall j: nat {:trigger bytes[j]} | j < Count(n,lane)*32
      ensures bytes[j] == Payload(n,lane,start,data)[j]
    {
      Geometry(n,lane,j/32);
      var source := start+(2*(j/32)+lane)*32;
      R.WordProjection(data,source);
      EncodeDecode(data[source..source+32]);
      assert G.Encode(S.DataWord(data,source),32) == data[source..source+32];
      assert bytes[j] == G.Encode(S.DataWord(data,source),32)[j%32];
    }
  }
  lemma StoreEffect(code: seq<Byte>, n: nat, i: nat, lane: nat, start: Word, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires |code| > 6282 && code[6282] == 0x52
    requires Admitted(n,i,lane,start,data) && i < Count(n,lane) && |prefix| <= 1022
    ensures M.Step(code,{},S.Running(6282,prefix+[S.DataWord(data,start+(2*i+lane)*32),160+i*32],Heap(n,i,lane,start,data)),value,data) == S.Running(6283,prefix,Heap(n,i+1,lane,start,data))
  {
    M.Delegate(code,{},S.Running(6282,prefix+[S.DataWord(data,start+(2*i+lane)*32),160+i*32],Heap(n,i,lane,start,data)),value,data);
    reveal S.Step(); Advance(n,i,lane,start,data);
  }
  ghost method Fill(n: nat, lane: nat, start: Word, data: seq<Byte>) returns (mem: seq<Byte>)
    requires Admitted(n,0,lane,start,data)
    ensures mem == Heap(n,Count(n,lane),lane,start,data) && mem[160..] == Payload(n,lane,start,data)
  {
    var index: nat := 0; mem := Heap(n,0,lane,start,data);
    while index < Count(n,lane)
      invariant index <= Count(n,lane) && mem == Heap(n,index,lane,start,data)
      decreases Count(n,lane)-index
    {
      Advance(n,index,lane,start,data);
      mem := S.Store(mem,160+index*32,S.DataWord(data,start+(2*index+lane)*32));
      index := index+1;
    }
    OriginalBytes(n,lane,start,data);
  }
}

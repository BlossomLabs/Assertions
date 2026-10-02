// SPDX-License-Identifier: MIT
// Physical retained-word stores and final length shrink with original-byte preservation.
include "../copy/Machine.dfy"
include "../scans/Representation.dfy"
module BytecodeWordUniqueMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  import R = BytecodeScanRepresentation
  type Byte = S.Byte
  type Word = S.Word
  function Extent(n: nat): nat { 160+n*32 }
  predicate Admitted(n: nat, ids: seq<nat>, start: Word, data: seq<Byte>, length: nat) {
    n < 0x800000000000000 && |ids| <= n && length <= n && |data| < G.Modulus() &&
    start+n*32 <= |data| && (forall j :: 0 <= j < |ids| ==> ids[j] < n)
  }
  function Source(n: nat, id: nat, start: Word, data: seq<Byte>): Word
    requires n < 0x800000000000000 && id < n && start+n*32 <= |data| < G.Modulus()
  { S.DataWord(data,start+id*32) }
  function Heap(n: nat, ids: seq<nat>, start: Word, data: seq<Byte>, length: nat): seq<Byte>
    requires Admitted(n,ids,start,data,length)
  {
    seq(Extent(n),j requires 0 <= j < Extent(n) =>
      if 64 <= j < 96 then G.Encode(Extent(n),32)[j-64]
      else if 128 <= j < 160 then G.Encode(length*32,32)[j-128]
      else if 160 <= j && (j-160)/32 < |ids| then
        G.Encode(Source(n,ids[(j-160)/32],start,data),32)[(j-160)%32]
      else 0)
  }
  function Payload(n: nat, ids: seq<nat>, start: Word, data: seq<Byte>): seq<Byte>
    requires Admitted(n,ids,start,data,|ids|)
  { seq(|ids|*32,j requires 0 <= j < |ids|*32 => data[start+ids[j/32]*32+j%32]) }
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
  lemma Header(n: nat, ids: seq<nat>, start: Word, data: seq<Byte>, length: nat)
    requires Admitted(n,ids,start,data,length)
    ensures S.Load(Heap(n,ids,start,data,length),64) == Extent(n)
    ensures S.Load(Heap(n,ids,start,data,length),128) == length*32
  {
    assert Heap(n,ids,start,data,length)[64..96] == G.Encode(Extent(n),32);
    assert Heap(n,ids,start,data,length)[128..160] == G.Encode(length*32,32);
    G.RoundTrip(Extent(n),32); G.RoundTrip(length*32,32);
  }
  lemma Advance(n: nat, ids: seq<nat>, start: Word, data: seq<Byte>, id: nat)
    requires Admitted(n,ids,start,data,n) && |ids| < n && id < n
    ensures S.Store(Heap(n,ids,start,data,n),160+|ids|*32,Source(n,id,start,data)) == Heap(n,ids+[id],start,data,n)
  {
    var before := Heap(n,ids,start,data,n);
    var offset := 160+|ids|*32;
    assert S.Round32(Extent(n)) == Extent(n);
    C.RoundedMonotone(offset+32,Extent(n));
    assert S.Expand(before,offset+32) == before;
    var after := S.Store(before,offset,Source(n,id,start,data));
    assert after == before[..offset]+G.Encode(Source(n,id,start,data),32)+before[offset+32..];
    forall j: nat {:trigger after[j]} | j < Extent(n)
      ensures after[j] == Heap(n,ids+[id],start,data,n)[j]
    {
      if offset <= j < offset+32 {
        assert (j-160)/32 == |ids| && (j-160)%32 == j-offset;
        assert (ids+[id])[|ids|] == id;
      } else {
        assert after[j] == before[j];
        if j >= 160 {
          assert (j-160)/32 != |ids|;
          assert ((j-160)/32 < |ids|) == ((j-160)/32 < |ids|+1);
          if (j-160)/32 < |ids| { assert (ids+[id])[(j-160)/32] == ids[(j-160)/32]; }
        }
      }
    }
  }
  lemma WordAt(n: nat, ids: seq<nat>, start: Word, data: seq<Byte>, length: nat, index: nat)
    requires Admitted(n,ids,start,data,length) && index < n
    ensures S.Load(Heap(n,ids,start,data,length),160+index*32) ==
            (if index < |ids| then Source(n,ids[index],start,data) else 0)
  {
    var offset := 160+index*32;
    var word := if index < |ids| then Source(n,ids[index],start,data) else 0;
    var chunk := Heap(n,ids,start,data,length)[offset..offset+32];
    forall j: nat {:trigger chunk[j]} | j < 32
      ensures chunk[j] == G.Encode(word,32)[j]
    {
      assert (offset+j-160)/32 == index && (offset+j-160)%32 == j;
      if |ids| <= index { ZeroEncoding(32); }
    }
    assert chunk == G.Encode(word,32);
    G.LoadProjection(Heap(n,ids,start,data,length),offset);
    assert G.Grow(Heap(n,ids,start,data,length),offset+32) == Heap(n,ids,start,data,length);
    G.WordPower(); G.RoundTrip(word,32);
  }
  lemma Shrink(n: nat, ids: seq<nat>, start: Word, data: seq<Byte>)
    requires Admitted(n,ids,start,data,n)
    ensures S.Store(Heap(n,ids,start,data,n),128,|ids|*32) == Heap(n,ids,start,data,|ids|)
  {
    var before := Heap(n,ids,start,data,n);
    assert S.Round32(Extent(n)) == Extent(n);
    C.RoundedMonotone(160,Extent(n));
    assert S.Expand(before,160) == before;
    var after := S.Store(before,128,|ids|*32);
    assert after == before[..128]+G.Encode(|ids|*32,32)+before[160..];
    forall j: nat {:trigger after[j]} | j < Extent(n)
      ensures after[j] == Heap(n,ids,start,data,|ids|)[j]
    {}
  }
  lemma OriginalBytes(n: nat, ids: seq<nat>, start: Word, data: seq<Byte>, length: nat)
    requires Admitted(n,ids,start,data,length)
    ensures Heap(n,ids,start,data,length)[160..160+|ids|*32] == Payload(n,ids,start,data)
  {
    var bytes := Heap(n,ids,start,data,length)[160..160+|ids|*32];
    forall j: nat {:trigger bytes[j]} | j < |ids|*32
      ensures bytes[j] == Payload(n,ids,start,data)[j]
    {
      var source := start+ids[j/32]*32;
      R.WordProjection(data,source);
      EncodeDecode(data[source..source+32]);
      assert G.Encode(Source(n,ids[j/32],start,data),32) == data[source..source+32];
      assert bytes[j] == G.Encode(Source(n,ids[j/32],start,data),32)[j%32];
    }
  }
  lemma StoreEffect(code: seq<Byte>, n: nat, ids: seq<nat>, start: Word, data: seq<Byte>,
                    id: nat, prefix: seq<Word>, value: Word)
    requires |code| > 6923 && code[6923] == 0x52
    requires Admitted(n,ids,start,data,n) && |ids| < n && id < n && |prefix| <= 1022
    ensures M.Step(code,{},S.Running(6923,prefix+[Source(n,id,start,data),160+|ids|*32],Heap(n,ids,start,data,n)),value,data) == S.Running(6924,prefix,Heap(n,ids+[id],start,data,n))
  {
    M.Delegate(code,{},S.Running(6923,prefix+[Source(n,id,start,data),160+|ids|*32],Heap(n,ids,start,data,n)),value,data);
    reveal S.Step(); Advance(n,ids,start,data,id);
  }
  lemma ShrinkEffect(code: seq<Byte>, n: nat, ids: seq<nat>, start: Word, data: seq<Byte>,
                     prefix: seq<Word>, value: Word)
    requires |code| > 6941 && code[6941] == 0x52
    requires Admitted(n,ids,start,data,n) && |prefix| <= 1022
    ensures M.Step(code,{},S.Running(6941,prefix+[|ids|*32,128],Heap(n,ids,start,data,n)),value,data) == S.Running(6942,prefix,Heap(n,ids,start,data,|ids|))
  {
    M.Delegate(code,{},S.Running(6941,prefix+[|ids|*32,128],Heap(n,ids,start,data,n)),value,data);
    reveal S.Step(); Shrink(n,ids,start,data);
  }
}

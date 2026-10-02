// SPDX-License-Identifier: MIT
// Physical interleaved original-word stores, including overlapping raw input slices.
include "../copy/Machine.dfy"
include "../scans/Representation.dfy"
module BytecodeWordZipMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  import R = BytecodeScanRepresentation
  type Byte = S.Byte
  type Word = S.Word
  function Extent(n: nat): nat { 160+n*64 }
  predicate Admitted(n: nat, filled: nat, a: Word, b: Word, data: seq<Byte>) {
    n < 0x400000000000000 && filled <= 2*n && |data| < G.Modulus() &&
    a+n*32 <= |data| && b+n*32 <= |data|
  }
  function Source(n: nat, index: nat, a: Word, b: Word, data: seq<Byte>): Word
    requires Admitted(n,0,a,b,data) && index < 2*n
  { S.DataWord(data,(if index%2 == 0 then a else b)+(index/2)*32) }
  function Heap(n: nat, filled: nat, a: Word, b: Word, data: seq<Byte>): seq<Byte>
    requires Admitted(n,filled,a,b,data)
  {
    seq(Extent(n),j requires 0 <= j < Extent(n) =>
      if 64 <= j < 96 then G.Encode(Extent(n),32)[j-64]
      else if 128 <= j < 160 then G.Encode(n*64,32)[j-128]
      else if 160 <= j && (j-160)/32 < filled then
        G.Encode(Source(n,(j-160)/32,a,b,data),32)[(j-160)%32]
      else 0)
  }
  function Payload(n: nat, a: Word, b: Word, data: seq<Byte>): seq<Byte>
    requires Admitted(n,2*n,a,b,data)
  { seq(n*64,j requires 0 <= j < n*64 => data[(if (j/32)%2 == 0 then a else b)+(j/64)*32+j%32]) }
  lemma Geometry(n: nat, index: nat)
    requires index < 2*n
    ensures index/2 < n
    ensures index/32/2 == index/64
  {}
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
  lemma Header(n: nat, filled: nat, a: Word, b: Word, data: seq<Byte>)
    requires Admitted(n,filled,a,b,data)
    ensures S.Load(Heap(n,filled,a,b,data),64) == Extent(n)
    ensures S.Load(Heap(n,filled,a,b,data),128) == n*64
  {
    assert Heap(n,filled,a,b,data)[64..96] == G.Encode(Extent(n),32);
    assert Heap(n,filled,a,b,data)[128..160] == G.Encode(n*64,32);
    G.RoundTrip(Extent(n),32); G.RoundTrip(n*64,32);
  }
  lemma Advance(n: nat, index: nat, a: Word, b: Word, data: seq<Byte>)
    requires Admitted(n,index,a,b,data) && index < 2*n
    ensures S.Store(Heap(n,index,a,b,data),160+index*32,Source(n,index,a,b,data)) == Heap(n,index+1,a,b,data)
  {
    var before := Heap(n,index,a,b,data);
    var offset := 160+index*32;
    assert S.Round32(Extent(n)) == Extent(n);
    C.RoundedMonotone(offset+32,Extent(n));
    assert S.Expand(before,offset+32) == before;
    var after := S.Store(before,offset,Source(n,index,a,b,data));
    assert after == before[..offset]+G.Encode(Source(n,index,a,b,data),32)+before[offset+32..];
    forall j: nat {:trigger after[j]} | j < Extent(n)
      ensures after[j] == Heap(n,index+1,a,b,data)[j]
    {
      if offset <= j < offset+32 {
        assert (j-160)/32 == index && (j-160)%32 == j-offset;
      } else {
        assert after[j] == before[j];
        if j >= 160 {
          assert (j-160)/32 != index;
          assert ((j-160)/32 < index) == ((j-160)/32 < index+1);
        }
      }
    }
  }
  lemma WordAt(n: nat, filled: nat, a: Word, b: Word, data: seq<Byte>, index: nat)
    requires Admitted(n,filled,a,b,data) && index < 2*n
    ensures S.Load(Heap(n,filled,a,b,data),160+index*32) ==
            (if index < filled then Source(n,index,a,b,data) else 0)
  {
    var offset := 160+index*32;
    var word := if index < filled then Source(n,index,a,b,data) else 0;
    var chunk := Heap(n,filled,a,b,data)[offset..offset+32];
    forall j: nat {:trigger chunk[j]} | j < 32
      ensures chunk[j] == G.Encode(word,32)[j]
    {
      assert (offset+j-160)/32 == index && (offset+j-160)%32 == j;
      if filled <= index { ZeroEncoding(32); }
    }
    assert chunk == G.Encode(word,32);
    G.LoadProjection(Heap(n,filled,a,b,data),offset);
    assert G.Grow(Heap(n,filled,a,b,data),offset+32) == Heap(n,filled,a,b,data);
    G.WordPower(); G.RoundTrip(word,32);
  }
  lemma OriginalBytes(n: nat, a: Word, b: Word, data: seq<Byte>)
    requires Admitted(n,2*n,a,b,data)
    ensures Heap(n,2*n,a,b,data)[160..] == Payload(n,a,b,data)
  {
    var bytes := Heap(n,2*n,a,b,data)[160..];
    forall j: nat {:trigger bytes[j]} | j < n*64
      ensures bytes[j] == Payload(n,a,b,data)[j]
    {
      Geometry(n,j/32);
      var source := (if (j/32)%2 == 0 then a else b)+((j/32)/2)*32;
      R.WordProjection(data,source);
      EncodeDecode(data[source..source+32]);
      assert G.Encode(Source(n,j/32,a,b,data),32) == data[source..source+32];
      assert bytes[j] == G.Encode(Source(n,j/32,a,b,data),32)[j%32];
    }
  }
  lemma StoreEffect(code: seq<Byte>, pc: nat, n: nat, index: nat, a: Word, b: Word,
                    prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires (pc == 2237 && index%2 == 0) || (pc == 2253 && index%2 == 1)
    requires |code| > pc && code[pc] == 0x52
    requires Admitted(n,index,a,b,data) && index < 2*n && |prefix| <= 1022
    ensures M.Step(code,{},S.Running(pc,prefix+[Source(n,index,a,b,data),160+index*32],Heap(n,index,a,b,data)),value,data) == S.Running(pc+1,prefix,Heap(n,index+1,a,b,data))
  {
    M.Delegate(code,{},S.Running(pc,prefix+[Source(n,index,a,b,data),160+index*32],Heap(n,index,a,b,data)),value,data);
    reveal S.Step(); Advance(n,index,a,b,data);
  }
  ghost method Fill(n: nat, a: Word, b: Word, data: seq<Byte>) returns (mem: seq<Byte>)
    requires Admitted(n,0,a,b,data)
    ensures mem == Heap(n,2*n,a,b,data) && mem[160..] == Payload(n,a,b,data)
  {
    var index: nat := 0; mem := Heap(n,0,a,b,data);
    while index < 2*n
      invariant index <= 2*n && mem == Heap(n,index,a,b,data)
      decreases 2*n-index
    {
      Advance(n,index,a,b,data);
      mem := S.Store(mem,160+index*32,Source(n,index,a,b,data));
      index := index+1;
    }
    OriginalBytes(n,a,b,data);
  }
}

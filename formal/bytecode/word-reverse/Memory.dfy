// SPDX-License-Identifier: MIT
// Physical reverse-word stores and exact original-byte preservation.
include "../copy/Machine.dfy"
include "../scans/Representation.dfy"
module BytecodeWordReverseMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  import R = BytecodeScanRepresentation
  type Byte = S.Byte
  type Word = S.Word
  function Extent(n: nat): nat { 160+n*32 }
  predicate Admitted(n: nat, filled: nat, start: Word, data: seq<Byte>) {
    n < 0x800000000000000 && filled <= n && |data| < G.Modulus() && start+n*32 <= |data|
  }
  function Heap(n: nat, filled: nat, start: Word, data: seq<Byte>): seq<Byte>
    requires Admitted(n,filled,start,data)
  {
    seq(Extent(n),j requires 0 <= j < Extent(n) =>
      if 64 <= j < 96 then G.Encode(Extent(n),32)[j-64]
      else if 128 <= j < 160 then G.Encode(n*32,32)[j-128]
      else if 160 <= j && n-filled <= (j-160)/32 then
        G.Encode(S.DataWord(data,start+(n-1-(j-160)/32)*32),32)[(j-160)%32]
      else 0)
  }
  function Payload(n: nat, start: Word, data: seq<Byte>): seq<Byte>
    requires Admitted(n,n,start,data)
  {
    seq(n*32,j requires 0 <= j < n*32 => data[start+(n-1-j/32)*32+j%32])
  }
  function Offset(n: nat, i: nat): nat
    requires i < n
  { 160+(n-1-i)*32 }
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
  {
    if width > 0 { ZeroEncoding(width-1); }
  }
  lemma Aligned(n: nat)
    ensures S.Round32(Extent(n)) == Extent(n)
  {}
  lemma Header(n: nat, filled: nat, start: Word, data: seq<Byte>)
    requires Admitted(n,filled,start,data)
    ensures S.Load(Heap(n,filled,start,data),64) == Extent(n)
    ensures S.Load(Heap(n,filled,start,data),128) == n*32
  {
    assert Heap(n,filled,start,data)[64..96] == G.Encode(Extent(n),32);
    assert Heap(n,filled,start,data)[128..160] == G.Encode(n*32,32);
    G.RoundTrip(Extent(n),32); G.RoundTrip(n*32,32);
  }
  lemma Advance(n: nat, i: nat, start: Word, data: seq<Byte>)
    requires Admitted(n,i,start,data) && i < n
    ensures S.Store(Heap(n,i,start,data),Offset(n,i),S.DataWord(data,start+i*32)) == Heap(n,i+1,start,data)
  {
    var before := Heap(n,i,start,data);
    var offset := Offset(n,i);
    Aligned(n);
    C.RoundedMonotone(offset+32,Extent(n));
    assert S.Expand(before,offset+32) == before;
    var after := S.Store(before,offset,S.DataWord(data,start+i*32));
    assert after == before[..offset]+G.Encode(S.DataWord(data,start+i*32),32)+before[offset+32..];
    forall j: nat {:trigger after[j]} | j < Extent(n)
      ensures after[j] == Heap(n,i+1,start,data)[j]
    {
      if offset <= j < offset+32 {
        assert (j-160)/32 == n-1-i && (j-160)%32 == j-offset;
        assert n-1-(j-160)/32 == i;
      } else {
        assert after[j] == before[j];
        if j >= 160 {
          assert (j-160)/32 != n-1-i;
          assert (n-i <= (j-160)/32) == (n-(i+1) <= (j-160)/32);
        }
      }
    }
  }
  lemma WordAt(n: nat, filled: nat, start: Word, data: seq<Byte>, index: nat)
    requires Admitted(n,filled,start,data) && index < n
    ensures S.Load(Heap(n,filled,start,data),160+index*32) ==
            (if n-filled <= index then S.DataWord(data,start+(n-1-index)*32) else 0)
  {
    var offset := 160+index*32;
    var word := if n-filled <= index then S.DataWord(data,start+(n-1-index)*32) else 0;
    var chunk := Heap(n,filled,start,data)[offset..offset+32];
    forall j: nat {:trigger chunk[j]} | j < 32
      ensures chunk[j] == G.Encode(word,32)[j]
    {
      assert (offset+j-160)/32 == index && (offset+j-160)%32 == j;
      if index < n-filled { ZeroEncoding(32); }
    }
    assert chunk == G.Encode(word,32);
    G.LoadProjection(Heap(n,filled,start,data),offset);
    assert G.Grow(Heap(n,filled,start,data),offset+32) == Heap(n,filled,start,data);
    G.WordPower(); G.RoundTrip(word,32);
  }
  lemma OriginalBytes(n: nat, start: Word, data: seq<Byte>)
    requires Admitted(n,n,start,data)
    ensures Heap(n,n,start,data)[160..] == Payload(n,start,data)
  {
    var bytes := Heap(n,n,start,data)[160..];
    forall j: nat {:trigger bytes[j]} | j < n*32
      ensures bytes[j] == Payload(n,start,data)[j]
    {
      var source := start+(n-1-j/32)*32;
      R.WordProjection(data,source);
      EncodeDecode(data[source..source+32]);
      assert G.Encode(S.DataWord(data,source),32) == data[source..source+32];
      assert bytes[j] == G.Encode(S.DataWord(data,source),32)[j%32];
    }
  }
  lemma StoreEffect(code: seq<Byte>, n: nat, i: nat, start: Word, prefix: seq<Word>, value: Word, data: seq<Byte>)
    requires |code| > 5927 && code[5927] == 0x52
    requires Admitted(n,i,start,data) && i < n && |prefix| <= 1022
    ensures M.Step(code,{},S.Running(5927,prefix+[S.DataWord(data,start+i*32),Offset(n,i)],Heap(n,i,start,data)),value,data) == S.Running(5928,prefix,Heap(n,i+1,start,data))
  {
    M.Delegate(code,{},S.Running(5927,prefix+[S.DataWord(data,start+i*32),Offset(n,i)],Heap(n,i,start,data)),value,data);
    reveal S.Step(); Advance(n,i,start,data);
  }
  ghost method Fill(n: nat, start: Word, data: seq<Byte>) returns (mem: seq<Byte>)
    requires Admitted(n,0,start,data)
    ensures mem == Heap(n,n,start,data) && mem[160..] == Payload(n,start,data)
  {
    var index: nat := 0; mem := Heap(n,0,start,data);
    while index < n
      invariant index <= n && mem == Heap(n,index,start,data)
      decreases n-index
    {
      Advance(n,index,start,data);
      mem := S.Store(mem,Offset(n,index),S.DataWord(data,start+index*32));
      index := index+1;
    }
    OriginalBytes(n,start,data);
  }
}

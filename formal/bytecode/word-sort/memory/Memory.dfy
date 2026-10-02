// SPDX-License-Identifier: MIT
// Physical two-buffer original-occurrence frames; allocation/body connection remains separate.
include "../spec/Original.dfy"
include "../../copy/Memory.dfy"
module BytecodeWordSortMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import O = BytecodeWordSortOriginalSpec
  type Byte = S.Byte
  type Word = S.Word
  function Extent(n: nat): nat { 192+2*n*32 }
  function Base(n: nat, right: bool): nat { if right then 160+n*32 else 128 }
  predicate Admitted(n: nat, left: seq<nat>, right: seq<nat>, start: Word, data: seq<Byte>) {
    O.Fits(data,start,n) && |left| == n && |right| == n &&
    (forall i :: 0 <= i < n ==> left[i] <= n && right[i] <= n)
  }
  // Sentinel n describes an unwritten zero scratch word, never an original occurrence.
  function Cell(n: nat, id: nat, start: Word, data: seq<Byte>): Word
    requires O.Fits(data,start,n) && id <= n
  { if id == n then 0 else S.DataWord(data,start+id*32) }
  function Heap(n: nat, left: seq<nat>, right: seq<nat>, start: Word, data: seq<Byte>): seq<Byte>
    requires Admitted(n,left,right,start,data)
  {
    seq(Extent(n),j requires 0 <= j < Extent(n) =>
      if 64 <= j < 96 then G.Encode(Extent(n),32)[j-64]
      else if 128 <= j < 160 then G.Encode(n*32,32)[j-128]
      else if Base(n,true) <= j < Base(n,true)+32 then G.Encode(n*32,32)[j-Base(n,true)]
      else if 160 <= j < Base(n,true) then G.Encode(Cell(n,left[(j-160)/32],start,data),32)[(j-160)%32]
      else if Base(n,true)+32 <= j then G.Encode(Cell(n,right[(j-Base(n,true)-32)/32],start,data),32)[(j-Base(n,true)-32)%32]
      else 0)
  }
  lemma Rounded(n: nat)
    ensures S.Round32(Extent(n)) == Extent(n)
    ensures S.Round32(Base(n,false)) == Base(n,false) && S.Round32(Base(n,true)) == Base(n,true)
  {}
  lemma Headers(n: nat, left: seq<nat>, right: seq<nat>, start: Word, data: seq<Byte>)
    requires Admitted(n,left,right,start,data)
    ensures S.Load(Heap(n,left,right,start,data),64) == Extent(n)
    ensures S.Load(Heap(n,left,right,start,data),128) == n*32
    ensures S.Load(Heap(n,left,right,start,data),Base(n,true)) == n*32
  {
    var mem := Heap(n,left,right,start,data);
    assert mem[64..96] == G.Encode(Extent(n),32);
    assert mem[128..160] == G.Encode(n*32,32);
    assert mem[Base(n,true)..Base(n,true)+32] == G.Encode(n*32,32);
    G.RoundTrip(Extent(n),32); G.RoundTrip(n*32,32);
  }
  lemma SlotByte(n: nat, left: seq<nat>, right: seq<nat>, start: Word, data: seq<Byte>, which: bool, index: nat, byte: nat)
    requires Admitted(n,left,right,start,data) && index < n && byte < 32
    ensures Heap(n,left,right,start,data)[Base(n,which)+32+index*32+byte] == G.Encode(Cell(n,(if which then right else left)[index],start,data),32)[byte]
  {
    var position := Base(n,which)+32+index*32+byte;
    if which {
      assert Base(n,true)+32 <= position < Extent(n);
      assert position >= 160 && position >= Base(n,true)+32;
      assert (position-Base(n,true)-32)/32 == index && (position-Base(n,true)-32)%32 == byte;
      assert Heap(n,left,right,start,data)[position] == G.Encode(Cell(n,right[index],start,data),32)[byte];
    } else {
      assert 160 <= position < Base(n,true);
      assert (position-160)/32 == index && (position-160)%32 == byte;
      assert Heap(n,left,right,start,data)[position] == G.Encode(Cell(n,left[index],start,data),32)[byte];
    }
  }
  lemma Read(n: nat, left: seq<nat>, right: seq<nat>, start: Word, data: seq<Byte>, which: bool, index: nat)
    requires Admitted(n,left,right,start,data) && index < n
    ensures S.Load(Heap(n,left,right,start,data),Base(n,which)+32+index*32) == Cell(n,(if which then right else left)[index],start,data)
  {
    var mem := Heap(n,left,right,start,data);
    var offset: Word := Base(n,which)+32+index*32;
    var value := Cell(n,(if which then right else left)[index],start,data);
    var chunk := mem[offset..offset+32];
    forall j: nat {:trigger chunk[j]} | j < 32
      ensures chunk[j] == G.Encode(value,32)[j]
    {
      SlotByte(n,left,right,start,data,which,index,j);
      assert chunk[j] == mem[offset+j];
    }
    assert chunk == G.Encode(value,32);
    G.LoadProjection(mem,offset);
    assert G.Grow(mem,offset+32) == mem;
    G.WordPower(); G.RoundTrip(value,32);
  }
  lemma Write(n: nat, left: seq<nat>, right: seq<nat>, start: Word, data: seq<Byte>, which: bool, index: nat, id: nat)
    requires Admitted(n,left,right,start,data) && index < n && id <= n
    ensures Admitted(n,(if which then left else left[index := id]),(if which then right[index := id] else right),start,data)
    ensures S.Store(Heap(n,left,right,start,data),Base(n,which)+32+index*32,Cell(n,id,start,data)) ==
            Heap(n,(if which then left else left[index := id]),(if which then right[index := id] else right),start,data)
  {
    var before := Heap(n,left,right,start,data);
    var offset: Word := Base(n,which)+32+index*32;
    Rounded(n); C.RoundedMonotone(offset+32,Extent(n));
    assert S.Expand(before,offset+32) == before;
    var after := S.Store(before,offset,Cell(n,id,start,data));
    assert after == before[..offset]+G.Encode(Cell(n,id,start,data),32)+before[offset+32..];
    var newLeft := if which then left else left[index := id];
    var newRight := if which then right[index := id] else right;
    forall j: nat {:trigger after[j]} | j < Extent(n)
      ensures after[j] == Heap(n,newLeft,newRight,start,data)[j]
    {
      if offset <= j < offset+32 {
        if which { assert (j-Base(n,true)-32)/32 == index && (j-Base(n,true)-32)%32 == j-offset; }
        else { assert (j-160)/32 == index && (j-160)%32 == j-offset; }
      } else {
        assert after[j] == before[j];
        if 160 <= j < Base(n,true) {
          if !which { assert (j-160)/32 != index; }
          assert newLeft[(j-160)/32] == left[(j-160)/32];
        } else if Base(n,true)+32 <= j {
          if which { assert (j-Base(n,true)-32)/32 != index; }
          assert newRight[(j-Base(n,true)-32)/32] == right[(j-Base(n,true)-32)/32];
        }
      }
    }
  }
  lemma OriginalPayload(n: nat, left: seq<nat>, right: seq<nat>, start: Word, data: seq<Byte>, which: bool)
    requires Admitted(n,left,right,start,data) && O.Bounds(n,(if which then right else left))
    ensures Heap(n,left,right,start,data)[Base(n,which)+32..Base(n,which)+32+n*32] == O.Payload(data,start,n,(if which then right else left))
  {
    var ids := if which then right else left;
    O.OriginalBytes(data,start,n,ids);
    var payload := Heap(n,left,right,start,data)[Base(n,which)+32..Base(n,which)+32+n*32];
    forall j: nat {:trigger payload[j]} | j < n*32
      ensures payload[j] == O.Encoded(data,start,n,ids)[j]
    {
      assert ids[j/32] < n;
      assert Cell(n,ids[j/32],start,data) == O.Values(data,start,n)[ids[j/32]];
      SlotByte(n,left,right,start,data,which,j/32,j%32);
      assert j/32*32+j%32 == j;
      assert payload[j] == Heap(n,left,right,start,data)[Base(n,which)+32+j];
    }
  }
}

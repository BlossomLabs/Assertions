// SPDX-License-Identifier: MIT
// Exact accumulator-first and supplied-order element memory writes, including overlaps.
include "../../word-apply/stamp-engine/Memory.dfy"
module BytecodeFoldStampMemoryV2 {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeApplyWindowInputs
  import M = BytecodeApplyStampMemory
  import R = BytecodeScanRepresentation
  predicate Fits(mem: seq<Byte>,ptr: Word,templateLength: Word,accOffset: Word,arrayOffset: Word,count: Word,data: seq<Byte>) {
    M.Fits(mem,ptr,templateLength,arrayOffset,count,data) && 96 <= ptr && accOffset <= templateLength-32
  }
  function Accumulator(mem: seq<Byte>,ptr: Word,accOffset: Word,acc: Word): seq<Byte>
    requires ptr < 0x20000000000000000 && accOffset < 0x10000000000000000
  { Store(mem,ptr+32+accOffset,acc) }
  lemma AccExtent(mem: seq<Byte>,ptr: Word,templateLength: Word,accOffset: Word,arrayOffset: Word,count: Word,data: seq<Byte>,acc: Word)
    requires Fits(mem,ptr,templateLength,accOffset,arrayOffset,count,data)
    ensures |Accumulator(mem,ptr,accOffset,acc)| == |mem|
    ensures M.Fits(Accumulator(mem,ptr,accOffset,acc),ptr,templateLength,arrayOffset,count,data)
  {
    R.StoredWord(mem,ptr+32+accOffset,acc);
    assert ptr+64+accOffset <= |mem|;
    assert Round32(ptr+64+accOffset) <= |mem|;
  }
  function Stamped(mem: seq<Byte>,ptr: Word,templateLength: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,index: nat): seq<Byte>
    requires Fits(mem,ptr,templateLength,accOffset,arrayOffset,count,data) && index <= count
    ensures |Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index)| == |mem|
  {
    AccExtent(mem,ptr,templateLength,accOffset,arrayOffset,count,data,acc);
    M.Extent(Accumulator(mem,ptr,accOffset,acc),ptr,templateLength,arrayOffset,count,data,word,index);
    M.Stamped(Accumulator(mem,ptr,accOffset,acc),ptr,templateLength,arrayOffset,count,data,word,index)
  }
  lemma Extent(mem: seq<Byte>,ptr: Word,templateLength: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,index: nat)
    requires Fits(mem,ptr,templateLength,accOffset,arrayOffset,count,data) && index <= count
    ensures |Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index)| == |mem|
  {
    AccExtent(mem,ptr,templateLength,accOffset,arrayOffset,count,data,acc);
    M.Extent(Accumulator(mem,ptr,accOffset,acc),ptr,templateLength,arrayOffset,count,data,word,index);
  }
  function LastByte(mem: seq<Byte>,ptr: Word,templateLength: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,index: nat,j: nat): Byte
    requires Fits(mem,ptr,templateLength,accOffset,arrayOffset,count,data) && index <= count && j < |mem|
    decreases index
  {
    if index == 0 then
      if ptr+32+accOffset <= j < ptr+64+accOffset then G.Encode(acc,32)[j-(ptr+32+accOffset)] else mem[j]
    else
      W.Index(templateLength,arrayOffset,count,data,index-1);
      var offset: Word := ptr+32+W.At(arrayOffset,index-1,data);
      if offset <= j < offset+32 then G.Encode(word,32)[j-offset]
      else LastByte(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index-1,j)
  }
  lemma OrderedBytes(mem: seq<Byte>,ptr: Word,templateLength: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,index: nat,j: nat)
    requires Fits(mem,ptr,templateLength,accOffset,arrayOffset,count,data) && index <= count && j < |mem|
    ensures Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index)[j] == LastByte(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index,j)
    decreases index
  {
    Extent(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index);
    if index == 0 {
      var offset: Word := ptr+32+accOffset;
      R.StoredWord(mem,offset,acc);
      if offset <= j < offset+32 {
        assert Accumulator(mem,ptr,accOffset,acc)[j] == G.Encode(acc,32)[j-offset];
      } else { M.StoredByteFrame(mem,offset,acc,j); }
    } else {
      OrderedBytes(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index-1,j);
      Extent(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index-1);
      W.Index(templateLength,arrayOffset,count,data,index-1);
      var previous := Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index-1);
      var offset: Word := ptr+32+W.At(arrayOffset,index-1,data);
      assert Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index) == Store(previous,offset,word);
      R.StoredWord(previous,offset,word);
      if offset <= j < offset+32 {
        assert Store(previous,offset,word)[j] == G.Encode(word,32)[j-offset];
      } else { M.StoredByteFrame(previous,offset,word,j); }
    }
  }
  lemma WordFrame(mem: seq<Byte>,ptr: Word,templateLength: Word,accOffset: Word,acc: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,index: nat,slot: Word)
    requires Fits(mem,ptr,templateLength,accOffset,arrayOffset,count,data) && index <= count && (slot as nat)+32 <= ptr
    ensures Load(Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index),slot) == Load(mem,slot)
  {
    Extent(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index);
    AccExtent(mem,ptr,templateLength,accOffset,arrayOffset,count,data,acc);
    var initial := Accumulator(mem,ptr,accOffset,acc);
    var stamped := Stamped(mem,ptr,templateLength,accOffset,acc,arrayOffset,count,data,word,index);
    R.StoredFrame(mem,ptr+32+accOffset,acc,slot);
    forall j: nat {:trigger stamped[slot+j]} | j < 32
      ensures stamped[slot+j] == initial[slot+j]
    { M.Outside(initial,ptr,templateLength,arrayOffset,count,data,word,index,slot+j); }
    var a := stamped[slot..slot+32];
    var b := initial[slot..slot+32];
    forall j: nat {:trigger a[j]} | j < 32
      ensures a[j] == b[j]
    {
      M.Outside(initial,ptr,templateLength,arrayOffset,count,data,word,index,slot+j);
      assert a[j] == stamped[slot+j];
      assert b[j] == initial[slot+j];
    }
    assert a == b;
    assert stamped[slot..slot+32] == initial[slot..slot+32];
    assert G.Grow(stamped,(slot as nat)+32) == stamped;
    assert G.Grow(initial,(slot as nat)+32) == initial;
  }
}

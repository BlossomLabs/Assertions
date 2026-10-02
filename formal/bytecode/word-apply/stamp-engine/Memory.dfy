// SPDX-License-Identifier: MIT
include "../windows/Inputs.dfy"
include "../../scans/Representation.dfy"
module BytecodeApplyStampMemory {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import W = BytecodeApplyWindowInputs
  import R = BytecodeScanRepresentation
  predicate Fits(mem: seq<Byte>,ptr: Word,templateLength: Word,arrayOffset: Word,count: Word,data: seq<Byte>) {
    W.Valid(templateLength,arrayOffset,count,data) && ptr < 0x20000000000000000 && |mem|%32 == 0 && |mem| < 0x80000000000000000 && (ptr as nat)+32+templateLength <= |mem|
  }
  function Stamped(mem: seq<Byte>,ptr: Word,templateLength: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,index: nat): seq<Byte>
    requires Fits(mem,ptr,templateLength,arrayOffset,count,data) && index <= count
    decreases index
  {
    if index == 0 then mem else Store(Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,index-1),ptr+32+W.At(arrayOffset,index-1,data),word)
  }
  lemma Extent(mem: seq<Byte>,ptr: Word,templateLength: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,index: nat)
    requires Fits(mem,ptr,templateLength,arrayOffset,count,data) && index <= count
    ensures |Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,index)| == |mem|
    ensures Fits(Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,index),ptr,templateLength,arrayOffset,count,data)
    decreases index
  {
    if index > 0 {
      Extent(mem,ptr,templateLength,arrayOffset,count,data,word,index-1);
      W.Index(templateLength,arrayOffset,count,data,index-1);
      assert W.At(arrayOffset,index-1,data) <= templateLength-32;
      var previous := Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,index-1);
      R.StoredWord(previous,ptr+32+W.At(arrayOffset,index-1,data),word);
      assert Round32(ptr+64+W.At(arrayOffset,index-1,data)) <= |mem|;
    }
  }
  lemma StoredByteFrame(mem: seq<Byte>,offset: Word,word: Word,j: nat)
    requires |mem|%32 == 0 && (offset as nat)+32 <= |mem| && j < |mem|
    requires j < offset || (offset as nat)+32 <= j
    ensures Store(mem,offset,word)[j] == mem[j]
  {
    R.StoredWord(mem,offset,word);
    assert Round32((offset as nat)+32) <= |mem|;
    assert Expand(mem,(offset as nat)+32) == mem;
    assert G.Grow(mem,(offset as nat)+32) == mem;
    if j < offset {} else { assert (offset as nat)+32 <= j; }
  }
  lemma Outside(mem: seq<Byte>,ptr: Word,templateLength: Word,arrayOffset: Word,count: Word,data: seq<Byte>,word: Word,index: nat,j: nat)
    requires Fits(mem,ptr,templateLength,arrayOffset,count,data) && index <= count && j < |mem|
    requires j < ptr+32 || ptr+32+templateLength <= j
    ensures |Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,index)| == |mem|
    ensures Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,index)[j] == mem[j]
    decreases index
  {
    Extent(mem,ptr,templateLength,arrayOffset,count,data,word,index);
    if index > 0 {
      Outside(mem,ptr,templateLength,arrayOffset,count,data,word,index-1,j);
      W.Index(templateLength,arrayOffset,count,data,index-1);
      assert W.At(arrayOffset,index-1,data) <= templateLength-32;
      var previous := Stamped(mem,ptr,templateLength,arrayOffset,count,data,word,index-1);
      Extent(mem,ptr,templateLength,arrayOffset,count,data,word,index-1);
      var offset: Word := ptr+32+W.At(arrayOffset,index-1,data);
      assert j < offset || (offset as nat)+32 <= j;
      StoredByteFrame(previous,offset,word,j);
    }
  }
}

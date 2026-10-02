// SPDX-License-Identifier: MIT
// Actual array offset/header stores admit byte encoding and preserve the source heap.
include "ArraySpec.dfy"
include "Memory.dfy"
module AssertionsGatherArrayMemory {
  import D = AssertionsGatherArraySpec
  import B = AssertionsGatherBytesSpec
  import M = AssertionsGatherBytesMemory
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  type Word = S.Word
  type Byte = S.Byte
  lemma Start(mem: seq<Byte>, arrayBase: Word, base: Word, count: Word)
    requires D.StartHeap(mem,arrayBase,base,count)
    ensures D.LoopHeap(D.Header2(mem,base,count),arrayBase,base,base+64+count*32,base+64,count,arrayBase+32,0)
    ensures S.Load(D.Header2(mem,base,count),base) == 32
    ensures S.Load(D.Header2(mem,base,count),base+32) == count
    ensures forall p: nat {:trigger D.Header2(mem,base,count)[p]} :: p < |mem| && p < base ==> D.Header2(mem,base,count)[p] == mem[p]
  {
    D.StartWords(mem,arrayBase,base,count);
    R.StoredWord(mem,base,32);
    var first := D.Header1(mem,base);
    R.StoredWord(first,base+32,count);
    R.StoredFrame(first,base+32,count,base);
    forall p: nat {:trigger D.Header2(mem,base,count)[p]} | p < |mem| && p < base
      ensures D.Header2(mem,base,count)[p] == mem[p]
    { M.StorePoint(mem,base,32,p); M.StorePoint(first,base+32,count,p); }
  }
  predicate Object(mem: seq<Byte>, base: Word, ptr: Word, length: Word) {
    ptr+32+length <= |mem| && ptr+32+length <= base && S.Load(mem,ptr) == length
  }
  lemma Prepared(mem: seq<Byte>, arrayBase: Word, base: Word, tail: Word, head: Word,
                 count: Word, source: Word, index: Word, ptr: Word, length: Word)
    requires D.LoopHeap(mem,arrayBase,base,tail,head,count,source,index) && index < count
    requires Object(mem,base,ptr,length) && tail+64+S.Round32(length) < 0x10000000000000000
    ensures B.Heap(D.Slot(mem,base,tail,head),tail,ptr,length)
    ensures |mem| <= |D.Slot(mem,base,tail,head)|
    ensures S.Load(D.Slot(mem,base,tail,head),head) == D.Offset(base,tail)
    ensures D.Slot(mem,base,tail,head)[ptr+32..ptr+32+length] == mem[ptr+32..ptr+32+length]
    ensures forall p: nat {:trigger D.Slot(mem,base,tail,head)[p]} :: p < |mem| && p < base ==> D.Slot(mem,base,tail,head)[p] == mem[p]
  {
    D.LoopWords(mem,arrayBase,base,tail,head,count,source,index);
    var offset := D.Offset(base,tail);
    R.StoredWord(mem,head,offset); R.StoredFrame(mem,head,offset,ptr);
    forall p: nat {:trigger D.Slot(mem,base,tail,head)[p]} | p < |mem| && p < base
      ensures D.Slot(mem,base,tail,head)[p] == mem[p]
    { M.StorePoint(mem,head,offset,p); }
    forall p: nat {:trigger D.Slot(mem,base,tail,head)[ptr+32+p]} | p < length
      ensures D.Slot(mem,base,tail,head)[ptr+32+p] == mem[ptr+32+p]
    { M.StorePoint(mem,head,offset,ptr+32+p); }
  }
  lemma LoadEqual(before: seq<Byte>, after: seq<Byte>, offset: Word)
    requires offset+32 <= |before| && offset+32 <= |after|
    requires forall p: nat {:trigger after[p]} :: offset <= p < offset+32 ==> after[p] == before[p]
    ensures S.Load(after,offset) == S.Load(before,offset)
  {
    assert after[offset..offset+32] == before[offset..offset+32];
    assert G.Grow(after,offset+32) == after && G.Grow(before,offset+32) == before;
  }
  lemma After(mem: seq<Byte>, arrayBase: Word, base: Word, tail: Word, head: Word,
              count: Word, source: Word, index: Word, ptr: Word, length: Word)
    requires D.LoopHeap(mem,arrayBase,base,tail,head,count,source,index) && index < count
    requires Object(mem,base,ptr,length) && tail+96+S.Round32(length) < 0x10000000000000000
    requires B.Heap(D.Slot(mem,base,tail,head),tail,ptr,length)
    ensures D.LoopHeap(B.Image(D.Slot(mem,base,tail,head),tail,ptr,length),arrayBase,base,B.End(tail,length),head+32,count,source+32,index+1)
    ensures forall p: nat {:trigger B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)[p]} :: p < |mem| && p < base ==> B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)[p] == mem[p]
  {
    hide S.Load(); hide G.Decode(); hide S.BitNot(); hide G.BitAnd(); hide B.Image(); hide B.Payload(); hide D.Slot();
    Prepared(mem,arrayBase,base,tail,head,count,source,index,ptr,length);
    var prepared := D.Slot(mem,base,tail,head);
    M.Built(prepared,tail,ptr,length); C.Rounded(length);
    forall p: nat {:trigger B.Image(prepared,tail,ptr,length)[p]} | p < |mem| && p < base
      ensures B.Image(prepared,tail,ptr,length)[p] == mem[p]
    {}
  }
  lemma Effect(mem: seq<Byte>, arrayBase: Word, base: Word, tail: Word, head: Word,
               count: Word, source: Word, index: Word, ptr: Word, length: Word)
    requires D.LoopHeap(mem,arrayBase,base,tail,head,count,source,index) && index < count
    requires Object(mem,base,ptr,length) && tail+96+S.Round32(length) < 0x10000000000000000
    requires B.Heap(D.Slot(mem,base,tail,head),tail,ptr,length)
    ensures |mem| <= |B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)|
    ensures S.Load(B.Image(D.Slot(mem,base,tail,head),tail,ptr,length),head) == D.Offset(base,tail)
    ensures B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)[tail..tail+32] == G.Encode(length,32)
    ensures B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)[tail+32..tail+32+length] == mem[ptr+32..ptr+32+length]
    ensures forall p: nat {:trigger B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)[p]} :: tail+32+length <= p < B.End(tail,length) ==> B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)[p] == 0
    ensures forall p: nat {:trigger B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)[p]} :: p < |mem| && p < tail && (p < head || head+32 <= p) ==> B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)[p] == mem[p]
    ensures forall p: nat {:trigger B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)[p]} :: p < |mem| && p < base ==> B.Image(D.Slot(mem,base,tail,head),tail,ptr,length)[p] == mem[p]
  {
    Prepared(mem,arrayBase,base,tail,head,count,source,index,ptr,length);
    var prepared := D.Slot(mem,base,tail,head);
    M.Built(prepared,tail,ptr,length); C.Rounded(length);
    var image := B.Image(prepared,tail,ptr,length);
    forall p: nat {:trigger image[p]} | p < |mem| && p < tail && (p < head || head+32 <= p)
      ensures image[p] == mem[p]
    { M.StoreOutside(mem,head,D.Offset(base,tail),p); }
    forall p: nat {:trigger image[p]} | head <= p < head+32
      ensures image[p] == prepared[p]
    {}
    LoadEqual(prepared,image,head);
    forall p: nat {:trigger B.Image(prepared,tail,ptr,length)[p]} | p < |mem| && p < base
      ensures B.Image(prepared,tail,ptr,length)[p] == mem[p]
    {}
  }
}

// SPDX-License-Identifier: MIT
include "../loop-output/Properties.dfy"
include "../../word-unique/Memory.dfy"
module BytecodeApplyRawLoopOutputBytes {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import I = BytecodeApplyRawInputs
  import L = BytecodeApplyRawLoopState
  import C = BytecodeApplyCallbackSuccessMemory
  import P = BytecodeApplyRawLoopOutputProperties
  import U = BytecodeWordUniqueMemory
  function Encoded(words: seq<S.Word>): seq<S.Byte>
    ensures |Encoded(words)| == 32*|words|
    decreases |words|
  { if |words| == 0 then [] else G.Encode(words[0],32)+Encoded(words[1..]) }
  lemma Append(words: seq<S.Word>,word: S.Word)
    ensures Encoded(words+[word]) == Encoded(words)+G.Encode(word,32)
    decreases |words|
  {
    if |words| > 0 {
      Append(words[1..],word);
      assert (words+[word])[1..] == words[1..]+[word];
    }
  }
  lemma ByteAt(words: seq<S.Word>,index: nat)
    requires index < 32*|words|
    ensures Encoded(words)[index] == G.Encode(words[index/32],32)[index%32]
    decreases |words|
  {
    if index < 32 { assert index/32 == 0 && index%32 == index; }
    else {
      ByteAt(words[1..],index-32);
      assert (index-32)/32 == index/32-1 && (index-32)%32 == index%32;
    }
  }
  function Block(data: seq<S.Byte>,index: S.Word): seq<S.Byte>
    requires L.Fits(data) && index < L.N(data)
    ensures |Block(data,index)| == 32
    ensures G.Encode(L.Original(data,index),32) == Block(data,index)
  {
    var word := L.Original(data,index);
    var block := data[I.Offset(I.SourceHead(data))+32*index..I.Offset(I.SourceHead(data))+32*index+32];
    U.EncodeDecode(block);
    block
  }
  lemma Receipt(returned: seq<S.Byte>)
    requires |returned| == 32
    ensures G.Encode(C.Result(returned),32) == returned
  {
    R.WordProjection(returned,0);
    assert returned[0..32] == returned;
    assert C.Result(returned) == S.DataWord(returned,0);
    assert C.Result(returned) == G.Decode(returned);
    U.EncodeDecode(returned);
  }
  lemma LoadBytes(heap: seq<S.Byte>,offset: S.Word)
    requires offset+32 <= |heap|
    ensures S.Load(heap,offset) == G.Decode(heap[offset..offset+32])
    ensures G.Encode(S.Load(heap,offset),32) == heap[offset..offset+32]
  {
    assert G.Grow(heap,offset+32) == heap;
    G.LoadProjection(heap,offset);
    U.EncodeDecode(heap[offset..offset+32]);
  }
  function Payload(data: seq<S.Byte>,filter: bool,receipts: seq<seq<S.Byte>>,index: S.Word): seq<S.Byte>
    requires L.Receipts(data,filter,receipts) && index <= L.N(data)
    ensures |Payload(data,filter,receipts,index)| == 32*L.Kept(data,filter,receipts,index)
    decreases index
  {
    if index == 0 then []
    else var prior := Payload(data,filter,receipts,index-1);
         if filter && C.Result(receipts[index-1]) == 0 then prior
         else prior+(if filter then Block(data,index-1) else receipts[index-1])
  }
  lemma SelectedBytes(data: seq<S.Byte>,filter: bool,receipts: seq<seq<S.Byte>>,index: S.Word)
    requires L.Receipts(data,filter,receipts) && index <= L.N(data)
    ensures Encoded(L.Selected(data,filter,receipts,index)) == Payload(data,filter,receipts,index)
    decreases index
  {
    if index > 0 {
      SelectedBytes(data,filter,receipts,index-1);
      if !filter || C.Result(receipts[index-1]) != 0 {
        var word := if filter then L.Original(data,index-1) else C.Result(receipts[index-1]);
        Append(L.Selected(data,filter,receipts,index-1),word);
        if filter { var block := Block(data,index-1); }
        else { Receipt(receipts[index-1]); }
      }
    }
  }
  lemma PhysicalBytes(data: seq<S.Byte>,filter: bool,receipts: seq<seq<S.Byte>>,index: S.Word)
    requires L.Receipts(data,filter,receipts) && index <= L.N(data)
    ensures L.Heap(data,filter,receipts,index)[160..160+32*L.Kept(data,filter,receipts,index)] == Payload(data,filter,receipts,index)
  {
    hide G.BitAnd();
    P.HeapWords(data,filter,receipts,index);
    SelectedBytes(data,filter,receipts,index);
    var heap := L.Heap(data,filter,receipts,index);
    var words := L.Selected(data,filter,receipts,index);
    var bytes := heap[160..160+32*L.Kept(data,filter,receipts,index)];
    assert |bytes| == |Encoded(words)|;
    forall j: nat | j < |bytes|
      ensures bytes[j] == Encoded(words)[j]
    {
      var slot: S.Word := j/32;
      var offset: S.Word := 160+32*slot;
      assert offset+32 <= |heap|;
      LoadBytes(heap,offset);
      assert G.Encode(words[slot],32) == heap[offset..offset+32];
      ByteAt(words,j);
      assert offset+j%32 == 160+j;
    }
  }
}

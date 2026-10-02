// SPDX-License-Identifier: MIT
// Independent allocation sum and filled-slot invariants for arbitrarily many RAW operands.
include "Iteration.dfy"
module AssertionsGatherLoopSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import I = AssertionsGatherRawIteration
  import B = AssertionsGatherLoopBounds
  import H = AssertionsGatherLoopMemory
  import P = AssertionsPrimitivePreparation
  import M = AssertionsRawResolveMemory
  type Word = S.Word
  type Byte = S.Byte
  datatype Item = RawItem(operand: Word, bytesRelative: Word, constraintsRelative: Word, length: Word)
  function Used(items: seq<Item>, index: nat): nat
    requires index <= |items|
    decreases index
  { if index == 0 then 0 else Used(items,index-1)+64+S.Round32(items[index-1].length) }
  opaque function Position(start: nat, items: seq<Item>, index: nat): nat
    requires index <= |items|
  { start+Used(items,index) }
  lemma Next(items: seq<Item>, index: nat)
    requires index < |items|
    ensures Position(0,items,index+1) == Position(0,items,index)+64+S.Round32(items[index].length)
  { reveal Position(); }
  lemma AtZero(start: nat, items: seq<Item>)
    ensures Position(start,items,0) == start
  { reveal Position(); }
  lemma AtLeast(start: nat, items: seq<Item>, index: nat)
    requires index <= |items|
    ensures start <= Position(start,items,index)
  { reveal Position(); }
  lemma AdvancePosition(start: nat, items: seq<Item>, index: nat)
    requires index < |items|
    ensures Position(start,items,index+1) == Position(start,items,index)+64+S.Round32(items[index].length)
  { reveal Position(); }
  lemma Monotone(items: seq<Item>, index: nat, end: nat)
    requires index <= end <= |items|
    ensures Used(items,index) <= Used(items,end)
    decreases end
  { if index < end { Monotone(items,index,end-1); } }
  lemma Aligned(items: seq<Item>, index: nat)
    requires index <= |items|
    ensures Used(items,index)%32 == 0
    decreases index
  { if index > 0 { Aligned(items,index-1); } }
  predicate Calldata(data: seq<Byte>, args: Word, items: seq<Item>) {
    |items| < 0x10000000000000000 && |data| < 0x10000000000000000 && args+|items|*32 < G.Modulus() &&
    forall index {:trigger items[index]} :: 0 <= index < |items| ==> I.Data(data,args,|items|,index,items[index].operand,items[index].bytesRelative,items[index].constraintsRelative,items[index].length)
  }
  predicate Ready(mem: seq<Byte>, arrayBase: Word, count: Word, free: Word) {
    |mem|%32 == 0 && 96 <= |mem| <= free+32 && free%32 == 0 && 128 <= free && free+32 < 0x10000000000000000 &&
    128 <= arrayBase && arrayBase+32+count*32 <= free && arrayBase+32+count*32 <= |mem| &&
    S.Load(mem,arrayBase) == count && S.Load(mem,64) == free
  }
  opaque function Cell(mem: seq<Byte>, offset: Word): Word { S.Load(mem,offset) }
  lemma CellRead(mem: seq<Byte>, offset: Word)
    ensures Cell(mem,offset) == S.Load(mem,offset)
  { reveal Cell(); }
  opaque predicate Done(mem: seq<Byte>, arrayBase: Word, start: nat, items: seq<Item>, index: nat)
  {
    index <= |items| && forall j {:trigger Position(start,items,j)} :: 0 <= j < index ==>
                                                                         Cell(mem,((arrayBase+32+j*32)%G.Modulus())) == Position(start,items,j)+32
  }
  lemma Filled(mem: seq<Byte>, arrayBase: Word, start: nat, items: seq<Item>, index: nat)
    requires index <= |items|
    requires forall j {:trigger Position(start,items,j)} :: 0 <= j < index ==> Cell(mem,((arrayBase+32+j*32)%G.Modulus())) == Position(start,items,j)+32
    ensures Done(mem,arrayBase,start,items,index)
  { reveal Done(); }
  lemma Admit(mem: seq<Byte>, data: seq<Byte>, args: Word, arrayBase: Word, start: nat, items: seq<Item>, index: nat)
    requires Calldata(data,args,items) && index < |items|
    requires start+Used(items,|items|)+96 < 0x10000000000000000
    requires Position(start,items,index) < 0x10000000000000000
    requires Ready(mem,arrayBase,|items|,Position(start,items,index))
    ensures I.Heap(mem,arrayBase,|items|,Position(start,items,index),items[index].length)
    ensures M.Fits(P.EmptyAssertion(mem,Position(start,items,index)),Position(start,items,index)+32,items[index].operand+items[index].bytesRelative+32,items[index].length,data)
  {
    reveal Position();
    Monotone(items,index+1,|items|); Next(items,index);
    var free: Word := Position(start,items,index);
    var item := items[index];
    H.Prepared(mem,free);
  }
  lemma RoundAlignment(free: Word, length: Word)
    requires free%32 == 0
    ensures (free+64+S.Round32(length))%32 == 0
  {}
  lemma ImageReady(mem: seq<Byte>, data: seq<Byte>, args: Word, count: Word, arrayBase: Word, free: Word, index: Word, operand: Word, bytesRelative: Word, constraintsRelative: Word, length: Word)
    requires I.Data(data,args,count,index,operand,bytesRelative,constraintsRelative,length) && I.Heap(mem,arrayBase,count,free,length)
    requires M.Fits(P.EmptyAssertion(mem,free),free+32,operand+bytesRelative+32,length,data)
    ensures Ready(I.Image(mem,arrayBase,index,free,operand,bytesRelative,length,data),arrayBase,count,free+64+S.Round32(length))
  {
    hide I.Image(); hide M.Construct(); hide P.EmptyAssertion();
    RoundAlignment(free,length);
    H.Prepared(mem,free);
    var prepared := P.EmptyAssertion(mem,free);
    var payload: Word := operand+bytesRelative+32;
    M.Built(prepared,free+32,payload,length,data);
    var built := M.Construct(prepared,free+32,payload,length,data);
    H.IterationFrame(mem,free,payload,length,data,arrayBase);
    B.ArrayOffsets(arrayBase,count,index);
    var slot: Word := arrayBase+32+index*32;
    R.StoredWord(built,slot,free+32); R.StoredFrame(built,slot,free+32,64); R.StoredFrame(built,slot,free+32,arrayBase);
    assert slot+32 <= |built|;
    assert S.Expand(built,slot+32) == built;
    assert |S.Store(built,slot,free+32)| == |built|;
    var image := I.Image(mem,arrayBase,index,free,operand,bytesRelative,length,data);
    assert image == S.Store(built,slot,free+32) by { reveal I.Image(); }
    assert Ready(image,arrayBase,count,free+64+S.Round32(length));
  }
  lemma PreviousSlot(mem: seq<Byte>, data: seq<Byte>, args: Word, count: Word, arrayBase: Word, free: Word, index: Word, operand: Word, bytesRelative: Word, constraintsRelative: Word, length: Word, previous: nat)
    requires I.Data(data,args,count,index,operand,bytesRelative,constraintsRelative,length) && I.Heap(mem,arrayBase,count,free,length)
    requires M.Fits(P.EmptyAssertion(mem,free),free+32,operand+bytesRelative+32,length,data) && previous < index
    ensures S.Load(I.Image(mem,arrayBase,index,free,operand,bytesRelative,length,data),arrayBase+32+previous*32) == S.Load(mem,arrayBase+32+previous*32)
  {
    var payload: Word := operand+bytesRelative+32;
    var built := M.Construct(P.EmptyAssertion(mem,free),free+32,payload,length,data);
    var other: Word := arrayBase+32+previous*32;
    var slot: Word := arrayBase+32+index*32;
    H.IterationFrame(mem,free,payload,length,data,other);
    M.Built(P.EmptyAssertion(mem,free),free+32,payload,length,data);
    R.StoredFrame(built,slot,free+32,other);
  }
  lemma FillAdvance(mem: seq<Byte>, next: seq<Byte>, data: seq<Byte>, args: Word, arrayBase: Word, free: Word, start: nat, items: seq<Item>, index: nat)
    requires index < |items| && free == Position(start,items,index) && Done(mem,arrayBase,start,items,index)
    requires Calldata(data,args,items) && I.Heap(mem,arrayBase,|items|,free,items[index].length)
    requires M.Fits(P.EmptyAssertion(mem,free),free+32,items[index].operand+items[index].bytesRelative+32,items[index].length,data)
    requires next == I.Image(mem,arrayBase,index,free,items[index].operand,items[index].bytesRelative,items[index].length,data)
    requires S.Load(next,arrayBase+32+index*32) == free+32
    ensures Done(next,arrayBase,start,items,index+1)
  {
    var item := items[index];
    assert I.Data(data,args,|items|,index,item.operand,item.bytesRelative,item.constraintsRelative,item.length);
    hide I.Image(); hide I.Data(); hide Calldata();
    reveal Done();
    forall j {:trigger Position(start,items,j)} | 0 <= j < index+1
      ensures Cell(next,((arrayBase+32+j*32)%G.Modulus())) == Position(start,items,j)+32
    {
      assert arrayBase+32+j*32 < G.Modulus();
      var older := items[j];
      var offset: Word := arrayBase+32+j*32;
      assert offset%G.Modulus() == offset;
      if j < index {
        assert Cell(mem,((arrayBase+32+j*32)%G.Modulus())) == Position(start,items,j)+32;
        CellRead(mem,offset);
        assert S.Load(mem,offset) == Position(start,items,j)+32;
        PreviousSlot(mem,data,args,|items|,arrayBase,free,index,item.operand,item.bytesRelative,item.constraintsRelative,item.length,j);
        assert S.Load(next,offset) == S.Load(mem,offset);
        CellRead(next,offset);
      } else {
        assert j == index && Position(start,items,j) == free;
        assert S.Load(next,offset) == free+32;
        CellRead(next,offset);
      }
    }
    Filled(next,arrayBase,start,items,index+1);
  }

}

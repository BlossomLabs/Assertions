// SPDX-License-Identifier: MIT
// Independent bytes-object contents and preservation across later RAW iterations.
include "LoopSpec.dfy"
module AssertionsGatherObjects {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import P = AssertionsGatherLoopSpec
  import I = AssertionsGatherRawIteration
  import H = AssertionsGatherLoopMemory
  import Q = AssertionsPrimitivePreparation
  import M = AssertionsRawResolveMemory
  type Word = S.Word
  type Byte = S.Byte
  predicate Value(data: seq<Byte>, mem: seq<Byte>, item: P.Item, position: nat) {
    position+64+item.length <= |mem| && item.operand+item.bytesRelative+32+item.length <= |data| &&
    S.Load(mem,((position+32)%G.Modulus())) == item.length &&
    mem[position+64..position+64+item.length] == data[item.operand+item.bytesRelative+32..item.operand+item.bytesRelative+32+item.length]
  }
  predicate Done(data: seq<Byte>, mem: seq<Byte>, start: nat, items: seq<P.Item>, index: nat)
    requires index <= |items|
  {
    forall j {:trigger items[j]} :: 0 <= j < index ==> Value(data,mem,items[j],P.Position(start,items,j))
  }
  lemma Produced(data: seq<Byte>, mem: seq<Byte>, item: P.Item, free: Word)
    requires free+32 < G.Modulus() && free+64+item.length <= |mem|
    requires item.operand+item.bytesRelative+32+item.length <= |data|
    requires S.Load(mem,free+32) == item.length
    requires mem[free+64..free+64+item.length] == data[item.operand+item.bytesRelative+32..item.operand+item.bytesRelative+32+item.length]
    ensures Value(data,mem,item,free)
  {}
  lemma Earlier(mem: seq<Byte>, data: seq<Byte>, args: Word, count: Word, arrayBase: Word, free: Word, index: Word, item: P.Item, older: P.Item, position: nat)
    requires I.Data(data,args,count,index,item.operand,item.bytesRelative,item.constraintsRelative,item.length) && I.Heap(mem,arrayBase,count,free,item.length)
    requires M.Fits(Q.EmptyAssertion(mem,free),free+32,item.operand+item.bytesRelative+32,item.length,data)
    requires Value(data,mem,older,position) && position+64+older.length <= free && arrayBase+32+count*32 <= position+32
    ensures Value(data,I.Image(mem,arrayBase,index,free,item.operand,item.bytesRelative,item.length,data),older,position)
  {
    hide I.Image(); hide M.Construct(); hide Q.EmptyAssertion();
    var offset: Word := item.operand+item.bytesRelative+32;
    var header: Word := position+32;
    var payload: Word := position+64;
    var slot: Word := arrayBase+32+index*32;
    var built := M.Construct(Q.EmptyAssertion(mem,free),free+32,offset,item.length,data);
    M.Built(Q.EmptyAssertion(mem,free),free+32,offset,item.length,data);
    H.IterationFrame(mem,free,offset,item.length,data,header);
    H.IterationRegion(mem,free,offset,item.length,data,payload,older.length);
    R.StoredFrame(built,slot,free+32,header);
    H.StoredRegion(built,slot,free+32,payload,older.length);
    var image := I.Image(mem,arrayBase,index,free,item.operand,item.bytesRelative,item.length,data);
    assert image == S.Store(built,slot,free+32) by { reveal I.Image(); }
    var previous: Word := position;
    Produced(data,image,older,previous);
  }
  lemma PastEnd(start: nat, items: seq<P.Item>, previous: nat, index: nat)
    requires previous < index <= |items|
    ensures P.Position(start,items,previous)+64+items[previous].length <= P.Position(start,items,index)
  {
    reveal P.Position();
    P.Next(items,previous); P.Monotone(items,previous+1,index);
  }
  lemma Advance(mem: seq<Byte>, next: seq<Byte>, data: seq<Byte>, args: Word, arrayBase: Word, free: Word, start: nat, items: seq<P.Item>, index: nat)
    requires index < |items| && free == P.Position(start,items,index) && Done(data,mem,start,items,index)
    requires P.Calldata(data,args,items) && I.Heap(mem,arrayBase,|items|,free,items[index].length)
    requires arrayBase+32+|items|*32 <= start
    requires M.Fits(Q.EmptyAssertion(mem,free),free+32,items[index].operand+items[index].bytesRelative+32,items[index].length,data)
    requires next == I.Image(mem,arrayBase,index,free,items[index].operand,items[index].bytesRelative,items[index].length,data)
    requires Value(data,next,items[index],free)
    ensures Done(data,next,start,items,index+1)
  {
    var item := items[index];
    assert I.Data(data,args,|items|,index,item.operand,item.bytesRelative,item.constraintsRelative,item.length);
    hide I.Image(); hide I.Data(); hide P.Calldata(); hide Value();
    forall j {:trigger items[j]} | 0 <= j < index+1
      ensures Value(data,next,items[j],P.Position(start,items,j))
    {
      if j < index {
        assert Value(data,mem,items[j],P.Position(start,items,j));
        PastEnd(start,items,j,index); P.AtLeast(start,items,j);
        Earlier(mem,data,args,|items|,arrayBase,free,index,item,items[j],P.Position(start,items,j));
      } else { assert j == index; }
    }
    assert Done(data,next,start,items,index+1);
  }

}

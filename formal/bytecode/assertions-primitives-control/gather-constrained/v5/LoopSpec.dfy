// SPDX-License-Identifier: MIT
// Independent constrained-RAW allocation totals and completed gather object specification.
include "../Iteration.dfy"
module AssertionsGatherConstrainedLoopSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = AssertionsGatherConstrainedIteration
  import C = AssertionsConstraintLoopSpec
  import M = AssertionsGatherConstrainedMemory
  import Q = BytecodeCopyMemory
  type Word = S.Word
  type Byte = S.Byte
  datatype Item = RawItem(operand: Word, bytesRelative: Word, constraintsRelative: Word, length: Word, constraints: seq<C.Constraint>)
  function Used(items: seq<Item>, index: nat): nat
    requires index <= |items|
    decreases index
  { if index == 0 then 0 else Used(items,index-1)+64+S.Round32(items[index-1].length)+C.Cost(items[index-1].constraints) }
  opaque function Position(start: nat, items: seq<Item>, index: nat): nat
    requires index <= |items|
  { start+Used(items,index) }
  lemma AtZero(start: nat, items: seq<Item>)
    ensures Position(start,items,0) == start
  { reveal Position(); }
  lemma Positions(start: nat, items: seq<Item>, index: nat)
    requires index <= |items|
    ensures Position(start,items,index) == start+Used(items,index)
    ensures start <= Position(start,items,index)
  { reveal Position(); }
  lemma AdvancePosition(start: nat, items: seq<Item>, index: nat)
    requires index < |items|
    ensures Position(start,items,index+1) == Position(start,items,index)+64+S.Round32(items[index].length)+C.Cost(items[index].constraints)
  { reveal Position(); }
  lemma Monotone(items: seq<Item>, index: nat, end: nat)
    requires index <= end <= |items|
    ensures Used(items,index) <= Used(items,end)
    decreases end-index
  { if index < end { Monotone(items,index,end-1); } }
  lemma ConstraintAlignment(cs: seq<C.Constraint>)
    ensures C.Cost(cs)%32 == 0
    decreases |cs|
  {
    if |cs| > 0 {
      ConstraintAlignment(cs[..|cs|-1]);
      Q.Rounded(cs[|cs|-1].length);
    }
  }
  lemma Aligned(items: seq<Item>, index: nat)
    requires index <= |items|
    ensures Used(items,index)%32 == 0
    decreases index
  {
    if index > 0 {
      Aligned(items,index-1); Q.Rounded(items[index-1].length);
      ConstraintAlignment(items[index-1].constraints);
    }
  }
  predicate Layout(data: seq<Byte>, items: seq<Item>) {
    |data| < 0x10000000000000000 &&
    forall j: nat {:trigger items[j]} :: j < |items| ==> (items[j].operand as nat)+items[j].bytesRelative+32+items[j].length <= |data|
  }
  predicate Calldata(data: seq<Byte>, args: Word, items: seq<Item>) {
    |items| < 0x10000000000000000 && Layout(data,items) && (args as nat)+|items|*32 < G.Modulus() &&
    forall index {:trigger items[index]} :: 0 <= index < |items| ==>
      I.Data(data,args,|items|,index,items[index].operand,items[index].bytesRelative,items[index].constraintsRelative,items[index].length,items[index].constraints)
  }
  predicate Budget(start: nat, items: seq<Item>) { start+Used(items,|items|)+160 < 0x10000000000000000 }
  opaque predicate Done(data: seq<Byte>, mem: seq<Byte>, arrayBase: Word, start: nat, items: seq<Item>, index: nat)
    requires Layout(data,items) && Budget(start,items)
  {
    index <= |items| && (arrayBase as nat)+32+|items|*32 < G.Modulus() &&
    forall j {:trigger Position(start,items,j)} :: 0 <= j < index ==>
      (arrayBase as nat)+64+j*32 <= |mem| && S.Load(mem,arrayBase+32+j*32) == Position(start,items,j)+32 &&
      Position(start,items,j)+64+items[j].length <= |mem| && Position(start,items,j)+64+items[j].length < G.Modulus() &&
      S.Load(mem,Position(start,items,j)+32) == items[j].length &&
      mem[Position(start,items,j)+64..Position(start,items,j)+64+items[j].length] ==
      data[items[j].operand+items[j].bytesRelative+32..items[j].operand+items[j].bytesRelative+32+items[j].length]
  }
  lemma PastEnd(start: nat, items: seq<Item>, index: nat, end: nat)
    requires index < end <= |items|
    ensures Position(start,items,index)+64+items[index].length <= Position(start,items,end)
  {
    AdvancePosition(start,items,index);
    Monotone(items,index+1,end);
    Positions(start,items,end); Positions(start,items,index+1);
    Q.Rounded(items[index].length);
  }
  lemma Admit(mem: seq<Byte>, data: seq<Byte>, args: Word, arrayBase: Word, start: nat, items: seq<Item>, index: nat)
    requires Calldata(data,args,items) && index < |items| && Budget(start,items)
    requires Position(start,items,index) < 0x10000000000000000
    requires I.Ready(mem,arrayBase,|items|,Position(start,items,index))
    ensures I.Data(data,args,|items|,index,items[index].operand,items[index].bytesRelative,items[index].constraintsRelative,items[index].length,items[index].constraints)
    ensures I.Heap(mem,arrayBase,|items|,Position(start,items,index),items[index].length,items[index].constraints)
  {
    Monotone(items,index+1,|items|);
    AdvancePosition(start,items,index); Positions(start,items,index); Positions(start,items,index+1);
  }
  lemma {:isolate_assertions} Advance(data: seq<Byte>, mem: seq<Byte>, next: seq<Byte>, args: Word, arrayBase: Word, free: Word,
                                    start: nat, items: seq<Item>, index: nat)
    requires Calldata(data,args,items) && Budget(start,items) && index < |items| && free == Position(start,items,index)
    requires I.Heap(mem,arrayBase,|items|,free,items[index].length,items[index].constraints) && Done(data,mem,arrayBase,start,items,index)
    requires (arrayBase as nat)+32+|items|*32 <= start
    requires I.Ready(next,arrayBase,|items|,I.NextFree(free,items[index].length,items[index].constraints))
    requires M.End(mem,free) <= |next|
    requires next[128..arrayBase+32+index*32] == mem[128..arrayBase+32+index*32]
    requires next[arrayBase+64+index*32..M.End(mem,free)] == mem[arrayBase+64+index*32..M.End(mem,free)]
    requires S.Load(next,arrayBase+32+index*32) == free+32
    requires (free as nat)+64+items[index].length <= |next| && S.Load(next,free+32) == items[index].length
    requires next[free+64..free+64+items[index].length] == data[items[index].operand+items[index].bytesRelative+32..items[index].operand+items[index].bytesRelative+32+items[index].length]
    ensures Done(data,next,arrayBase,start,items,index+1)
  {
    hide S.Load(); hide G.Decode();
    reveal Done();
    var slot: Word := arrayBase+32+index*32;
    var end := M.End(mem,free);
    forall j {:trigger Position(start,items,j)} | 0 <= j < index+1
      ensures (arrayBase as nat)+64+j*32 <= |next| && S.Load(next,arrayBase+32+j*32) == Position(start,items,j)+32 &&
              Position(start,items,j)+64+items[j].length <= |next| && Position(start,items,j)+64+items[j].length < G.Modulus() &&
              S.Load(next,Position(start,items,j)+32) == items[j].length &&
              next[Position(start,items,j)+64..Position(start,items,j)+64+items[j].length] ==
              data[items[j].operand+items[j].bytesRelative+32..items[j].operand+items[j].bytesRelative+32+items[j].length]
    {
      if j == index {
        assert Position(start,items,j) == free;
      } else {
        PastEnd(start,items,j,index); Positions(start,items,j);
        var pointer: Word := Position(start,items,j)+32;
        var previous: Word := arrayBase+32+j*32;
        assert previous+32 <= slot;
        M.WindowWord(next,mem,128,(slot as nat)-128,previous);
        assert slot+32 <= pointer && (pointer as nat)+32+items[j].length <= end;
        M.WindowWord(next,mem,slot+32,end-slot-32,pointer);
        M.WindowBytes(next,mem,slot+32,end-slot-32,pointer+32,items[j].length);
      }
    }
  }
}

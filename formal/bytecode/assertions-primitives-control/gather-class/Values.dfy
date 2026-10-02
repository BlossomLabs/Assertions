// SPDX-License-Identifier: MIT
// Independent input byte values and physical resolver-object to serializer bridge.
include "Body.dfy"
include "../gather-public/serialization/Work.dfy"
module AssertionsGatherRawValues {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = AssertionsGatherLoopSpec
  import O = AssertionsGatherObjects
  import Q = AssertionsGatherAllocation
  import W = AssertionsGatherArrayWork
  import D = AssertionsGatherArraySpec
  type Word = S.Word
  type Byte = S.Byte
  predicate Layout(data: seq<Byte>, items: seq<P.Item>) {
    forall j: nat {:trigger items[j]} :: j < |items| ==> items[j].operand+items[j].bytesRelative+32+items[j].length <= |data|
  }
  function Values(data: seq<Byte>, items: seq<P.Item>): seq<seq<Byte>>
    requires Layout(data,items)
  {
    seq(|items|,j requires 0 <= j < |items| =>
      data[items[j].operand+items[j].bytesRelative+32..items[j].operand+items[j].bytesRelative+32+items[j].length])
  }
  function PointerAt(start: nat, items: seq<P.Item>, index: nat): Word
    requires start+P.Used(items,|items|)+96 < 0x10000000000000000 && index < |items|
  { P.Monotone(items,index,|items|); Position(start,items,index); P.Position(start,items,index)+32 }
  function Pointers(start: nat, items: seq<P.Item>): seq<Word>
    requires start+P.Used(items,|items|)+96 < 0x10000000000000000
  { seq(|items|,j requires 0 <= j < |items| => PointerAt(start,items,j)) }
  lemma Position(start: nat, items: seq<P.Item>, index: nat)
    requires index <= |items|
    ensures P.Position(start,items,index) == start+P.Used(items,index)
  { reveal P.Position(); }
  lemma Inputs(data: seq<Byte>, args: Word, items: seq<P.Item>)
    requires P.Calldata(data,args,items)
    ensures Layout(data,items)
  {
    forall j: nat {:trigger items[j]} | j < |items|
      ensures items[j].operand+items[j].bytesRelative+32+items[j].length <= |data|
    {}
  }
  lemma Length(data: seq<Byte>, items: seq<P.Item>, index: nat)
    requires Layout(data,items) && index < |items|
    ensures |Values(data,items)| == |items|
    ensures |Values(data,items)[index]| == items[index].length
    ensures Values(data,items)[index] == data[items[index].operand+items[index].bytesRelative+32..items[index].operand+items[index].bytesRelative+32+items[index].length]
  {}
  lemma Used(data: seq<Byte>, items: seq<P.Item>, index: nat)
    requires Layout(data,items) && index <= |items|
    ensures P.Used(items,index) == W.Used(Values(data,items),index)+index*32
    decreases index
  {
    if index > 0 { Used(data,items,index-1); Length(data,items,index-1); }
  }
  lemma Pointer(start: nat, items: seq<P.Item>, index: nat)
    requires start+P.Used(items,|items|)+96 < 0x10000000000000000 && index < |items|
    ensures Pointers(start,items)[index] == P.Position(start,items,index)+32
  {}
  lemma Sources(data: seq<Byte>, mem: seq<Byte>, arrayBase: Word, start: nat, base: Word, items: seq<P.Item>)
    requires |items| < 0x10000000000000000 && Layout(data,items) && start == Q.End(arrayBase,|items|)
    requires start+P.Used(items,|items|)+96 < 0x10000000000000000
    requires base == start+P.Used(items,|items|)
    requires P.Ready(mem,arrayBase,|items|,base) && P.Done(mem,arrayBase,start,items,|items|) && O.Done(data,mem,start,items,|items|)
    requires W.Budget(base,Values(data,items))
    ensures W.Sources(mem,arrayBase,base,Values(data,items),Pointers(start,items))
    ensures D.StartHeap(mem,arrayBase,base,|items|)
  {
    hide S.Load(); hide G.Decode();
    var values := Values(data,items);
    var pointers := Pointers(start,items);
    reveal P.Done();
    forall j: nat {:trigger pointers[j]} | j < |values|
      ensures pointers[j]+32+|values[j]| <= |mem| && pointers[j]+32+|values[j]| <= base &&
              S.Load(mem,arrayBase+32+j*32) == pointers[j] && S.Load(mem,pointers[j]) == |values[j]| &&
              mem[pointers[j]+32..pointers[j]+32+|values[j]|] == values[j]
    {
      Length(data,items,j); Pointer(start,items,j);
      assert O.Value(data,mem,items[j],P.Position(start,items,j));
      assert P.Cell(mem,((arrayBase+32+j*32)%G.Modulus())) == P.Position(start,items,j)+32;
      P.CellRead(mem,arrayBase+32+j*32);
      O.PastEnd(start,items,j,|items|); Position(start,items,|items|);
      Position(start,items,j); P.Monotone(items,j,|items|);
    }
  }
}

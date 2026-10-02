// SPDX-License-Identifier: MIT
// Bridge independent constrained-RAW input values and retained objects to canonical bytes[] serialization.
include "Body.dfy"
include "../../gather-public/serialization/Work.dfy"
module AssertionsGatherConstrainedValues {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = AssertionsGatherConstrainedLoopSpec
  import I = AssertionsGatherConstrainedIteration
  import Q = AssertionsGatherAllocation
  import W = AssertionsGatherArrayWork
  import D = AssertionsGatherArraySpec
  type Word = S.Word
  type Byte = S.Byte
  predicate Layout(data: seq<Byte>, items: seq<P.Item>) { P.Layout(data,items) }
  function Values(data: seq<Byte>, items: seq<P.Item>): seq<seq<Byte>>
    requires Layout(data,items)
  {
    seq(|items|,j requires 0 <= j < |items| =>
      data[items[j].operand+items[j].bytesRelative+32..items[j].operand+items[j].bytesRelative+32+items[j].length])
  }
  function PointerAt(start: nat, items: seq<P.Item>, index: nat): Word
    requires P.Budget(start,items) && index < |items|
  {
    P.Monotone(items,index,|items|); P.Positions(start,items,index);
    P.Position(start,items,index)+32
  }
  function Pointers(start: nat, items: seq<P.Item>): seq<Word>
    requires P.Budget(start,items)
  { seq(|items|,j requires 0 <= j < |items| => PointerAt(start,items,j)) }
  lemma Inputs(data: seq<Byte>, args: Word, items: seq<P.Item>)
    requires P.Calldata(data,args,items)
    ensures Layout(data,items)
  {}
  lemma Length(data: seq<Byte>, items: seq<P.Item>, index: nat)
    requires Layout(data,items) && index < |items|
    ensures |Values(data,items)| == |items|
    ensures |Values(data,items)[index]| == items[index].length
    ensures Values(data,items)[index] == data[items[index].operand+items[index].bytesRelative+32..items[index].operand+items[index].bytesRelative+32+items[index].length]
  {}
  lemma Pointer(start: nat, items: seq<P.Item>, index: nat)
    requires P.Budget(start,items) && index < |items|
    ensures Pointers(start,items)[index] == P.Position(start,items,index)+32
  {}
  lemma {:isolate_assertions} Sources(data: seq<Byte>, mem: seq<Byte>, arrayBase: Word, start: nat, base: Word, items: seq<P.Item>)
    requires |items| < 0x10000000000000000 && Layout(data,items) && start == Q.End(arrayBase,|items|)
    requires P.Budget(start,items) && base == start+P.Used(items,|items|)
    requires I.Ready(mem,arrayBase,|items|,base) && P.Done(data,mem,arrayBase,start,items,|items|)
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
      P.PastEnd(start,items,j,|items|); P.Positions(start,items,|items|);
      P.Positions(start,items,j); P.Monotone(items,j,|items|);
    }
  }
}

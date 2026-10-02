// SPDX-License-Identifier: MIT
// Independent observable pointer-array and byte-object result of the exact RAW body.
include "Body.dfy"
module AssertionsGatherRawResults {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import P = AssertionsGatherLoopSpec
  import O = AssertionsGatherObjects
  type Word = S.Word
  type Byte = S.Byte
  predicate Output(data: seq<Byte>, mem: seq<Byte>, arrayBase: Word, start: nat, items: seq<P.Item>) {
    S.Load(mem,arrayBase) == |items| && S.Load(mem,64) == start+P.Used(items,|items|) &&
    forall j {:trigger P.Position(start,items,j)} :: 0 <= j < |items| ==>
                                                       S.Load(mem,((arrayBase+32+j*32)%G.Modulus())) == P.Position(start,items,j)+32 &&
                                                       P.Position(start,items,j)+64+items[j].length <= |mem| &&
                                                       items[j].operand+items[j].bytesRelative+32+items[j].length <= |data| &&
                                                       S.Load(mem,((P.Position(start,items,j)+32)%G.Modulus())) == items[j].length &&
                                                       mem[P.Position(start,items,j)+64..P.Position(start,items,j)+64+items[j].length] == data[items[j].operand+items[j].bytesRelative+32..items[j].operand+items[j].bytesRelative+32+items[j].length]
  }
  lemma Point(data: seq<Byte>, mem: seq<Byte>, arrayBase: Word, start: nat, items: seq<P.Item>, index: nat)
    requires P.Done(mem,arrayBase,start,items,|items|) && O.Done(data,mem,start,items,|items|) && index < |items|
    ensures S.Load(mem,((arrayBase+32+index*32)%G.Modulus())) == P.Position(start,items,index)+32
    ensures O.Value(data,mem,items[index],P.Position(start,items,index))
  {
    reveal P.Done();
    P.CellRead(mem,((arrayBase+32+index*32)%G.Modulus()));
  }
  lemma Materialized(data: seq<Byte>, mem: seq<Byte>, arrayBase: Word, start: nat, items: seq<P.Item>)
    requires P.Done(mem,arrayBase,start,items,|items|) && O.Done(data,mem,start,items,|items|)
    requires S.Load(mem,arrayBase) == |items| && S.Load(mem,64) == start+P.Used(items,|items|)
    ensures Output(data,mem,arrayBase,start,items)
  {
    forall j {:trigger P.Position(start,items,j)} | 0 <= j < |items|
      ensures S.Load(mem,((arrayBase+32+j*32)%G.Modulus())) == P.Position(start,items,j)+32 && O.Value(data,mem,items[j],P.Position(start,items,j))
    { Point(data,mem,arrayBase,start,items,j); }
  }
}

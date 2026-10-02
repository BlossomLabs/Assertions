// SPDX-License-Identifier: MIT
// Independent complete digit-span semantics for arbitrary successful suffix chains.
include "../suffix-connection/Number.dfy"
module BytecodeCollectionsSuffixSemantics {
  import G = BytecodeGetterMachine
  import D = BytecodeCollectionsDecimalLoop
  datatype Shape = Shape(pos: nat, dynamic: nat, span: int)
  predicate Fits(shape: Shape,limit: G.Word) {
    shape.pos <= limit && shape.dynamic <= 1 && 1 <= shape.span < 0x10000000000000000000000000000000000000000000000000000000000000000 &&
    (shape.dynamic == 0 || shape.span == 1)
  }
  function Next(data: seq<G.Byte>,offset: G.Word,shape: Shape,close: nat): Shape
    requires shape.pos+1 <= close
  {
    Shape(close+1,if close == shape.pos+1 then 1 else shape.dynamic,
          if close == shape.pos+1 then 1 else if shape.dynamic == 1 then shape.span
          else shape.span*D.Number(data,offset,shape.pos+1,close))
  }
  predicate Valid(data: seq<G.Byte>,offset: G.Word,limit: G.Word,shape: Shape,closings: seq<nat>)
    decreases |closings|
  {
    Fits(shape,limit) &&
    if |closings| == 0 then
      shape.pos >= limit || D.DataByte(data,offset,shape.pos) != 91
    else
      var close := closings[0];
      shape.pos+1 <= close < limit &&
      D.DataByte(data,offset,shape.pos) == 91 && D.DataByte(data,offset,close) == 93 &&
      (forall i {:trigger D.DataByte(data,offset,i)} :: shape.pos+1 <= i < close ==> D.Digit(D.DataByte(data,offset,i))) &&
      0 <= D.Number(data,offset,shape.pos+1,close) <= 0xffffffff &&
      (close > shape.pos+1 ==> D.Number(data,offset,shape.pos+1,close) >= 1) &&
      (shape.dynamic == 0 && close > shape.pos+1 ==> shape.span*D.Number(data,offset,shape.pos+1,close) <= 0xffffffff) &&
      Valid(data,offset,limit,Next(data,offset,shape,close),closings[1..])
  }
  function Final(data: seq<G.Byte>,offset: G.Word,limit: G.Word,shape: Shape,closings: seq<nat>): Shape
    requires Valid(data,offset,limit,shape,closings)
    ensures Fits(Final(data,offset,limit,shape,closings),limit)
    decreases |closings|
  {
    if |closings| == 0 then shape
    else Final(data,offset,limit,Next(data,offset,shape,closings[0]),closings[1..])
  }
}

// SPDX-License-Identifier: MIT
// Independent successful finite suffix prefixes may stop before a rejecting suffix.
include "../type-parser/Bounds.dfy"
module BytecodeCollectionsSuffixPrefixSemantics {
  import G = BytecodeGetterMachine
  import D = BytecodeCollectionsDecimalLoop
  import S = BytecodeCollectionsSuffixSemantics
  import B = BytecodeCollectionsTypeBounds
  predicate Valid(data: seq<G.Byte>,offset: G.Word,limit: G.Word,shape: S.Shape,closings: seq<nat>)
    decreases |closings|
  {
    B.MathematicalFits(shape,limit) &&
    if |closings| == 0 then true
    else
      var close := closings[0];
      shape.pos+1 <= close < limit && D.DataByte(data,offset,shape.pos) == 91 && D.DataByte(data,offset,close) == 93 &&
      (forall i {:trigger D.DataByte(data,offset,i)} :: shape.pos+1 <= i < close ==> D.Digit(D.DataByte(data,offset,i))) &&
      0 <= D.Number(data,offset,shape.pos+1,close) <= 0xffffffff &&
      (close > shape.pos+1 ==> D.Number(data,offset,shape.pos+1,close) >= 1) &&
      (shape.dynamic == 0 && close > shape.pos+1 ==> shape.span*D.Number(data,offset,shape.pos+1,close) <= 0xffffffff) &&
      Valid(data,offset,limit,S.Next(data,offset,shape,close),closings[1..])
  }
  function Final(data: seq<G.Byte>,offset: G.Word,limit: G.Word,shape: S.Shape,closings: seq<nat>): S.Shape
    requires Valid(data,offset,limit,shape,closings)
    ensures B.MathematicalFits(Final(data,offset,limit,shape,closings),limit)
    decreases |closings|
  {
    if |closings| == 0 then shape
    else Final(data,offset,limit,S.Next(data,offset,shape,closings[0]),closings[1..])
  }
  lemma Admission(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,shape: S.Shape,closings: seq<nat>)
    requires Valid(data,offset,limit,shape,closings) && p < shape.pos && limit < 0x10000000000000000
    requires shape.span <= 0xffffffff*(shape.pos-p)
    ensures S.Fits(shape,limit) && S.Fits(Final(data,offset,limit,shape,closings),limit)
    ensures Final(data,offset,limit,shape,closings).pos >= shape.pos
    ensures Final(data,offset,limit,shape,closings).span <= 0xffffffff*(Final(data,offset,limit,shape,closings).pos-p)
    decreases |closings|
  {
    assert 0xffffffff*limit < G.Modulus();
    if |closings| > 0 {
      var close := closings[0];var next := S.Next(data,offset,shape,close);
      assert next.pos > shape.pos && next.span <= 0xffffffff;
      assert next.span <= 0xffffffff*(next.pos-p);
      Admission(data,offset,p,limit,next,closings[1..]);
    }
  }
}

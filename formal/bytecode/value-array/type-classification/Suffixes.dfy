// SPDX-License-Identifier: MIT
// Universal constructive independent finite suffix success/rejection classification.
include "Mathematics.dfy"
module BytecodeCollectionsSuffixClassification {
  import G = BytecodeGetterMachine
  import D = BytecodeCollectionsDecimalLoop
  import S = BytecodeCollectionsSuffixSemantics
  import P = BytecodeCollectionsSuffixPrefixSemantics
  import B = BytecodeCollectionsTypeBounds
  import M = BytecodeCollectionsTypeClassificationMathematics
  import Q = BytecodeCollectionsSuffixRejectSemantics
  import W = BytecodeCollectionsSuffixFootprintScalar
  import C = BytecodeCollectionsParserSuffixRejection
  ghost method Parse(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,base: S.Shape) returns (rejected: bool,result: S.Shape,closings: seq<nat>,q: G.Word,k: G.Word)
    requires B.MathematicalFits(base,limit) && p < base.pos && limit < 0x10000000000000000
    requires base.span <= 0xffffffff*(base.pos-p)
    ensures P.Valid(data,offset,limit,base,closings) && result == P.Final(data,offset,limit,base,closings)
    ensures rejected ==> C.Invalid(data,offset,p,limit,base,closings,q,k)
    ensures !rejected ==> B.SuffixSyntax(data,offset,limit,base,closings) && result == B.SuffixResult(data,offset,limit,base,closings)
  {
    rejected := false;result := base;closings := [];q := 0;k := 0;
    while result.pos < limit && D.DataByte(data,offset,result.pos) == 91
      invariant P.Valid(data,offset,limit,base,closings) && result == P.Final(data,offset,limit,base,closings)
      invariant p < result.pos <= limit && B.MathematicalFits(result,limit)
      invariant result.span <= 0xffffffff*(result.pos-p)
      decreases limit-result.pos
    {
      P.Admission(data,offset,p,limit,base,closings);
      var end: G.Word := result.pos;var dyn: G.Word := result.dynamic;var words: G.Word := result.span;
      q,k := Q.Find(data,offset,end+1,limit);W.ProductFits(words,k,p,end);
      if Q.Rejected(data,offset,end,limit,dyn,words,q,k) { rejected := true;return; }
      assert q < limit && D.DataByte(data,offset,q) == 93 && k <= 0xffffffff;
      assert q == end+1 || k >= 1;
      var next := S.Next(data,offset,result,q);
      assert B.MathematicalFits(next,limit) && 1 <= next.span <= 0xffffffff;
      assert P.Valid(data,offset,limit,result,[q]);
      M.AppendSuffix(data,offset,limit,base,closings,q);
      closings := closings+[q];result := next;
      assert result.span <= 0xffffffff*(result.pos-p);
    }
    M.CompleteSuffix(data,offset,limit,base,closings);
  }
}

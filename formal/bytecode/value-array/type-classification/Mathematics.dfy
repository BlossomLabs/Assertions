// SPDX-License-Identifier: MIT
// Constructive independent descriptor-prefix grammar, with derived fitting widths.
include "../type-rejection/Semantics.dfy"
module BytecodeCollectionsTypeClassificationMathematics {
  import G = BytecodeGetterMachine
  import D = BytecodeCollectionsDecimalLoop
  import L = BytecodeCollectionsScanNameLoop
  import N = BytecodeCollectionsNamedParser
  import S = BytecodeCollectionsSuffixSemantics
  import P = BytecodeCollectionsSuffixPrefixSemantics
  import B = BytecodeCollectionsTypeBounds
  import T = BytecodeCollectionsTypeSemantics
  import TP = BytecodeCollectionsTuplePrefixBounds
  import TB = BytecodeCollectionsTupleBaseBounds
  lemma AppendSuffix(data: seq<G.Byte>,offset: G.Word,limit: G.Word,shape: S.Shape,closings: seq<nat>,close: nat)
    requires P.Valid(data,offset,limit,shape,closings)
    requires P.Valid(data,offset,limit,P.Final(data,offset,limit,shape,closings),[close])
    ensures P.Valid(data,offset,limit,shape,closings+[close])
    ensures P.Final(data,offset,limit,shape,closings+[close]) == S.Next(data,offset,P.Final(data,offset,limit,shape,closings),close)
    decreases |closings|
  {
    if |closings| > 0 {
      var next := S.Next(data,offset,shape,closings[0]);
      AppendSuffix(data,offset,limit,next,closings[1..],close);
      assert (closings+[close])[1..] == closings[1..]+[close];
    }
  }
  lemma CompleteSuffix(data: seq<G.Byte>,offset: G.Word,limit: G.Word,shape: S.Shape,closings: seq<nat>)
    requires P.Valid(data,offset,limit,shape,closings)
    requires var final := P.Final(data,offset,limit,shape,closings);final.pos == limit || D.DataByte(data,offset,final.pos) != 91
    ensures B.SuffixSyntax(data,offset,limit,shape,closings)
    ensures B.SuffixResult(data,offset,limit,shape,closings) == P.Final(data,offset,limit,shape,closings)
    decreases |closings|
  {
    if |closings| > 0 { CompleteSuffix(data,offset,limit,S.Next(data,offset,shape,closings[0]),closings[1..]); }
  }
  lemma AppendChild(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,previous: seq<T.Descriptor>,last: T.Descriptor,closing: G.Byte)
    requires TP.Children(data,offset,p,limit,previous) && limit < 0x10000000000000000
    requires (TP.Admission(data,offset,p,limit,previous);B.Syntax(data,offset,TP.Next(p,previous),limit,last))
    requires last.shape.pos < limit && D.DataByte(data,offset,last.shape.pos) == closing && (closing == 44 || closing == 41)
    ensures closing == 44 ==> TP.Children(data,offset,p,limit,previous+[last])
    ensures closing == 41 ==> TB.Children(data,offset,p,limit,previous+[last])
    ensures T.Sum(previous+[last]) == T.Sum(previous)+last.shape.span
    ensures T.Flags(previous+[last]) == (if last.shape.dynamic == 1 then 1 else T.Flags(previous))
  {
    TP.Admission(data,offset,p,limit,previous);var children := previous+[last];
    forall i | 0 <= i < |children|
      ensures T.Start(p,children,i) < limit && B.Syntax(data,offset,T.Start(p,children,i),limit,children[i])
      ensures children[i].shape.pos < limit && D.DataByte(data,offset,children[i].shape.pos) == (if i+1 < |children| then 44 else closing)
    {
      if i < |previous| {
        assert children[i] == previous[i];assert T.Start(p,children,i) == T.Start(p,previous,i);
      } else {
        assert i == |previous| && children[i] == last;assert T.Start(p,children,i) == TP.Next(p,previous);
      }
    }
    assert children[..|previous|] == previous;T.Extend(children,|previous|);
  }
  lemma NamedSyntax(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,end: G.Word,result: S.Shape,closings: seq<nat>)
    requires N.Name(data,offset,p,limit,end)
    requires B.SuffixSyntax(data,offset,limit,S.Shape(end,N.Dynamic(data,offset,p,end),1),closings)
    requires result == B.SuffixResult(data,offset,limit,S.Shape(end,N.Dynamic(data,offset,p,end),1),closings)
    ensures B.Syntax(data,offset,p,limit,T.Named(end,result,closings))
  {
    var tree := T.Named(end,result,closings);
    assert T.Base(data,offset,p,tree) == S.Shape(end,N.Dynamic(data,offset,p,end),1);
    assert B.MathematicalFits(result,limit);
    reveal B.Syntax();
  }
  lemma TupleSyntax(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,children: seq<T.Descriptor>,result: S.Shape,closings: seq<nat>)
    requires TB.Children(data,offset,p,limit,children)
    requires B.SuffixSyntax(data,offset,limit,TB.Base(p,children),closings)
    requires result == B.SuffixResult(data,offset,limit,TB.Base(p,children),closings)
    ensures B.Syntax(data,offset,p,limit,T.Tuple(children,result,closings))
  {
    var tree := T.Tuple(children,result,closings);
    assert T.Base(data,offset,p,tree) == TB.Base(p,children);
    assert B.MathematicalFits(result,limit);
    reveal B.Syntax();
  }
  ghost method FindName(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word) returns (end: G.Word)
    requires p < limit < 0x10000000000000000
    ensures p <= end <= limit
    ensures end == p ==> !L.Allowed(D.DataByte(data,offset,p))
    ensures p < end ==> N.Name(data,offset,p,limit,end)
  {
    end := p;
    while end < limit && L.Allowed(D.DataByte(data,offset,end))
      invariant p <= end <= limit
      invariant forall i {:trigger D.DataByte(data,offset,i)} :: p <= i < end ==> L.Allowed(D.DataByte(data,offset,i))
      decreases limit-end
    {
      forall i {:trigger D.DataByte(data,offset,i)} | p <= i < end+1
        ensures L.Allowed(D.DataByte(data,offset,i))
      { if i == end { assert L.Allowed(D.DataByte(data,offset,i)); } }
      end := end+1;
    }
    forall i {:trigger L.DataByte(data,offset,i)} | p <= i < end
      ensures L.Allowed(L.DataByte(data,offset,i))
    {
      assert D.DataByte(data,offset,i) == L.DataByte(data,offset,i);
      assert L.Allowed(D.DataByte(data,offset,i));
    }
    assert D.DataByte(data,offset,end) == L.DataByte(data,offset,end);
  }
}

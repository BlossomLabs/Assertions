// SPDX-License-Identifier: MIT
// Universal finite independent descriptor grammar classifier; no supplied rejection witness.
include "Suffixes.dfy"
module BytecodeCollectionsTypeClassification {
  import G = BytecodeGetterMachine
  import D = BytecodeCollectionsDecimalLoop
  import N = BytecodeCollectionsNamedParser
  import S = BytecodeCollectionsSuffixSemantics
  import T = BytecodeCollectionsTypeSemantics
  import B = BytecodeCollectionsTypeBounds
  import TP = BytecodeCollectionsTuplePrefixBounds
  import TB = BytecodeCollectionsTupleBaseBounds
  import R = BytecodeCollectionsTypeRejectSemantics
  import M = BytecodeCollectionsTypeClassificationMathematics
  import F = BytecodeCollectionsSuffixClassification
  ghost method Parse(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word) returns (rejected: bool,tree: T.Descriptor,problem: R.Rejection)
    requires p <= limit < 0x10000000000000000
    ensures rejected ==> R.Syntax(data,offset,p,limit,problem)
    ensures !rejected ==> B.Syntax(data,offset,p,limit,tree)
    decreases limit-p
  {
    hide B.Syntax();
    rejected := true;tree := T.Named(0,S.Shape(0,0,0),[]);problem := R.AtLimit;
    if p == limit { return; }
    if D.DataByte(data,offset,p) != 40 {
      var end: G.Word;end := M.FindName(data,offset,p,limit);
      if end == p { problem := R.BadName;return; }
      var base := S.Shape(end,N.Dynamic(data,offset,p,end),1);
      var result: S.Shape;var closings: seq<nat>;var q: G.Word;var k: G.Word;
      rejected,result,closings,q,k := F.Parse(data,offset,p,limit,base);
      if rejected { problem := R.NamedSuffix(end,closings,q,k); }
      else { tree := T.Named(end,result,closings);M.NamedSyntax(data,offset,p,limit,end,result,closings); }
    } else {
      var previous: seq<T.Descriptor> := [];var q: G.Word := p+1;var children: seq<T.Descriptor> := [];
      while true
        invariant TP.Children(data,offset,p,limit,previous)
        invariant q == TP.Next(p,previous) && p < q <= limit
        decreases limit-q
      {
        var childRejected: bool;var child: T.Descriptor;var inner: R.Rejection;
        childRejected,child,inner := Parse(data,offset,q,limit);
        if childRejected { problem := R.Child(previous,inner);return; }
        B.Admission(data,offset,q,limit,child);
        var end: G.Word := child.shape.pos;
        if end == limit { problem := R.Separator(previous,child);return; }
        var b := D.DataByte(data,offset,end);
        if b == 44 {
          M.AppendChild(data,offset,p,limit,previous,child,b);
          previous := previous+[child];q := end+1;
        } else if b == 41 {
          M.AppendChild(data,offset,p,limit,previous,child,b);children := previous+[child];break;
        } else { problem := R.Separator(previous,child);return; }
      }
      TB.Admission(data,offset,p,limit,children);var base := TB.Base(p,children);
      var result: S.Shape;var closings: seq<nat>;var stop: G.Word;var k: G.Word;
      rejected,result,closings,stop,k := F.Parse(data,offset,p,limit,base);
      if rejected { problem := R.TupleSuffix(children,closings,stop,k); }
      else { tree := T.Tuple(children,result,closings);M.TupleSyntax(data,offset,p,limit,children,result,closings); }
    }
  }
}

// SPDX-License-Identifier: MIT
// Independent finite descriptor rejection trees, with no EVM error frame input.
include "../tuple-separator-rejection/Connection.dfy"
include "../parser-suffix-rejection/Connection.dfy"
include "../name-scanner-v2/Loop.dfy"
module BytecodeCollectionsTypeRejectSemantics {
  import G = BytecodeGetterMachine
  import D = BytecodeCollectionsDecimalLoop
  import N = BytecodeCollectionsNamedParser
  import L = BytecodeCollectionsScanNameLoop
  import S = BytecodeCollectionsSuffixSemantics
  import T = BytecodeCollectionsTypeSemantics
  import B = BytecodeCollectionsTypeBounds
  import TB = BytecodeCollectionsTupleBaseBounds
  import TP = BytecodeCollectionsTuplePrefixBounds
  import C = BytecodeCollectionsParserSuffixRejection
  import TS = BytecodeCollectionsTupleSeparatorRejection
  datatype Rejection = AtLimit | BadName
                     | NamedSuffix(nameEnd: G.Word,closings: seq<nat>,q: G.Word,k: G.Word)
                     | TupleSuffix(children: seq<T.Descriptor>,closings: seq<nat>,q: G.Word,k: G.Word)
                     | Child(previous: seq<T.Descriptor>,inner: Rejection)
                     | Separator(previous: seq<T.Descriptor>,last: T.Descriptor)
  predicate Syntax(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,problem: Rejection)
    decreases problem
  {
    p <= limit && limit < 0x10000000000000000 &&
    if problem.AtLimit? then p == limit
    else p < limit &&
         if problem.BadName? then !L.Allowed(D.DataByte(data,offset,p)) && D.DataByte(data,offset,p) != 40
         else if problem.NamedSuffix? then N.Name(data,offset,p,limit,problem.nameEnd) &&
                                           C.Invalid(data,offset,p,limit,S.Shape(problem.nameEnd,N.Dynamic(data,offset,p,problem.nameEnd),1),problem.closings,problem.q,problem.k)
         else if problem.TupleSuffix? then TB.Children(data,offset,p,limit,problem.children) &&
                                           C.Invalid(data,offset,p,limit,TB.Base(p,problem.children),problem.closings,problem.q,problem.k)
         else if problem.Child? then TP.Children(data,offset,p,limit,problem.previous) &&
                                     (TP.Admission(data,offset,p,limit,problem.previous);Syntax(data,offset,TP.Next(p,problem.previous),limit,problem.inner))
         else TS.Syntax(data,offset,p,limit,problem.previous,problem.last)
  }
  predicate StackFits(prefixWords: nat,problem: Rejection)
    decreases problem
  {
    prefixWords <= 1004 &&
    if problem.TupleSuffix? then forall i :: 0 <= i < |problem.children| ==> T.StackFits(prefixWords+13,problem.children[i])
    else if problem.Child? then (forall i :: 0 <= i < |problem.previous| ==> T.StackFits(prefixWords+13,problem.previous[i])) && StackFits(prefixWords+13,problem.inner)
    else if problem.Separator? then (forall i :: 0 <= i < |problem.previous| ==> T.StackFits(prefixWords+13,problem.previous[i])) && T.StackFits(prefixWords+13,problem.last)
    else true
  }
  function Position(data: seq<G.Byte>,offset: G.Word,p: G.Word,limit: G.Word,problem: Rejection): G.Word
    requires Syntax(data,offset,p,limit,problem)
    decreases problem
  {
    if problem.AtLimit? || problem.BadName? then p
    else if problem.NamedSuffix? || problem.TupleSuffix? then problem.q
    else if problem.Child? then (TP.Admission(data,offset,p,limit,problem.previous);Position(data,offset,TP.Next(p,problem.previous),limit,problem.inner))
    else (TP.Admission(data,offset,p,limit,problem.previous);B.Admission(data,offset,TP.Next(p,problem.previous),limit,problem.last);problem.last.shape.pos)
  }
}

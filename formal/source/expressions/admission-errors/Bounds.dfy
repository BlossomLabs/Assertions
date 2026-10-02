// SPDX-License-Identifier: MIT
include "Encoding.dfy"
module ExpressionAdmissionErrorBounds {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiWordSemantics
  import P = AbiParserSpec
  import A = ExpressionAdmission
  import W = ExpressionAdmissionErrors

  lemma SuffixBound(t: seq<Byte>, q: nat, limit: nat, s: Descriptor, d: bool, w: nat)
    requires q <= limit <= |t| && Uint(w)
    ensures P.Suffix(t,q,limit,s,d,w).BadDescriptor? ==> P.Suffix(t,q,limit,s,d,w).at <= limit
    decreases limit-q
  {
    if q < limit && t[q] == 91 {
      var digits := P.DigitsFrom(t,q+1,limit,0);
      var e,k := digits.0,digits.1;
      var a := e == q+1;
      var nextW := if a then 1 else if d then w else w*k;
      if nextW < Limit() && e < limit && t[e] == 93 && k <= 0xffffffff && nextW <= 0xffffffff && (k != 0 || a) {
        SuffixBound(t,e+1,limit,if a then Dynamic(s) else Fixed(s,t[q+1..e]),a||d,nextW);
      }
    }
  }
  lemma ParseBound(t: seq<Byte>, p: nat, limit: nat)
    requires Uint(|t|) && p <= limit <= |t|
    ensures P.Parse(t,p,limit).BadDescriptor? ==> P.Parse(t,p,limit).at <= limit
    decreases limit-p,0
  {
    if p < limit {
      if t[p] == 40 {
        FieldsBound(t,p+1,limit,[],0,false);
        var base := P.Fields(t,p+1,limit,[],0,false);
        if base.Shaped? { SuffixBound(t,base.end,limit,base.syntax,base.dynamic,base.words); }
      } else {
        var e := NameEnd(t,p,limit);
        if e > p { SuffixBound(t,e,limit,Name(t[p..e]),Dyn(Name(t[p..e])),1); }
      }
    }
  }
  lemma FieldsBound(t: seq<Byte>, q: nat, limit: nat, fs: seq<Descriptor>, sum: nat, dyn: bool)
    requires Uint(|t|) && q <= limit <= |t| && Uint(sum)
    ensures P.Fields(t,q,limit,fs,sum,dyn).BadDescriptor? ==> P.Fields(t,q,limit,fs,sum,dyn).at <= limit
    decreases limit-q,1
  {
    ParseBound(t,q,limit);
    var child := P.Parse(t,q,limit);
    if child.Shaped? && sum+child.words < Limit() && child.end < limit && t[child.end] == 44 {
      FieldsBound(t,child.end+1,limit,fs+[child.syntax],sum+child.words,dyn||child.dynamic);
    }
  }
  lemma WholeBound(t: seq<Byte>)
    requires Uint(|t|)
    ensures P.Whole(t).BadDescriptor? ==> P.Whole(t).at <= |t| && Uint(P.Whole(t).at)
  { ParseBound(t,0,|t|); }

  predicate WordNodes(nodes: seq<A.Node>) {
    Uint(|nodes|) && forall i :: 0 <= i < |nodes| ==>
                                   Uint(|nodes[i].valueType|) && (forall j :: 0 <= j < |nodes[i].refs| ==> Uint(nodes[i].refs[j]))
  }
  lemma ScanFields(nodes: seq<A.Node>, start: nat, hash: seq<Byte>->nat)
    requires WordNodes(nodes) && start <= |nodes|
    ensures A.Scan(nodes,start,hash).Rejected? ==> W.Fits(A.Scan(nodes,start,hash).error)
    decreases |nodes|-start
  {
    if start < |nodes| {
      WholeBound(nodes[start].valueType);
      A.ReferenceVerdict(nodes[start].refs,start,0);
      ScanFields(nodes,start+1,hash);
    }
  }
  lemma AdmissionFields(nodes: seq<A.Node>, result: nat, hash: seq<Byte>->nat)
    requires WordNodes(nodes) && Uint(result)
    ensures A.Admit(nodes,result,hash).Rejected? ==> W.Fits(A.Admit(nodes,result,hash).error)
  { if result < |nodes| { ScanFields(nodes,0,hash); } }
}

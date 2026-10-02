// SPDX-License-Identifier: MIT
// Constructive tuple child geometry from independently encoded recursive types.
// This module supplies semantic children, not the physical recursive child traces.
include "DescriptorEncoding.dfy"
include "TupleSpec.dfy"
module AssertionsNavigationTupleGrammar {
  import S = AssertionsNavigationDescriptorSpec
  import E = AssertionsNavigationDescriptorEncoding
  import F = AssertionsNavigationTupleSpec
  function End(types: seq<S.Type>,p: nat,index: nat): nat
    requires index < |types|
  { p+1+|E.Fields(types,index+1)| }
  function Children(types: seq<S.Type>,p: nat): seq<F.Field>
  { seq(|types|, i requires 0 <= i < |types| => F.Field(End(types,p,i),S.Dynamic(types[i]),S.Words(types[i]))) }
  function Cursor(types: seq<S.Type>,p: nat,index: nat): nat
    requires index < |types|
  { if index == 0 then p+1 else Children(types,p)[index-1].end+1 }
  lemma FieldsPrefix(types: seq<S.Type>,left: nat,right: nat)
    requires left <= right <= |types|
    ensures |E.Fields(types,left)| <= |E.Fields(types,right)|
    ensures E.Fields(types,right)[..|E.Fields(types,left)|] == E.Fields(types,left)
    decreases right-left
  {
    if left < right { FieldsPrefix(types,left,right-1); }
  }
  lemma SumMonotone(types: seq<S.Type>,left: nat,right: nat)
    requires left <= right <= |types|
    ensures S.Sum(types,left) <= S.Sum(types,right)
    decreases right-left
  { if left < right { SumMonotone(types,left,right-1); } }
  lemma Aggregates(types: seq<S.Type>,p: nat,count: nat)
    requires count <= |types|
    ensures F.Sum(Children(types,p),count) == S.Sum(types,count)
    ensures F.Dynamic(Children(types,p),count) <==> (exists i :: 0 <= i < count && S.Dynamic(types[i]))
    decreases count
  {
    if count > 0 {
      Aggregates(types,p,count-1);
      assert Children(types,p)[count-1].words == S.Words(types[count-1]);
      assert Children(types,p)[count-1].dynamic == S.Dynamic(types[count-1]);
      if exists i :: 0 <= i < count && S.Dynamic(types[i]) {
        var i :| 0 <= i < count && S.Dynamic(types[i]);
        if i < count-1 { assert exists j :: 0 <= j < count-1 && S.Dynamic(types[j]); }
      }
    }
  }
  lemma Geometry(types: seq<S.Type>,p: nat)
    requires S.Valid(S.Tuple(types))
    ensures |Children(types,p)| == |types| > 0
    ensures F.Positive(Children(types,p))
    ensures F.Footprint(Children(types,p)) == S.Words(S.Tuple(types))
    ensures F.Sum(Children(types,p),|types|) < 0x10000000000000000000000000000000000000000000000000000000000000000
    ensures forall i :: 0 <= i < |types| ==> (p < Cursor(types,p,i) <= Children(types,p)[i].end < p+|E.Encode(S.Tuple(types))| &&
                                              E.Encode(S.Tuple(types))[Children(types,p)[i].end-p] == (if i+1 == |types| then 41 else 44))
  {
    Aggregates(types,p,|types|);
    forall i | 0 <= i < |types|
      ensures Children(types,p)[i].words >= 1 && (Children(types,p)[i].dynamic ==> Children(types,p)[i].words == 1)
      ensures p < Cursor(types,p,i) <= Children(types,p)[i].end < p+|E.Encode(S.Tuple(types))|
      ensures E.Encode(S.Tuple(types))[Children(types,p)[i].end-p] == (if i+1 == |types| then 41 else 44)
    {
      S.Positive(types[i]); E.EncodeValid(types[i]);
      E.FieldsValid(types,i); E.FieldsValid(types,i+1);
      FieldsPrefix(types,i+1,|types|);
      if i+1 < |types| {
        FieldsPrefix(types,i+2,|types|);
        assert E.Fields(types,i+2) == E.Fields(types,i+1)+[44]+E.Encode(types[i+1]);
        assert E.Fields(types,|types|)[|E.Fields(types,i+1)|] == 44;
      }
    }
  }
}

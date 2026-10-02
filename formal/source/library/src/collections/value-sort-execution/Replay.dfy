// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsValueSortExecutionReplay {
  import opened CollectionsValueSortExecutionModel
  import T = CollectionsValueSortTraceModel
  import Core = CollectionsSortModel
  import Proof = CollectionsValueSortTraceProperties
  lemma Restrict(a: T.Environment,b: T.Environment,cut: nat,next: nat)
    requires Future(a,b,cut) && next >= cut
    ensures Future(a,b,next)
  {}
  lemma Merge(source: seq<nat>,middle: nat,end: nat,a: nat,b: nat,before: seq<T.Row>,first: T.Environment,second: T.Environment)
    requires a <= middle <= b <= end <= |source|
    requires Future(first,second,|before|)
    ensures T.Merge(source,middle,end,a,b,before,first) == T.Merge(source,middle,end,a,b,before,second)
    decreases middle-a+end-b
  {
    if a == middle || b == end { return; }
    var q := T.Request(a,b,source[a],source[b]);
    assert first(before,q) == second(before,q);
    var choice := first(before,q);
    var next := before+[T.Row(q,choice)];
    Restrict(first,second,|before|,|next|);
    if choice.Chosen? {
      if choice.left { Merge(source,middle,end,a+1,b,next,first,second); }
      else { Merge(source,middle,end,a,b+1,next,first,second); }
    }
  }
  lemma MergeWindow(source: seq<nat>,middle: nat,end: nat,a: nat,b: nat,before: seq<T.Row>,first: T.Environment,second: T.Environment,cut: nat)
    requires a <= middle <= b <= end <= |source|
    requires T.Clear(before) && Window(first,second,|before|,cut)
    requires |T.Merge(source,middle,end,a,b,before,first).trace| <= cut
    ensures T.Merge(source,middle,end,a,b,before,first) == T.Merge(source,middle,end,a,b,before,second)
    decreases middle-a+end-b
  {
    if a == middle || b == end { return; }
    var q := T.Request(a,b,source[a],source[b]);
    var choice := first(before,q);
    var next := before+[T.Row(q,choice)];
    if choice.Rejected? {
      assert |before| < cut;
      assert first(before,q) == second(before,q);
      return;
    }
    var aa := if choice.left then a+1 else a;
    var bb := if choice.left then b else b+1;
    assert T.Clear(next);
    Proof.MergeFacts(source,middle,end,aa,bb,next,first,(x: nat,y: nat)=>true);
    assert |before| < cut;
    assert first(before,q) == second(before,q);
    assert Window(first,second,|next|,cut);
    MergeWindow(source,middle,end,aa,bb,next,first,second,cut);
  }
  lemma PassWindow(source: seq<nat>,width: nat,start: nat,before: seq<T.Row>,first: T.Environment,second: T.Environment,cut: nat)
    requires width > 0 && T.Clear(before)
    requires Window(first,second,|before|,cut)
    requires |T.Pass(source,width,start,before,first).trace| <= cut
    ensures T.Pass(source,width,start,before,first) == T.Pass(source,width,start,before,second)
    decreases |source|-start
  {
    if start >= |source| { return; }
    var middle := Core.Min(start+width,|source|);
    var end := Core.Min(start+2*width,|source|);
    var one := T.Merge(source,middle,end,start,middle,before,first);
    Proof.MergeFacts(source,middle,end,start,middle,before,first,(x: nat,y: nat)=>true);
    if one.Success? {
      Proof.PassFacts(source,width,start+2*width,one.trace,first,(x: nat,y: nat)=>true);
    }
    MergeWindow(source,middle,end,start,middle,before,first,second,cut);
    if one.Success? {
      assert Window(first,second,|one.trace|,cut);
      PassWindow(source,width,start+2*width,one.trace,first,second,cut);
    }
  }
  lemma SortWindow(source: seq<nat>,width: nat,before: seq<T.Row>,first: T.Environment,second: T.Environment,cut: nat)
    requires width > 0 && T.Clear(before)
    requires Window(first,second,|before|,cut)
    requires |T.Sort(source,width,before,first).trace| <= cut
    ensures T.Sort(source,width,before,first) == T.Sort(source,width,before,second)
    decreases |source|-width
  {
    if width >= |source| { return; }
    var one := T.Pass(source,width,0,before,first);
    Proof.PassFacts(source,width,0,before,first,(x: nat,y: nat)=>true);
    if one.Success? { Proof.SortFacts(one.ids,2*width,one.trace,first,(x: nat,y: nat)=>true); }
    PassWindow(source,width,0,before,first,second,cut);
    if one.Success? {
      assert Window(first,second,|one.trace|,cut);
      SortWindow(one.ids,2*width,one.trace,first,second,cut);
    }
  }

}

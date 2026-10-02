// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsValueSortTraceProperties {
  import opened AbiFrames
  import opened CollectionsValueSortTraceModel
  import C = CollectionsSortModel
  lemma PrependJoin(a: seq<nat>,b: seq<nat>,out: Outcome)
    ensures Prepend(a,Prepend(b,out)) == Prepend(a+b,out)
  {}
  lemma Append(trace: seq<Row>,q: Request,env: Environment)
    ensures Extends(trace,trace+[Row(q,env(trace,q))],env)
  {}
  lemma Compose(a: seq<Row>,b: seq<Row>,c: seq<Row>,env: Environment)
    requires Extends(a,b,env) && Extends(b,c,env)
    ensures Extends(a,c,env)
  {
    forall i | |a| <= i < |c|
      ensures c[i].choice == env(c[..i],c[i].request)
    {
      if i < |b| { assert c[..i] == b[..i] && c[i] == b[i]; }
    }
  }
  lemma Prefix(a: seq<Row>,b: seq<Row>,le: (nat,nat)->bool)
    requires a <= b
    ensures Coherent(b,le) ==> Coherent(a,le)
    ensures Clear(b) ==> Clear(a)
  {
    forall i | 0 <= i < |a| ensures a[i] == b[i] {}
  }
  lemma MergeFacts(source: seq<nat>,middle: nat,end: nat,a: nat,b: nat,trace: seq<Row>,env: Environment,le: (nat,nat)->bool)
    requires a <= middle <= b <= end <= |source| && Clear(trace)
    ensures Extends(trace,Merge(source,middle,end,a,b,trace,env).trace,env)
    ensures Stopped(Merge(source,middle,end,a,b,trace,env))
    ensures Merge(source,middle,end,a,b,trace,env).Success? ==>
              multiset(Merge(source,middle,end,a,b,trace,env).ids) == multiset(source[a..middle])+multiset(source[b..end])
    ensures Merge(source,middle,end,a,b,trace,env).Success? && Coherent(Merge(source,middle,end,a,b,trace,env).trace,le) ==>
              Merge(source,middle,end,a,b,trace,env).ids == C.Merge(le,source[a..middle],source[b..end])
    decreases middle-a+end-b
  {
    if a < middle && b < end {
      var q := Request(a,b,source[a],source[b]); var choice := env(trace,q);
      var next := trace+[Row(q,choice)];
      Append(trace,q,env);
      if choice.Chosen? {
        assert Clear(next);
        var rest: Outcome;
        if choice.left {
          MergeFacts(source,middle,end,a+1,b,next,env,le);
          rest := Merge(source,middle,end,a+1,b,next,env);
          assert source[a..middle] == [source[a]]+source[a+1..middle];
        } else {
          MergeFacts(source,middle,end,a,b+1,next,env,le);
          rest := Merge(source,middle,end,a,b+1,next,env);
          assert source[b..end] == [source[b]]+source[b+1..end];
        }
        Compose(trace,next,rest.trace,env); Prefix(next,rest.trace,le);
        if Coherent(rest.trace,le) {
          assert next[|trace|] == Row(q,choice);
          assert choice.left == le(source[a],source[b]);
        }
      }
    }
  }

  lemma PassFacts(source: seq<nat>,width: nat,start: nat,trace: seq<Row>,env: Environment,le: (nat,nat)->bool)
    requires width > 0 && Clear(trace)
    ensures Extends(trace,Pass(source,width,start,trace,env).trace,env)
    ensures Stopped(Pass(source,width,start,trace,env))
    ensures Pass(source,width,start,trace,env).Success? ==>
              multiset(Pass(source,width,start,trace,env).ids) == multiset(source[C.Min(start,|source|)..])
    decreases |source|-start
  {
    if start < |source| {
      var middle := C.Min(start+width,|source|); var end := C.Min(start+2*width,|source|);
      MergeFacts(source,middle,end,start,middle,trace,env,le);
      var first := Merge(source,middle,end,start,middle,trace,env);
      if first.Success? {
        PassFacts(source,width,start+2*width,first.trace,env,le);
        var rest := Pass(source,width,start+2*width,first.trace,env);
        Compose(trace,first.trace,rest.trace,env);
        assert source[start..] == source[start..middle]+source[middle..end]+source[end..];
      }
    }
  }
  lemma SortFacts(source: seq<nat>,width: nat,trace: seq<Row>,env: Environment,le: (nat,nat)->bool)
    requires width > 0 && Clear(trace)
    ensures Extends(trace,Sort(source,width,trace,env).trace,env)
    ensures Stopped(Sort(source,width,trace,env))
    ensures Sort(source,width,trace,env).Success? ==> multiset(Sort(source,width,trace,env).ids) == multiset(source)
    decreases |source|-width
  {
    if width < |source| {
      PassFacts(source,width,0,trace,env,le);
      var pass := Pass(source,width,0,trace,env);
      if pass.Success? {
        SortFacts(pass.ids,2*width,pass.trace,env,le);
        Compose(trace,pass.trace,Sort(pass.ids,2*width,pass.trace,env).trace,env);
        assert source[0..] == source;
      }
    }
  }
  lemma Advance(block: nat,width: nat)
    ensures block*(2*width)+2*width == (block+1)*(2*width)
  {}

  lemma Counters(n: nat,width: nat,start: nat)
    requires CountRoom(n) && 0 < width < n && start < n
    ensures width*2 < Pow256(32) && start+width < Pow256(32) && start+2*width < Pow256(32)
  {}
  lemma Increment(n: nat,i: nat)
    requires CountRoom(n) && i < n
    ensures i+1 < Pow256(32)
  {}
}

// SPDX-License-Identifier: MIT
// Value merge suffix under faithful comparison-result and value-array projections.
include "Properties.dfy"
module CollectionsValueSortTraceSource {
  import opened CollectionsValueSortTraceModel
  import C = CollectionsSortModel
  import Core = CollectionsSortConnection
  import R = CollectionsSortRanges
  import Proof = CollectionsValueSortTraceProperties

  ghost method MergeRange(source: seq<nat>,initial: seq<nat>,start: nat,middle: nat,end: nat,before: seq<Row>,env: Environment,le: (nat,nat)->bool)
    returns (result: Outcome,scratch: seq<nat>)
    requires CountRoom(|source|)
    requires |initial| == |source| && start <= middle <= end <= |source| && Clear(before)
    ensures result == Merge(source,middle,end,start,middle,before,env)
    ensures |scratch| == |source| && scratch[..start] == initial[..start] && scratch[end..] == initial[end..]
    ensures result.Success? ==> scratch[start..end] == result.ids && multiset(result.ids) == multiset(source[start..end])
    ensures Extends(before,result.trace,env) && Stopped(result)
    ensures result.Success? && Coherent(result.trace,le) ==> result.ids == C.Merge(le,source[start..middle],source[middle..end])
  {
    scratch := initial;
    var expected := Merge(source,middle,end,start,middle,before,env);
    Proof.MergeFacts(source,middle,end,start,middle,before,env,le);
    var trace := before;
    var a := start; var b := middle;
    var dest := start;
    while $DEST_GUARD
      invariant start <= a <= middle <= b <= end
      invariant start <= dest <= end && (a-start)+(b-middle) == dest-start
      invariant |scratch| == |source| && scratch[..start] == initial[..start] && scratch[end..] == initial[end..]
      invariant Prepend(scratch[start..dest],Merge(source,middle,end,a,b,trace,env)) == expected
      invariant Clear(trace)
      decreases end-dest
    {
      var takeA := $TAKE_INIT;
      var rest := Merge(source,middle,end,a,b,trace,env);
      if $COMPARE_GUARD {
        var q := Request(a,b,source[a],source[b]);
        var choice := env(trace,q);
        trace := trace+[Row(q,choice)];
        if choice.Rejected? { result := Failure(choice.reason,trace); return; }
        takeA := choice.left;
      }
      if $LEFT_EMPTY { takeA := false; }
      var prefix := scratch[start..dest];
      var value: nat;
      if takeA {
        assert a < middle;
        value := source[a];
        assert source[a..middle] == [source[a]]+source[a+1..middle];
        assert rest == Prepend([value],Merge(source,middle,end,a+1,b,trace,env));
        Proof.PrependJoin(prefix,[value],Merge(source,middle,end,a+1,b,trace,env));
        Proof.Increment(|source|,a);
        a := a+1;
      } else {
        assert b < end;
        value := source[b];
        assert source[b..end] == [source[b]]+source[b+1..end];
        assert rest == Prepend([value],Merge(source,middle,end,a,b+1,trace,env));
        Proof.PrependJoin(prefix,[value],Merge(source,middle,end,a,b+1,trace,env));
        Proof.Increment(|source|,b);
        b := b+1;
      }
      Core.Write(scratch,start,dest,end,value);
      scratch := scratch[dest := value];
      Proof.Increment(|source|,dest);
      dest := dest+1;
    }
    assert a == middle && b == end;
    result := Success(scratch[start..end],trace);
    assert source[start..end] == source[start..middle]+source[middle..end];
  }

  ghost method Pass(source: seq<nat>,initial: seq<nat>,width: nat,before: seq<Row>,env: Environment,le: (nat,nat)->bool)
    returns (result: Outcome,scratch: seq<nat>)
    requires CountRoom(|source|) && 0 < width < |source| && |initial| == |source| && Clear(before)
    ensures result == CollectionsValueSortTraceModel.Pass(source,width,0,before,env)
    ensures |scratch| == |source|
    ensures result.Success? ==> scratch == result.ids && multiset(scratch) == multiset(source)
    ensures Extends(before,result.trace,env) && Stopped(result)
    ensures result.Success? && Coherent(result.trace,le) && C.Order(|source|,le) && C.Runs(|source|,le,source,width) ==> C.Runs(|source|,le,scratch,2*width)
  {
    var n := |source|;
    var expected := CollectionsValueSortTraceModel.Pass(source,width,0,before,env);
    Proof.PassFacts(source,width,0,before,env,le);
    var trace := before;
    scratch := initial;
    var start: nat := 0; var block: nat := 0;
    while $START_GUARD
      invariant start == block*(2*width) && |scratch| == n
      invariant Prepend(scratch[..C.Min(start,n)],CollectionsValueSortTraceModel.Pass(source,width,start,trace,env)) == expected
      invariant Clear(trace)
      invariant Coherent(trace,le) && C.Order(n,le) && C.Runs(n,le,source,width) ==>
                  (forall j: nat :: j < block && j*(2*width) < n ==>
                                      var lo := j*(2*width); var hi := C.Min(lo+2*width,n);
                                                             C.Sorted(le,scratch[lo..hi]) && multiset(scratch[lo..hi]) == multiset(C.Range(lo,hi-lo)))
      decreases n-start
    {
      Proof.Counters(n,width,start);
      var middle := C.Min(start+width,n); var end := C.Min(start+2*width,n);
      var previous := scratch; var previousTrace := trace;
      var prefix := scratch[..start];
      var pending := CollectionsValueSortTraceModel.Pass(source,width,start,trace,env);
      var merged;
      merged,scratch := MergeRange(source,scratch,start,middle,end,trace,env,le);
      if merged.Failure? { result := merged; return; }
      Proof.Prefix(previousTrace,merged.trace,le);
      trace := merged.trace;
      Proof.PrependJoin(prefix,merged.ids,CollectionsValueSortTraceModel.Pass(source,width,start+2*width,trace,env));
      assert scratch[..end] == scratch[..start]+scratch[start..end];
      assert source[..end] == source[..start]+source[start..end];
      if Coherent(trace,le) && C.Order(n,le) && C.Runs(n,le,source,width) {
        R.Block(n,le,source,width,block);
        forall j: nat | j < block && j*(2*width) < n
          ensures var lo := j*(2*width); var hi := C.Min(lo+2*width,n); scratch[lo..hi] == previous[lo..hi]
        {
          R.Scale(j+1,block,2*width);
          var lo := j*(2*width); var hi := C.Min(lo+2*width,n);
          assert lo+2*width == (j+1)*(2*width);
          assert hi <= start;
          Core.Prefix(scratch,previous,start,lo,hi);
        }

      }
      Proof.Advance(block,width);
      start := start+2*width; block := block+1;
    }
    result := Success(scratch,trace);
    assert C.Min(start,n) == n && scratch[..n] == scratch && source[..n] == source;
    if Coherent(trace,le) && C.Order(n,le) && C.Runs(n,le,source,width) {
      reveal C.Runs();
      forall j: nat | j*(2*width) < n
        ensures var lo := j*(2*width); var hi := C.Min(lo+2*width,n);
                                       C.Sorted(le,scratch[lo..hi]) && multiset(scratch[lo..hi]) == multiset(C.Range(lo,hi-lo))
      {
        if j >= block { R.Scale(block,j,2*width); assert false; }
      }
    }
  }


  ghost method Sort(n: nat,env: Environment,le: (nat,nat)->bool) returns (result: Outcome)
    requires CountRoom(n)
    ensures result == CollectionsValueSortTraceModel.Sort(C.Range(0,n),1,[],env)
    ensures Extends([],result.trace,env) && Stopped(result)
    ensures result.Success? ==> |result.ids| == n && multiset(result.ids) == multiset(C.Range(0,n)) && C.Well(n,result.ids)
    ensures result.Success? && Coherent(result.trace,le) && C.Order(n,le) ==> C.Sorted(le,result.ids)
    ensures n < 2 ==> result == Success(C.Range(0,n),[])
  {
    var out := C.Range(0,n);
    var scratch: seq<nat> := seq(n,i => n);
    var trace: seq<Row> := [];
    var width: nat := 1;
    var expected := CollectionsValueSortTraceModel.Sort(out,1,trace,env);
    Proof.SortFacts(out,1,trace,env,le);
    R.Initial(n,le);
    while $WIDTH_GUARD
      invariant width > 0 && |out| == n && |scratch| == n
      invariant Clear(trace) && multiset(out) == multiset(C.Range(0,n))
      invariant CollectionsValueSortTraceModel.Sort(out,width,trace,env) == expected
      invariant Coherent(trace,le) && C.Order(n,le) ==> C.Runs(n,le,out,width)
      decreases n-width
    {
      Proof.Counters(n,width,0);
      var previous := out; var previousTrace := trace;
      var pass;
      pass,scratch := Pass(out,scratch,width,trace,env,le);
      if pass.Failure? { result := pass; return; }
      Proof.Prefix(previousTrace,pass.trace,le);
      trace := pass.trace;
      out := scratch; scratch := previous;
      width := width*2;
    }
    result := Success(out,trace);
    if n > 0 && Coherent(trace,le) && C.Order(n,le) {
      assert C.Sorted(le,out) by { reveal C.Runs(); assert 0*width < n && C.Min(0+width,n) == n; }
    }
    R.Verdict(n,le,out);
  }
}

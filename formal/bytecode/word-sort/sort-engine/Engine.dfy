// SPDX-License-Identifier: MIT
// Actual arbitrary finite width loop with physical swaps and independent stable-sort verdict.
include "../pass-engine/Engine.dfy"
include "../initial-memory/Memory.dfy"
include "../segments/PassEnter.generated.dfy"
include "../segments/PassFinish.generated.dfy"
include "../segments/PassAfterMul.generated.dfy"
include "../segments/SortExit.generated.dfy"
include "../mul2-swap/Mul2Swap.generated.dfy"
module BytecodeSortEngine {
  import opened BytecodeScanMachine
  import M = BytecodeWordSortMemory
  import O = BytecodeWordSortOriginalSpec
  import N = BytecodeSortInitialMemory
  import P = BytecodeSortPassEngine
  import G = BytecodeSortRangeEngine
  import A = BytecodeSortSegmentPassEnter
  import F = BytecodeSortSegmentPassFinish
  import T = BytecodeSortSegmentPassAfterMul
  import X = BytecodeSortSegmentSortExit
  import K = BytecodeSortHelperMul2Swap
  import E = BytecodeScanExecution
  import S = CollectionsSortModel
  import R = CollectionsSortRanges
  predicate Matches(code: seq<Byte>) { P.Matches(code) && A.Matches(code) && F.Matches(code) && T.Matches(code) && X.Matches(code) && K.Matches(code) }
  function Destinations(): set<nat> { P.Destinations()+A.Destinations()+F.Destinations()+T.Destinations()+X.Destinations()+K.Destinations() }
  ghost method Append(code: seq<Byte>, value: Word, data: seq<Byte>, left: seq<State>, right: seq<State>, small: set<nat>) returns (trace: seq<State>)
    requires E.Trace(code,Destinations(),value,data,left) && E.Trace(code,small,value,data,right)
    requires small <= Destinations() && left[|left|-1] == right[0]
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace == left+right[1..] && trace[0] == left[0] && trace[|trace|-1] == right[|right|-1]
  { E.WidenTrace(code,small,Destinations(),value,data,right); E.Join(code,Destinations(),value,data,left,right); trace := left+right[1..]; }
  ghost method Run(code: seq<Byte>, n: Word, offset: Word, data: seq<Byte>, value: Word)
    returns (state: State, trace: seq<State>, left: seq<nat>, right: seq<nat>, which: bool, ids: seq<nat>)
    requires Matches(code) && O.Fits(data,offset,n)
    ensures M.Admitted(n,left,right,offset,data) && ids == (if which then right else left)
    ensures |ids| == n && multiset(ids) == multiset(S.Range(0,n)) && O.Bounds(n,ids) && O.Sorted(O.Values(data,offset,n),ids)
    ensures state == Running(518,[785862473,M.Base(n,which)],M.Heap(n,left,right,offset,data))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(3612,[785862473,518,offset,n*32,128,n,160+n*32,1],M.Heap(n,N.Originals(n),N.Scratch(n),offset,data)) && trace[|trace|-1] == state
  {
    left := N.Originals(n); right := N.Scratch(n); which := false;
    var le := (x: nat,y: nat) => G.Le(n,offset,data,x,y);
    assert S.Order(n,le);
    assert left == S.Range(0,n);
    R.Initial(n,le);
    var width: Word := 1;
    state := Running(3612,[785862473,518,offset,n*32,128,n,160+n*32,1],M.Heap(n,left,right,offset,data));
    trace := [state];
    while width < n
      invariant 0 < width <= 2*n+1 && M.Admitted(n,left,right,offset,data)
      invariant O.Bounds(n,(if which then right else left)) && multiset((if which then right else left)) == multiset(S.Range(0,n))
      invariant S.Runs(n,le,(if which then right else left),width)
      invariant state == Running(3612,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width],M.Heap(n,left,right,offset,data))
      invariant E.Trace(code,Destinations(),value,data,trace) && trace[|trace|-1] == state
      invariant trace[0] == Running(3612,[785862473,518,offset,n*32,128,n,160+n*32,1],M.Heap(n,N.Originals(n),N.Scratch(n),offset,data))
      decreases n-width
    {
      var out: Word := M.Base(n,which); var other: Word := M.Base(n,!which);
      var mem := M.Heap(n,left,right,offset,data);
      var part: seq<State>; var start: Word;
      state,part := A.Run(code,offset,n,out,other,width,0,0,0,0,0,0,0,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,A.Destinations());
      state,part,left,right,start := P.Run(code,n,left,right,offset,data,which,width,value);
      trace := Append(code,value,data,trace,part,P.Destinations());
      mem := M.Heap(n,left,right,offset,data);
      state,part := F.Run(code,offset,n,out,other,width,start,0,0,0,0,0,0,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,F.Destinations());
      var prefix: seq<Word> := [785862473,518,offset,n*32,other,n,out,width];
      assert state == Running(23581,prefix+[3919,2,width],mem);
      state,part := K.Run(code,prefix,width,mem,value,data);
      trace := Append(code,value,data,trace,part,K.Destinations());
      state,part := T.Run(code,offset,n,other,out,width,0,0,0,0,0,0,0,0,0,mem,value,data);
      trace := Append(code,value,data,trace,part,T.Destinations());
      width := width*2; which := !which;
    }
    ids := if which then right else left;
    if n > 0 {
      assert S.Sorted(le,ids) by { reveal S.Runs(); assert 0*width < n && S.Min(width,n) == n; }
    }
    R.Verdict(n,le,ids);
    forall i,j | 0 <= i < j < n
      ensures O.Values(data,offset,n)[ids[i]] <= O.Values(data,offset,n)[ids[j]] && (O.Values(data,offset,n)[ids[i]] == O.Values(data,offset,n)[ids[j]] ==> ids[i] < ids[j])
    {
      assert le(ids[i],ids[j]) && (le(ids[j],ids[i]) ==> ids[i] < ids[j]);
      assert M.Cell(n,ids[i],offset,data) == O.Values(data,offset,n)[ids[i]] && M.Cell(n,ids[j],offset,data) == O.Values(data,offset,n)[ids[j]];
    }
    var out: Word := M.Base(n,which); var other: Word := M.Base(n,!which);
    var part: seq<State>;
    state,part := X.Run(code,offset,n,out,other,width,0,0,0,0,0,0,0,0,0,M.Heap(n,left,right,offset,data),value,data);
    trace := Append(code,value,data,trace,part,X.Destinations());
  }
}

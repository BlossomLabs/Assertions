// SPDX-License-Identifier: MIT
// Arbitrary finite actual pass, preserving occurrence IDs and doubling sorted run width.
include "../range-engine/Engine.dfy"
include "../block-connection/Connection.dfy"
include "../pass-finish-proof/Finished.dfy"
include "../pass-block-proof/Advance.dfy"
include "../pass-start-proof/Next.dfy"
include "../pass-range-proof/Sorted.dfy"
module BytecodeSortPassEngine {
  import opened BytecodeScanMachine
  import M = BytecodeWordSortMemory
  import O = BytecodeWordSortOriginalSpec
  import B = BytecodeSortBlockConnection
  import G = BytecodeSortRangeEngine
  import I = BytecodeSortInnerConnection
  import E = BytecodeScanExecution
  import S = CollectionsSortModel
  import R = CollectionsSortRanges
  import C = CollectionsSortConnection
  import A = BytecodeSortPassBlocks
  import F = BytecodeSortFinishedPass
  import T = BytecodeSortNextStart
  import Q = BytecodeSortMergedBlock
  import P = CollectionsSortMerge
  predicate Matches(code: seq<Byte>) { B.Matches(code) && I.Matches(code) }
  function Destinations(): set<nat> { B.Destinations()+I.Destinations() }
  lemma BoundsSame(n: nat, a: seq<nat>, b: seq<nat>)
    requires O.Bounds(n,a) && multiset(a) == multiset(b)
    ensures O.Bounds(n,b)
  {
    forall i {:trigger b[i]} | 0 <= i < |b| ensures b[i] < n
    {
      P.SameMember(b,a,b[i]);
      var j :| 0 <= j < |a| && a[j] == b[i];
    }
  }
  ghost method Append(code: seq<Byte>, value: Word, data: seq<Byte>, left: seq<State>, right: seq<State>, small: set<nat>) returns (trace: seq<State>)
    requires E.Trace(code,Destinations(),value,data,left) && E.Trace(code,small,value,data,right)
    requires small <= Destinations() && left[|left|-1] == right[0]
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace == left+right[1..] && trace[0] == left[0] && trace[|trace|-1] == right[|right|-1]
  { E.WidenTrace(code,small,Destinations(),value,data,right); E.Join(code,Destinations(),value,data,left,right); trace := left+right[1..]; }
  lemma BlocksPrefix(a: seq<nat>, b: seq<nat>, start: nat, n: nat, width: nat, block: nat)
    requires 0 < width && |a| == |b| == n && start == block*(2*width) && start <= n && a[..start] == b[..start]
    ensures forall j: nat :: j < block && j*(2*width) < n ==> var lo := j*(2*width); var hi := S.Min(lo+2*width,n); a[lo..hi] == b[lo..hi]
  {
    forall j: nat | j < block && j*(2*width) < n
      ensures var lo := j*(2*width); var hi := S.Min(lo+2*width,n); a[lo..hi] == b[lo..hi]
    {
      R.Scale(j+1,block,2*width);
      var lo := j*(2*width); var hi := S.Min(lo+2*width,n);
      assert lo+2*width == (j+1)*(2*width);
      assert hi <= start;
      C.Prefix(a,b,start,lo,hi);
    }
  }
  ghost method Run(code: seq<Byte>, n: Word, left: seq<nat>, right: seq<nat>, offset: Word, data: seq<Byte>, which: bool, width: Word, value: Word)
    returns (state: State, trace: seq<State>, left1: seq<nat>, right1: seq<nat>, start: Word)
    requires Matches(code) && M.Admitted(n,left,right,offset,data) && O.Bounds(n,(if which then right else left)) && 0 < width < n
    ensures M.Admitted(n,left1,right1,offset,data) && n <= start < 3*n
    ensures (if which then right1 else left1) == (if which then right else left)
    ensures O.Bounds(n,(if which then left1 else right1))
    ensures multiset((if which then left1 else right1)) == multiset((if which then right else left))
    ensures var le := (x: nat,y: nat) => G.Le(n,offset,data,x,y);
            S.Order(n,le) && S.Runs(n,le,(if which then right else left),width) ==> S.Runs(n,le,(if which then left1 else right1),2*width)
    ensures state == Running(3622,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width,start],M.Heap(n,left1,right1,offset,data))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(3622,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width,0],M.Heap(n,left,right,offset,data)) && trace[|trace|-1] == state
  {
    var source := if which then right else left;
    var scratch := if which then left else right;
    var le := (x: nat,y: nat) => G.Le(n,offset,data,x,y);
    var out: Word := M.Base(n,which); var other: Word := M.Base(n,!which);
    left1 := left; right1 := right; start := 0;
    var block: nat := 0;
    state := Running(3622,[785862473,518,offset,n*32,out,n,other,width,0],M.Heap(n,left1,right1,offset,data));
    trace := [state];
    while start < n
      invariant start == block*(2*width) && start < 3*n
      invariant M.Admitted(n,left1,right1,offset,data)
      invariant (if which then right1 else left1) == source && (if which then left1 else right1) == scratch
      invariant |scratch| == n && multiset(scratch[..S.Min(start,n)]) == multiset(source[..S.Min(start,n)])
      invariant S.Order(n,le) && S.Runs(n,le,source,width) ==> (forall j: nat :: j < block && j*(2*width) < n ==>
                                                                                   var lo := j*(2*width); var hi := S.Min(lo+2*width,n); S.Sorted(le,scratch[lo..hi]) && multiset(scratch[lo..hi]) == multiset(S.Range(lo,hi-lo)))
      invariant E.Trace(code,Destinations(),value,data,trace) && trace[|trace|-1] == state
      invariant trace[0] == Running(3622,[785862473,518,offset,n*32,out,n,other,width,0],M.Heap(n,left,right,offset,data))
      invariant state == Running(3622,[785862473,518,offset,n*32,out,n,other,width,start],M.Heap(n,left1,right1,offset,data))
      decreases n-start
    {
      var part: seq<State>; var middle: Word; var end: Word;
      state,part,middle,end := B.Prepare(code,n,offset,out,other,width,start,M.Heap(n,left1,right1,offset,data),value,data);
      trace := Append(code,value,data,trace,part,B.Destinations());
      var previous := scratch;
      state,part,left1,right1 := G.Run(code,n,left1,right1,offset,data,which,width,start,middle,end,value);
      trace := Append(code,value,data,trace,part,I.Destinations());
      scratch := if which then left1 else right1;
      assert scratch[..end] == scratch[..start]+scratch[start..end];
      assert source[..end] == source[..start]+source[start..end];
      if S.Order(n,le) && S.Runs(n,le,source,width) {
        Q.SortedBlock(n,le,source,scratch[start..end],width,start,middle,end,block);
        A.Advance(previous,scratch,n,width,start,end,block,le);
      }
      state,part := B.Finish(code,n,offset,out,other,width,start,middle,end,M.Heap(n,left1,right1,offset,data),value,data);
      trace := Append(code,value,data,trace,part,B.Destinations());
      T.Next(start,block,width,n);
      start := start+2*width; block := block+1;
    }
    assert S.Min(start,n) == n && scratch[..n] == scratch && source[..n] == source;
    BoundsSame(n,source,scratch);
    if S.Order(n,le) && S.Runs(n,le,source,width) {
      F.Finished(n,le,scratch,width,start,block);
    }
  }
}

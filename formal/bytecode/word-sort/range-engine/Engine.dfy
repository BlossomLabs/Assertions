// SPDX-License-Identifier: MIT
// Arbitrary finite actual merge range, connected to independent recursive Merge.
include "../inner-connection/Connection.dfy"
module BytecodeSortRangeEngine {
  import opened BytecodeScanMachine
  import M = BytecodeWordSortMemory
  import O = BytecodeWordSortOriginalSpec
  import I = BytecodeSortInnerConnection
  import E = BytecodeScanExecution
  import S = CollectionsSortModel
  import C = CollectionsSortConnection
  import P = CollectionsSortMerge
  predicate Le(n: nat, offset: Word, data: seq<Byte>, x: nat, y: nat)
    requires O.Fits(data,offset,n)
  { x < n && y < n && M.Cell(n,x,offset,data) <= M.Cell(n,y,offset,data) }
  ghost method Run(code: seq<Byte>, n: Word, left: seq<nat>, right: seq<nat>, offset: Word, data: seq<Byte>, which: bool,
                   width: Word, start: Word, middle: Word, end: Word, value: Word)
    returns (state: State, trace: seq<State>, left1: seq<nat>, right1: seq<nat>)
    requires I.Matches(code) && M.Admitted(n,left,right,offset,data)
    requires O.Bounds(n,(if which then right else left))
    requires 0 < width <= 2*n+1 && start <= middle <= end <= n
    ensures M.Admitted(n,left1,right1,offset,data)
    ensures (if which then right1 else left1) == (if which then right else left)
    ensures var source := if which then right else left;
            var before := if which then left else right;
            var after := if which then left1 else right1;
            after[..start] == before[..start] && after[end..] == before[end..] &&
            after[start..end] == S.Merge((x: nat,y: nat) => Le(n,offset,data,x,y),source[start..middle],source[middle..end]) &&
            multiset(after[start..end]) == multiset(source[start..end])
    ensures state == Running(3726,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width,start,middle,end,middle,end,end],M.Heap(n,left1,right1,offset,data))
    ensures E.Trace(code,I.Destinations(),value,data,trace)
    ensures trace[0] == Running(3726,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width,start,middle,end,start,middle,start],M.Heap(n,left,right,offset,data)) && trace[|trace|-1] == state
  {
    var source := if which then right else left;
    var before := if which then left else right;
    var scratch := before;
    var le := (x: nat,y: nat) => Le(n,offset,data,x,y);
    left1 := left; right1 := right;
    var a: Word := start; var b: Word := middle; var dest: Word := start;
    state := Running(3726,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width,start,middle,end,a,b,dest],M.Heap(n,left1,right1,offset,data));
    trace := [state];
    while dest < end
      invariant start <= a <= middle <= b <= end && start <= dest <= end && (a-start)+(b-middle) == dest-start
      invariant M.Admitted(n,left1,right1,offset,data)
      invariant (if which then right1 else left1) == source && (if which then left1 else right1) == scratch
      invariant |scratch| == n && scratch[..start] == before[..start] && scratch[end..] == before[end..]
      invariant scratch[start..dest]+S.Merge(le,source[a..middle],source[b..end]) == S.Merge(le,source[start..middle],source[middle..end])
      invariant E.Trace(code,I.Destinations(),value,data,trace) && trace[|trace|-1] == state
      invariant trace[0] == Running(3726,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width,start,middle,end,start,middle,start],M.Heap(n,left,right,offset,data))
      invariant state == Running(3726,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width,start,middle,end,a,b,dest],M.Heap(n,left1,right1,offset,data))
      decreases end-dest
    {
      var oldA := a; var oldB := b;
      var part: seq<State>; var id: nat; var takeA: bool;
      var nextLeft: seq<nat>; var nextRight: seq<nat>;
      state,part,nextLeft,nextRight,a,b,id,takeA := I.Run(code,n,left1,right1,offset,data,which,width,start,middle,end,a,b,dest,value);
      if takeA {
        assert oldA < middle && id == source[oldA];
        assert source[oldA..middle] == [id]+source[oldA+1..middle];
        assert S.Merge(le,source[oldA..middle],source[oldB..end]) == [id]+S.Merge(le,source[a..middle],source[b..end]);
      } else {
        assert oldB < end && id == source[oldB];
        assert source[oldB..end] == [id]+source[oldB+1..end];
        assert S.Merge(le,source[oldA..middle],source[oldB..end]) == [id]+S.Merge(le,source[a..middle],source[b..end]);
      }
      E.Join(code,I.Destinations(),value,data,trace,part);
      trace := trace+part[1..];
      C.Write(scratch,start,dest,end,id);
      scratch := scratch[dest := id];
      left1 := nextLeft; right1 := nextRight;
      dest := dest+1;
    }
    assert a == middle && b == end;
    P.Permutation(le,source[start..middle],source[middle..end]);
    assert source[start..end] == source[start..middle]+source[middle..end];
  }
}

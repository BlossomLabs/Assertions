// SPDX-License-Identifier: MIT
// Actual complete merge iteration, original occurrence read/write and index progress.
include "../decision-connection/Connection.dfy"
include "../helper-connection/Connection.dfy"
include "../kernels/Inc1.generated.dfy"
include "../segments/InnerContinue.generated.dfy"
include "../segments/TakeLeftPrepare.generated.dfy"
include "../segments/TakeRightPrepare.generated.dfy"
include "../segments/AfterLeftInc.generated.dfy"
include "../segments/AfterRightInc.generated.dfy"
include "../segments/InnerTail.generated.dfy"
module BytecodeSortInnerConnection {
  import opened BytecodeScanMachine
  import M = BytecodeWordSortMemory
  import D = BytecodeSortDecisionConnection
  import H = BytecodeSortPhysicalHelperConnection
  import R = BytecodeSortMemoryHelperWordAt
  import W = BytecodeSortMemoryHelperSetWord
  import I = BytecodeSortHelperInc1
  import G = BytecodeSortSegmentInnerContinue
  import L = BytecodeSortSegmentTakeLeftPrepare
  import B = BytecodeSortSegmentTakeRightPrepare
  import A = BytecodeSortSegmentAfterLeftInc
  import C = BytecodeSortSegmentAfterRightInc
  import T = BytecodeSortSegmentInnerTail
  import E = BytecodeScanExecution
  predicate Matches(code: seq<Byte>) {
    D.Matches(code) && R.Matches(code) && W.Matches(code) && I.Matches(code) && G.Matches(code) && L.Matches(code) && B.Matches(code) && A.Matches(code) && C.Matches(code) && T.Matches(code)
  }
  function Destinations(): set<nat> { D.Destinations()+R.Destinations()+W.Destinations()+I.Destinations()+G.Destinations()+L.Destinations()+B.Destinations()+A.Destinations()+C.Destinations()+T.Destinations() }
  ghost method Append(code: seq<Byte>, value: Word, data: seq<Byte>, left: seq<State>, right: seq<State>, small: set<nat>) returns (trace: seq<State>)
    requires E.Trace(code,Destinations(),value,data,left) && E.Trace(code,small,value,data,right)
    requires small <= Destinations() && left[|left|-1] == right[0]
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace == left+right[1..] && trace[0] == left[0] && trace[|trace|-1] == right[|right|-1]
  { E.WidenTrace(code,small,Destinations(),value,data,right); E.Join(code,Destinations(),value,data,left,right); trace := left+right[1..]; }
  ghost method Run(code: seq<Byte>, n: Word, left: seq<nat>, right: seq<nat>, offset: Word, data: seq<Byte>, which: bool,
                   width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, value: Word)
    returns (state: State, trace: seq<State>, left1: seq<nat>, right1: seq<nat>, a1: Word, b1: Word, id: nat, takeA: bool)
    requires Matches(code) && M.Admitted(n,left,right,offset,data)
    requires var source := if which then right else left; forall i {:trigger source[i]} :: 0 <= i < n ==> source[i] < n
    requires 0 < width <= 2*n+1 && start <= a <= middle <= b <= end <= n && start <= dest < end
    requires (a-start)+(b-middle) == dest-start
    ensures takeA == (a < middle && (b == end || M.Cell(n,(if which then right else left)[a],offset,data) <= M.Cell(n,(if which then right else left)[b],offset,data)))
    ensures id == (if which then right else left)[if takeA then a else b] && id < n
    ensures a1 == a+(if takeA then 1 else 0) && b1 == b+(if takeA then 0 else 1)
    ensures start <= a1 <= middle <= b1 <= end && (a1-start)+(b1-middle) == dest+1-start
    ensures left1 == (if which then left[dest := id] else left) && right1 == (if which then right else right[dest := id])
    ensures M.Admitted(n,left1,right1,offset,data)
    ensures state == Running(3726,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width,start,middle,end,a1,b1,dest+1],M.Heap(n,left1,right1,offset,data))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(3726,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width,start,middle,end,a,b,dest],M.Heap(n,left,right,offset,data)) && trace[|trace|-1] == state
  {
    var out: Word := M.Base(n,which);
    var scratch: Word := M.Base(n,!which);
    var mem := M.Heap(n,left,right,offset,data);
    var source := if which then right else left;
    state,trace := G.Run(code,offset,n,out,scratch,width,start,middle,end,a,b,dest,0,0,0,mem,value,data);
    E.WidenTrace(code,G.Destinations(),Destinations(),value,data,trace);
    var part: seq<State>;
    state,part,takeA := D.Run(code,n,left,right,offset,data,which,width,start,middle,end,a,b,dest,value);
    trace := Append(code,value,data,trace,part,D.Destinations());
    var take: Word := if takeA then 1 else 0;
    var prefix: seq<Word> := [785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a,b,dest,take,3860,scratch,dest,3847,out];
    var index: Word;
    if takeA {
      index := a; a1 := a+1; b1 := b;
      state,part := L.Run(code,offset,n,out,scratch,width,start,middle,end,a,b,dest,0,0,take,mem,value,data);
      trace := Append(code,value,data,trace,part,L.Destinations());
      assert state == Running(23760,prefix+[a,3830,a],mem);
      state,part := I.Run(code,prefix+[a],a,3830,mem,value,data);
      trace := Append(code,value,data,trace,part,I.Destinations());
      state,part := A.Run(code,offset,n,out,scratch,width,start,middle,end,a,b,dest,0,0,take,mem,value,data);
      trace := Append(code,value,data,trace,part,A.Destinations());
    } else {
      index := b; a1 := a; b1 := b+1;
      state,part := B.Run(code,offset,n,out,scratch,width,start,middle,end,a,b,dest,0,0,take,mem,value,data);
      trace := Append(code,value,data,trace,part,B.Destinations());
      assert state == Running(23760,prefix+[b,3813,b],mem);
      state,part := I.Run(code,prefix+[b],b,3813,mem,value,data);
      trace := Append(code,value,data,trace,part,I.Destinations());
      state,part := C.Run(code,offset,n,out,scratch,width,start,middle,end,a,b,dest,0,0,take,mem,value,data);
      trace := Append(code,value,data,trace,part,C.Destinations());
    }
    id := source[index];
    var frame: seq<Word> := [785862473,518,offset,n*32,out,n,scratch,width,start,middle,end,a1,b1,dest,take];
    assert state == Running(3833,frame+[3860,scratch,dest,3847,out,index],mem);
    state,part := H.Read(code,frame+[3860,scratch,dest],n,left,right,offset,data,which,index,value);
    trace := Append(code,value,data,trace,part,R.Destinations());
    state,part := H.Write(code,frame,n,left,right,offset,data,!which,dest,id,value);
    trace := Append(code,value,data,trace,part,W.Destinations());
    left1 := if which then left[dest := id] else left;
    right1 := if which then right else right[dest := id];
    state,part := T.Run(code,offset,n,out,scratch,width,start,middle,end,a1,b1,dest,0,0,take,M.Heap(n,left1,right1,offset,data),value,data);
    trace := Append(code,value,data,trace,part,T.Destinations());
  }
}

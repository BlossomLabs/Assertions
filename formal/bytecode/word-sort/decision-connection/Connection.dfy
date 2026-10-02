// SPDX-License-Identifier: MIT
// Exact unsigned left-first merge choice from physical original-occurrence buffers.
include "../memory/Memory.dfy"
include "../segments/DecisionLeft.generated.dfy"
include "../segments/DecisionRight.generated.dfy"
include "../segments/DecisionLeftExhausted.generated.dfy"
include "../segments/DecisionRightExhausted.generated.dfy"
module BytecodeSortDecisionConnection {
  import opened BytecodeScanMachine
  import M = BytecodeWordSortMemory
  import A = BytecodeSortSegmentDecisionLeft
  import B = BytecodeSortSegmentDecisionRight
  import C = BytecodeSortSegmentDecisionLeftExhausted
  import D = BytecodeSortSegmentDecisionRightExhausted
  import E = BytecodeScanExecution
  predicate Matches(code: seq<Byte>) { A.Matches(code) && B.Matches(code) && C.Matches(code) && D.Matches(code) }
  function Destinations(): set<nat> { A.Destinations()+B.Destinations()+C.Destinations()+D.Destinations() }
  ghost method Run(code: seq<Byte>, n: Word, left: seq<nat>, right: seq<nat>, offset: Word, data: seq<Byte>, which: bool,
                   width: Word, start: Word, middle: Word, end: Word, a: Word, b: Word, dest: Word, value: Word)
    returns (state: State, trace: seq<State>, takeA: bool)
    requires Matches(code) && M.Admitted(n,left,right,offset,data)
    requires 0 < width <= 2*n+1 && start <= a <= middle <= b <= end <= n && dest < end && (a < middle || b < end)
    ensures takeA == (a < middle && (b == end || M.Cell(n,(if which then right else left)[a],offset,data) <= M.Cell(n,(if which then right else left)[b],offset,data)))
    ensures state == Running(3789,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width,start,middle,end,a,b,dest,(if takeA then 1 else 0)],M.Heap(n,left,right,offset,data))
    ensures E.Trace(code,Destinations(),value,data,trace)
    ensures trace[0] == Running(3735,[785862473,518,offset,n*32,M.Base(n,which),n,M.Base(n,!which),width,start,middle,end,a,b,dest],M.Heap(n,left,right,offset,data)) && trace[|trace|-1] == state
    ensures |trace| == (if a == middle then 23 else if b == end then 25 else 45)
  {
    var mem := M.Heap(n,left,right,offset,data);
    var out: Word := M.Base(n,which);
    var scratch: Word := M.Base(n,!which);
    var source := if which then right else left;
    M.Rounded(n);
    if a == middle {
      takeA := false;
      state,trace := C.Run(code,offset,n,out,scratch,width,start,middle,end,a,b,dest,0,0,0,mem,value,data);
      E.WidenTrace(code,C.Destinations(),Destinations(),value,data,trace);
    } else if b == end {
      takeA := true;
      state,trace := D.Run(code,offset,n,out,scratch,width,start,middle,end,a,b,dest,0,0,0,mem,value,data);
      E.WidenTrace(code,D.Destinations(),Destinations(),value,data,trace);
    } else {
      M.Read(n,left,right,offset,data,which,a);
      M.Read(n,left,right,offset,data,which,b);
      var lword := M.Cell(n,source[a],offset,data);
      var rword := M.Cell(n,source[b],offset,data);
      takeA := lword <= rword;
      if takeA {
        state,trace := A.Run(code,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,0,mem,value,data);
        E.WidenTrace(code,A.Destinations(),Destinations(),value,data,trace);
      } else {
        state,trace := B.Run(code,offset,n,out,scratch,width,start,middle,end,a,b,dest,lword,rword,0,mem,value,data);
        E.WidenTrace(code,B.Destinations(),Destinations(),value,data,trace);
      }
    }
  }
}

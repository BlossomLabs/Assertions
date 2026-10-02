// SPDX-License-Identifier: MIT
// Lazy constrained RAW cond body; only the selected operand is admitted.
include "Prefix.dfy"
include "Selected.dfy"
module AssertionsCondConstrainedBody {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import D = AssertionsCondConstrainedSpec
  import H = AssertionsCondConstrainedHeap
  import L = AssertionsConstraintLoopSpec
  import N = AssertionsCondConstrainedPrefix
  import T = AssertionsCondConstrainedSelected
  import F = AssertionsGatherLoopFrame
  import Q = AssertionsPrimitiveExternalLift
  import W = AssertionsCondFirstWord
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) { N.Matches(code) && T.Matches(code) }
  function Destinations(ret: Word): set<nat> { N.Destinations(ret)+T.Destinations(ret) }
  function ConditionFree(free: Word, condition: D.Operand): Word
    requires D.Budget(free,condition)
  { L.Free(free+64+S.Round32(condition.length),condition.constraints,|condition.constraints|) }
  ghost method Run(code: seq<Byte>, ret: Word, condition: D.Operand, then_: Word,
                   else_: Word, selected: D.Operand, free: Word, prefix: seq<Word>,
                   mem: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat,
                   self: Word, value: Word, observations: seq<A.Observation>)
    returns (frame: E.Frame, frames: seq<E.Frame>)
    requires Matches(code) && D.Span(data,condition) && D.Heap(mem,free,condition) && |prefix| <= 930
    requires condition.length >= 32 ==> D.Span(data,selected) && D.Budget(ConditionFree(free,condition),selected) &&
                                        selected.pointer == (if H.First(D.Payload(data,condition)) == 0 then else_ else then_)
    ensures Q.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(1743,prefix+[ret,condition.pointer,then_,else_],mem),returned,cursor)
    ensures frames[|frames|-1] == frame
    ensures condition.length < 32 ==> frame == E.Frame(S.Reverted(W.Error(condition.length)),returned,cursor)
    ensures condition.length >= 32 ==> frame == E.Frame(S.Returned(D.Payload(data,selected)),returned,cursor)
  {
    hide S.DataWord(); hide S.Window();
    frame,frames := N.Run(code,ret,condition,then_,else_,free,prefix,mem,data,returned,cursor,self,value,observations);
    F.Widen(code,N.Destinations(ret),Destinations(ret),self,value,data,observations,frames);
    if condition.length >= 32 {
      var currentFree := ConditionFree(free,condition);
      assert D.Heap(frame.state.memory,currentFree,selected);
      var next,part := T.Run(code,ret,condition.pointer,then_,else_,free+32,
                             H.First(D.Payload(data,condition)),selected,currentFree,prefix,frame.state.memory,
                             data,returned,cursor,self,value,observations);
      F.Widen(code,T.Destinations(ret),Destinations(ret),self,value,data,observations,part);
      F.Join(code,Destinations(ret),self,value,data,observations,frames,part);
      frames := frames+part[1..];
      frame := next;
    }
  }
}

// SPDX-License-Identifier: MIT
// Actual cond prefix and constrained condition, with independent calldata admission.
include "Condition.dfy"
include "Spec.dfy"
module AssertionsCondConstrainedPrefix {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import D = AssertionsCondConstrainedSpec
  import H = AssertionsCondConstrainedHeap
  import C = AssertionsControlCondStart
  import N = AssertionsCondConstrainedCondition
  import P = AssertionsPrimitivePreparation
  import L = AssertionsConstraintLoopSpec
  import F = AssertionsGatherLoopFrame
  import Q = AssertionsPrimitiveExternalLift
  import W = AssertionsCondFirstWord
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) {
    C.Matches(code) && N.Matches(code) && 1783 < |code| && code[1783] == 0x5b
  }
  function Destinations(ret: Word): set<nat> { C.Destinations(ret)+N.Destinations(ret) }
  ghost method Run(code: seq<Byte>, ret: Word, condition: D.Operand, then_: Word,
                   else_: Word, free: Word, prefix: seq<Word>, mem: seq<Byte>,
                   data: seq<Byte>, returned: seq<Byte>, cursor: nat,
                   self: Word, value: Word, observations: seq<A.Observation>)
    returns (frame: E.Frame, frames: seq<E.Frame>)
    requires Matches(code) && D.Span(data,condition) && D.Heap(mem,free,condition)
    requires |prefix| <= 939
    ensures Q.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(1743,prefix+[ret,condition.pointer,then_,else_],mem),returned,cursor)
    ensures frames[|frames|-1] == frame && frame.returned == returned && frame.cursor == cursor
    ensures condition.length < 32 ==> frame == E.Frame(S.Reverted(W.Error(condition.length)),returned,cursor)
    ensures condition.length >= 32 ==> frame.state.Running? && frame.state.pc == 1783 &&
                                       frame.state.stack == prefix+[ret,condition.pointer,then_,else_,free+32,0,0,H.First(D.Payload(data,condition))]
    ensures condition.length >= 32 ==> L.Heap(frame.state.memory,free+32,D.Payload(data,condition),
                                              L.Free(free+64+S.Round32(condition.length),condition.constraints,|condition.constraints|))
  {
    hide S.DataWord(); hide S.Window();
    D.Prepared(1770,0,0,condition,free,prefix+[ret,condition.pointer,then_,else_,0],mem,data);
    var state, states := C.Run(code,ret,condition.pointer,then_,else_,0,0,0,free,prefix,mem,value,data);
    assert C.Memory2(ret,condition.pointer,then_,else_,0,0,0,free,prefix,mem) == P.EmptyAssertion(mem,free);
    frames := F.Lift(code,C.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    var part: seq<E.Frame>;
    frame,part := N.Run(code,ret,condition.pointer,then_,else_,free,condition.bytesRelative,
                        condition.constraintsRelative,condition.length,free+32,condition.constraints,prefix,
                        P.EmptyAssertion(mem,free),self,value,data,returned,cursor,observations);
    F.Widen(code,N.Destinations(ret),Destinations(ret),self,value,data,observations,part);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part);
    frames := frames+part[1..];
  }
}

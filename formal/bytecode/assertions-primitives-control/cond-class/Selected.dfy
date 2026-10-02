// SPDX-License-Identifier: MIT
// Exact lazy selected RAW operand resolve and physical raw RETURN.
include "RawSpec.dfy"
include "Memory.dfy"
include "FalseReturn.generated.dfy"
include "../gather-composition/Frame.dfy"
module AssertionsCondRawSelected {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import T = AssertionsControlCondTrue
  import B = AssertionsControlCondFalse
  import X = AssertionsCondFalseReturn
  import Z = AssertionsControlRawReturn
  import P = AssertionsPrimitivePreparation
  import D = AssertionsCondRawSpec
  import R = AssertionsRawResolve
  import RR = AssertionsRawResolveConnection
  import M = AssertionsRawResolveMemory
  import Q = AssertionsCondMemory
  import F = AssertionsGatherLoopFrame
  import L = AssertionsPrimitiveExternalLift
  type Word = S.Word
  type Byte = S.Byte
  predicate Matches(code: seq<Byte>) { T.Matches(code) && B.Matches(code) && X.Matches(code) && Z.Matches(code) && R.Matches(code,1017) && R.Matches(code,1815) }
  function Destinations(ret: Word): set<nat> { T.Destinations(ret)+B.Destinations(ret)+X.Destinations(ret)+Z.Destinations(ret)+R.Destinations(1017)+R.Destinations(1815) }
  ghost method Run(code: seq<Byte>, ret: Word, condition: Word, then_: Word, else_: Word, conditionPtr: Word, word: Word, selected: D.Operand, free: Word, prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>, returned: seq<Byte>, cursor: nat, self: Word, value: Word, observations: seq<A.Observation>) returns (frame: E.Frame, frames: seq<E.Frame>)
    requires Matches(code) && D.Span(data,selected) && D.Heap(mem,free,selected) && |prefix| <= 930
    requires selected.pointer == (if word == 0 then else_ else then_)
    ensures L.Trace(code,Destinations(ret),self,value,data,observations,frames)
    ensures frames[0] == E.Frame(S.Running(1783,prefix+[ret,condition,then_,else_,conditionPtr,0,0,word],mem),returned,cursor) && frames[|frames|-1] == frame
    ensures frame == E.Frame(S.Returned(D.Payload(data,selected)),returned,cursor)
  {
    hide S.DataWord(); hide S.Window(); hide G.Decode(); hide M.Construct();
    var branchRet: Word := if word == 0 then 1815 else 1017;
    var index: Word := if word == 0 then 2 else 1;
    var state: S.State;
    var states: seq<S.State>;
    if word == 0 {
      state,states := B.Run(code,ret,condition,then_,else_,conditionPtr,0,word,free,prefix,mem,value,data);
      assert B.Memory2(ret,condition,then_,else_,conditionPtr,0,word,free,prefix,mem) == P.EmptyAssertion(mem,free);
      frames := F.Lift(code,B.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    } else {
      state,states := T.Run(code,ret,condition,then_,else_,conditionPtr,0,word,free,prefix,mem,value,data);
      assert T.Memory2(ret,condition,then_,else_,conditionPtr,0,word,free,prefix,mem) == P.EmptyAssertion(mem,free);
      frames := F.Lift(code,T.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    }
    var part: seq<E.Frame>;
    D.Admitted(branchRet,0,index,selected,free,prefix+[ret,condition,then_,else_,conditionPtr,0],mem,data);
    frame,part := RR.Run(code,Destinations(ret),branchRet,selected.pointer,free,0,index,selected.bytesRelative,selected.constraintsRelative,selected.length,free+32,prefix+[ret,condition,then_,else_,conditionPtr,0],P.EmptyAssertion(mem,free),data,returned,cursor,self,value,observations);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    M.Built(P.EmptyAssertion(mem,free),free+32,D.Offset(selected),selected.length,data);
    var image := M.Construct(P.EmptyAssertion(mem,free),free+32,D.Offset(selected),selected.length,data);
    var finalFree: Word := free+64+S.Round32(selected.length);
    if word == 0 {
      state,states := X.Run(code,ret,condition,then_,else_,conditionPtr,0,free+32,finalFree,prefix,image,value,data);
      part := F.Lift(code,X.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
      F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    }
    state,states := Z.Run(code,ret,0,0,0,free+32,selected.length,0,finalFree,prefix+[ret,condition,then_,else_,conditionPtr],image,value,data);
    part := F.Lift(code,Z.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    Q.Payload(P.EmptyAssertion(mem,free),free+32,D.Offset(selected),selected.length,data);
    frame := E.Frame(state,returned,cursor);
  }
}

// SPDX-License-Identifier: MIT
// Exact lazy selected constrained RAW operand resolve and physical raw RETURN.
include "Spec.dfy"
include "../cond-class/FalseReturn.generated.dfy"
include "../gather-composition/Frame.dfy"
module AssertionsCondConstrainedSelected {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import T = AssertionsControlCondTrue
  import B = AssertionsControlCondFalse
  import X = AssertionsCondFalseReturn
  import Z = AssertionsControlRawReturn
  import P = AssertionsPrimitivePreparation
  import D = AssertionsCondConstrainedSpec
  import R = AssertionsConstrainedRawConnection
  import H = AssertionsConstraintLoopSpec
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
    hide S.DataWord(); hide S.Window(); hide G.Decode();
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
    D.Prepared(branchRet,0,index,selected,free,prefix+[ret,condition,then_,else_,conditionPtr,0],mem,data);
    state,part := R.Run(code,Destinations(ret),branchRet,selected.pointer,free,0,index,
                        selected.bytesRelative,selected.constraintsRelative,selected.length,free+32,selected.constraints,
                        prefix+[ret,condition,then_,else_,conditionPtr,0],P.EmptyAssertion(mem,free),
                        self,value,data,returned,cursor,observations);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    var image := state.memory;
    var bytes := D.Payload(data,selected);
    var finalFree := H.Free(free+64+S.Round32(selected.length),selected.constraints,|selected.constraints|);
    assert H.Heap(image,free+32,bytes,finalFree);
    assert selected.constraints[..|selected.constraints|] == selected.constraints;
    assert finalFree == free+64+S.Round32(selected.length)+H.Cost(selected.constraints);
    assert finalFree+96 < G.Modulus();
    if word == 0 {
      state,states := X.Run(code,ret,condition,then_,else_,conditionPtr,0,free+32,finalFree,prefix,image,value,data);
      part := F.Lift(code,X.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
      F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    }
    state,states := Z.Run(code,ret,0,0,0,free+32,selected.length,0,finalFree,prefix+[ret,condition,then_,else_,conditionPtr],image,value,data);
    part := F.Lift(code,Z.Destinations(ret),Destinations(ret),self,value,data,observations,states,returned,cursor);
    F.Join(code,Destinations(ret),self,value,data,observations,frames,part); frames := frames+part[1..];
    assert G.Grow(image,free+64+selected.length) == image;
    assert image[free+64..free+64+selected.length] == bytes;
    frame := E.Frame(state,returned,cursor);
  }
}

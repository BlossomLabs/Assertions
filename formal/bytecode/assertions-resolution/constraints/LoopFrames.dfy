// SPDX-License-Identifier: MIT
// Compose complete physical validator segments through one common EVM frame.
include "../raw/Frame.dfy"
include "LeafFrame.dfy"
module AssertionsConstraintLoopFrames {
  import S = BytecodeScanMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import Q = AssertionsRawResolveFrame
  import R = AssertionsRawResolveMachine
  import L = AssertionsConstraintLeafFrame
  import X = AssertionsConstraintExecution
  type Word = S.Word
  type Byte = S.Byte
  lemma SameTrace(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word,
                  data: seq<Byte>, observations: seq<M.Observation>, frames: seq<E.Frame>)
    requires L.Trace(code,destinations,self,value,data,observations,frames)
    ensures Q.Trace(code,destinations,self,value,data,observations,frames)
  {}
  lemma Join(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word,
             data: seq<Byte>, observations: seq<M.Observation>, first: seq<E.Frame>, second: seq<E.Frame>)
    requires Q.Trace(code,destinations,self,value,data,observations,first)
    requires Q.Trace(code,destinations,self,value,data,observations,second)
    requires first[|first|-1] == second[0]
    ensures Q.Trace(code,destinations,self,value,data,observations,first+second[1..])
  {
    var joined := first+second[1..];
    forall i {:trigger joined[i]} | 0 <= i < |joined|-1
      ensures M.Step(code,destinations,joined[i],self,value,data,observations) == joined[i+1] && joined[i+1].state != S.Bad
    {
      if i < |first|-1 {
        assert joined[i] == first[i] && joined[i+1] == first[i+1];
      } else {
        var j := i-(|first|-1);
        assert 0 <= j < |second|-1;
        assert joined[i] == second[j] && joined[i+1] == second[j+1];
      }
    }
  }
  lemma LiftRaw(code: seq<Byte>, small: set<nat>, destinations: set<nat>, self: Word, value: Word,
                data: seq<Byte>, observations: seq<M.Observation>, returned: seq<Byte>, cursor: nat, states: seq<S.State>)
    requires small <= destinations && R.Trace(code,small,value,data,states)
    requires forall i {:trigger states[i]} :: 0 <= i < |states| ==> Q.Local(code,states[i])
    ensures Q.Trace(code,destinations,self,value,data,observations,Q.Lift(states,returned,cursor))
  {
    R.WidenTrace(code,small,destinations,value,data,states);
    Q.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,states);
  }
  lemma LiftLeaf(code: seq<Byte>, small: set<nat>, destinations: set<nat>, self: Word, value: Word,
                 data: seq<Byte>, observations: seq<M.Observation>, returned: seq<Byte>, cursor: nat, states: seq<S.State>)
    requires small <= destinations && X.Trace(code,small,value,data,states)
    requires states[0].Running? ==> |states[0].stack| <= 1024
    ensures Q.Trace(code,destinations,self,value,data,observations,L.Lift(states,returned,cursor))
  {
    X.WidenTrace(code,small,destinations,value,data,states);
    L.LiftTrace(code,destinations,returned,cursor,self,value,data,observations,states);
    SameTrace(code,destinations,self,value,data,observations,L.Lift(states,returned,cursor));
  }
}

// SPDX-License-Identifier: MIT
include "../Frame.dfy"
module AssertionsRawPublicExecution {
  import S = BytecodeScanMachine
  import X = AssertionsRawResolveMachine
  import Q = AssertionsRawResolveFrame
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  type Word = S.Word
  type Byte = S.Byte
  lemma Join(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>, first: seq<S.State>, second: seq<S.State>)
    requires X.Trace(code,destinations,value,data,first) && X.Trace(code,destinations,value,data,second)
    requires first[|first|-1] == second[0]
    requires forall i {:trigger first[i]} :: 0 <= i < |first|-1 ==> Q.Local(code,first[i])
    requires forall i {:trigger second[i]} :: 0 <= i < |second|-1 ==> Q.Local(code,second[i])
    ensures X.Trace(code,destinations,value,data,first+second[1..])
    ensures forall i {:trigger (first+second[1..])[i]} :: 0 <= i < |first+second[1..]|-1 ==> Q.Local(code,(first+second[1..])[i])
    ensures (first+second[1..])[0] == first[0]
    ensures (first+second[1..])[|first+second[1..]|-1] == second[|second|-1]
  {
    forall i {:trigger (first+second[1..])[i]} | 0 <= i < |first+second[1..]|-1
      ensures X.Step(code,destinations,(first+second[1..])[i],value,data) == (first+second[1..])[i+1] && (first+second[1..])[i+1] != S.Bad
      ensures Q.Local(code,(first+second[1..])[i])
    {
      if i < |first|-1 {
        assert (first+second[1..])[i] == first[i];
        assert (first+second[1..])[i+1] == first[i+1];
      } else {
        var j := i-(|first|-1);
        assert 0 <= j < |second|-1;
        assert (first+second[1..])[i] == second[j];
        assert (first+second[1..])[i+1] == second[j+1];
      }
    }
  }
  lemma LiftTrace(code: seq<Byte>, destinations: set<nat>, returned: seq<Byte>, cursor: nat,
                  self: Word, value: Word, data: seq<Byte>, observations: seq<M.Observation>, states: seq<S.State>)
    requires X.Trace(code,destinations,value,data,states)
    requires forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==> Q.Local(code,states[i])
    ensures Q.Trace(code,destinations,self,value,data,observations,Q.Lift(states,returned,cursor))
    ensures Q.Lift(states,returned,cursor)[0] == E.Frame(states[0],returned,cursor)
    ensures Q.Lift(states,returned,cursor)[|states|-1] == E.Frame(states[|states|-1],returned,cursor)
  {
    forall i {:trigger Q.Lift(states,returned,cursor)[i]} | 0 <= i < |states|-1
      ensures M.Step(code,destinations,Q.Lift(states,returned,cursor)[i],self,value,data,observations) == Q.Lift(states,returned,cursor)[i+1] && Q.Lift(states,returned,cursor)[i+1].state != S.Bad
    { Q.Step(code,destinations,states[i],returned,cursor,self,value,data,observations); }
  }
}

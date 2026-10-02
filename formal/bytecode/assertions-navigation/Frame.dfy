// SPDX-License-Identifier: MIT
include "../scans/Execution.dfy"
include "../assertions-machine/External.dfy"
module AssertionsNavigationFrame {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import T = BytecodeScanExecution
  import A = AssertionsSignedMachine
  import B = AssertionsByteMachine
  import C = BytecodeCopyMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  type Word = S.Word
  type Byte = S.Byte
  predicate Local(code: seq<Byte>, state: S.State) {
    state.Running? && state.pc < |code| && |state.stack| <= 1024 &&
    code[state.pc] !in {0,0x0b,0x13,0x1a,0x20,0x30,0x31,0x37,0x38,0x3b,0x3d,0x3e,0x5a,0x5e,0xfa}
  }
  lemma Step(code: seq<Byte>, destinations: set<nat>, state: S.State,
             returned: seq<Byte>, cursor: nat, self: Word, value: Word,
             data: seq<Byte>, observations: seq<M.Observation>)
    requires Local(code,state)
    ensures M.Step(code,destinations,E.Frame(state,returned,cursor),self,value,data,observations) ==
            E.Frame(S.Step(code,destinations,state,value,data),returned,cursor)
  {
    M.Delegate(code,destinations,E.Frame(state,returned,cursor),self,value,data,observations);
    E.Delegate(code,destinations,E.Frame(state,returned,cursor),self,value,data,M.Project(observations));
    C.Delegate(code,destinations,state,value,data);
    A.Delegate(code,destinations,state,value,data);
  }
  function Lift(states: seq<S.State>, returned: seq<Byte>, cursor: nat): seq<E.Frame> {
    seq(|states|,i requires 0 <= i < |states| => E.Frame(states[i],returned,cursor))
  }
  predicate Trace(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word,
                  data: seq<Byte>, observations: seq<M.Observation>, frames: seq<E.Frame>) {
    |frames| > 0 && forall i {:trigger frames[i]} :: 0 <= i < |frames|-1 ==>
                                                       M.Step(code,destinations,frames[i],self,value,data,observations) == frames[i+1] && frames[i+1].state != S.Bad
  }
  lemma LiftTrace(code: seq<Byte>, destinations: set<nat>, returned: seq<Byte>, cursor: nat,
                  self: Word, value: Word, data: seq<Byte>, observations: seq<M.Observation>, states: seq<S.State>)
    requires T.Trace(code,destinations,value,data,states)
    requires forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==> Local(code,states[i])
    ensures Trace(code,destinations,self,value,data,observations,Lift(states,returned,cursor))
    ensures Lift(states,returned,cursor)[0] == E.Frame(states[0],returned,cursor)
    ensures Lift(states,returned,cursor)[|states|-1] == E.Frame(states[|states|-1],returned,cursor)
  {
    forall i {:trigger Lift(states,returned,cursor)[i]} | 0 <= i < |states|-1
      ensures M.Step(code,destinations,Lift(states,returned,cursor)[i],self,value,data,observations) == Lift(states,returned,cursor)[i+1] && Lift(states,returned,cursor)[i+1].state != S.Bad
    { Step(code,destinations,states[i],returned,cursor,self,value,data,observations); }
  }
}

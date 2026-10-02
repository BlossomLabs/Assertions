// SPDX-License-Identifier: MIT
// Transport every accepted signed/scalar constraint trace into the full frame model.
include "../Execution.dfy"
include "../../assertions-machine/External.dfy"
module AssertionsConstraintLeafFrame {
  import S = BytecodeScanMachine
  import A = AssertionsSignedMachine
  import B = AssertionsByteMachine
  import C = BytecodeCopyMachine
  import E = BytecodeExternalMachine
  import M = AssertionsExternalMachine
  import X = AssertionsConstraintExecution
  type Word = S.Word
  type Byte = S.Byte
  function Unsupported(): set<nat> { {0x00,0x0b,0x1a,0x20,0x30,0x31,0x37,0x38,0x3b,0x3d,0x3e,0x5a,0x5e,0xfa} }
  lemma RejectUnsupported(code: seq<Byte>, destinations: set<nat>, state: S.State, value: Word, data: seq<Byte>)
    requires state.Running? && state.pc < |code| && code[state.pc] in Unsupported()
    ensures A.Step(code,destinations,state,value,data) == S.Bad
  { reveal A.Step(); reveal S.Step(); }
  lemma Step(code: seq<Byte>, destinations: set<nat>, state: S.State,
             returned: seq<Byte>, cursor: nat, self: Word, value: Word,
             data: seq<Byte>, observations: seq<M.Observation>)
    requires A.Step(code,destinations,state,value,data) != S.Bad
    requires state.Running? ==> |state.stack| <= 1024
    ensures M.Step(code,destinations,E.Frame(state,returned,cursor),self,value,data,observations) ==
            E.Frame(A.Step(code,destinations,state,value,data),returned,cursor)
  {
    if state.Running? {
      if state.pc >= |code| { reveal A.Step(); reveal S.Step(); }
      assert state.pc < |code|;
      if code[state.pc] in Unsupported() { RejectUnsupported(code,destinations,state,value,data); }
      assert code[state.pc] !in Unsupported();
      if code[state.pc] == 0x13 {
        M.ArithmeticStep(code,destinations,E.Frame(state,returned,cursor),self,value,data,observations);
        B.Delegate(code,destinations,state,value,data);
      } else {
        M.Delegate(code,destinations,E.Frame(state,returned,cursor),self,value,data,observations);
        E.Delegate(code,destinations,E.Frame(state,returned,cursor),self,value,data,M.Project(observations));
        C.Delegate(code,destinations,state,value,data);A.Delegate(code,destinations,state,value,data);
      }
    } else {
      reveal M.Step(); reveal E.Step(); reveal B.Step(); reveal A.Step(); reveal C.Step(); reveal S.Step();
    }
  }
  lemma {:isolate_assertions} StackStep(code: seq<Byte>, destinations: set<nat>, state: S.State, value: Word, data: seq<Byte>)
    requires state.Running? ==> |state.stack| <= 1024
    ensures A.Step(code,destinations,state,value,data).Running? ==>
            |A.Step(code,destinations,state,value,data).stack| <= 1024
  { reveal A.Step(); reveal S.Step(); }
  lemma StackAt(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>, states: seq<S.State>, index: nat)
    requires X.Trace(code,destinations,value,data,states) && index < |states|
    requires states[0].Running? ==> |states[0].stack| <= 1024
    ensures states[index].Running? ==> |states[index].stack| <= 1024
    decreases index
  {
    if index > 0 {
      StackAt(code,destinations,value,data,states,index-1);
      StackStep(code,destinations,states[index-1],value,data);
    }
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
    requires X.Trace(code,destinations,value,data,states)
    requires states[0].Running? ==> |states[0].stack| <= 1024
    ensures Trace(code,destinations,self,value,data,observations,Lift(states,returned,cursor))
    ensures Lift(states,returned,cursor)[0] == E.Frame(states[0],returned,cursor)
    ensures Lift(states,returned,cursor)[|states|-1] == E.Frame(states[|states|-1],returned,cursor)
  {
    forall i {:trigger Lift(states,returned,cursor)[i]} | 0 <= i < |states|-1
      ensures M.Step(code,destinations,Lift(states,returned,cursor)[i],self,value,data,observations) == Lift(states,returned,cursor)[i+1] && Lift(states,returned,cursor)[i+1].state != S.Bad
    { StackAt(code,destinations,value,data,states,i); Step(code,destinations,states[i],returned,cursor,self,value,data,observations); }
  }
}

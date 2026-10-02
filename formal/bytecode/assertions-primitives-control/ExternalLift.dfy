// SPDX-License-Identifier: MIT
// Preserve external observation history while composing scan-only helper traces.
include "../copy/Lift.dfy"
include "../external-calls/Execution.dfy"
include "../assertions-machine/External.dfy"
module AssertionsPrimitiveExternalLift {
  import S = BytecodeScanMachine
  import C = BytecodeCopyTraceLift
  import CE = BytecodeCopyExecution
  import E = BytecodeScanExecution
  import M = BytecodeExternalMachine
  import X = BytecodeExternalExecution
  import A = AssertionsExternalMachine
  import B = AssertionsByteMachine
  import I = AssertionsSignedMachine
  type Byte = S.Byte
  type Word = S.Word
  type Frame = M.Frame
  predicate Trace(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<A.Observation>, frames: seq<Frame>) {
    |frames| > 0 && forall i {:trigger frames[i]} :: 0 <= i < |frames|-1 ==> A.Step(code,destinations,frames[i],self,value,data,observations) == frames[i+1] && frames[i+1].state != S.Bad
  }
  function Frames(states: seq<S.State>, returned: seq<Byte>, cursor: nat): seq<Frame> {
    seq(|states|,i requires 0 <= i < |states| => M.Frame(states[i],returned,cursor))
  }
  lemma Ordinary(code: seq<Byte>, destinations: set<nat>, state: S.State, value: Word, data: seq<Byte>)
    requires state.Running? && state.pc < |code| && |state.stack| <= 1024
    requires S.Step(code,destinations,state,value,data) != S.Bad
    ensures code[state.pc] !in B.Opcodes()+I.Opcodes()+M.Opcodes()+{0,0x31,0x20,0x38}
  {
    reveal S.Step();
  }
  lemma Step(code: seq<Byte>, destinations: set<nat>, state: S.State, self: Word, value: Word, data: seq<Byte>, observations: seq<A.Observation>, returned: seq<Byte>, cursor: nat)
    requires state.Running? && state.pc < |code| && |state.stack| <= 1024
    requires S.Step(code,destinations,state,value,data) != S.Bad
    ensures A.Step(code,destinations,M.Frame(state,returned,cursor),self,value,data,observations) == M.Frame(S.Step(code,destinations,state,value,data),returned,cursor)
  {
    Ordinary(code,destinations,state,value,data);
    A.Delegate(code,destinations,M.Frame(state,returned,cursor),self,value,data,observations);
    C.Step(code,destinations,state,value,data);
    M.Delegate(code,destinations,M.Frame(state,returned,cursor),self,value,data,A.Project(observations));
  }
  lemma Lift(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<A.Observation>, states: seq<S.State>, returned: seq<Byte>, cursor: nat)
    requires E.Trace(code,destinations,value,data,states)
    requires forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==> states[i].Running? && states[i].pc < |code| && |states[i].stack| <= 1024
    ensures Trace(code,destinations,self,value,data,observations,Frames(states,returned,cursor))
    ensures Frames(states,returned,cursor)[0] == M.Frame(states[0],returned,cursor)
    ensures Frames(states,returned,cursor)[|states|-1] == M.Frame(states[|states|-1],returned,cursor)
    ensures forall f <- Frames(states,returned,cursor) :: f.returned == returned && f.cursor == cursor
  {
    forall i {:trigger Frames(states,returned,cursor)[i]} | 0 <= i < |states|-1
      ensures A.Step(code,destinations,Frames(states,returned,cursor)[i],self,value,data,observations) == Frames(states,returned,cursor)[i+1] && Frames(states,returned,cursor)[i+1].state != S.Bad
    {
      assert S.Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != S.Bad;
      Step(code,destinations,states[i],self,value,data,observations,returned,cursor);
    }
  }
}

// SPDX-License-Identifier: MIT
// Additive ADDRESS/CALLER profile; accepted legacy machine definitions remain unchanged.
include "../../bytecode/scans/Execution.dfy"
module SharedFoundationEnvironmentStepV4 {
  import opened BytecodeScanMachine
  import E = BytecodeScanExecution
  predicate Accounts(self: Word,caller: Word) { self < 0x10000000000000000000000000000000000000000 && caller < 0x10000000000000000000000000000000000000000 }
  opaque function StepWithEnvironment(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>,self: Word,caller: Word): State {
    if !state.Running? || state.pc >= |code| then Step(code,destinations,state,value,data)
    else
      var ins := Fetch(code,state.pc);
      if ins.op == 0x30 || ins.op == 0x33 then
        if |state.stack| < 1024 then Running(ins.next,state.stack+[if ins.op == 0x30 then self else caller],state.memory) else Bad
      else Step(code,destinations,state,value,data)
  }
  predicate Legacy(code: seq<Byte>,state: State) {
    !state.Running? || state.pc >= |code| || (Fetch(code,state.pc).op != 0x30 && Fetch(code,state.pc).op != 0x33)
  }
  lemma LegacyStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>,self: Word,caller: Word)
    requires Legacy(code,state)
    ensures StepWithEnvironment(code,destinations,state,value,data,self,caller) == Step(code,destinations,state,value,data)
  { reveal StepWithEnvironment(); }
  lemma Address(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>,self: Word,caller: Word)
    requires state.Running? && state.pc < |code| && code[state.pc] == 0x30 && |state.stack| < 1024
    ensures StepWithEnvironment(code,destinations,state,value,data,self,caller) == Running(state.pc+1,state.stack+[self],state.memory)
  { reveal StepWithEnvironment(); }
  lemma Caller(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>,self: Word,caller: Word)
    requires state.Running? && state.pc < |code| && code[state.pc] == 0x33 && |state.stack| < 1024
    ensures StepWithEnvironment(code,destinations,state,value,data,self,caller) == Running(state.pc+1,state.stack+[caller],state.memory)
  { reveal StepWithEnvironment(); }
  lemma FullStack(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>,self: Word,caller: Word)
    requires state.Running? && state.pc < |code| && (code[state.pc] == 0x30 || code[state.pc] == 0x33) && |state.stack| >= 1024
    ensures StepWithEnvironment(code,destinations,state,value,data,self,caller) == Bad
  { reveal StepWithEnvironment(); }
  predicate Trace(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,self: Word,caller: Word,states: seq<State>) {
    |states| > 0 && forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==>
                                                       StepWithEnvironment(code,destinations,states[i],value,data,self,caller) == states[i+1] && states[i+1] != Bad
  }
  lemma LiftLegacy(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,self: Word,caller: Word,states: seq<State>)
    requires E.Trace(code,destinations,value,data,states)
    requires forall i :: 0 <= i < |states|-1 ==> Legacy(code,states[i])
    ensures Trace(code,destinations,value,data,self,caller,states)
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures StepWithEnvironment(code,destinations,states[i],value,data,self,caller) == states[i+1] && states[i+1] != Bad
    { LegacyStep(code,destinations,states[i],value,data,self,caller); }
  }
  lemma Extend(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,self: Word,caller: Word,states: seq<State>,next: State)
    requires Trace(code,destinations,value,data,self,caller,states)
    requires next == StepWithEnvironment(code,destinations,states[|states|-1],value,data,self,caller) && next != Bad
    ensures Trace(code,destinations,value,data,self,caller,states+[next])
  {
    forall i {:trigger (states+[next])[i]} | 0 <= i < |states|
      ensures StepWithEnvironment(code,destinations,(states+[next])[i],value,data,self,caller) == (states+[next])[i+1] && (states+[next])[i+1] != Bad
    {
      if i < |states|-1 { assert (states+[next])[i] == states[i]; assert (states+[next])[i+1] == states[i+1]; }
    }
  }
  lemma Join(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,self: Word,caller: Word,left: seq<State>,right: seq<State>)
    requires Trace(code,destinations,value,data,self,caller,left) && Trace(code,destinations,value,data,self,caller,right)
    requires left[|left|-1] == right[0]
    ensures Trace(code,destinations,value,data,self,caller,left+right[1..])
    ensures (left+right[1..])[0] == left[0] && (left+right[1..])[|left+right[1..]|-1] == right[|right|-1]
  {
    forall i {:trigger (left+right[1..])[i]} | 0 <= i < |left+right[1..]|-1
      ensures StepWithEnvironment(code,destinations,(left+right[1..])[i],value,data,self,caller) == (left+right[1..])[i+1] && (left+right[1..])[i+1] != Bad
    {
      if i < |left|-1 { assert (left+right[1..])[i] == left[i]; assert (left+right[1..])[i+1] == left[i+1]; }
      else { var j := i-(|left|-1); assert (left+right[1..])[i] == right[j]; assert (left+right[1..])[i+1] == right[j+1]; }
    }
  }
}

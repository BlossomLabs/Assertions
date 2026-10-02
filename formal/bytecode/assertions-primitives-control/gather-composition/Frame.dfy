// SPDX-License-Identifier: MIT
include "../ExternalLift.dfy"
module AssertionsGatherLoopFrame {
  import S = BytecodeScanMachine
  import E = BytecodeScanExecution
  import M = BytecodeExternalMachine
  import A = AssertionsExternalMachine
  import L = AssertionsPrimitiveExternalLift
  import B = AssertionsByteMachine
  import I = AssertionsSignedMachine
  import X = BytecodeExternalExecution
  type Byte = S.Byte
  type Word = S.Word
  lemma Join(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<A.Observation>, left: seq<M.Frame>, right: seq<M.Frame>)
    requires L.Trace(code,destinations,self,value,data,observations,left) && L.Trace(code,destinations,self,value,data,observations,right)
    requires left[|left|-1] == right[0]
    ensures L.Trace(code,destinations,self,value,data,observations,left+right[1..])
    ensures (left+right[1..])[0] == left[0] && (left+right[1..])[|left+right[1..]|-1] == right[|right|-1]
  {
    forall i {:trigger (left+right[1..])[i]} | 0 <= i < |left+right[1..]|-1
      ensures A.Step(code,destinations,(left+right[1..])[i],self,value,data,observations) == (left+right[1..])[i+1] && (left+right[1..])[i+1].state != S.Bad
    {
      if i < |left|-1 { assert (left+right[1..])[i] == left[i]; assert (left+right[1..])[i+1] == left[i+1]; }
      else { var j := i-(|left|-1); assert 0 <= j < |right|-1; assert (left+right[1..])[i] == right[j]; assert (left+right[1..])[i+1] == right[j+1]; }
    }
  }
  ghost method Lift(code: seq<Byte>, small: set<nat>, destinations: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<A.Observation>, states: seq<S.State>, returned: seq<Byte>, cursor: nat) returns (frames: seq<M.Frame>)
    requires small <= destinations && E.Trace(code,small,value,data,states)
    requires forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==> states[i].Running? && states[i].pc < |code| && |states[i].stack| <= 1024
    ensures L.Trace(code,destinations,self,value,data,observations,frames)
    ensures frames[0] == M.Frame(states[0],returned,cursor) && frames[|frames|-1] == M.Frame(states[|states|-1],returned,cursor)
  {
    E.WidenTrace(code,small,destinations,value,data,states);
    L.Lift(code,destinations,self,value,data,observations,states,returned,cursor);
    frames := L.Frames(states,returned,cursor);
  }
  lemma WidenStep(code: seq<Byte>, small: set<nat>, large: set<nat>, frame: M.Frame, self: Word, value: Word, data: seq<Byte>, observations: seq<A.Observation>)
    requires small <= large && A.Step(code,small,frame,self,value,data,observations).state != S.Bad
    ensures A.Step(code,small,frame,self,value,data,observations) == A.Step(code,large,frame,self,value,data,observations)
  {
    reveal A.Step();
    if frame.state.Running? && frame.state.pc < |code| && |frame.state.stack| <= 1024 {
      var op := code[frame.state.pc];
      if op in B.Opcodes()+I.Opcodes() { reveal B.Step(); reveal I.Step(); }
      else if op !in {0,0x31,0x20,0x38} {
        X.WidenStep(code,small,large,frame,self,value,data,A.Project(observations));
      }
    }
  }
  lemma Widen(code: seq<Byte>, small: set<nat>, large: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<A.Observation>, frames: seq<M.Frame>)
    requires small <= large && L.Trace(code,small,self,value,data,observations,frames)
    ensures L.Trace(code,large,self,value,data,observations,frames)
  {
    forall i {:trigger frames[i]} | 0 <= i < |frames|-1
      ensures A.Step(code,large,frames[i],self,value,data,observations) == frames[i+1] && frames[i+1].state != S.Bad
    {
      WidenStep(code,small,large,frames[i],self,value,data,observations);
    }
  }
}


// SPDX-License-Identifier: MIT
// Arbitrary finite history-indexed traces; no fixture or fuel bound.
include "Machine.dfy"
include "../copy/Execution.dfy"
module BytecodeExternalExecution {
  import M = BytecodeExternalMachine
  import C = BytecodeCopyExecution
  import CM = BytecodeCopyMachine
  import S = BytecodeScanMachine
  type Byte = M.Byte
  type Word = M.Word
  type Frame = M.Frame
  type Observation = M.Observation
  predicate Trace(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>, frames: seq<Frame>) {
    |frames| > 0 && forall i {:trigger frames[i]} :: 0 <= i < |frames|-1 ==> M.Step(code,destinations,frames[i],self,value,data,observations) == frames[i+1] && frames[i+1].state != S.Bad
  }
  lemma Extend(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>, frames: seq<Frame>, next: Frame)
    requires Trace(code,destinations,self,value,data,observations,frames)
    requires next == M.Step(code,destinations,frames[|frames|-1],self,value,data,observations) && next.state != S.Bad
    ensures Trace(code,destinations,self,value,data,observations,frames+[next])
  {
    forall i {:trigger (frames+[next])[i]} | 0 <= i < |frames|
      ensures M.Step(code,destinations,(frames+[next])[i],self,value,data,observations) == (frames+[next])[i+1] && (frames+[next])[i+1].state != S.Bad
    {
      if i < |frames|-1 {
        assert (frames+[next])[i] == frames[i];
        assert (frames+[next])[i+1] == frames[i+1];
      }
    }
  }
  lemma Join(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>, left: seq<Frame>, right: seq<Frame>)
    requires Trace(code,destinations,self,value,data,observations,left) && Trace(code,destinations,self,value,data,observations,right)
    requires left[|left|-1] == right[0]
    ensures Trace(code,destinations,self,value,data,observations,left+right[1..])
    ensures (left+right[1..])[0] == left[0] && (left+right[1..])[|left+right[1..]|-1] == right[|right|-1]
  {
    forall i {:trigger (left+right[1..])[i]} | 0 <= i < |left+right[1..]|-1
      ensures M.Step(code,destinations,(left+right[1..])[i],self,value,data,observations) == (left+right[1..])[i+1] && (left+right[1..])[i+1].state != S.Bad
    {
      if i < |left|-1 {
        assert (left+right[1..])[i] == left[i];
        assert (left+right[1..])[i+1] == left[i+1];
      } else {
        var j := i-(|left|-1);
        assert 0 <= j < |right|-1;
        assert (left+right[1..])[i] == right[j];
        assert (left+right[1..])[i+1] == right[j+1];
      }
    }
  }
  lemma WidenStep(code: seq<Byte>, small: set<nat>, large: set<nat>, frame: Frame, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>)
    requires small <= large && M.Step(code,small,frame,self,value,data,observations).state != S.Bad
    ensures M.Step(code,small,frame,self,value,data,observations) == M.Step(code,large,frame,self,value,data,observations)
  {
    reveal M.Step();
    if !frame.state.Running? || frame.state.pc >= |code| || S.Fetch(code,frame.state.pc).op !in M.Opcodes() {
      C.WidenStep(code,small,large,frame.state,value,data);
    }
  }
  lemma WidenTrace(code: seq<Byte>, small: set<nat>, large: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>, frames: seq<Frame>)
    requires small <= large && Trace(code,small,self,value,data,observations,frames)
    ensures Trace(code,large,self,value,data,observations,frames)
  {
    forall i {:trigger frames[i]} | 0 <= i < |frames|-1
      ensures M.Step(code,large,frames[i],self,value,data,observations) == frames[i+1] && frames[i+1].state != S.Bad
    { WidenStep(code,small,large,frames[i],self,value,data,observations); }
  }
  lemma Lift(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>, states: seq<S.State>, returned: seq<Byte>, cursor: nat)
    requires C.Trace(code,destinations,value,data,states)
    ensures Trace(code,destinations,self,value,data,observations,seq(|states|,i requires 0 <= i < |states| => M.Frame(states[i],returned,cursor)))
  {
    var frames := seq(|states|,i requires 0 <= i < |states| => M.Frame(states[i],returned,cursor));
    forall i {:trigger frames[i]} | 0 <= i < |states|-1
      ensures M.Step(code,destinations,frames[i],self,value,data,observations) == frames[i+1] && frames[i+1].state != S.Bad
    {
      NoExternal(code,destinations,states[i],value,data);
      M.Delegate(code,destinations,frames[i],self,value,data,observations);
    }
  }
  lemma NoExternal(code: seq<Byte>, destinations: set<nat>, state: S.State, value: Word, data: seq<Byte>)
    requires CM.Step(code,destinations,state,value,data) != S.Bad
    ensures !state.Running? || state.pc >= |code| || S.Fetch(code,state.pc).op !in M.Opcodes()
  { reveal CM.Step(); reveal S.Step(); }
}

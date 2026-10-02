// SPDX-License-Identifier: MIT
// Arbitrary finite history-indexed traces; no fixture or fuel bound.
include "Machine.dfy"
include "../../external-calls/Execution.dfy"
module OperationsCaseFoldExecution {
  import M = BytecodeExternalMachine
  import Base = BytecodeExternalExecution
  import F = OperationsCaseFoldMachine
  import S = BytecodeScanMachine
  type Byte = M.Byte
  type Word = M.Word
  type Frame = M.Frame
  type Observation = M.Observation
  predicate Trace(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>, frames: seq<Frame>) {
    |frames| > 0 && forall i {:trigger frames[i]} :: 0 <= i < |frames|-1 ==> F.Step(code,destinations,frames[i],self,value,data,observations) == frames[i+1] && frames[i+1].state != S.Bad
  }
  lemma Extend(code: seq<Byte>, destinations: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>, frames: seq<Frame>, next: Frame)
    requires Trace(code,destinations,self,value,data,observations,frames)
    requires next == F.Step(code,destinations,frames[|frames|-1],self,value,data,observations) && next.state != S.Bad
    ensures Trace(code,destinations,self,value,data,observations,frames+[next])
  {
    forall i {:trigger (frames+[next])[i]} | 0 <= i < |frames|
      ensures F.Step(code,destinations,(frames+[next])[i],self,value,data,observations) == (frames+[next])[i+1] && (frames+[next])[i+1].state != S.Bad
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
      ensures F.Step(code,destinations,(left+right[1..])[i],self,value,data,observations) == (left+right[1..])[i+1] && (left+right[1..])[i+1].state != S.Bad
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
    requires small <= large && F.Step(code,small,frame,self,value,data,observations).state != S.Bad
    ensures F.Step(code,small,frame,self,value,data,observations) == F.Step(code,large,frame,self,value,data,observations)
  {
    reveal F.Step();
    if !frame.state.Running? || frame.state.pc>=|code| || S.Fetch(code,frame.state.pc).op !in {0x18,0x1a,0x53} {
      Base.WidenStep(code,small,large,frame,self,value,data,observations);
    }
  }
  lemma WidenTrace(code: seq<Byte>, small: set<nat>, large: set<nat>, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>, frames: seq<Frame>)
    requires small <= large && Trace(code,small,self,value,data,observations,frames)
    ensures Trace(code,large,self,value,data,observations,frames)
  {
    forall i {:trigger frames[i]} | 0 <= i < |frames|-1
      ensures F.Step(code,large,frames[i],self,value,data,observations) == frames[i+1] && frames[i+1].state != S.Bad
    { WidenStep(code,small,large,frames[i],self,value,data,observations); }
  }
}

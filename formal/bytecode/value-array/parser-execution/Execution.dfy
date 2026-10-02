// SPDX-License-Identifier: MIT
// Exact trace lifting and destination union for the scanner/copy/BYTE machines.
include "../byte-machine/Execution.dfy"
include "../../scans/Execution.dfy"
module BytecodeCollectionsParserExecution {
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import C = BytecodeCopyMachine
  import B = BytecodeCollectionsArrayByteMachine
  import SE = BytecodeScanExecution
  import CE = BytecodeCopyExecution
  import E = BytecodeCollectionsArrayByteExecution
  lemma ScanCannotCopy(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>)
    requires state.Running? && state.pc < |code| && Fetch(code,state.pc).op in {0x37,0x5e}
    ensures S.Step(code,destinations,state,value,data) == Bad
  { reveal S.Step(); }
  lemma LiftScan(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,states: seq<State>)
    requires SE.Trace(code,destinations,value,data,states)
    ensures E.Trace(code,destinations,value,data,states)
  {
    assert |states| > 0 by { reveal SE.Trace(); }
    hide SE.Trace();
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures C.Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != Bad
    {
      reveal SE.Trace();
      assert S.Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != Bad;
      if states[i].Running? && states[i].pc < |code| && Fetch(code,states[i].pc).op in {0x37,0x5e} {
        ScanCannotCopy(code,destinations,states[i],value,data);
      }
      C.Delegate(code,destinations,states[i],value,data);
    }
    assert CE.Trace(code,destinations,value,data,states);
    E.LiftCopy(code,destinations,value,data,states);
  }
  lemma WidenScan(code: seq<Byte>,small: set<nat>,large: set<nat>,state: State,value: Word,data: seq<Byte>)
    requires small <= large && S.Step(code,small,state,value,data) != Bad
    ensures S.Step(code,large,state,value,data) == S.Step(code,small,state,value,data)
  { reveal S.Step(); }
  lemma WidenCopy(code: seq<Byte>,small: set<nat>,large: set<nat>,state: State,value: Word,data: seq<Byte>)
    requires small <= large && C.Step(code,small,state,value,data) != Bad
    ensures C.Step(code,large,state,value,data) == C.Step(code,small,state,value,data)
  {
    if state.Running? && state.pc < |code| && Fetch(code,state.pc).op in {0x37,0x5e} { reveal C.Step(); }
    else {
      C.Delegate(code,small,state,value,data);C.Delegate(code,large,state,value,data);
      WidenScan(code,small,large,state,value,data);
    }
  }
  lemma WidenByte(code: seq<Byte>,small: set<nat>,large: set<nat>,state: State,value: Word,data: seq<Byte>)
    requires small <= large && B.Step(code,small,state,value,data) != Bad
    ensures B.Step(code,large,state,value,data) == B.Step(code,small,state,value,data)
  {
    if state.Running? && state.pc < |code| && Fetch(code,state.pc).op == 0x1a { reveal B.Step(); }
    else {
      B.Delegate(code,small,state,value,data);B.Delegate(code,large,state,value,data);
      WidenCopy(code,small,large,state,value,data);
    }
  }
  lemma WidenTrace(code: seq<Byte>,small: set<nat>,large: set<nat>,value: Word,data: seq<Byte>,states: seq<State>)
    requires small <= large && E.Trace(code,small,value,data,states)
    ensures E.Trace(code,large,value,data,states)
  {
    assert |states| > 0 by { reveal E.Trace(); }
    hide E.Trace();
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures B.Step(code,large,states[i],value,data) == states[i+1] && states[i+1] != Bad
    {
      reveal E.Trace();
      assert B.Step(code,small,states[i],value,data) == states[i+1] && states[i+1] != Bad;
      WidenByte(code,small,large,states[i],value,data);
    }
    reveal E.Trace();
    assert E.Trace(code,large,value,data,states);
  }
  lemma Join(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,left: seq<State>,right: seq<State>)
    requires E.Trace(code,destinations,value,data,left) && E.Trace(code,destinations,value,data,right) && left[|left|-1] == right[0]
    ensures E.Trace(code,destinations,value,data,left+right[1..])
  {
    forall i {:trigger (left+right[1..])[i]} | 0 <= i < |left+right[1..]|-1
      ensures B.Step(code,destinations,(left+right[1..])[i],value,data) == (left+right[1..])[i+1] && (left+right[1..])[i+1] != Bad
    {
      if i < |left|-1 { assert (left+right[1..])[i] == left[i] && (left+right[1..])[i+1] == left[i+1]; }
      else { var j := i-(|left|-1);assert 0 <= j < |right|-1;assert (left+right[1..])[i] == right[j] && (left+right[1..])[i+1] == right[j+1]; }
    }
  }
}

// SPDX-License-Identifier: MIT
// Finite actual-step traces compose without a fuel or iteration cut-off.
include "Machine.dfy"
include "../scans/Execution.dfy"
module BytecodeCopyExecution {
  import opened BytecodeScanMachine
  import M = BytecodeCopyMachine
  import S = BytecodeScanMachine
  import E = BytecodeScanExecution
  predicate Trace(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>, states: seq<State>) {
    |states| > 0 && forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==>
                                                       M.Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != Bad
  }
  lemma Extend(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>, states: seq<State>, next: State)
    requires Trace(code,destinations,value,data,states)
    requires next == M.Step(code,destinations,states[|states|-1],value,data) && next != Bad
    ensures Trace(code,destinations,value,data,states+[next])
  {
    forall i {:trigger (states+[next])[i]} | 0 <= i < |states|
      ensures M.Step(code,destinations,(states+[next])[i],value,data) == (states+[next])[i+1] && (states+[next])[i+1] != Bad
    {
      if i < |states|-1 {
        assert (states+[next])[i] == states[i];
        assert (states+[next])[i+1] == states[i+1];
      }
    }
  }
  lemma WidenStep(code: seq<Byte>, small: set<nat>, large: set<nat>, state: State, value: Word, data: seq<Byte>)
    requires small <= large && M.Step(code,small,state,value,data) != Bad
    ensures M.Step(code,small,state,value,data) == M.Step(code,large,state,value,data)
  {
    reveal M.Step();
    if !state.Running? || state.pc >= |code| || S.Fetch(code,state.pc).op !in {0x37,0x5e} {
      E.WidenStep(code,small,large,state,value,data);
    }
  }
  lemma WidenTrace(code: seq<Byte>, small: set<nat>, large: set<nat>, value: Word, data: seq<Byte>, states: seq<State>)
    requires small <= large && Trace(code,small,value,data,states)
    ensures Trace(code,large,value,data,states)
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures M.Step(code,large,states[i],value,data) == states[i+1] && states[i+1] != Bad
    {
      assert M.Step(code,small,states[i],value,data) == states[i+1];
      assert states[i+1] != Bad;
      WidenStep(code,small,large,states[i],value,data);
    }
  }
  lemma Join(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>, left: seq<State>, right: seq<State>)
    requires Trace(code,destinations,value,data,left) && Trace(code,destinations,value,data,right)
    requires left[|left|-1] == right[0]
    ensures Trace(code,destinations,value,data,left+right[1..])
    ensures (left+right[1..])[0] == left[0]
    ensures (left+right[1..])[|left+right[1..]|-1] == right[|right|-1]
  {
    forall i {:trigger (left+right[1..])[i]} | 0 <= i < |left+right[1..]|-1
      ensures M.Step(code,destinations,(left+right[1..])[i],value,data) == (left+right[1..])[i+1] && (left+right[1..])[i+1] != Bad
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
  lemma Lift(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>, states: seq<State>)
    requires E.Trace(code,destinations,value,data,states)
    requires forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==> !states[i].Running? || states[i].pc >= |code| || S.Fetch(code,states[i].pc).op !in {0x37,0x5e}
    ensures Trace(code,destinations,value,data,states)
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures M.Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != Bad
    { M.Delegate(code,destinations,states[i],value,data); }
  }
}

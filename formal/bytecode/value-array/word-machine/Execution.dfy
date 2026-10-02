// SPDX-License-Identifier: MIT
include "Machine.dfy"
module BytecodeCollectionsArrayWordExecution {
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import C = BytecodeCopyMachine
  import B = BytecodeCollectionsArrayByteMachine
  import E = BytecodeCollectionsArrayByteExecution
  import M = BytecodeCollectionsArrayWordMachine
  predicate Trace(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,states: seq<State>) {
    |states| > 0 && forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==>
                                                       M.Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != Bad
  }
  lemma Extend(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,states: seq<State>,next: State)
    requires Trace(code,destinations,value,data,states)
    requires next != Bad && M.Step(code,destinations,states[|states|-1],value,data) == next
    ensures Trace(code,destinations,value,data,states+[next])
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures M.Step(code,destinations,(states+[next])[i],value,data) == (states+[next])[i+1] && (states+[next])[i+1] != Bad
    { assert (states+[next])[i] == states[i] && (states+[next])[i+1] == states[i+1]; }
  }
  lemma LiftByte(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,states: seq<State>)
    requires E.Trace(code,destinations,value,data,states)
    ensures Trace(code,destinations,value,data,states)
  {
    assert |states| > 0 by { reveal E.Trace(); }
    hide E.Trace();
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures M.Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != Bad
    {
      reveal E.Trace();
      assert B.Step(code,destinations,states[i],value,data) == states[i+1];
      assert states[i+1] != Bad;
      if states[i].Running? && states[i].pc < |code| && Fetch(code,states[i].pc).op == 0x0b {
        reveal B.Step();reveal C.Step();reveal S.Step();
        assert B.Step(code,destinations,states[i],value,data) == Bad;
      }
      M.Delegate(code,destinations,states[i],value,data);
    }
  }
  lemma Join(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,left: seq<State>,right: seq<State>)
    requires Trace(code,destinations,value,data,left) && Trace(code,destinations,value,data,right)
    requires left[|left|-1] == right[0]
    ensures Trace(code,destinations,value,data,left+right[1..])
  {
    forall i {:trigger left[i]} | 0 <= i < |left|-1
      ensures M.Step(code,destinations,(left+right[1..])[i],value,data) == (left+right[1..])[i+1] && (left+right[1..])[i+1] != Bad
    { assert (left+right[1..])[i] == left[i] && (left+right[1..])[i+1] == left[i+1]; }
    forall j {:trigger right[j]} | 0 <= j < |right|-1
      ensures M.Step(code,destinations,(left+right[1..])[|left|-1+j],value,data) == (left+right[1..])[|left|+j] && (left+right[1..])[|left|+j] != Bad
    {
      if j == 0 { assert (left+right[1..])[|left|-1] == right[0]; }
      else { assert (left+right[1..])[|left|-1+j] == right[j]; }
      assert (left+right[1..])[|left|+j] == right[j+1];
    }
  }
}

// SPDX-License-Identifier: MIT
include "Machine.dfy"
module BytecodeCollectionsArrayByteExecution {
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import C = BytecodeCopyMachine
  import E = BytecodeCopyExecution
  import B = BytecodeCollectionsArrayByteMachine
  predicate Trace(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,states: seq<State>) {
    |states| > 0 && forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==>
                                                       B.Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != Bad
  }
  lemma Extend(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,states: seq<State>,next: State)
    requires Trace(code,destinations,value,data,states)
    requires next != Bad && B.Step(code,destinations,states[|states|-1],value,data) == next
    ensures Trace(code,destinations,value,data,states+[next])
  { forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures B.Step(code,destinations,(states+[next])[i],value,data) == (states+[next])[i+1] && (states+[next])[i+1] != Bad
    { assert (states+[next])[i] == states[i] && (states+[next])[i+1] == states[i+1]; } }
  lemma LiftCopy(code: seq<Byte>,destinations: set<nat>,value: Word,data: seq<Byte>,states: seq<State>)
    requires E.Trace(code,destinations,value,data,states)
    ensures Trace(code,destinations,value,data,states)
  {
    assert |states| > 0 by { reveal E.Trace(); }
    hide E.Trace();
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures B.Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != Bad
    {
      reveal E.Trace();
      assert C.Step(code,destinations,states[i],value,data) == states[i+1];
      assert states[i+1] != Bad;
      if states[i].Running? && states[i].pc < |code| && Fetch(code,states[i].pc).op == 0x1a {
        reveal C.Step();reveal S.Step();
        assert C.Step(code,destinations,states[i],value,data) == Bad;
      }
      B.Delegate(code,destinations,states[i],value,data);
    }
  }
}

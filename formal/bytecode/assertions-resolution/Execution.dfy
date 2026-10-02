// SPDX-License-Identifier: MIT
include "../assertions-machine/Signed.dfy"
module AssertionsConstraintExecution {
  import S = BytecodeScanMachine
  import M = AssertionsSignedMachine
  type Word = S.Word
  type Byte = S.Byte
  predicate Trace(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>, states: seq<S.State>) {
    |states| > 0 && forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==>
                                                       M.Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != S.Bad
  }
  lemma Extend(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>, states: seq<S.State>, next: S.State)
    requires Trace(code,destinations,value,data,states)
    requires next == M.Step(code,destinations,states[|states|-1],value,data) && next != S.Bad
    ensures Trace(code,destinations,value,data,states+[next])
    ensures (states+[next])[0] == states[0] && (states+[next])[|states+[next]|-1] == next
  {
    forall i {:trigger (states+[next])[i]} | 0 <= i < |states|
      ensures M.Step(code,destinations,(states+[next])[i],value,data) == (states+[next])[i+1] && (states+[next])[i+1] != S.Bad
    {
      if i < |states|-1 {
        assert (states+[next])[i] == states[i];
        assert (states+[next])[i+1] == states[i+1];
      }
    }
  }
  lemma WidenStep(code: seq<Byte>, small: set<nat>, large: set<nat>, state: S.State, value: Word, data: seq<Byte>)
    requires small <= large && M.Step(code,small,state,value,data) != S.Bad
    ensures M.Step(code,small,state,value,data) == M.Step(code,large,state,value,data)
  { reveal M.Step(); reveal S.Step(); }
  lemma WidenTrace(code: seq<Byte>, small: set<nat>, large: set<nat>, value: Word, data: seq<Byte>, states: seq<S.State>)
    requires small <= large && Trace(code,small,value,data,states)
    ensures Trace(code,large,value,data,states)
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures M.Step(code,large,states[i],value,data) == states[i+1] && states[i+1] != S.Bad
    { WidenStep(code,small,large,states[i],value,data); }
  }
}

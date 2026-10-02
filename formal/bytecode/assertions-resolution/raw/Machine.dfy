// SPDX-License-Identifier: MIT
// Local resolver subset: exact calldata copies and signed comparisons delegate
// the reviewed models, without external-world observations on this raw path.
include "../../assertions-machine/Signed.dfy"
include "../../copy/Machine.dfy"
module AssertionsRawResolveMachine {
  import S = BytecodeScanMachine
  import A = AssertionsSignedMachine
  import C = BytecodeCopyMachine
  type Word = S.Word
  type Byte = S.Byte
  opaque function Step(code: seq<Byte>, destinations: set<nat>, state: S.State,
                       value: Word, data: seq<Byte>): S.State {
    if state.Running? && state.pc < |code| && code[state.pc] in {0x37,0x5e}
    then C.Step(code,destinations,state,value,data)
    else A.Step(code,destinations,state,value,data)
  }
  predicate Trace(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>, states: seq<S.State>) {
    |states| > 0 && forall i {:trigger states[i]} :: 0 <= i < |states|-1 ==>
                                                       Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != S.Bad
  }
  lemma Extend(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>, states: seq<S.State>, next: S.State)
    requires Trace(code,destinations,value,data,states)
    requires next == Step(code,destinations,states[|states|-1],value,data) && next != S.Bad
    ensures Trace(code,destinations,value,data,states+[next])
    ensures (states+[next])[0] == states[0] && (states+[next])[|states+[next]|-1] == next
  {
    forall i {:trigger (states+[next])[i]} | 0 <= i < |states|
      ensures Step(code,destinations,(states+[next])[i],value,data) == (states+[next])[i+1] && (states+[next])[i+1] != S.Bad
    {
      if i < |states|-1 {
        assert (states+[next])[i] == states[i];
        assert (states+[next])[i+1] == states[i+1];
      }
    }
  }
  lemma WidenStep(code: seq<Byte>, small: set<nat>, large: set<nat>, state: S.State, value: Word, data: seq<Byte>)
    requires small <= large && Step(code,small,state,value,data) != S.Bad
    ensures Step(code,small,state,value,data) == Step(code,large,state,value,data)
  { reveal Step(); reveal C.Step(); reveal A.Step(); reveal S.Step(); }
  lemma WidenTrace(code: seq<Byte>, small: set<nat>, large: set<nat>, value: Word, data: seq<Byte>, states: seq<S.State>)
    requires small <= large && Trace(code,small,value,data,states)
    ensures Trace(code,large,value,data,states)
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures Step(code,large,states[i],value,data) == states[i+1] && states[i+1] != S.Bad
    { WidenStep(code,small,large,states[i],value,data); }
  }
}

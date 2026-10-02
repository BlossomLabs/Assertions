// SPDX-License-Identifier: MIT
// Every successful trace of the smaller reached subset is a copy-aware trace.
include "Execution.dfy"
module BytecodeCopyTraceLift {
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import E = BytecodeScanExecution
  import M = BytecodeCopyMachine
  import C = BytecodeCopyExecution
  lemma Step(code: seq<Byte>, destinations: set<nat>, state: State, value: Word, data: seq<Byte>)
    requires S.Step(code,destinations,state,value,data) != Bad
    ensures M.Step(code,destinations,state,value,data) == S.Step(code,destinations,state,value,data)
  {
    if state.Running? && state.pc < |code| && S.Fetch(code,state.pc).op in {0x37,0x5e} {
      reveal S.Step();
      assert S.Step(code,destinations,state,value,data) == Bad;
    }
    M.Delegate(code,destinations,state,value,data);
  }
  lemma Trace(code: seq<Byte>, destinations: set<nat>, value: Word, data: seq<Byte>, states: seq<State>)
    requires E.Trace(code,destinations,value,data,states)
    ensures C.Trace(code,destinations,value,data,states)
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures M.Step(code,destinations,states[i],value,data) == states[i+1] && states[i+1] != Bad
    {
      assert S.Step(code,destinations,states[i],value,data) == states[i+1];
      Step(code,destinations,states[i],value,data);
    }
  }
}

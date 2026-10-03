// SPDX-License-Identifier: MIT
include "../../../.generated/OperationsRuntime.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/pure-steps.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/trace-proof.dfy"

module OperationsDispatcher {
  import opened Int
  import opened EvmState
  import EVM
  import EvmFork
  import Stack
  import U256
  import OperationsRuntime
  import PureSteps
  import PushSummaries
  import ForkFacts
  import ExecutionTraceProof

  lemma Selector(st: ExecutingState, selector: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 11 && st.PC() == 25
    requires st.evm.stack.contents == []
    requires st.evm.context.CallDataSize() == 68
    requires U256.Shr(st.evm.context.CallDataRead(0),224) == selector
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 5 && states[0] == st
    ensures states[4] == EXECUTING(st.evm.(pc:=30,gas:=st.Gas()-11,
                                   stack:=Stack.Make([selector])))
  {
    OperationsRuntime.Window000(); reveal OperationsRuntime.Chunk000();
    assert forall i | 0 <= i < 256 :: st.evm.code.contents[i] == OperationsRuntime.Chunk000()[i];
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    PureSteps.PushZero(st);
    var s1: ExecutingState := EVM.Execute(st);
    PureSteps.CallDataLoad(s1);
    var s2: ExecutingState := EVM.Execute(s1);
    PushSummaries.PushOne(s2,224);
    var s3: ExecutingState := EVM.Execute(s2);
    PureSteps.Shr(s3);
    var s4: ExecutingState := EVM.Execute(s3);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
  }
}

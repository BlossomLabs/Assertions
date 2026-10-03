// SPDX-License-Identifier: MIT
include "../../../.generated/OperationsCodeFacts.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/checked-add.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/pure-steps.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/trace-proof.dfy"

module OperationsUnsignedArithmetic {
  import opened Int
  import opened EvmState
  import EVM
  import EvmFork
  import Stack
  import U256
  import CheckedAddition
  import Word
  import Code
  import ByteUtils
  import OperationsRuntime
  import OperationsCodeFacts
  import PureSteps
  import PushSummaries
  import InstructionSteps
  import ForkFacts
  import ExecutionTraceProof

  lemma PanicCall(st: ExecutingState) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 14 && st.PC() == 20244
    requires st.Capacity() >= 2
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 4 && states[0] == st
    ensures states[3] == EXECUTING(st.evm.(pc:=20125,gas:=st.Gas()-14,
                                   stack:=Stack.Make([2984]+st.evm.stack.contents)))
  {
    ForkFacts.CancunMembership();
    OperationsCodeFacts.Window079(st.evm.code); reveal OperationsRuntime.Chunk079();
    PushSummaries.PushTwo(st,11,168);
    var s1: ExecutingState := EVM.Execute(st);
    PushSummaries.PushTwo(s1,78,157);
    var s2: ExecutingState := EVM.Execute(s1);
    OperationsCodeFacts.Destination20125(s2.evm.code);
    InstructionSteps.JumpStep(s2);
    var s3: ExecutingState := EVM.Execute(s2);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
  }

  lemma Check(st: ExecutingState, a: u256, b: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 35 && st.PC() == 20232
    requires st.evm.stack.contents == [a,b,3085,0,b,a,1329,0x771602f7]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 11 && states[0] == st
    ensures states[10] == EXECUTING(st.evm.(pc:=(if a as int+b as int < TWO_256 then 2984 else 20244),gas:=st.Gas()-35,
                                    stack:=Stack.Make([U256.Add(a,b),a,b,3085,0,b,a,1329,0x771602f7])))
  {
    CheckedAddition.Unsigned(a,b);
    CheckedAddition.Unsigned(b,a);
    assert U256.Add(a,b) == U256.Add(b,a);
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window079(st.evm.code); reveal OperationsRuntime.Chunk079();
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    PureSteps.Dup(s1,1);
    var s2: ExecutingState := EVM.Execute(s1);
    PureSteps.Dup(s2,3);
    var s3: ExecutingState := EVM.Execute(s2);
    InstructionSteps.AddStep(s3);
    var s4: ExecutingState := EVM.Execute(s3);
    PureSteps.Dup(s4,1);
    var s5: ExecutingState := EVM.Execute(s4);
    PureSteps.Dup(s5,3);
    var s6: ExecutingState := EVM.Execute(s5);
    PureSteps.Gt(s6);
    var s7: ExecutingState := EVM.Execute(s6);
    PureSteps.IsZero(s7);
    var s8: ExecutingState := EVM.Execute(s7);
    PushSummaries.PushTwo(s8,11,168);
    var s9: ExecutingState := EVM.Execute(s8);
    OperationsCodeFacts.Destination2984(s9.evm.code);
    InstructionSteps.JumpIfStep(s9);
    var s10: ExecutingState := EVM.Execute(s9);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
    ExecutionTraceProof.Append(states,s5); states := states+[s5];
    ExecutionTraceProof.Append(states,s6); states := states+[s6];
    ExecutionTraceProof.Append(states,s7); states := states+[s7];
    ExecutionTraceProof.Append(states,s8); states := states+[s8];
    ExecutionTraceProof.Append(states,s9); states := states+[s9];
    ExecutionTraceProof.Append(states,s10); states := states+[s10];
  }
}

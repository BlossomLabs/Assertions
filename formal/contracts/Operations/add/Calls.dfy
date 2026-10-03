// SPDX-License-Identifier: MIT
include "../../../.generated/OperationsCodeFacts.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/pure-steps.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/trace-proof.dfy"

module OperationsUnsignedCalls {
  import opened Int
  import opened EvmState
  import EVM
  import EvmFork
  import Stack
  import U256
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

  lemma DecodeCall(st: ExecutingState) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 23 && st.PC() == 2108
    requires st.evm.stack.contents == [0x771602f7]
    requires st.evm.context.CallDataSize() == 68
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 8 && states[0] == st
    ensures states[7] == EXECUTING(st.evm.(pc:=18650,gas:=st.Gas()-23,
                                   stack:=Stack.Make([4,68,2122,1329,0x771602f7])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window008(st.evm.code); reveal OperationsRuntime.Chunk008();
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    PushSummaries.PushTwo(s1,5,49);
    var s2: ExecutingState := EVM.Execute(s1);
    PushSummaries.PushTwo(s2,8,74);
    var s3: ExecutingState := EVM.Execute(s2);
    PureSteps.CallDataSize(s3);
    var s4: ExecutingState := EVM.Execute(s3);
    PushSummaries.PushOne(s4,4);
    var s5: ExecutingState := EVM.Execute(s4);
    PushSummaries.PushTwo(s5,72,218);
    var s6: ExecutingState := EVM.Execute(s5);
    OperationsCodeFacts.Destination18650(s6.evm.code);
    InstructionSteps.JumpStep(s6);
    var s7: ExecutingState := EVM.Execute(s6);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
    ExecutionTraceProof.Append(states,s5); states := states+[s5];
    ExecutionTraceProof.Append(states,s6); states := states+[s6];
    ExecutionTraceProof.Append(states,s7); states := states+[s7];
  }

  lemma BodyCall(st: ExecutingState, a: u256, b: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 12 && st.PC() == 2122
    requires st.evm.stack.contents == [b,a,1329,0x771602f7]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 4 && states[0] == st
    ensures states[3] == EXECUTING(st.evm.(pc:=5974,gas:=st.Gas()-12,
                                   stack:=Stack.Make([b,a,1329,0x771602f7])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window008(st.evm.code); reveal OperationsRuntime.Chunk008();
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    PushSummaries.PushTwo(s1,23,86);
    var s2: ExecutingState := EVM.Execute(s1);
    OperationsCodeFacts.Destination5974(s2.evm.code);
    InstructionSteps.JumpStep(s2);
    var s3: ExecutingState := EVM.Execute(s2);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
  }

  lemma AdditionCall(st: ExecutingState, a: u256, b: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 23 && st.PC() == 5974
    requires st.evm.stack.contents == [b,a,1329,0x771602f7]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 8 && states[0] == st
    ensures states[7] == EXECUTING(st.evm.(pc:=20232,gas:=st.Gas()-23,
                                   stack:=Stack.Make([a,b,3085,0,b,a,1329,0x771602f7])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window023(st.evm.code); reveal OperationsRuntime.Chunk023();
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    PureSteps.PushZero(s1);
    var s2: ExecutingState := EVM.Execute(s1);
    PushSummaries.PushTwo(s2,12,13);
    var s3: ExecutingState := EVM.Execute(s2);
    PureSteps.Dup(s3,3);
    var s4: ExecutingState := EVM.Execute(s3);
    PureSteps.Dup(s4,5);
    var s5: ExecutingState := EVM.Execute(s4);
    PushSummaries.PushTwo(s5,79,8);
    var s6: ExecutingState := EVM.Execute(s5);
    OperationsCodeFacts.Destination20232(s6.evm.code);
    InstructionSteps.JumpStep(s6);
    var s7: ExecutingState := EVM.Execute(s6);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
    ExecutionTraceProof.Append(states,s5); states := states+[s5];
    ExecutionTraceProof.Append(states,s6); states := states+[s6];
    ExecutionTraceProof.Append(states,s7); states := states+[s7];
  }

  lemma AdditionReturn(st: ExecutingState, value: u256, a: u256, b: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 19 && st.PC() == 2984
    requires st.evm.stack.contents == [value,a,b,3085,0,b,a,1329,0x771602f7]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 7 && states[0] == st
    ensures states[6] == EXECUTING(st.evm.(pc:=3085,gas:=st.Gas()-19,
                                   stack:=Stack.Make([value,0,b,a,1329,0x771602f7])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window011(st.evm.code); reveal OperationsRuntime.Chunk011();
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    InstructionSteps.SwapStep(s1,3);
    var s2: ExecutingState := EVM.Execute(s1);
    InstructionSteps.SwapStep(s2,2);
    var s3: ExecutingState := EVM.Execute(s2);
    InstructionSteps.PopStep(s3);
    var s4: ExecutingState := EVM.Execute(s3);
    InstructionSteps.PopStep(s4);
    var s5: ExecutingState := EVM.Execute(s4);
    OperationsCodeFacts.Destination3085(s5.evm.code);
    InstructionSteps.JumpStep(s5);
    var s6: ExecutingState := EVM.Execute(s5);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
    ExecutionTraceProof.Append(states,s5); states := states+[s5];
    ExecutionTraceProof.Append(states,s6); states := states+[s6];
  }

  lemma BodyReturn(st: ExecutingState, value: u256, a: u256, b: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 21 && st.PC() == 3085
    requires st.evm.stack.contents == [value,0,b,a,1329,0x771602f7]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 8 && states[0] == st
    ensures states[7] == EXECUTING(st.evm.(pc:=1329,gas:=st.Gas()-21,
                                   stack:=Stack.Make([value,0x771602f7])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window012(st.evm.code); reveal OperationsRuntime.Chunk012();
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    InstructionSteps.SwapStep(s1,4);
    var s2: ExecutingState := EVM.Execute(s1);
    InstructionSteps.SwapStep(s2,3);
    var s3: ExecutingState := EVM.Execute(s2);
    InstructionSteps.PopStep(s3);
    var s4: ExecutingState := EVM.Execute(s3);
    InstructionSteps.PopStep(s4);
    var s5: ExecutingState := EVM.Execute(s4);
    InstructionSteps.PopStep(s5);
    var s6: ExecutingState := EVM.Execute(s5);
    OperationsCodeFacts.Destination1329(s6.evm.code);
    InstructionSteps.JumpStep(s6);
    var s7: ExecutingState := EVM.Execute(s6);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
    ExecutionTraceProof.Append(states,s5); states := states+[s5];
    ExecutionTraceProof.Append(states,s6); states := states+[s6];
    ExecutionTraceProof.Append(states,s7); states := states+[s7];
  }
}

// SPDX-License-Identifier: MIT
include "../../../.generated/OperationsRuntime.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/pure-steps.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/trace-proof.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/boundaries.dfy"

module OperationsEntry {
  import opened Int
  import opened EvmState
  import EVM
  import EvmFork
  import Memory
  import Stack
  import Gas
  import Code
  import InstructionBoundaries
  import OperationsRuntime
  import PureSteps
  import PushSummaries
  import InstructionSteps
  import ForkFacts
  import ExecutionTraceProof

  function InitializedMemory(): Memory.T
  {
    Memory.WriteUint256(Memory.Expand(Memory.Create(),95),64,128)
  }

  lemma Initialize(st: ExecutingState) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 63
    requires st.PC() == 0
    requires st.evm.stack.contents == []
    requires st.evm.memory.contents == []
    requires st.evm.context.callValue == 0
    requires st.evm.context.CallDataSize() == 68
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 16 && states[0] == st
    ensures states[15] == EXECUTING(st.evm.(pc:=25,gas:=st.Gas()-63,
                                    stack:=Stack.Make([]),memory:=InitializedMemory()))
  {
    OperationsRuntime.Window000(); reveal OperationsRuntime.Chunk000();
    assert forall i | 0 <= i < 256 :: st.evm.code.contents[i] == OperationsRuntime.Chunk000()[i];
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    PushSummaries.PushOne(st,128);
    var s1: ExecutingState := EVM.Execute(st);
    PushSummaries.PushOne(s1,64);
    var s2: ExecutingState := EVM.Execute(s1);
    assert Gas.CostExpandBytes(s2,2,0,32) == 9 by {
      assert s2.Operands() == 2 && s2.Peek(0) == 64;
      assert s2.evm.memory.contents == [];
      assert Memory.SmallestLarg32(95) == 96;
      assert Gas.QuadraticCost(3) == 9 && Gas.QuadraticCost(0) == 0;
      assert Gas.ExpansionSize(s2.evm.memory,64,32) == 9;
    }
    PureSteps.Store(s2);
    var s3: ExecutingState := EVM.Execute(s2);
    assert s3.evm.memory == InitializedMemory();
    PureSteps.CallValue(s3);
    var s4: ExecutingState := EVM.Execute(s3);
    PureSteps.Dup(s4,1);
    var s5: ExecutingState := EVM.Execute(s4);
    PureSteps.IsZero(s5);
    var s6: ExecutingState := EVM.Execute(s5);
    PushSummaries.PushTwo(s6,0,15);
    var s7: ExecutingState := EVM.Execute(s6);
    assert s7.IsJumpDest(15) by {
      var code := s7.evm.code;
      assert Code.IsInstructionStart(code,15,15) by { reveal Code.IsInstructionStart(); }
      InstructionBoundaries.Predecessor(code,14,15);
      InstructionBoundaries.Predecessor(code,13,15);
      InstructionBoundaries.Predecessor(code,12,15);
      InstructionBoundaries.Predecessor(code,11,15);
      InstructionBoundaries.Predecessor(code,8,15);
      InstructionBoundaries.Predecessor(code,7,15);
      InstructionBoundaries.Predecessor(code,6,15);
      InstructionBoundaries.Predecessor(code,5,15);
      InstructionBoundaries.Predecessor(code,4,15);
      InstructionBoundaries.Predecessor(code,2,15);
      InstructionBoundaries.Predecessor(code,0,15);
    }
    InstructionSteps.JumpIfStep(s7);
    var s8: ExecutingState := EVM.Execute(s7);
    InstructionSteps.JumpDestStep(s8);
    var s9: ExecutingState := EVM.Execute(s8);
    InstructionSteps.PopStep(s9);
    var s10: ExecutingState := EVM.Execute(s9);
    PushSummaries.PushOne(s10,4);
    var s11: ExecutingState := EVM.Execute(s10);
    PureSteps.CallDataSize(s11);
    var s12: ExecutingState := EVM.Execute(s11);
    PureSteps.Lt(s12);
    var s13: ExecutingState := EVM.Execute(s12);
    PureSteps.Push(s13,2);
    var s14: ExecutingState := EVM.Execute(s13);
    InstructionSteps.JumpIfStep(s14);
    var s15: ExecutingState := EVM.Execute(s14);
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
    ExecutionTraceProof.Append(states,s11); states := states+[s11];
    ExecutionTraceProof.Append(states,s12); states := states+[s12];
    ExecutionTraceProof.Append(states,s13); states := states+[s13];
    ExecutionTraceProof.Append(states,s14); states := states+[s14];
    ExecutionTraceProof.Append(states,s15); states := states+[s15];
  }
}

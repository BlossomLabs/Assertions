// SPDX-License-Identifier: MIT
include "../../../.generated/OperationsCodeFacts.dfy"
include "../../../shared/abi/Bridge.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/pure-steps.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/trace-proof.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/word-store.dfy"

module OperationsPanic {
  import opened Int
  import opened EvmState
  import EVM
  import EvmFork
  import Memory
  import Gas
  import Code
  import ByteUtils
  import U256
  import ShiftFacts
  import WordStoreFacts
  import AbiEncoding
  import AbiBridge
  import OperationsRuntime
  import OperationsCodeFacts
  import PureSteps
  import PushSummaries
  import InstructionSteps
  import ForkFacts
  import ExecutionTraceProof

  const ShiftedSelector: u256 := 0x4e487b7100000000000000000000000000000000000000000000000000000000

  lemma Encoding(mem: Memory.T)
    requires |mem.contents| >= 36
    ensures Memory.Slice(Memory.WriteUint256(Memory.WriteUint256(mem,0,ShiftedSelector),4,17),0,36) == AbiEncoding.Panic11()
  {
    WordStoreFacts.Store256(mem.contents,0,ShiftedSelector);
    var first := Memory.WriteUint256(mem,0,ShiftedSelector);
    WordStoreFacts.Store256(first.contents,4,17);
    assert U256.ToBytes(ShiftedSelector)[..4] == [0x4e,0x48,0x7b,0x71];
    assert first.contents[..4] == [0x4e,0x48,0x7b,0x71];
    AbiBridge.Word(17);
  }

  lemma Report(st: ExecutingState) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.PC() == 20125 && st.Gas() >= 29
    requires st.Capacity() >= 3
    requires |st.evm.memory.contents| >= 36
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 13 && states[0] == st
    ensures states[12] == ERROR(REVERTS,st.Gas()-29,AbiEncoding.Panic11())
  {
    OperationsCodeFacts.Window078(st.evm.code); reveal OperationsRuntime.Chunk078();
    ForkFacts.CancunMembership();
    ShiftFacts.Power();
    assert U256.Shl(0x4e487b71,224) == ShiftedSelector;
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    assert Code.Slice(s1.evm.code,20127,4) == [0x4e,0x48,0x7b,0x71];
    assert ByteUtils.ConvertBytesTo256([0x4e,0x48,0x7b,0x71]) == 0x4e487b71;
    PureSteps.Push(s1,4);
    var s2: ExecutingState := EVM.Execute(s1);
    PushSummaries.PushOne(s2,224);
    var s3: ExecutingState := EVM.Execute(s2);
    PureSteps.Shl(s3);
    var s4: ExecutingState := EVM.Execute(s3);
    PureSteps.PushZero(s4);
    var s5: ExecutingState := EVM.Execute(s4);
    assert Gas.CostExpandBytes(s5,2,0,32) == 0;
    PureSteps.Store(s5);
    var s6: ExecutingState := EVM.Execute(s5);
    PushSummaries.PushOne(s6,17);
    var s7: ExecutingState := EVM.Execute(s6);
    PushSummaries.PushOne(s7,4);
    var s8: ExecutingState := EVM.Execute(s7);
    assert Gas.CostExpandBytes(s8,2,0,32) == 0;
    PureSteps.Store(s8);
    var s9: ExecutingState := EVM.Execute(s8);
    PushSummaries.PushOne(s9,36);
    var s10: ExecutingState := EVM.Execute(s9);
    PureSteps.PushZero(s10);
    var s11: ExecutingState := EVM.Execute(s10);
    assert Gas.CostExpandRange(s11,2,0,1) == 0;
    Encoding(st.evm.memory);
    PureSteps.Revert(s11);
    var s12 := EVM.Execute(s11);
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
  }
}

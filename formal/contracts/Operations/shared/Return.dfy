// SPDX-License-Identifier: MIT
include "Entry.dfy"
include "../../../.generated/OperationsCodeFacts.dfy"
include "../../../shared/abi/Bridge.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/word-store.dfy"

module OperationsReturn {
  import opened Int
  import opened EvmState
  import EVM
  import EvmFork
  import Memory
  import Stack
  import Gas
  import U256
  import OperationsEntry
  import OperationsRuntime
  import OperationsCodeFacts
  import AbiEncoding
  import AbiBridge
  import WordStoreFacts
  import PureSteps
  import PushSummaries
  import LoadSummaries
  import InstructionSteps
  import ForkFacts
  import ExecutionTraceProof

  function EncodedMemory(value: u256): Memory.T {
    Memory.WriteUint256(Memory.Expand(OperationsEntry.InitializedMemory(),159),128,value)
  }

  lemma MemoryLayout(value: u256)
    ensures |OperationsEntry.InitializedMemory().contents| == 96
    ensures Memory.ReadUint256(OperationsEntry.InitializedMemory(),64) == 128
    ensures |EncodedMemory(value).contents| == 160
    ensures Memory.ReadUint256(EncodedMemory(value),64) == 128
    ensures Memory.Slice(EncodedMemory(value),128,32) == AbiEncoding.Word(value as int)
  {
    var empty := Memory.Expand(Memory.Create(),95);
    assert |empty.contents| == 96;
    WordStoreFacts.Store256(empty.contents,64,128);
    AbiBridge.Word(128);
    var initialized := OperationsEntry.InitializedMemory();
    assert initialized.contents[64..96] == AbiEncoding.Word(128);
    AbiBridge.FullWord(initialized.contents,64,128);
    var expanded := Memory.Expand(initialized,159);
    assert |expanded.contents| == 160;
    assert expanded.contents[64..96] == initialized.contents[64..96];
    WordStoreFacts.Store256(expanded.contents,128,value);
    AbiBridge.Word(value);
    var encoded := EncodedMemory(value);
    assert encoded.contents[64..96] == AbiEncoding.Word(128);
    AbiBridge.FullWord(encoded.contents,64,128);
  }

  lemma Encode(st: ExecutingState, value: u256, selector: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.PC() == 1329 && st.Gas() >= 39
    requires st.evm.stack.contents == [value,selector]
    requires st.evm.memory == OperationsEntry.InitializedMemory()
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 11 && states[0] == st
    ensures states[10] == EXECUTING(st.evm.(pc:=1301,gas:=st.Gas()-39,
                                    stack:=Stack.Make([160,selector]),memory:=EncodedMemory(value)))
  {
    MemoryLayout(value);
    OperationsCodeFacts.Window005(st.evm.code); reveal OperationsRuntime.Chunk005();
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    PushSummaries.PushOne(s1,64);
    var s2: ExecutingState := EVM.Execute(s1);
    LoadSummaries.Fits(s2);
    var s3: ExecutingState := EVM.Execute(s2);
    InstructionSteps.SwapStep(s3,1);
    var s4: ExecutingState := EVM.Execute(s3);
    PureSteps.Dup(s4,2);
    var s5: ExecutingState := EVM.Execute(s4);
    assert Gas.CostExpandBytes(s5,2,0,32) == 6 by {
      assert s5.Operands() == 4 && s5.Peek(0) == 128;
      assert |s5.evm.memory.contents| == 96;
      assert Memory.SmallestLarg32(159) == 160;
      assert Gas.QuadraticCost(5) == 15 && Gas.QuadraticCost(3) == 9;
      assert Gas.ExpansionSize(s5.evm.memory,128,32) == 6;
    }
    PureSteps.Store(s5);
    var s6: ExecutingState := EVM.Execute(s5);
    PushSummaries.PushOne(s6,32);
    var s7: ExecutingState := EVM.Execute(s6);
    InstructionSteps.AddStep(s7);
    var s8: ExecutingState := EVM.Execute(s7);
    PushSummaries.PushTwo(s8,5,21);
    var s9: ExecutingState := EVM.Execute(s8);
    OperationsCodeFacts.Destination1301(s9.evm.code);
    InstructionSteps.JumpStep(s9);
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

  lemma ReturnBase(st: ExecutingState, value: u256, selector: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.PC() == 1301 && st.Gas() >= 10
    requires st.evm.stack.contents == [160,selector]
    requires st.evm.memory == EncodedMemory(value)
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 5 && states[0] == st
    ensures states[4] == EXECUTING(st.evm.(pc:=1306,gas:=st.Gas()-10,
                                   stack:=Stack.Make([128,128,160,selector])))
  {
    MemoryLayout(value);
    OperationsCodeFacts.Window005(st.evm.code); reveal OperationsRuntime.Chunk005();
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    PushSummaries.PushOne(s1,64);
    var s2: ExecutingState := EVM.Execute(s1);
    LoadSummaries.Fits(s2);
    var s3: ExecutingState := EVM.Execute(s2);
    PureSteps.Dup(s3,1);
    var s4: ExecutingState := EVM.Execute(s3);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
  }

  lemma ReturnLength(st: ExecutingState, selector: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.PC() == 1306 && st.Gas() >= 9
    requires st.evm.stack.contents == [128,128,160,selector]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 4 && states[0] == st
    ensures states[3] == EXECUTING(st.evm.(pc:=1309,gas:=st.Gas()-9,
                                   stack:=Stack.Make([128,32,selector])))
  {
    OperationsCodeFacts.Window005(st.evm.code); reveal OperationsRuntime.Chunk005();
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    InstructionSteps.SwapStep(st,2);
    var s1: ExecutingState := EVM.Execute(st);
    assert s1.evm.stack.contents == [160,128,128,selector];
    assert (160-128) % TWO_256 == 32;
    PureSteps.Sub(s1);
    var s2: ExecutingState := EVM.Execute(s1);
    assert s2.evm.stack.contents == [32,128,selector];
    InstructionSteps.SwapStep(s2,1);
    var s3: ExecutingState := EVM.Execute(s2);
    assert s3.evm.stack.contents == [128,32,selector];
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
  }

  lemma Finish(st: ExecutingState, value: u256, selector: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.PC() == 1301 && st.Gas() >= 19
    requires st.evm.stack.contents == [160,selector]
    requires st.evm.memory == EncodedMemory(value)
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 9 && states[0] == st
    ensures states[8] == RETURNS(st.Gas()-19,AbiEncoding.Word(value as int),st.evm.world,st.evm.transient,st.evm.substate)
  {
    var base := ReturnBase(st,value,selector);
    var length := ReturnLength(base[4],selector);
    assert |base| == 5 && |length| == 4;
    assert base[4] == length[0];
    assert ExecutionTraceProof.Valid(base) && ExecutionTraceProof.Valid(length);
    ExecutionTraceProof.Join(base,length);
    var prefix := base+length[1..];
    var ready: ExecutingState := length[3];
    MemoryLayout(value);
    OperationsCodeFacts.Window005(ready.evm.code); reveal OperationsRuntime.Chunk005();
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    assert 0xf3 in ready.evm.fork.bytecodes;
    assert ready.Peek(0) == 128 && ready.Peek(1) == 32;
    assert ready.evm.memory == EncodedMemory(value);
    assert |ready.evm.memory.contents| == 160;
    assert Gas.CostExpandRange(ready,2,0,1) == 0;
    PureSteps.Return(ready);
    var terminal := EVM.Execute(ready);
    ExecutionTraceProof.Append(prefix,terminal);
    states := prefix+[terminal];
  }
}

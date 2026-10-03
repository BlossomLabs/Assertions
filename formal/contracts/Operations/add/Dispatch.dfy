// SPDX-License-Identifier: MIT
include "../../../.generated/OperationsCodeFacts.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/pure-steps.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/trace-proof.dfy"

module OperationsUnsignedDispatcher {
  import opened Int
  import opened EvmState
  import EVM
  import EvmFork
  import Stack
  import Code
  import ByteUtils
  import OperationsRuntime
  import OperationsCodeFacts
  import PureSteps
  import PushSummaries
  import InstructionSteps
  import ForkFacts
  import ExecutionTraceProof

  lemma FirstSplit(st: ExecutingState) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 22 && st.PC() == 30
    requires st.evm.stack.contents == [0x771602f7]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 6 && states[0] == st
    ensures states[5] == EXECUTING(st.evm.(pc:=655,gas:=st.Gas()-22,
                                   stack:=Stack.Make([0x771602f7])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window000(st.evm.code); reveal OperationsRuntime.Chunk000();
    PureSteps.Dup(st,1);
    var s1: ExecutingState := EVM.Execute(st);
    assert Code.Slice(s1.evm.code,32,4) == [129,254,87,134];
    assert ByteUtils.ConvertBytesTo256([129,254,87,134]) == 2180929414;
    PureSteps.Push(s1,4);
    var s2: ExecutingState := EVM.Execute(s1);
    PureSteps.Gt(s2);
    var s3: ExecutingState := EVM.Execute(s2);
    PushSummaries.PushTwo(s3,2,143);
    var s4: ExecutingState := EVM.Execute(s3);
    OperationsCodeFacts.Destination655(s4.evm.code);
    InstructionSteps.JumpIfStep(s4);
    var s5: ExecutingState := EVM.Execute(s4);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
    ExecutionTraceProof.Append(states,s5); states := states+[s5];
  }

  lemma RangeSplits(st: ExecutingState) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 67 && st.PC() == 655
    requires st.evm.stack.contents == [0x771602f7]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 17 && states[0] == st
    ensures states[16] == EXECUTING(st.evm.(pc:=689,gas:=st.Gas()-67,
                                    stack:=Stack.Make([0x771602f7])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window002(st.evm.code); reveal OperationsRuntime.Chunk002();
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    PureSteps.Dup(s1,1);
    var s2: ExecutingState := EVM.Execute(s1);
    assert Code.Slice(s2.evm.code,658,4) == [64,129,111,174];
    assert ByteUtils.ConvertBytesTo256([64,129,111,174]) == 1082224558;
    PureSteps.Push(s2,4);
    var s3: ExecutingState := EVM.Execute(s2);
    PureSteps.Gt(s3);
    var s4: ExecutingState := EVM.Execute(s3);
    PushSummaries.PushTwo(s4,3,200);
    var s5: ExecutingState := EVM.Execute(s4);
    InstructionSteps.JumpIfStep(s5);
    var s6: ExecutingState := EVM.Execute(s5);
    PureSteps.Dup(s6,1);
    var s7: ExecutingState := EVM.Execute(s6);
    assert Code.Slice(s7.evm.code,669,4) == [101,82,241,135];
    assert ByteUtils.ConvertBytesTo256([101,82,241,135]) == 1699934599;
    PureSteps.Push(s7,4);
    var s8: ExecutingState := EVM.Execute(s7);
    PureSteps.Gt(s8);
    var s9: ExecutingState := EVM.Execute(s8);
    PushSummaries.PushTwo(s9,3,60);
    var s10: ExecutingState := EVM.Execute(s9);
    InstructionSteps.JumpIfStep(s10);
    var s11: ExecutingState := EVM.Execute(s10);
    PureSteps.Dup(s11,1);
    var s12: ExecutingState := EVM.Execute(s11);
    assert Code.Slice(s12.evm.code,680,4) == [110,242,92,58];
    assert ByteUtils.ConvertBytesTo256([110,242,92,58]) == 1861377082;
    PureSteps.Push(s12,4);
    var s13: ExecutingState := EVM.Execute(s12);
    PureSteps.Gt(s13);
    var s14: ExecutingState := EVM.Execute(s13);
    PushSummaries.PushTwo(s14,2,246);
    var s15: ExecutingState := EVM.Execute(s14);
    InstructionSteps.JumpIfStep(s15);
    var s16: ExecutingState := EVM.Execute(s15);
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
    ExecutionTraceProof.Append(states,s16); states := states+[s16];
  }

  lemma SignatureCases(st: ExecutingState) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 88 && st.PC() == 689
    requires st.evm.stack.contents == [0x771602f7]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 21 && states[0] == st
    ensures states[20] == EXECUTING(st.evm.(pc:=2108,gas:=st.Gas()-88,
                                    stack:=Stack.Make([0x771602f7])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window002(st.evm.code); reveal OperationsRuntime.Chunk002();
    PureSteps.Dup(st,1);
    var s1: ExecutingState := EVM.Execute(st);
    assert Code.Slice(s1.evm.code,691,4) == [110,242,92,58];
    assert ByteUtils.ConvertBytesTo256([110,242,92,58]) == 1861377082;
    PureSteps.Push(s1,4);
    var s2: ExecutingState := EVM.Execute(s1);
    PureSteps.Eq(s2);
    var s3: ExecutingState := EVM.Execute(s2);
    PushSummaries.PushTwo(s3,8,18);
    var s4: ExecutingState := EVM.Execute(s3);
    InstructionSteps.JumpIfStep(s4);
    var s5: ExecutingState := EVM.Execute(s4);
    PureSteps.Dup(s5,1);
    var s6: ExecutingState := EVM.Execute(s5);
    assert Code.Slice(s6.evm.code,702,4) == [117,152,181,8];
    assert ByteUtils.ConvertBytesTo256([117,152,181,8]) == 1972942088;
    PureSteps.Push(s6,4);
    var s7: ExecutingState := EVM.Execute(s6);
    PureSteps.Eq(s7);
    var s8: ExecutingState := EVM.Execute(s7);
    PushSummaries.PushTwo(s8,8,24);
    var s9: ExecutingState := EVM.Execute(s8);
    InstructionSteps.JumpIfStep(s9);
    var s10: ExecutingState := EVM.Execute(s9);
    PureSteps.Dup(s10,1);
    var s11: ExecutingState := EVM.Execute(s10);
    assert Code.Slice(s11.evm.code,713,4) == [117,244,71,154];
    assert ByteUtils.ConvertBytesTo256([117,244,71,154]) == 1978943386;
    PureSteps.Push(s11,4);
    var s12: ExecutingState := EVM.Execute(s11);
    PureSteps.Eq(s12);
    var s13: ExecutingState := EVM.Execute(s12);
    PushSummaries.PushTwo(s13,8,42);
    var s14: ExecutingState := EVM.Execute(s13);
    InstructionSteps.JumpIfStep(s14);
    var s15: ExecutingState := EVM.Execute(s14);
    PureSteps.Dup(s15,1);
    var s16: ExecutingState := EVM.Execute(s15);
    assert Code.Slice(s16.evm.code,724,4) == [119,22,2,247];
    assert ByteUtils.ConvertBytesTo256([119,22,2,247]) == 1997931255;
    PureSteps.Push(s16,4);
    var s17: ExecutingState := EVM.Execute(s16);
    PureSteps.Eq(s17);
    var s18: ExecutingState := EVM.Execute(s17);
    PushSummaries.PushTwo(s18,8,60);
    var s19: ExecutingState := EVM.Execute(s18);
    OperationsCodeFacts.Destination2108(s19.evm.code);
    InstructionSteps.JumpIfStep(s19);
    var s20: ExecutingState := EVM.Execute(s19);
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
    ExecutionTraceProof.Append(states,s16); states := states+[s16];
    ExecutionTraceProof.Append(states,s17); states := states+[s17];
    ExecutionTraceProof.Append(states,s18); states := states+[s18];
    ExecutionTraceProof.Append(states,s19); states := states+[s19];
    ExecutionTraceProof.Append(states,s20); states := states+[s20];
  }
}

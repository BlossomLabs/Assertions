// SPDX-License-Identifier: MIT
include "../../../.generated/OperationsCodeFacts.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/pure-steps.dfy"
include "../../../../proof-tools/dafnyevm/src/dafny/trace-proof.dfy"

module OperationsDecode {
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

  lemma PrepareWordPair(st: ExecutingState, returnPC: u256, continuation: u256, selector: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 8 && st.PC() == 18650
    requires st.evm.stack.contents == [4,68,returnPC,continuation,selector]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 5 && states[0] == st
    ensures states[4] == EXECUTING(st.evm.(pc:=18655,gas:=st.Gas()-8,
                                   stack:=Stack.Make([64,0,0,4,68,returnPC,continuation,selector])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window072(st.evm.code); reveal OperationsRuntime.Chunk072();
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    PureSteps.PushZero(s1);
    var s2: ExecutingState := EVM.Execute(s1);
    PureSteps.PushZero(s2);
    var s3: ExecutingState := EVM.Execute(s2);
    PushSummaries.PushOne(s3,64);
    var s4: ExecutingState := EVM.Execute(s3);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
  }

  lemma WordPairDifference(st: ExecutingState, returnPC: u256, continuation: u256, selector: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 9 && st.PC() == 18655
    requires st.evm.stack.contents == [64,0,0,4,68,returnPC,continuation,selector]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 4 && states[0] == st
    ensures states[3] == EXECUTING(st.evm.(pc:=18658,gas:=st.Gas()-9,
                                   stack:=Stack.Make([64,64,0,0,4,68,returnPC,continuation,selector])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window072(st.evm.code); reveal OperationsRuntime.Chunk072();
    PureSteps.Dup(st,4);
    var s1: ExecutingState := EVM.Execute(st);
    PureSteps.Dup(s1,6);
    var s2: ExecutingState := EVM.Execute(s1);
    PureSteps.Sub(s2);
    var s3: ExecutingState := EVM.Execute(s2);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
  }

  lemma AcceptWordPair(st: ExecutingState, returnPC: u256, continuation: u256, selector: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 19 && st.PC() == 18658
    requires st.evm.stack.contents == [64,64,0,0,4,68,returnPC,continuation,selector]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 5 && states[0] == st
    ensures states[4] == EXECUTING(st.evm.(pc:=18667,gas:=st.Gas()-19,
                                   stack:=Stack.Make([0,0,4,68,returnPC,continuation,selector])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window072(st.evm.code); reveal OperationsRuntime.Chunk072();
    assert Word.asI256(64) == 64;
    PureSteps.SLt(st);
    var s1: ExecutingState := EVM.Execute(st);
    assert s1.Peek(0) == 0;
    PureSteps.IsZero(s1);
    var s2: ExecutingState := EVM.Execute(s1);
    assert s2.Peek(0) == 1;
    PushSummaries.PushTwo(s2,72,235);
    var s3: ExecutingState := EVM.Execute(s2);
    assert s3.Peek(0) == 18667 && s3.Peek(1) == 1;
    OperationsCodeFacts.Destination18667(s3.evm.code);
    InstructionSteps.JumpIfStep(s3);
    var s4: ExecutingState := EVM.Execute(s3);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
  }

  lemma CheckWordPair(st: ExecutingState, returnPC: u256, continuation: u256, selector: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 36 && st.PC() == 18650
    requires st.evm.stack.contents == [4,68,returnPC,continuation,selector]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 12 && states[0] == st
    ensures states[11] == EXECUTING(st.evm.(pc:=18667,gas:=st.Gas()-36,
                                    stack:=Stack.Make([0,0,4,68,returnPC,continuation,selector])))
  {
    var prepared := PrepareWordPair(st,returnPC,continuation,selector);
    var difference := WordPairDifference(prepared[4],returnPC,continuation,selector);
    ExecutionTraceProof.Join(prepared,difference);
    var prefix := prepared+difference[1..];
    var accepted := AcceptWordPair(difference[3],returnPC,continuation,selector);
    ExecutionTraceProof.Join(prefix,accepted);
    states := prefix+accepted[1..];
  }

  lemma ReadWordPair(st: ExecutingState, a: u256, b: u256, returnPC: u256, continuation: u256, selector: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 42 && st.PC() == 18667
    requires st.evm.stack.contents == [0,0,4,68,returnPC,continuation,selector]
    requires st.evm.context.CallDataSize() == 68
    requires st.evm.context.CallDataRead(4) == a
    requires st.evm.context.CallDataRead(36) == b
    requires st.IsJumpDest(returnPC)
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 15 && states[0] == st
    ensures states[14] == EXECUTING(st.evm.(pc:=returnPC as nat,gas:=st.Gas()-42,
                                    stack:=Stack.Make([b,a,continuation,selector])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window072(st.evm.code); reveal OperationsRuntime.Chunk072();
    InstructionSteps.JumpDestStep(st);
    var s1: ExecutingState := EVM.Execute(st);
    InstructionSteps.PopStep(s1);
    var s2: ExecutingState := EVM.Execute(s1);
    InstructionSteps.PopStep(s2);
    var s3: ExecutingState := EVM.Execute(s2);
    PureSteps.Dup(s3,1);
    var s4: ExecutingState := EVM.Execute(s3);
    PureSteps.CallDataLoad(s4);
    var s5: ExecutingState := EVM.Execute(s4);
    InstructionSteps.SwapStep(s5,3);
    var s6: ExecutingState := EVM.Execute(s5);
    PushSummaries.PushOne(s6,32);
    var s7: ExecutingState := EVM.Execute(s6);
    InstructionSteps.SwapStep(s7,1);
    var s8: ExecutingState := EVM.Execute(s7);
    InstructionSteps.SwapStep(s8,2);
    var s9: ExecutingState := EVM.Execute(s8);
    InstructionSteps.AddStep(s9);
    var s10: ExecutingState := EVM.Execute(s9);
    PureSteps.CallDataLoad(s10);
    var s11: ExecutingState := EVM.Execute(s10);
    InstructionSteps.SwapStep(s11,2);
    var s12: ExecutingState := EVM.Execute(s11);
    InstructionSteps.PopStep(s12);
    var s13: ExecutingState := EVM.Execute(s12);
    assert s13.IsJumpDest(returnPC);
    InstructionSteps.JumpStep(s13);
    var s14: ExecutingState := EVM.Execute(s13);
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
  }
}

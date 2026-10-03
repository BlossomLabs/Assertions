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

  lemma Sum(st: ExecutingState, a: u256, b: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 10 && st.PC() == 20232
    requires st.evm.stack.contents == [a,b,3085,0,b,a,1329,0x771602f7]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 5 && states[0] == st
    ensures states[4] == EXECUTING(st.evm.(pc:=20236,gas:=st.Gas()-10,
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
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
  }

  lemma OverflowFlag(st: ExecutingState, a: u256, b: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 12 && st.PC() == 20236
    requires st.evm.stack.contents == [U256.Add(a,b),a,b,3085,0,b,a,1329,0x771602f7]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 5 && states[0] == st
    ensures states[4] == EXECUTING(st.evm.(pc:=20240,gas:=st.Gas()-12,
                                   stack:=Stack.Make([(if a as int+b as int < TWO_256 then 1 else 0),U256.Add(a,b),a,b,3085,0,b,a,1329,0x771602f7])))
  {
    CheckedAddition.Unsigned(a,b);
    CheckedAddition.Unsigned(b,a);
    assert U256.Add(a,b) == U256.Add(b,a);
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window079(st.evm.code); reveal OperationsRuntime.Chunk079();
    PureSteps.Dup(st,1);
    var s1: ExecutingState := EVM.Execute(st);
    PureSteps.Dup(s1,3);
    var s2: ExecutingState := EVM.Execute(s1);
    PureSteps.Gt(s2);
    var s3: ExecutingState := EVM.Execute(s2);
    PureSteps.IsZero(s3);
    var s4: ExecutingState := EVM.Execute(s3);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
    ExecutionTraceProof.Append(states,s3); states := states+[s3];
    ExecutionTraceProof.Append(states,s4); states := states+[s4];
  }

  lemma Branch(st: ExecutingState, a: u256, b: u256) returns (states: seq<State>)
    requires st.evm.code.contents == OperationsRuntime.Code()
    requires st.evm.fork == EvmFork.CANCUN
    requires st.Gas() >= 13 && st.PC() == 20240
    requires st.evm.stack.contents == [(if a as int+b as int < TWO_256 then 1 else 0),U256.Add(a,b),a,b,3085,0,b,a,1329,0x771602f7]
    ensures ExecutionTraceProof.Valid(states)
    ensures |states| == 3 && states[0] == st
    ensures states[2] == EXECUTING(st.evm.(pc:=(if a as int+b as int < TWO_256 then 2984 else 20244),gas:=st.Gas()-13,
                                   stack:=Stack.Make([U256.Add(a,b),a,b,3085,0,b,a,1329,0x771602f7])))
  {
    ForkFacts.CancunMembership();
    reveal EvmFork.CANCUN; reveal EvmFork.CANCUN_BYTECODES; reveal EvmFork.GENISIS_BYTECODES;
    EvmFork.EipSet(EvmFork.CANCUN_EIPS,EvmFork.GENISIS_BYTECODES);
    OperationsCodeFacts.Window079(st.evm.code); reveal OperationsRuntime.Chunk079();
    PushSummaries.PushTwo(st,11,168);
    var s1: ExecutingState := EVM.Execute(st);
    OperationsCodeFacts.Destination2984(s1.evm.code);
    InstructionSteps.JumpIfStep(s1);
    var s2: ExecutingState := EVM.Execute(s1);
    states := [st];
    ExecutionTraceProof.Append(states,s1); states := states+[s1];
    ExecutionTraceProof.Append(states,s2); states := states+[s2];
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
    var sum := Sum(st,a,b);
    var flag := OverflowFlag(sum[4],a,b);
    ExecutionTraceProof.Join(sum,flag);
    var prefix := sum+flag[1..];
    var branch := Branch(flag[4],a,b);
    ExecutionTraceProof.Join(prefix,branch);
    states := prefix+branch[1..];
  }
}

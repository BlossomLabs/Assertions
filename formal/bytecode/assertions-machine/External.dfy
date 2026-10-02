// SPDX-License-Identifier: MIT
// Assertions frame extension. Observations must describe the actual EVM world.
include "Bytes.dfy"
include "../external-calls/Machine.dfy"
module AssertionsExternalMachine {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeExternalMachine
  import B = AssertionsByteMachine
  import A = AssertionsSignedMachine
  type Byte = S.Byte
  type Word = S.Word
  type Frame = E.Frame
  datatype Observation = External(observation: E.Observation)
                       | Balance(account: Word, amount: Word)
                       | Keccak(input: seq<Byte>, digest: Word)
  function Project(observations: seq<Observation>): seq<E.Observation> {
    seq(|observations|,i requires 0 <= i < |observations| =>
      if observations[i].External? then observations[i].observation else E.Gas(0))
  }
  function HashInput(memory: seq<Byte>, offset: Word, length: Word): seq<Byte> {
    if length == 0 then [] else
    G.Grow(memory,(offset as nat)+length)[offset..(offset as nat)+length]
  }
  predicate HashFits(memory: seq<Byte>, offset: Word, length: Word) {
    |memory| < G.Modulus() && (length == 0 || S.Round32((offset as nat)+length) < G.Modulus())
  }
  function HashMemory(memory: seq<Byte>, offset: Word, length: Word): seq<Byte> {
    if length == 0 then memory else S.Expand(memory,(offset as nat)+length)
  }
  opaque function Step(code: seq<Byte>, destinations: set<nat>, frame: Frame,
                       self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>): Frame {
    var state := frame.state;
    if !state.Running? then frame
    else if state.pc >= |code| then E.Frame(S.Returned([]),frame.returned,frame.cursor)
    else var op := code[state.pc];
         var stack := state.stack;
         var n := |stack|;
         var cursor := frame.cursor;
         if n > 1024 then E.Frame(S.Bad,frame.returned,cursor)
         else if op == 0 then E.Frame(S.Returned([]),frame.returned,cursor)
         else if op in B.Opcodes()+A.Opcodes() then
           E.Frame(B.Step(code,destinations,state,value,data),frame.returned,cursor)
         else if op == 0x38 && n < 1024 && |code| < G.Modulus() then
           E.Frame(S.Running(state.pc+1,stack+[|code|],state.memory),frame.returned,cursor)
         else if op == 0x31 && n >= 1 && cursor < |observations| && observations[cursor].Balance? &&
                 observations[cursor].account == E.Address(stack[n-1]) then
           E.Frame(S.Running(state.pc+1,stack[..n-1]+[observations[cursor].amount],state.memory),frame.returned,cursor+1)
         else if op == 0x20 && n >= 2 && cursor < |observations| && observations[cursor].Keccak? &&
                 HashFits(state.memory,stack[n-1],stack[n-2]) &&
                 observations[cursor].input == HashInput(state.memory,stack[n-1],stack[n-2]) then
           E.Frame(S.Running(state.pc+1,stack[..n-2]+[observations[cursor].digest],
                             HashMemory(state.memory,stack[n-1],stack[n-2])),frame.returned,cursor+1)
         else if op in {0x31,0x20,0x38} then E.Frame(S.Bad,frame.returned,cursor)
         else if op in {0x5a,0x3b,0xfa} && (cursor >= |observations| || !observations[cursor].External?) then
           E.Frame(S.Bad,frame.returned,cursor)
         else E.Step(code,destinations,frame,self,value,data,Project(observations))
  }
  lemma BalanceStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, memory: seq<Byte>,
                    account: Word, amount: Word, returned: seq<Byte>, cursor: nat,
                    observations: seq<Observation>, self: Word, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x31 && |prefix| <= 1023
    requires cursor < |observations| && observations[cursor] == Balance(E.Address(account),amount)
    ensures Step(code,{},E.Frame(S.Running(pc,prefix+[account],memory),returned,cursor),
                 self,value,data,observations) ==
            E.Frame(S.Running(pc+1,prefix+[amount],memory),returned,cursor+1)
  { reveal Step(); }
  lemma HashStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, memory: seq<Byte>,
                 offset: Word, length: Word, digest: Word, returned: seq<Byte>, cursor: nat,
                 observations: seq<Observation>, self: Word, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x20 && |prefix| <= 1022
    requires HashFits(memory,offset,length)
    requires cursor < |observations| && observations[cursor] == Keccak(HashInput(memory,offset,length),digest)
    ensures Step(code,{},E.Frame(S.Running(pc,prefix+[length,offset],memory),returned,cursor),
                 self,value,data,observations) ==
            E.Frame(S.Running(pc+1,prefix+[digest],HashMemory(memory,offset,length)),returned,cursor+1)
  { reveal Step(); }
  lemma CodeSizeStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, memory: seq<Byte>,
                     returned: seq<Byte>, cursor: nat, observations: seq<Observation>,
                     self: Word, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x38 && |prefix| < 1024 && |code| < G.Modulus()
    ensures Step(code,{},E.Frame(S.Running(pc,prefix,memory),returned,cursor),
                 self,value,data,observations) ==
            E.Frame(S.Running(pc+1,prefix+[|code|],memory),returned,cursor)
  { reveal Step(); }
  lemma ArithmeticStep(code: seq<Byte>, destinations: set<nat>, frame: Frame,
                       self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>)
    requires frame.state.Running? && frame.state.pc < |code| && |frame.state.stack| <= 1024
    requires code[frame.state.pc] in B.Opcodes()+A.Opcodes()
    ensures Step(code,destinations,frame,self,value,data,observations) ==
            E.Frame(B.Step(code,destinations,frame.state,value,data),frame.returned,frame.cursor)
  { reveal Step(); }
  lemma Delegate(code: seq<Byte>, destinations: set<nat>, frame: Frame,
                 self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>)
    requires frame.state.Running? && frame.state.pc < |code| && |frame.state.stack| <= 1024
    requires code[frame.state.pc] !in B.Opcodes()+A.Opcodes()+{0,0x31,0x20,0x38}
    requires code[frame.state.pc] in {0x5a,0x3b,0xfa} ==>
               frame.cursor < |observations| && observations[frame.cursor].External?
    ensures Step(code,destinations,frame,self,value,data,observations) ==
            E.Step(code,destinations,frame,self,value,data,Project(observations))
  { reveal Step(); }
  lemma ExternalProjection(observations: seq<E.Observation>)
    ensures Project(seq(|observations|,i requires 0 <= i < |observations| => External(observations[i]))) == observations
  {
    forall i | 0 <= i < |observations|
      ensures Project(seq(|observations|,j requires 0 <= j < |observations| => External(observations[j])))[i] == observations[i]
    {}
  }
}

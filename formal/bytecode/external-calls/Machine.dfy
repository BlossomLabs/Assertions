// SPDX-License-Identifier: MIT
// Reached STATICCALL/GAS/EXTCODESIZE/ADDRESS and caller-local returndata extension.
include "Memory.dfy"
include "../copy/Machine.dfy"
module BytecodeExternalMachine {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMachine
  import M = BytecodeExternalMemory
  type Byte = S.Byte
  type Word = S.Word
  // These observations describe actual execution, including caller identity and
  // requested gas. They do not promise which gas amount reaches the child.
  datatype Observation = Gas(available: Word)
                       | CodeSize(account: Word, size: Word)
                       | StaticCall(caller: Word, requestedGas: Word, target: Word, input: seq<Byte>, success: bool, returned: seq<Byte>)
  datatype Frame = Frame(state: S.State, returned: seq<Byte>, cursor: nat)
  function Address(word: Word): Word { word%0x10000000000000000000000000000000000000000 }
  predicate Context(self: Word) { self < 0x10000000000000000000000000000000000000000 }
  function Opcodes(): set<nat> { {0x30,0x3b,0x3d,0x3e,0x5a,0xfa} }
  opaque function Step(code: seq<Byte>, destinations: set<nat>, frame: Frame, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>): Frame {
    var state := frame.state;
    if !state.Running? || state.pc >= |code| then Frame(C.Step(code,destinations,state,value,data),frame.returned,frame.cursor)
    else var ins := S.Fetch(code,state.pc);
         var stack := state.stack;
         var n := |stack|;
         var mem := state.memory;
         var cursor := frame.cursor;
         if ins.op !in Opcodes() then Frame(C.Step(code,destinations,state,value,data),frame.returned,cursor)
         else if !Context(self) || n > 1024 then Frame(S.Bad,frame.returned,cursor)
         else if ins.op == 0x30 && n < 1024 then Frame(S.Running(ins.next,stack+[self],mem),frame.returned,cursor)
         else if ins.op == 0x3d && n < 1024 && |frame.returned| < G.Modulus() then Frame(S.Running(ins.next,stack+[|frame.returned|],mem),frame.returned,cursor)
         else if ins.op == 0x3e && n >= 3 then
           if (stack[n-2] as nat)+stack[n-3] > |frame.returned| || !C.Fits(mem,stack[n-1],stack[n-2],stack[n-3],false) then Frame(S.Bad,frame.returned,cursor)
           else Frame(S.Running(ins.next,stack[..n-3],M.ReturnCopy(mem,stack[n-1],stack[n-2],stack[n-3],frame.returned)),frame.returned,cursor)
         else if ins.op == 0x5a && n < 1024 && cursor < |observations| && observations[cursor].Gas? then
           Frame(S.Running(ins.next,stack+[observations[cursor].available],mem),frame.returned,cursor+1)
         else if ins.op == 0x3b && n >= 1 && cursor < |observations| && observations[cursor].CodeSize? && observations[cursor].account == Address(stack[n-1]) then
           Frame(S.Running(ins.next,stack[..n-1]+[observations[cursor].size],mem),frame.returned,cursor+1)
         else if ins.op == 0xfa && n >= 6 && cursor < |observations| && observations[cursor].StaticCall? then
           var call := observations[cursor];
           if call.caller != self || call.requestedGas != stack[n-1] || call.target != Address(stack[n-2]) || call.input != M.Input(mem,stack[n-3],stack[n-4]) || |call.returned| >= G.Modulus() || !M.Fits(mem,stack[n-3],stack[n-4],stack[n-5],stack[n-6]) then Frame(S.Bad,frame.returned,cursor)
           else Frame(S.Running(ins.next,stack[..n-6]+[if call.success then 1 else 0],M.Output(mem,stack[n-3],stack[n-4],stack[n-5],stack[n-6],call.returned)),call.returned,cursor+1)
         else Frame(S.Bad,frame.returned,cursor)
  }
  lemma Delegate(code: seq<Byte>, destinations: set<nat>, frame: Frame, self: Word, value: Word, data: seq<Byte>, observations: seq<Observation>)
    requires !frame.state.Running? || frame.state.pc >= |code| || S.Fetch(code,frame.state.pc).op !in Opcodes()
    ensures Step(code,destinations,frame,self,value,data,observations) == Frame(C.Step(code,destinations,frame.state,value,data),frame.returned,frame.cursor)
  { reveal Step(); }
  lemma StaticStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, mem: seq<Byte>, self: Word, gas: Word, target: Word, inputOffset: Word, inputSize: Word, outputOffset: Word, outputSize: Word, oldReturn: seq<Byte>, returned: seq<Byte>, success: bool, cursor: nat, observations: seq<Observation>, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0xfa && Context(self) && |prefix| <= 1018
    requires M.Fits(mem,inputOffset,inputSize,outputOffset,outputSize) && |returned| < G.Modulus()
    requires cursor < |observations| && observations[cursor] == StaticCall(self,gas,Address(target),M.Input(mem,inputOffset,inputSize),success,returned)
    ensures Step(code,{},Frame(S.Running(pc,prefix+[outputSize,outputOffset,inputSize,inputOffset,target,gas],mem),oldReturn,cursor),self,value,data,observations) == Frame(S.Running(pc+1,prefix+[if success then 1 else 0],M.Output(mem,inputOffset,inputSize,outputOffset,outputSize,returned)),returned,cursor+1)
  { reveal Step(); }
  lemma ReturnSizeStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, mem: seq<Byte>, self: Word, returned: seq<Byte>, cursor: nat, observations: seq<Observation>, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x3d && Context(self) && |prefix| < 1024 && |returned| < G.Modulus()
    ensures Step(code,{},Frame(S.Running(pc,prefix,mem),returned,cursor),self,value,data,observations) == Frame(S.Running(pc+1,prefix+[|returned|],mem),returned,cursor)
  { reveal Step(); }
  lemma ReturnCopyStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, mem: seq<Byte>, self: Word, destination: Word, source: Word, size: Word, returned: seq<Byte>, cursor: nat, observations: seq<Observation>, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x3e && Context(self) && |prefix| <= 1021
    requires (source as nat)+size <= |returned| && C.Fits(mem,destination,source,size,false)
    ensures Step(code,{},Frame(S.Running(pc,prefix+[size,source,destination],mem),returned,cursor),self,value,data,observations) == Frame(S.Running(pc+1,prefix,M.ReturnCopy(mem,destination,source,size,returned)),returned,cursor)
  { reveal Step(); }
  lemma ReturnCopyBounds(code: seq<Byte>, pc: nat, prefix: seq<Word>, mem: seq<Byte>, self: Word, destination: Word, source: Word, size: Word, returned: seq<Byte>, cursor: nat, observations: seq<Observation>, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x3e && Context(self) && |prefix| <= 1021
    requires (source as nat)+size > |returned|
    ensures Step(code,{},Frame(S.Running(pc,prefix+[size,source,destination],mem),returned,cursor),self,value,data,observations).state == S.Bad
  { reveal Step(); }
  lemma AddressStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, mem: seq<Byte>, self: Word, returned: seq<Byte>, cursor: nat, observations: seq<Observation>, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x30 && Context(self) && |prefix| < 1024
    ensures Step(code,{},Frame(S.Running(pc,prefix,mem),returned,cursor),self,value,data,observations) == Frame(S.Running(pc+1,prefix+[self],mem),returned,cursor)
  { reveal Step(); }
  lemma GasStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, mem: seq<Byte>, self: Word, returned: seq<Byte>, cursor: nat, observations: seq<Observation>, available: Word, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x5a && Context(self) && |prefix| < 1024
    requires cursor < |observations| && observations[cursor] == Gas(available)
    ensures Step(code,{},Frame(S.Running(pc,prefix,mem),returned,cursor),self,value,data,observations) == Frame(S.Running(pc+1,prefix+[available],mem),returned,cursor+1)
  { reveal Step(); }
  lemma CodeSizeStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, mem: seq<Byte>, self: Word, target: Word, size: Word, returned: seq<Byte>, cursor: nat, observations: seq<Observation>, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x3b && Context(self) && |prefix| < 1024
    requires cursor < |observations| && observations[cursor] == CodeSize(Address(target),size)
    ensures Step(code,{},Frame(S.Running(pc,prefix+[target],mem),returned,cursor),self,value,data,observations) == Frame(S.Running(pc+1,prefix+[size],mem),returned,cursor+1)
  { reveal Step(); }
  lemma MaskedAddress(word: Word)
    ensures Context(Address(word)) && Address(Address(word)) == Address(word)
  {}
}

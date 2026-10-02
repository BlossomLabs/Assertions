// SPDX-License-Identifier: MIT
// Local SIGNEXTEND extension, delegating all other existing BYTE/copy/scan opcodes.
include "Mathematics.dfy"
module BytecodeCollectionsArrayWordMachine {
  import opened BytecodeScanMachine
  import B = BytecodeCollectionsArrayByteMachine
  import M = BytecodeCollectionsArrayWordMathematics
  opaque function Step(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State {
    if !state.Running? || state.pc >= |code| || Fetch(code,state.pc).op != 0x0b then B.Step(code,destinations,state,value,data)
    else var ins := Fetch(code,state.pc);var stack := state.stack;var n := |stack|;
                                                                  if n < 2 then Bad else Running(ins.next,stack[..n-2]+[M.SignExtend(stack[n-1],stack[n-2])],state.memory)
  }
  lemma Delegate(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>)
    requires !state.Running? || state.pc >= |code| || Fetch(code,state.pc).op != 0x0b
    ensures Step(code,destinations,state,value,data) == B.Step(code,destinations,state,value,data)
  { reveal Step(); }
  lemma SignStep(code: seq<Byte>,pc: nat,prefix: seq<Word>,word: Word,index: Word,mem: seq<Byte>,value: Word,data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x0b
    ensures Step(code,{},Running(pc,prefix+[word,index],mem),value,data) == Running(pc+1,prefix+[M.SignExtend(index,word)],mem)
  { reveal Step(); }
}

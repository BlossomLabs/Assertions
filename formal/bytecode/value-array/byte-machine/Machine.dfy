// SPDX-License-Identifier: MIT
// Local BYTE extension: all existing checked scan/copy behavior is delegated unchanged.
include "../../copy/Execution.dfy"
module BytecodeCollectionsArrayByteMachine {
  import opened BytecodeScanMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMachine
  function ByteWord(index: Word,word: Word): Word
    ensures ByteWord(index,word) < 256
  { if index >= 32 then 0 else (word/G.Pow256(31-index))%256 }
  opaque function Step(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State {
    if !state.Running? || state.pc >= |code| || Fetch(code,state.pc).op != 0x1a then C.Step(code,destinations,state,value,data)
    else var ins := Fetch(code,state.pc); var stack := state.stack; var n := |stack|;
                                                                    if n < 2 then Bad else Running(ins.next,stack[..n-2]+[ByteWord(stack[n-1],stack[n-2])],state.memory)
  }
  lemma Delegate(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>)
    requires !state.Running? || state.pc >= |code| || Fetch(code,state.pc).op != 0x1a
    ensures Step(code,destinations,state,value,data) == C.Step(code,destinations,state,value,data)
  { reveal Step(); }
  lemma ByteStep(code: seq<Byte>,pc: nat,prefix: seq<Word>,word: Word,index: Word,mem: seq<Byte>,value: Word,data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x1a
    ensures Step(code,{},Running(pc,prefix+[word,index],mem),value,data) == Running(pc+1,prefix+[ByteWord(index,word)],mem)
  { reveal Step(); }
}

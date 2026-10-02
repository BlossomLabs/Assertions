// SPDX-License-Identifier: MIT
// Control/stack projection of the opcodes reached by the canonical dispatchers.
// Sufficient instruction resources and the actual initial MSTORE are premises.
module OperationsRawDispatchMachine {
  type Byte = x: nat | x < 256 witness 0
  type Word = x: nat | x < 0x10000000000000000000000000000000000000000000000000000000000000000 witness 0
  datatype State = Running(pc: nat, stack: seq<Word>, initialized: bool)
                 | Chosen(entryPc: nat, remaining: seq<Word>, freePointer: bool)
                 | Rejected | Bad
  datatype Instruction = Op(op: nat, next: nat, immediate: Word)

  function Selector(word: Word): Word {
    word / 0x100000000000000000000000000000000000000000000000000000000
  }

  lemma SelectorBound(word: Word)
    ensures Selector(word) < 0x100000000
  {}

  function Fetch(code: seq<Byte>, pc: nat): Instruction
    requires pc < |code|
  {
    var op := code[pc];
    if op == 0x5f then Op(op,pc+1,0)
    else if op == 0x60 && pc+1 < |code| then Op(op,pc+2,(code[pc+1] as nat))
    else if op == 0x61 && pc+2 < |code| then Op(op,pc+3,(code[pc+1] as nat)*256+(code[pc+2] as nat))
    else if op == 0x62 && pc+3 < |code| then Op(op,pc+4,((code[pc+1] as nat)*256+(code[pc+2] as nat))*256+(code[pc+3] as nat))
    else if op == 0x63 && pc+4 < |code| then Op(op,pc+5,(((code[pc+1] as nat)*256+(code[pc+2] as nat))*256+(code[pc+3] as nat))*256+(code[pc+4] as nat))
    else Op(op,pc+1,0)
  }

  function Step(code: seq<Byte>, destinations: set<nat>, entries: set<nat>,
                state: State, value: Word, size: Word, word: Word): State {
    if !state.Running? then state
    else if state.pc in entries then
      if state.pc < |code| && code[state.pc] == 0x5b && state.pc in destinations
      then Chosen(state.pc,state.stack,state.initialized) else Bad
    else if state.pc >= |code| then Bad
    else
      var ins := Fetch(code,state.pc);
      var s := state.stack;
      var n := |s|;
      var init := state.initialized;
      if ins.op in {0x5f,0x60,0x61,0x62,0x63} then Running(ins.next,s+[ins.immediate],init)
      else if ins.op == 0x5b then Running(ins.next,s,init)
      else if ins.op == 0x34 then Running(ins.next,s+[value],init)
      else if ins.op == 0x36 then Running(ins.next,s+[size],init)
      else if ins.op == 0x80 && n >= 1 then Running(ins.next,s+[s[n-1]],init)
      else if ins.op == 0x50 && n >= 1 then Running(ins.next,s[..n-1],init)
      else if ins.op == 0x15 && n >= 1 then Running(ins.next,s[..n-1]+[if s[n-1] == 0 then 1 else 0],init)
      else if ins.op == 0x35 && n >= 1 && s[n-1] == 0 then Running(ins.next,s[..n-1]+[word],init)
      else if ins.op == 0x1c && n >= 2 && s[n-1] == 224 then Running(ins.next,s[..n-2]+[Selector(s[n-2])],init)
      else if ins.op in {0x10,0x11,0x14} && n >= 2 then
        var truth := if ins.op == 0x10 then s[n-1] < s[n-2]
                     else if ins.op == 0x11 then s[n-1] > s[n-2]
                     else s[n-1] == s[n-2];
        Running(ins.next,s[..n-2]+[if truth then 1 else 0],init)
      else if ins.op == 0x52 && n >= 2 && s[n-1] == 64 && s[n-2] == 128 then Running(ins.next,s[..n-2],true)
      else if ins.op == 0x57 && n >= 2 then
        if s[n-2] == 0 then Running(ins.next,s[..n-2],init)
        else if s[n-1] in destinations && s[n-1] < |code| && code[s[n-1]] == 0x5b then Running(s[n-1],s[..n-2],init)
        else Bad
      else if ins.op == 0xfd && n >= 2 && s[n-1] == 0 && s[n-2] == 0 then Rejected
      else Bad
  }
}

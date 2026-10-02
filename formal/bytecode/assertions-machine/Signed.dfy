// SPDX-License-Identifier: MIT
// Additional reached arithmetic opcodes for Assertions; existing models unchanged.
include "../scans/Machine.dfy"
module AssertionsSignedMachine {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  type Word = S.Word
  type Byte = S.Byte
  type State = S.State
  function Opcodes(): set<nat> { {0x13} }
  opaque function Step(code: seq<Byte>, destinations: set<nat>, state: State,
                       value: Word, data: seq<Byte>): State {
    if !state.Running? || state.pc >= |code| || S.Fetch(code,state.pc).op !in Opcodes()
    then S.Step(code,destinations,state,value,data)
    else var stack := state.stack;
         var n := |stack|;
         if n < 2 then S.Bad
         else S.Running(state.pc+1,stack[..n-2]+[
                          if G.Signed(stack[n-1]) > G.Signed(stack[n-2]) then 1 else 0],state.memory)
  }
  lemma Delegate(code: seq<Byte>, destinations: set<nat>, state: State,
                 value: Word, data: seq<Byte>)
    requires !state.Running? || state.pc >= |code| || S.Fetch(code,state.pc).op !in Opcodes()
    ensures Step(code,destinations,state,value,data) == S.Step(code,destinations,state,value,data)
  { reveal Step(); }
  lemma SignedGreater(code: seq<Byte>, pc: nat, prefix: seq<Word>, memory: seq<Byte>,
                      lower: Word, upper: Word, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x13 && |prefix| <= 1022
    ensures Step(code,{},S.Running(pc,prefix+[lower,upper],memory),value,data) ==
            S.Running(pc+1,prefix+[if G.Signed(upper) > G.Signed(lower) then 1 else 0],memory)
  { reveal Step(); }
  lemma ReversedComparison(lower: Word, upper: Word)
    ensures (G.Signed(upper) > G.Signed(lower)) == (G.Signed(lower) < G.Signed(upper))
  {}
}

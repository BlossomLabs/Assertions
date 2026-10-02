// SPDX-License-Identifier: MIT
// BYTE and SIGNEXTEND preserve the shared physical stack/memory representation.
include "Signed.dfy"
module AssertionsByteMachine {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import A = AssertionsSignedMachine
  type Word = S.Word
  type Byte = S.Byte
  type State = S.State
  function ByteAt(index: Word, value: Word): Word {
    if index >= 32 then 0 else G.Encode(value,32)[index]
  }
  function SignExtend(index: Word, value: Word): Word {
    if index >= 32 then value
    else var modulus := G.Pow256(index+1);
         var low := value%modulus;
         (if low < modulus/2 then low else low+G.Modulus()-modulus)%G.Modulus()
  }
  function Opcodes(): set<nat> { {0x0b,0x1a} }
  opaque function Step(code: seq<Byte>, destinations: set<nat>, state: State,
                       value: Word, data: seq<Byte>): State {
    if !state.Running? || state.pc >= |code| || S.Fetch(code,state.pc).op !in Opcodes()
    then A.Step(code,destinations,state,value,data)
    else var stack := state.stack;
         var n := |stack|;
         if n < 2 then S.Bad
         else S.Running(state.pc+1,stack[..n-2]+[
                          if code[state.pc] == 0x0b then SignExtend(stack[n-1],stack[n-2])
                          else ByteAt(stack[n-1],stack[n-2])],state.memory)
  }
  lemma Delegate(code: seq<Byte>, destinations: set<nat>, state: State,
                 value: Word, data: seq<Byte>)
    requires !state.Running? || state.pc >= |code| || S.Fetch(code,state.pc).op !in Opcodes()
    ensures Step(code,destinations,state,value,data) == A.Step(code,destinations,state,value,data)
  { reveal Step(); }
  lemma ByteStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, memory: seq<Byte>,
                 index: Word, input: Word, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x1a && |prefix| <= 1022
    ensures Step(code,{},S.Running(pc,prefix+[input,index],memory),value,data) ==
            S.Running(pc+1,prefix+[ByteAt(index,input)],memory)
  { reveal Step(); }
  lemma ExtendStep(code: seq<Byte>, pc: nat, prefix: seq<Word>, memory: seq<Byte>,
                   index: Word, input: Word, value: Word, data: seq<Byte>)
    requires pc < |code| && code[pc] == 0x0b && |prefix| <= 1022
    ensures Step(code,{},S.Running(pc,prefix+[input,index],memory),value,data) ==
            S.Running(pc+1,prefix+[SignExtend(index,input)],memory)
  { reveal Step(); }
  lemma PowerMonotone(n: nat, m: nat)
    requires n <= m
    ensures G.Pow256(n) <= G.Pow256(m)
    decreases m
  {
    if n == 0 {
      if m > 0 { PowerMonotone(0,m-1); }
    } else {
      PowerMonotone(n-1,m-1);
    }
  }
  lemma ByteRange(index: Word, input: Word)
    ensures ByteAt(index,input) < 256
  {}
  lemma WideExtension(index: Word, input: Word)
    requires index >= 31
    ensures SignExtend(index,input) == input
  {
    if index == 31 { G.WordPower(); }
  }
  lemma SignedExtension(index: Word, input: Word)
    requires index < 32
    ensures G.Signed(SignExtend(index,input)) ==
            (if input%G.Pow256(index+1) < G.Pow256(index+1)/2
             then input%G.Pow256(index+1) else input%G.Pow256(index+1)-G.Pow256(index+1))
  {
    G.WordPower();
    PowerMonotone(index+1,32);
    var modulus := G.Pow256(index+1);
    var low := input%modulus;
    assert modulus <= G.Modulus();
    if low < modulus/2 {
      assert low < G.Modulus()/2;
    } else {
      assert low+G.Modulus()-modulus < G.Modulus();
      assert low+G.Modulus()-modulus >= G.Modulus()/2;
    }
  }
}

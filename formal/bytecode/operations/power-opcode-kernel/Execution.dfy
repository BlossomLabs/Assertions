// SPDX-License-Identifier: MIT
// Reviewed EXP extension to the immutable reached-opcode machine. Native
// checking, raw entry connections and complete retained closure remain open.
include "../signed-multiply-repair-v2/Machine.dfy"
include "../power-kernel/Bounds.generated.dfy"
module OperationsPowerExecution {
  import M = OperationsSignedMultiplyMachine
  import K = OperationsPowerWordKernel
  import P = OperationsCheckedPowerModel
  opaque function Execute(code:seq<M.Byte>,destinations:set<nat>,state:M.State,
                          value:M.Word,size:M.Word,word:M.Word,a:M.Word,b:M.Word):M.State
  {
    if !state.Running? || state.pc>=|code| || M.Fetch(code,state.pc).op!=0x0a
    then M.Step(code,destinations,state,value,size,word,a,b)
    else
      var ins:=M.Fetch(code,state.pc);var stack:=state.stack;var count:=|stack|;
                                                             if count<2 then M.Bad
                                                             else M.Running(ins.next,stack[..count-2]+[K.PowWord(stack[count-1],stack[count-2])],state.memory)
  }
  lemma Ordinary(code:seq<M.Byte>,destinations:set<nat>,state:M.State,
                 value:M.Word,size:M.Word,word:M.Word,a:M.Word,b:M.Word)
    requires !state.Running? || state.pc>=|code| || M.Fetch(code,state.pc).op!=0x0a
    ensures Execute(code,destinations,state,value,size,word,a,b)==M.Step(code,destinations,state,value,size,word,a,b)
  { reveal Execute(); }
  lemma ExpInstruction(code:seq<M.Byte>,destinations:set<nat>,pc:nat,stack:seq<M.Word>,memory:seq<M.Byte>,
                       value:M.Word,size:M.Word,word:M.Word,a:M.Word,b:M.Word)
    requires pc<|code| && M.Fetch(code,pc).op==0x0a && |stack|>=2
    ensures Execute(code,destinations,M.Running(pc,stack,memory),value,size,word,a,b)==
            M.Running(M.Fetch(code,pc).next,stack[..|stack|-2]+[P.Power(stack[|stack|-1],stack[|stack|-2])%M.Modulus()],memory)
  {
    K.PowWordMeaning(stack[|stack|-1],stack[|stack|-2]);
    reveal Execute();
  }
  lemma ExpEmpty(code:seq<M.Byte>,destinations:set<nat>,pc:nat,stack:seq<M.Word>,memory:seq<M.Byte>,
                 value:M.Word,size:M.Word,word:M.Word,a:M.Word,b:M.Word)
    requires pc<|code| && M.Fetch(code,pc).op==0x0a && |stack|<2
    ensures Execute(code,destinations,M.Running(pc,stack,memory),value,size,word,a,b)==M.Bad
  { reveal Execute(); }
}

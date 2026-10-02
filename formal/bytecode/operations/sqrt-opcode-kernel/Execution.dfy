// SPDX-License-Identifier: MIT
// Local reached-opcode representation: SHL is unsigned multiplication by 2^amount modulo2^256,
// and SHR is unsigned division by 2^amount. Reviewed EVM interpretation remains explicit.
// No equivalence to a different bitvector interpreter is assumed or claimed.
include "../log2-repair-v7/Machine.dfy"
module OperationsSquareRootExecution {
  import opened OperationsBytecodeLog2Machine
  opaque function Left(input: Word,amount: Word): Word {
    if amount>=256 then 0 else (input*Pow2(amount))%Modulus()
  }
  opaque function Execute(code: seq<Byte>,destinations: set<nat>,state: State,
                          value: Word,size: Word,word: Word,a: Word): State {
    if !state.Running? || state.pc>=|code| then Step(code,destinations,state,value,size,word,a,0,0)
    else var ins:=Fetch(code,state.pc); var stack:=state.stack; var n:=|stack|;
                                                                if ins.op==0x02 && n>=2 then
                                                                  Running(ins.next,stack[..n-2]+[(stack[n-1]*stack[n-2])%Modulus()],state.memory)
                                                                else if ins.op==0x1b && n>=2 then
                                                                  Running(ins.next,stack[..n-2]+[Left(stack[n-2],stack[n-1])],state.memory)
                                                                else Step(code,destinations,state,value,size,word,a,0,0)
  }
  lemma ShiftStep(code: seq<Byte>,destinations: set<nat>,pc: nat,next: nat,prefix: seq<Word>,mem: seq<Byte>,
                  input: Word,amount: Word,value: Word,size: Word,word: Word,a: Word)
    requires pc<|code| && Fetch(code,pc)==Op(0x1b,next,0) && |prefix|+2<=1024
    ensures Execute(code,destinations,Running(pc,prefix+[input,amount],mem),value,size,word,a)==
            Running(next,prefix+[Left(input,amount)],mem)
  { reveal Execute(); }
  lemma MultiplyStep(code: seq<Byte>,destinations: set<nat>,pc: nat,next: nat,prefix: seq<Word>,mem: seq<Byte>,
                     left: Word,right: Word,value: Word,size: Word,word: Word,a: Word)
    requires pc<|code| && Fetch(code,pc)==Op(0x02,next,0) && |prefix|+2<=1024
    ensures Execute(code,destinations,Running(pc,prefix+[left,right],mem),value,size,word,a)==
            Running(next,prefix+[(left*right)%Modulus()],mem)
  { reveal Execute(); }
  lemma RightStep(code: seq<Byte>,destinations: set<nat>,pc: nat,next: nat,prefix: seq<Word>,mem: seq<Byte>,
                  input: Word,amount: Word,value: Word,size: Word,word: Word,a: Word)
    requires pc<|code| && Fetch(code,pc)==Op(0x1c,next,0) && |prefix|+2<=1024
    ensures Execute(code,destinations,Running(pc,prefix+[input,amount],mem),value,size,word,a)==
            Running(next,prefix+[Right(input,amount)],mem)
  { reveal Execute(); reveal Step(); }
  lemma AddStep(code: seq<Byte>,destinations: set<nat>,pc: nat,next: nat,prefix: seq<Word>,mem: seq<Byte>,
                left: Word,right: Word,value: Word,size: Word,word: Word,a: Word)
    requires pc<|code| && Fetch(code,pc)==Op(0x01,next,0) && |prefix|+2<=1024
    ensures Execute(code,destinations,Running(pc,prefix+[left,right],mem),value,size,word,a)==
            Running(next,prefix+[(left+right)%Modulus()],mem)
  { reveal Execute(); reveal Step(); }
  lemma DivideStep(code: seq<Byte>,destinations: set<nat>,pc: nat,next: nat,prefix: seq<Word>,mem: seq<Byte>,
                   numerator: Word,denominator: Word,value: Word,size: Word,word: Word,a: Word)
    requires pc<|code| && Fetch(code,pc)==Op(0x04,next,0) && |prefix|+2<=1024
    ensures Execute(code,destinations,Running(pc,prefix+[denominator,numerator],mem),value,size,word,a)==
            Running(next,prefix+[Quotient(numerator,denominator)],mem)
  { reveal Execute(); reveal Step(); }
}

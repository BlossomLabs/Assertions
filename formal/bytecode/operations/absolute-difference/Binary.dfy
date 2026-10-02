// SPDX-License-Identifier: MIT
include "Machine.dfy"
module OperationsAbsoluteDifferenceBinaryKernel {
  import opened OperationsAbsoluteDifferenceMachine
  lemma AddStep(code: seq<Byte>, destinations: set<nat>, pc: nat, next: nat,
                prefix: seq<Word>, mem: seq<Byte>, top: Word, below: Word,
                value: Word, size: Word, word: Word, a: Word, b: Word)
    requires pc < |code| && Fetch(code,pc) == Op(0x01,next,0)
    requires |prefix| <= 1022
    ensures Step(code,destinations,Running(pc,prefix+[below,top],mem),value,size,word,a,b)
         == Running(next,prefix+[((top as nat)+(below as nat))%Modulus()],mem)
  { reveal Step(); }
  lemma SubStep(code: seq<Byte>, destinations: set<nat>, pc: nat, next: nat,
                prefix: seq<Word>, mem: seq<Byte>, top: Word, below: Word,
                value: Word, size: Word, word: Word, a: Word, b: Word)
    requires pc < |code| && Fetch(code,pc) == Op(0x03,next,0)
    requires |prefix| <= 1022
    ensures Step(code,destinations,Running(pc,prefix+[below,top],mem),value,size,word,a,b)
         == Running(next,prefix+[(top+Modulus()-below)%Modulus()],mem)
  { reveal Step(); }
}

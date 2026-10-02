// SPDX-License-Identifier: MIT
include "Machine.dfy"
module OperationsSignedModularOpcodeBinaryKernel {
  import opened OperationsSignedModularOpcodeMachine
  import C = OperationsSignedModularOpcodeWordConversion
  lemma {:autoRevealDependencies false} HalfWordShift()
    ensures Shift(1,255)==0x8000000000000000000000000000000000000000000000000000000000000000
  {
    var input:bv256:=1;
    var output:bv256:=0x8000000000000000000000000000000000000000000000000000000000000000;
    C.Inverse256(input);C.Inverse256(output);
    assert input<<255==output;
    assert (input as nat)==1;
    assert (output as nat)==0x8000000000000000000000000000000000000000000000000000000000000000;
    ShiftBridgeAt(1,255,255,input,0x8000000000000000000000000000000000000000000000000000000000000000);
  }
  lemma AddStep(code: seq<Byte>, destinations: set<nat>, pc: nat, next: nat,
                prefix: seq<Word>, mem: seq<Byte>, top: Word, below: Word,
                value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires pc < |code| && Fetch(code,pc) == Op(0x01,next,0)
    requires |prefix| <= 1022
    ensures Step(code,destinations,Running(pc,prefix+[below,top],mem),value,size,word,a,b,c)
         == Running(next,prefix+[((top as nat)+(below as nat))%Modulus()],mem)
  { reveal Step(); }
  lemma SubStep(code: seq<Byte>, destinations: set<nat>, pc: nat, next: nat,
                prefix: seq<Word>, mem: seq<Byte>, top: Word, below: Word,
                value: Word, size: Word, word: Word, a: Word, b: Word, c: Word)
    requires pc < |code| && Fetch(code,pc) == Op(0x03,next,0)
    requires |prefix| <= 1022
    ensures Step(code,destinations,Running(pc,prefix+[below,top],mem),value,size,word,a,b,c)
         == Running(next,prefix+[(top+Modulus()-below)%Modulus()],mem)
  { reveal Step(); }
}

// SPDX-License-Identifier: MIT
// Checked ordinary-opcode bridges; exact runtime and public domains unchanged.
include "Kernel.dfy"
module OperationsHashSuccessOpcodes {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import K = OperationsHashSuccessKernel

  lemma LoadHeap(code: seq<Byte>, destinations: set<nat>, data: seq<Byte>,
                 hashes: map<seq<Byte>,Word>, pc: nat, prefix: seq<Word>)
    requires |data|<0x10000000000000000 && pc<|code| && code[pc]==0x51
    ensures E.Execute(code,destinations,Running(pc,prefix+[64],K.Initial()),data,0,0,hashes)==
            Running(pc+1,prefix+[128],K.Initial())
  {
    StoreLoad([],64,128);
    assert Load(K.Initial(),64)==128;
    assert Fetch(code,pc)==Op(0x51,pc+1,0);
    reveal E.Execute(); reveal Step();
    assert (prefix+[64])[..|prefix|]==prefix;
  }

  lemma Jump(code: seq<Byte>, destinations: set<nat>, data: seq<Byte>,
             hashes: map<seq<Byte>,Word>, pc: nat, prefix: seq<Word>,
             target: Word, mem: seq<Byte>)
    requires |data|<0x10000000000000000 && pc<|code| && code[pc]==0x56
    requires target in destinations && target<|code| && code[target]==0x5b
    ensures E.Execute(code,destinations,Running(pc,prefix+[target],mem),data,0,0,hashes)==
            Running(target,prefix,mem)
  {
    assert Fetch(code,pc)==Op(0x56,pc+1,0);
    reveal E.Execute(); reveal Step();
    assert (prefix+[target])[..|prefix|]==prefix;
  }
}

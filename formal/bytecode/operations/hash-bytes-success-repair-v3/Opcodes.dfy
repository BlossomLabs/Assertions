// SPDX-License-Identifier: MIT
// Checked ordinary-opcode bridges; exact runtime and public domains unchanged.
include "Kernel.dfy"
include "State.generated.dfy"
module OperationsHashSuccessOpcodes {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import K = OperationsHashSuccessKernel
  import S = OperationsHashSuccessState

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
  lemma LoadState(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,
                  result: Word,hashes: map<seq<Byte>,Word>)
    requires S.Matches(code) && K.Observed(data,source,count,result,hashes)
    requires S.Good(5,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures S.Good(6,E.Execute(code,S.Destinations(),state,data,0,0,hashes),data,source,count,result)
  {
    reveal S.Good(); reveal S.Matches();
    var prefix: seq<Word> := [2854126814,1329,source,count,0,source,count];
    assert state==Running(7574,prefix+[64],K.Initial());
    LoadHeap(code,S.Destinations(),data,hashes,7574,prefix);
    assert E.Execute(code,S.Destinations(),state,data,0,0,hashes)==Running(7575,prefix+[128],K.Initial());
    assert prefix+[128]==[2854126814,1329,source,count,0,source,count,128];
  }

}

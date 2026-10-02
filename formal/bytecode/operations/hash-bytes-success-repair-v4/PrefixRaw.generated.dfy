// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "../hash-bytes-repair-v3/Execution.dfy"
include "Prefix.generated.dfy"
include "PrefixRawBlock0.generated.dfy"
include "PrefixRawBlock1.generated.dfy"
include "PrefixRawBlock2.generated.dfy"
include "PrefixRawBlock3.generated.dfy"
include "PrefixRawBlock4.generated.dfy"
include "PrefixRawBlock5.generated.dfy"
include "PrefixRawBlock6.generated.dfy"
include "PrefixRawBlock7.generated.dfy"
module OperationsHashRawEntryPrefix {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashSuccessPrefix
  import B0 = OperationsHashRawBlockPrefix0
  import B1 = OperationsHashRawBlockPrefix1
  import B2 = OperationsHashRawBlockPrefix2
  import B3 = OperationsHashRawBlockPrefix3
  import B4 = OperationsHashRawBlockPrefix4
  import B5 = OperationsHashRawBlockPrefix5
  import B6 = OperationsHashRawBlockPrefix6
  import B7 = OperationsHashRawBlockPrefix7
  ghost method Run(code: seq<Byte>,data: seq<Byte>,value: Word,word: Word,a: Word,b: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires |data|<0x10000000000000000 && word==E.DataWord(data,0) && a==E.DataWord(data,4) && b==E.DataWord(data,(a as nat)+4)
    requires R.Matches(code) && R.Admitted(value,|data|,word,a,b)
    ensures state==Running(7568,[2854126814,1329,(a as nat)+36,b],Store([],64,128))
  {
    R.Start(value,|data|,word,a,b); state:=Running(0,[],[]);
    state:=B0.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B1.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B2.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B3.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B4.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B5.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B6.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B7.RunBlock(code,state,data,value,word,a,b,hashes);
    R.Frontier(state,value,|data|,word,a,b);
  }
}

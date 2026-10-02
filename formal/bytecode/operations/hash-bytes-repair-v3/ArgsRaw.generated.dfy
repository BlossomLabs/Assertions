// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "Execution.dfy"
include "Args.generated.dfy"
include "ArgsRawBlock0.generated.dfy"
include "ArgsRawBlock1.generated.dfy"
include "ArgsRawBlock2.generated.dfy"
include "ArgsRawBlock3.generated.dfy"
module OperationsHashRawEntryArgs {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashBytesArgs
  import B0 = OperationsHashRawBlockArgs0
  import B1 = OperationsHashRawBlockArgs1
  import B2 = OperationsHashRawBlockArgs2
  import B3 = OperationsHashRawBlockArgs3
  ghost method Run(code: seq<Byte>,data: seq<Byte>,value: Word,word: Word,a: Word,b: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires |data|<0x10000000000000000 && word==E.DataWord(data,0) && a==E.DataWord(data,4) && b==E.DataWord(data,(a as nat)+4)
    requires R.Matches(code) && R.Admitted(value,|data|,word,a,b)
    ensures state==Reverted([])
  {
    R.Start(value,|data|,word,a,b); state:=Running(0,[],[]);
    state:=B0.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B1.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B2.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B3.RunBlock(code,state,data,value,word,a,b,hashes);
  }
}

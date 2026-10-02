// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "Execution.dfy"
include "PayloadWindow.generated.dfy"
include "PayloadWindowRawBlock0.generated.dfy"
include "PayloadWindowRawBlock1.generated.dfy"
include "PayloadWindowRawBlock2.generated.dfy"
include "PayloadWindowRawBlock3.generated.dfy"
include "PayloadWindowRawBlock4.generated.dfy"
include "PayloadWindowRawBlock5.generated.dfy"
include "PayloadWindowRawBlock6.generated.dfy"
module OperationsHashRawEntryPayloadWindow {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashBytesPayloadWindow
  import B0 = OperationsHashRawBlockPayloadWindow0
  import B1 = OperationsHashRawBlockPayloadWindow1
  import B2 = OperationsHashRawBlockPayloadWindow2
  import B3 = OperationsHashRawBlockPayloadWindow3
  import B4 = OperationsHashRawBlockPayloadWindow4
  import B5 = OperationsHashRawBlockPayloadWindow5
  import B6 = OperationsHashRawBlockPayloadWindow6
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
    state:=B4.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B5.RunBlock(code,state,data,value,word,a,b,hashes);
    state:=B6.RunBlock(code,state,data,value,word,a,b,hashes);
  }
}

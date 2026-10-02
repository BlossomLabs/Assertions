// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "Execution.dfy"
include "OffsetBound.generated.dfy"
include "OffsetBoundRawBlock0.generated.dfy"
include "OffsetBoundRawBlock1.generated.dfy"
include "OffsetBoundRawBlock2.generated.dfy"
include "OffsetBoundRawBlock3.generated.dfy"
include "OffsetBoundRawBlock4.generated.dfy"
module OperationsHashRawEntryOffsetBound {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashBytesOffsetBound
  import B0 = OperationsHashRawBlockOffsetBound0
  import B1 = OperationsHashRawBlockOffsetBound1
  import B2 = OperationsHashRawBlockOffsetBound2
  import B3 = OperationsHashRawBlockOffsetBound3
  import B4 = OperationsHashRawBlockOffsetBound4
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
  }
}

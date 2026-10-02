// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "Execution.dfy"
include "LengthBound.generated.dfy"
include "LengthBoundRawBlock0.generated.dfy"
include "LengthBoundRawBlock1.generated.dfy"
include "LengthBoundRawBlock2.generated.dfy"
include "LengthBoundRawBlock3.generated.dfy"
include "LengthBoundRawBlock4.generated.dfy"
include "LengthBoundRawBlock5.generated.dfy"
module OperationsHashRawEntryLengthBound {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashBytesLengthBound
  import B0 = OperationsHashRawBlockLengthBound0
  import B1 = OperationsHashRawBlockLengthBound1
  import B2 = OperationsHashRawBlockLengthBound2
  import B3 = OperationsHashRawBlockLengthBound3
  import B4 = OperationsHashRawBlockLengthBound4
  import B5 = OperationsHashRawBlockLengthBound5
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
  }
}

// SPDX-License-Identifier: MIT
// Generated actual calldata trace lift. Never edit directly.
include "Execution.dfy"
include "Nonzero.generated.dfy"
include "NonzeroRawBlock0.generated.dfy"
module OperationsHashRawEntryNonzero {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import R = OperationsHashBytesNonzero
  import B0 = OperationsHashRawBlockNonzero0
  ghost method Run(code: seq<Byte>,data: seq<Byte>,value: Word,word: Word,a: Word,b: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires |data|<0x10000000000000000 && word==E.DataWord(data,0) && a==E.DataWord(data,4) && b==E.DataWord(data,(a as nat)+4)
    requires R.Matches(code) && R.Admitted(value,|data|,word,a,b)
    ensures state==Reverted([])
  {
    R.Start(value,|data|,word,a,b); state:=Running(0,[],[]);
    state:=B0.RunBlock(code,state,data,value,word,a,b,hashes);
  }
}

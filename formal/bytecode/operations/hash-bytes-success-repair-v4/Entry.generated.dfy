// SPDX-License-Identifier: MIT
// Generated complete exact successful hash body; never edit directly.
include "Kernel.dfy"
include "State.generated.dfy"
include "Block0.generated.dfy"
include "Block1.generated.dfy"
include "Block2.generated.dfy"
module OperationsHashSuccessEntry {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import K = OperationsHashSuccessKernel
  import opened OperationsHashSuccessState
  import B0 = OperationsHashSuccessBlock0
  import B1 = OperationsHashSuccessBlock1
  import B2 = OperationsHashSuccessBlock2
  lemma SemanticResult(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(47,state,data,source,count,result)
    ensures state.Running? && |state.stack|>=2 && state.stack[|state.stack|-1]==128
    ensures state.stack[|state.stack|-2]==result
  { reveal Good(); }
  lemma SemanticWitness(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(47,state,data,source,count,result)
    requires count==2 && result==0xbc07f95faa953d0c799ffc75a8afda081bafda1396ac3ec9ba52784dccf67316
    requires data[source..(source as nat)+(count as nat)]==[165,165]
    ensures state.Running? && |state.stack|>=2 && state.stack[|state.stack|-1]==128
    ensures state.stack[|state.stack|-2]==result
  { reveal Good(); }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>,initial: State) returns(state: State)
    requires Matches(code) && K.Observed(data,source,count,result,hashes)
    requires initial==Running(7568,[2854126814,1329,source,count],K.Initial())
    ensures state==Returned(Encode(result,32))
  {
    reveal Good(); state:=initial;
    assert Good(0,state,data,source,count,result);
    state:=B0.RunBlock(code,state,data,source,count,result,hashes);
    state:=B1.RunBlock(code,state,data,source,count,result,hashes);
    state:=B2.RunBlock(code,state,data,source,count,result,hashes);
  }
}

// SPDX-License-Identifier: MIT
// Finite arbitrary successful nonstopping prefix followed by the first reached callback failure.
include "../failed-iteration/Connection.dfy"
module BytecodeFoldFirstFailureModel {
  import opened BytecodeScanMachine
  import X = BytecodeExternalMachine
  import L = BytecodeFoldLoopModelV2
  import F = BytecodeFoldFailedIteration
  import I = BytecodeFoldSuccessfulIterationV2
  import H = BytecodeApplyCallbackSuccessMemory
  predicate Resources(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word,prefix: seq<L.Receipt>,failure: F.Receipt)
    decreases |prefix|
  {
    if |prefix| == 0 then F.Resources(data,mem,c,index,failure) else
    L.StepReady(data,mem,c,index,prefix[0]) && !I.Stop(c.exit,H.Result(prefix[0].returned)) &&
    Resources(data,L.Next(data,mem,c,index,prefix[0]),c,index+1,prefix[1..],failure)
  }
  predicate Truthful(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word,prefix: seq<L.Receipt>,failure: F.Receipt,self: Word,cursor: nat,observations: seq<X.Observation>)
    requires Resources(data,mem,c,index,prefix,failure)
    decreases |prefix|
  {
    if |prefix| == 0 then F.Truthful(data,mem,c,index,failure,self,cursor,observations) else
    cursor+2 < |observations| && observations[cursor] == X.Gas(prefix[0].gasBefore) && observations[cursor+1] == X.Gas(prefix[0].requestedGas) &&
    observations[cursor+2] == X.StaticCall(self,prefix[0].requestedGas,c.target,L.Payload(data,mem,c,index,prefix[0]),true,prefix[0].returned) &&
    Truthful(data,L.Next(data,mem,c,index,prefix[0]),c,index+1,prefix[1..],failure,self,cursor+3,observations)
  }
  function Error(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word,prefix: seq<L.Receipt>,failure: F.Receipt): seq<Byte>
    requires Resources(data,mem,c,index,prefix,failure)
    decreases |prefix|
  {
    if |prefix| == 0 then F.Error(data,mem,c,index,failure) else
    Error(data,L.Next(data,mem,c,index,prefix[0]),c,index+1,prefix[1..],failure)
  }
  lemma Reached(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word,prefix: seq<L.Receipt>,failure: F.Receipt)
    requires Resources(data,mem,c,index,prefix,failure)
    ensures L.Ready(data,mem,c) && index < c.total
  { }
}

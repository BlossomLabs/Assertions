// SPDX-License-Identifier: MIT
// Complete exact generic strict-index dispatch. Fresh native closure pending.
include "InvalidHigh.generated.dfy"
include "InvalidLow.generated.dfy"
include "Positive.generated.dfy"
include "Negative.generated.dfy"
module OperationsStringAtIndexConnection {
  import S = BytecodeScanMachine
  import M = BytecodeExternalMachine
  import E = OperationsCaseFoldExecution
  import I = OperationsStringAtInputs
  import K = OperationsStringAtKernel
  import N = OperationsStringAtStrictIndex
  import IH = OperationsStringAtIndexInvalidHigh
  import IL = OperationsStringAtIndexInvalidLow
  import P = OperationsStringAtIndexPositive
  import V = OperationsStringAtIndexNegative
  predicate Matches(code:seq<S.Byte>,ret:S.Word) { IH.Matches(code,ret) && IL.Matches(code,ret) && P.Matches(code,ret) && V.Matches(code,ret) }
  function Destinations(ret:S.Word):set<nat> { IH.Destinations(ret)+IL.Destinations(ret)+P.Destinations(ret)+V.Destinations(ret) }
  function Expected(prefix:seq<S.Word>,ret:S.Word,word:S.Word,length:S.Word):M.Frame
    requires length<I.U64
  {
    if I.InRange(word,length) then M.Frame(S.Running(ret,prefix+[I.Position(word,length)],K.Initial()),[],0)
    else M.Frame(S.Reverted(I.Packet(I.InvalidByteIndex(word,length))),[],0)
  }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,prefix:seq<S.Word>,ret:S.Word,word:S.Word,length:S.Word,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code,ret) && Destinations(ret)<=destinations && |prefix|<=980 && length<I.U64
    ensures state==Expected(prefix,ret,word,length)
    ensures E.Trace(code,destinations,self,value,data,observations,trace) && trace[0]==M.Frame(S.Running(11497,prefix+[ret,word,length],K.Initial()),[],0) && trace[|trace|-1]==state
  {
    N.Partition(word,length);
    if N.Class(word,length)==N.InvalidHigh { state,trace:=IH.Run(code,destinations,prefix,ret,word,length,self,value,data,observations); }
    else if N.Class(word,length)==N.InvalidLow { state,trace:=IL.Run(code,destinations,prefix,ret,word,length,self,value,data,observations); }
    else if N.Class(word,length)==N.Positive { state,trace:=P.Run(code,destinations,prefix,ret,word,length,self,value,data,observations); }
    else { assert N.Class(word,length)==N.Negative;state,trace:=V.Run(code,destinations,prefix,ret,word,length,self,value,data,observations); }
  }
}

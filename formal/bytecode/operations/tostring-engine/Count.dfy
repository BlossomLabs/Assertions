// SPDX-License-Identifier: MIT
// Original-byte finite decimal count loop; native proof pending.
include "../tostring-controls/CountStart.generated.dfy"
include "../tostring-controls/CountTake.generated.dfy"
include "../tostring-controls/CountDone.generated.dfy"
module OperationsToStringCount {
  import S = BytecodeScanMachine
  import M = BytecodeExternalMachine
  import E = OperationsCaseFoldExecution
  import D = OperationsToStringDecimal
  import Start = OperationsToStringCountStart
  import Take = OperationsToStringCountTake
  import Done = OperationsToStringCountDone
  predicate Matches(code:seq<S.Byte>) { Start.Matches(code) && Take.Matches(code) && Done.Matches(code) }
  function Destinations():set<nat> { Start.Destinations()+Take.Destinations()+Done.Destinations() }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,prefix:seq<S.Word>,original:S.Word,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && |prefix|<=1000 && original>0
    ensures state==M.Frame(S.Running(5576,prefix+[original,96,D.Steps(original),0],mem),[],0)
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
    ensures trace[0]==M.Frame(S.Running(5497,prefix+[original],mem),[],0) && trace[|trace|-1]==state
    ensures 1<=D.Steps(original)<=78
  {
    D.WordDigits(original);D.CountBegin(original);
    state,trace:=Start.Run(code,destinations,prefix,original,0,original,mem,self,value,data,observations);
    var current:S.Word:=original;var done:S.Word:=0;
    while current>0
      invariant D.Count(original,current,done) && done<=78
      invariant state==M.Frame(S.Running(5538,prefix+[original,96,done,current],mem),[],0)
      invariant E.Trace(code,destinations,self,value,data,observations,trace)
      invariant trace[0]==M.Frame(S.Running(5497,prefix+[original],mem),[],0) && trace[|trace|-1]==state
      decreases current
    {
      D.CountNext(original,current,done);D.Quotient(current);
      var next,part:=Take.Run(code,destinations,prefix,original,done,current,mem,self,value,data,observations);
      E.Join(code,destinations,self,value,data,observations,trace,part);
      trace:=trace+part[1..];state:=next;
      current:=current/10;done:=done+1;
    }
    var next,part:=Done.Run(code,destinations,prefix,original,done,current,mem,self,value,data,observations);
    E.Join(code,destinations,self,value,data,observations,trace,part);
    trace:=trace+part[1..];state:=next;
    assert D.Steps(original)>0;
  }
}

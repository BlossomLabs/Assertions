// SPDX-License-Identifier: MIT
// Exact finite decimal digit-write loop; native proof pending.
include "../tostring-controls/FillTake.generated.dfy"
include "../tostring-controls/FillDone.generated.dfy"
module OperationsToStringFill {
  import S = BytecodeScanMachine
  import M = BytecodeExternalMachine
  import E = OperationsCaseFoldExecution
  import I = OperationsToStringInputs
  import D = OperationsToStringDecimal
  import K = OperationsToStringFillMemory
  import H = OperationsToStringFrame
  import Take = OperationsToStringFillTake
  import Done = OperationsToStringFillDone
  predicate Matches(code:seq<S.Byte>) { Take.Matches(code) && Done.Matches(code) }
  function Destinations():set<nat> { Take.Destinations()+Done.Destinations() }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,prefix:seq<S.Word>,original:S.Word,base:S.Word,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && |prefix|<=1000
    requires K.Inv(mem,base,original,original,D.Steps(original))
    ensures state.state.Running? && state.state.pc==5752 && state.state.stack==prefix+[original,96,0,base,0] && state.returned==[] && state.cursor==0
    ensures K.Inv(state.state.memory,base,original,0,0) && K.Payload(state.state.memory,base,D.Steps(original))==I.Digits(original)
    ensures H.Stable(mem,state.state.memory,base) && |state.state.memory|==|mem|
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
    ensures trace[0]==M.Frame(S.Running(5649,prefix+[original,96,D.Steps(original),base,original],mem),[],0) && trace[|trace|-1]==state
  {
    var current:S.Word:=original;var left:S.Word:=D.Steps(original);var memory:=mem;
    state:=M.Frame(S.Running(5649,prefix+[original,96,left,base,current],mem),[],0);trace:=[state];
    while current>0
      invariant K.Inv(memory,base,original,current,left)
      invariant H.Stable(mem,memory,base) && |memory|==|mem|
      invariant state==M.Frame(S.Running(5649,prefix+[original,96,left,base,current],memory),[],0)
      invariant E.Trace(code,destinations,self,value,data,observations,trace)
      invariant trace[0]==M.Frame(S.Running(5649,prefix+[original,96,D.Steps(original),base,original],mem),[],0) && trace[|trace|-1]==state
      decreases current
    {
      D.Quotient(current);K.Next(memory,base,original,current,left);
      var next,part:=Take.Run(code,destinations,prefix,original,left,base,current,memory,self,value,data,observations);
      E.Join(code,destinations,self,value,data,observations,trace,part);
      H.Chain(mem,memory,next.state.memory,base);
      trace:=trace+part[1..];state:=next;memory:=state.state.memory;
      current:=current/10;left:=left-1;
    }
    K.Finish(memory,base,original,left);
    var next,part:=Done.Run(code,destinations,prefix,original,left,base,current,memory,self,value,data,observations);
    E.Join(code,destinations,self,value,data,observations,trace,part);
    trace:=trace+part[1..];state:=next;
  }
}

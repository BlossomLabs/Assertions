// SPDX-License-Identifier: MIT
// Exact PC-zero to canonical returned bytes for both ASCII folding entries; native pending.
include "../casefold-raw/Admission.dfy"
include "../casefold-engine/Engine.dfy"
include "../casefold-return/Return.generated.dfy"
module OperationsCaseFoldFullConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import E = OperationsCaseFoldExecution
  import I = OperationsCaseFoldInputs
  import K = OperationsCaseFoldKernel
  import Raw = OperationsCaseFoldRawAdmission
  import Body = OperationsCaseFoldEngine
  import Q = OperationsCaseFoldReturnKernel
  import Return = OperationsCaseFoldReturn
  function Destinations():set<nat> { Raw.Destinations()+Body.Destinations()+Return.Destinations() }
  predicate Matches(code:seq<S.Byte>) { Raw.Matches(code) && Body.Matches(code) && Return.Matches(code) }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>,lower:bool)
    returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && I.Frame(data) && I.Assigned(data,value,lower)
    ensures state==(if I.Admission(data,value)==I.Accepted then M.Frame(S.Returned(Q.Canonical(I.Result(data,lower))),[],0) else M.Frame(S.Reverted([]),[],0))
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(0,[],[]),[],0) && trace[|trace|-1]==state
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
  {
    I.AdmissionSpan(data,value);
    state,trace:=Raw.Run(code,destinations,self,value,data,observations,lower);
    if I.Admission(data,value)==I.Accepted {
      var offset:=Raw.Payload(data);var length:=I.Length(data);
      assert offset==I.Payload(data);
      assert K.Input(data,offset,length);
      var tail:seq<M.Frame>;
      state,tail:=Body.Run(code,destinations,offset,length,lower,self,value,data,observations);
      assert trace[|trace|-1]==tail[0];
      E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
      var memory:=state.state.memory;
      Q.SourceLayout(memory,data,offset,length,lower);
      state,tail:=Return.Run(code,destinations,offset,length,length,lower,memory,self,value,data,observations);
      assert trace[|trace|-1]==tail[0];
      E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
      assert Q.Body(data,offset,length,lower)==I.Result(data,lower);
    }
  }
}

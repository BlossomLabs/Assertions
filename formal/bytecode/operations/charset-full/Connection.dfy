// SPDX-License-Identifier: MIT
// Full exact raw charset entry to scalar return; native verification pending.
include "../charset-raw/Admission.dfy"
include "../charset-engine/Engine.dfy"
module OperationsCharsetFull {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = OperationsCharsetInputs
  import K = OperationsCharsetKernel
  import Raw = OperationsCharsetRaw
  import Engine = OperationsCharsetEngine
  function Destinations():set<nat> { Raw.Destinations()+Engine.Destinations() }
  predicate Matches(code:seq<S.Byte>) { Raw.Matches(code) && Engine.Matches(code) }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && I.Frame(data) && I.Assigned(data,value)
    ensures !I.Span(data) || value!=0 ==> state==M.Frame(S.Reverted([]),[],0)
    ensures I.Span(data) && value==0 ==> state==M.Frame(S.Returned(G.Encode(I.Result(data),32)),[],0)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(0,[],[]),[],0) && trace[|trace|-1]==state
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
  {
    state,trace:=Raw.Run(code,destinations,self,value,data,observations);
    I.AdmissionSpan(data,value);
    if I.Admission(data,value)==I.Accepted {
      K.InitialFits();
      var tail:seq<M.Frame>;
      state,tail:=Engine.Run(code,destinations,I.Payload(data),I.Length(data),I.Mask(data),K.Initial(),self,value,data,observations);
      assert trace[|trace|-1]==tail[0];
      E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
    }
  }
}

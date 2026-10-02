// SPDX-License-Identifier: MIT
// Complete ordered raw charset decoder composition; native pending.
include "Nonzero.generated.dfy"
include "Short.generated.dfy"
include "Args.generated.dfy"
include "OffsetBound.generated.dfy"
include "LengthWindow.generated.dfy"
include "LengthBound.generated.dfy"
include "PayloadWindow.generated.dfy"
include "Accepted.generated.dfy"
module OperationsCharsetRaw {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = OperationsCharsetInputs
  import K = OperationsCharsetKernel
  import Nonzero = OperationsCharsetRawNonzero
  import Short = OperationsCharsetRawShort
  import Args = OperationsCharsetRawArgs
  import OffsetBound = OperationsCharsetRawOffsetBound
  import LengthWindow = OperationsCharsetRawLengthWindow
  import LengthBound = OperationsCharsetRawLengthBound
  import PayloadWindow = OperationsCharsetRawPayloadWindow
  import Accepted = OperationsCharsetRawAccepted
  function Destinations():set<nat> { Nonzero.Destinations()+Short.Destinations()+Args.Destinations()+OffsetBound.Destinations()+LengthWindow.Destinations()+LengthBound.Destinations()+PayloadWindow.Destinations()+Accepted.Destinations() }
  predicate Matches(code:seq<S.Byte>) { Nonzero.Matches(code) && Short.Matches(code) && Args.Matches(code) && OffsetBound.Matches(code) && LengthWindow.Matches(code) && LengthBound.Matches(code) && PayloadWindow.Matches(code) && Accepted.Matches(code) }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && I.Frame(data) && I.Assigned(data,value)
    ensures I.Admission(data,value)==I.Accepted ==>
              state==M.Frame(S.Running(4121,[0x3e8c97e3,1289,I.Payload(data),I.Length(data),I.Mask(data)],K.Initial()),[],0)
    ensures I.Admission(data,value)!=I.Accepted ==> state==M.Frame(S.Reverted([]),[],0)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(0,[],[]),[],0) && trace[|trace|-1]==state
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
  {
    if I.Admission(data,value)==I.Nonzero { state,trace:=Nonzero.Run(code,destinations,self,value,data,observations); }
    else if I.Admission(data,value)==I.Short { state,trace:=Short.Run(code,destinations,self,value,data,observations); }
    else if I.Admission(data,value)==I.Args { state,trace:=Args.Run(code,destinations,self,value,data,observations); }
    else if I.Admission(data,value)==I.OffsetBound { state,trace:=OffsetBound.Run(code,destinations,self,value,data,observations); }
    else if I.Admission(data,value)==I.LengthWindow { state,trace:=LengthWindow.Run(code,destinations,self,value,data,observations); }
    else if I.Admission(data,value)==I.LengthBound { state,trace:=LengthBound.Run(code,destinations,self,value,data,observations); }
    else if I.Admission(data,value)==I.PayloadWindow { state,trace:=PayloadWindow.Run(code,destinations,self,value,data,observations); }
    else { state,trace:=Accepted.Run(code,destinations,self,value,data,observations); }
    I.AdmissionSpan(data,value);
    reveal G.Modulus();
  }
}

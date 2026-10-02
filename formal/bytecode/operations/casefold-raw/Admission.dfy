// SPDX-License-Identifier: MIT
// Complete ordered raw case-fold admission; native pending.
include "LowerNonzero.generated.dfy"
include "LowerShort.generated.dfy"
include "LowerArgs.generated.dfy"
include "LowerOffsetBound.generated.dfy"
include "LowerLengthWindow.generated.dfy"
include "LowerLengthBound.generated.dfy"
include "LowerPayloadWindow.generated.dfy"
include "LowerAccepted.generated.dfy"
include "UpperNonzero.generated.dfy"
include "UpperShort.generated.dfy"
include "UpperArgs.generated.dfy"
include "UpperOffsetBound.generated.dfy"
include "UpperLengthWindow.generated.dfy"
include "UpperLengthBound.generated.dfy"
include "UpperPayloadWindow.generated.dfy"
include "UpperAccepted.generated.dfy"
module OperationsCaseFoldRawAdmission {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import E = OperationsCaseFoldExecution
  import I = OperationsCaseFoldInputs
  import K = OperationsCaseFoldKernel
  import B = OperationsCaseFoldBinary
  import LowerNonzero = OperationsCaseFoldRawLowerNonzero
  import LowerShort = OperationsCaseFoldRawLowerShort
  import LowerArgs = OperationsCaseFoldRawLowerArgs
  import LowerOffsetBound = OperationsCaseFoldRawLowerOffsetBound
  import LowerLengthWindow = OperationsCaseFoldRawLowerLengthWindow
  import LowerLengthBound = OperationsCaseFoldRawLowerLengthBound
  import LowerPayloadWindow = OperationsCaseFoldRawLowerPayloadWindow
  import LowerAccepted = OperationsCaseFoldRawLowerAccepted
  import UpperNonzero = OperationsCaseFoldRawUpperNonzero
  import UpperShort = OperationsCaseFoldRawUpperShort
  import UpperArgs = OperationsCaseFoldRawUpperArgs
  import UpperOffsetBound = OperationsCaseFoldRawUpperOffsetBound
  import UpperLengthWindow = OperationsCaseFoldRawUpperLengthWindow
  import UpperLengthBound = OperationsCaseFoldRawUpperLengthBound
  import UpperPayloadWindow = OperationsCaseFoldRawUpperPayloadWindow
  import UpperAccepted = OperationsCaseFoldRawUpperAccepted
  function Destinations():set<nat> { LowerNonzero.Destinations()+LowerShort.Destinations()+LowerArgs.Destinations()+LowerOffsetBound.Destinations()+LowerLengthWindow.Destinations()+LowerLengthBound.Destinations()+LowerPayloadWindow.Destinations()+LowerAccepted.Destinations()+UpperNonzero.Destinations()+UpperShort.Destinations()+UpperArgs.Destinations()+UpperOffsetBound.Destinations()+UpperLengthWindow.Destinations()+UpperLengthBound.Destinations()+UpperPayloadWindow.Destinations()+UpperAccepted.Destinations() }
  predicate Matches(code:seq<S.Byte>) { LowerNonzero.Matches(code) && LowerShort.Matches(code) && LowerArgs.Matches(code) && LowerOffsetBound.Matches(code) && LowerLengthWindow.Matches(code) && LowerLengthBound.Matches(code) && LowerPayloadWindow.Matches(code) && LowerAccepted.Matches(code) && UpperNonzero.Matches(code) && UpperShort.Matches(code) && UpperArgs.Matches(code) && UpperOffsetBound.Matches(code) && UpperLengthWindow.Matches(code) && UpperLengthBound.Matches(code) && UpperPayloadWindow.Matches(code) && UpperAccepted.Matches(code) }
  function Payload(data:seq<S.Byte>):S.Word { I.Payload(data)%G.Modulus() }
  function Stack(data:seq<S.Byte>,lower:bool):seq<S.Word> {
    [I.Selector(lower),1362,Payload(data),I.Length(data),96,3085,Payload(data),I.Length(data),B.Cell(I.Low(lower)),B.Cell(I.High(lower))]
  }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>,lower:bool)
    returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && I.Frame(data) && I.Assigned(data,value,lower)
    ensures state==(if I.Admission(data,value)==I.Accepted then M.Frame(S.Running(12150,Stack(data,lower),K.Base()),[],0) else M.Frame(S.Reverted([]),[],0))
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(0,[],[]),[],0) && trace[|trace|-1]==state
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
  {
    if lower {
      if I.Admission(data,value)==I.Nonzero { state,trace:=LowerNonzero.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.Short { state,trace:=LowerShort.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.Args { state,trace:=LowerArgs.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.OffsetBound { state,trace:=LowerOffsetBound.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.LengthWindow { state,trace:=LowerLengthWindow.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.LengthBound { state,trace:=LowerLengthBound.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.PayloadWindow { state,trace:=LowerPayloadWindow.Run(code,destinations,self,value,data,observations); }
      else { state,trace:=LowerAccepted.Run(code,destinations,self,value,data,observations); }
    } else {
      if I.Admission(data,value)==I.Nonzero { state,trace:=UpperNonzero.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.Short { state,trace:=UpperShort.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.Args { state,trace:=UpperArgs.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.OffsetBound { state,trace:=UpperOffsetBound.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.LengthWindow { state,trace:=UpperLengthWindow.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.LengthBound { state,trace:=UpperLengthBound.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.PayloadWindow { state,trace:=UpperPayloadWindow.Run(code,destinations,self,value,data,observations); }
      else { state,trace:=UpperAccepted.Run(code,destinations,self,value,data,observations); }
    }
    B.CellWord(I.Low(lower));B.CellWord(I.High(lower));
  }
}

// SPDX-License-Identifier: MIT
// Complete original-byte decimal raw boundary; native proof pending.
include "UnsignedNonzero.generated.dfy"
include "UnsignedShort.generated.dfy"
include "UnsignedArgs.generated.dfy"
include "UnsignedAccepted.generated.dfy"
include "SignedNonzero.generated.dfy"
include "SignedShort.generated.dfy"
include "SignedArgs.generated.dfy"
include "SignedAccepted.generated.dfy"
module OperationsToStringRawAdmission {
  import S = BytecodeScanMachine
  import M = BytecodeExternalMachine
  import E = OperationsCaseFoldExecution
  import I = OperationsToStringInputs
  import K = OperationsToStringMemory
  import UNonzero = OperationsToStringRawUnsignedNonzero
  import UShort = OperationsToStringRawUnsignedShort
  import UArgs = OperationsToStringRawUnsignedArgs
  import UAccepted = OperationsToStringRawUnsignedAccepted
  import SNonzero = OperationsToStringRawSignedNonzero
  import SShort = OperationsToStringRawSignedShort
  import SArgs = OperationsToStringRawSignedArgs
  import SAccepted = OperationsToStringRawSignedAccepted
  predicate Matches(code:seq<S.Byte>) { UNonzero.Matches(code) && UShort.Matches(code) && UArgs.Matches(code) && UAccepted.Matches(code) && SNonzero.Matches(code) && SShort.Matches(code) && SArgs.Matches(code) && SAccepted.Matches(code) }
  function Destinations():set<nat> { UNonzero.Destinations()+UShort.Destinations()+UArgs.Destinations()+UAccepted.Destinations()+SNonzero.Destinations()+SShort.Destinations()+SArgs.Destinations()+SAccepted.Destinations() }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,signed:bool,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && I.Frame(data) && I.Assigned(data,value,signed)
    ensures state==(if I.Admission(data,value)==I.Accepted then M.Frame(S.Running(if signed then 2412 else 5497,[I.Selector(signed),1362,I.RawWord(data)],K.Base()),[],0) else M.Frame(S.Reverted([]),[],0))
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
    ensures trace[0]==M.Frame(S.Running(0,[],[]),[],0) && trace[|trace|-1]==state
  {
    if signed {
      if I.Admission(data,value)==I.Nonzero { state,trace:=SNonzero.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.Short { state,trace:=SShort.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.Args { state,trace:=SArgs.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.Accepted { state,trace:=SAccepted.Run(code,destinations,self,value,data,observations); }
    }
    else if !signed {
      if I.Admission(data,value)==I.Nonzero { state,trace:=UNonzero.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.Short { state,trace:=UShort.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.Args { state,trace:=UArgs.Run(code,destinations,self,value,data,observations); }
      else if I.Admission(data,value)==I.Accepted { state,trace:=UAccepted.Run(code,destinations,self,value,data,observations); }
    }
  }
}

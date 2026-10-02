// SPDX-License-Identifier: MIT
// Complete prepared signed-base wrapper control; native verification pending.
include "Enter00.generated.dfy"
include "Enter01.generated.dfy"
include "Enter10.generated.dfy"
include "Enter11.generated.dfy"
include "ReturnPositiveBase.generated.dfy"
include "ReturnNegativeEven.generated.dfy"
include "ReturnNegativeOdd.generated.dfy"
module OperationsModularPowerSignedWrapper {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import E = OperationsModularPowerExecution
  import K = OperationsModularPowerSignedKernel
  import L = OperationsModularPowerUnsignedMemory
  import A = OperationsModularPowerSignedArithmetic
  import Enter00 = OperationsModularPowerSignedEnter00
  import Enter01 = OperationsModularPowerSignedEnter01
  import Enter10 = OperationsModularPowerSignedEnter10
  import Enter11 = OperationsModularPowerSignedEnter11
  import ReturnPositiveBase = OperationsModularPowerSignedReturnPositiveBase
  import ReturnNegativeEven = OperationsModularPowerSignedReturnNegativeEven
  import ReturnNegativeOdd = OperationsModularPowerSignedReturnNegativeOdd
  function Destinations():set<nat> {
    Enter00.Destinations()+Enter01.Destinations()+Enter10.Destinations()+Enter11.Destinations()+
    ReturnPositiveBase.Destinations()+ReturnNegativeEven.Destinations()+ReturnNegativeOdd.Destinations()
  }
  predicate Matches(code:seq<S.Byte>) {
    Enter00.Matches(code) && Enter01.Matches(code) && Enter10.Matches(code) && Enter11.Matches(code) &&
    ReturnPositiveBase.Matches(code) && ReturnNegativeEven.Matches(code) && ReturnNegativeOdd.Matches(code)
  }
  ghost method Enter(code:seq<S.Byte>,destinations:set<nat>,base:S.Word,exponent:S.Word,modulusWord:S.Word,
                     mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>)
    returns(frame:E.Frame,trace:seq<E.Frame>)
    requires Matches(code) && Destinations()<=destinations && L.Admitted(mem)
    ensures frame==M.Frame(S.Running(9244,[0x640c3e5a,1329,base,exponent,modulusWord,0,3390,5241,K.Magnitude(base),exponent,K.Magnitude(modulusWord)],mem),[],0)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(5210,[0x640c3e5a,1329,base,exponent,modulusWord],mem),[],0) && trace[|trace|-1]==frame
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
  {
    K.MagnitudeIdentity(base);K.MagnitudeIdentity(modulusWord);
    if base<K.Half {
      if modulusWord<K.Half { frame,trace:=Enter00.Run(code,destinations,base,exponent,modulusWord,0,0,0,mem,[],0,self,value,data,observations); }
      else { frame,trace:=Enter01.Run(code,destinations,base,exponent,modulusWord,0,0,0,mem,[],0,self,value,data,observations); }
    } else {
      if modulusWord<K.Half { frame,trace:=Enter10.Run(code,destinations,base,exponent,modulusWord,0,0,0,mem,[],0,self,value,data,observations); }
      else { frame,trace:=Enter11.Run(code,destinations,base,exponent,modulusWord,0,0,0,mem,[],0,self,value,data,observations); }
    }
  }
  ghost method Return(code:seq<S.Byte>,destinations:set<nat>,base:S.Word,exponent:S.Word,modulusWord:S.Word,
                      finalBase:S.Word,finalExponent:S.Word,result:S.Word,mem:seq<S.Byte>,returned:seq<S.Byte>,cursor:nat,
                      self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>)
    returns(frame:E.Frame,trace:seq<E.Frame>)
    requires Matches(code) && Destinations()<=destinations && L.Admitted(mem)
    requires modulusWord!=0 && result<K.Magnitude(modulusWord)
    ensures frame==M.Frame(S.Returned(G.Encode(K.SignedResult(result,base>=K.Half && K.Odd(exponent)),32)),returned,cursor)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(3085,[0x640c3e5a,1329,base,exponent,modulusWord,0,3390,5241,finalBase,finalExponent,K.Magnitude(modulusWord),result],mem),returned,cursor)
    ensures trace[|trace|-1]==frame && E.Trace(code,destinations,self,value,data,observations,trace)
  {
    A.Represent(base,exponent,modulusWord,result);
    if base<K.Half { frame,trace:=ReturnPositiveBase.Run(code,destinations,base,exponent,modulusWord,finalBase,finalExponent,result,mem,returned,cursor,self,value,data,observations); }
    else if exponent%2==0 { frame,trace:=ReturnNegativeEven.Run(code,destinations,base,exponent,modulusWord,finalBase,finalExponent,result,mem,returned,cursor,self,value,data,observations); }
    else { assert exponent%2==1;frame,trace:=ReturnNegativeOdd.Run(code,destinations,base,exponent,modulusWord,finalBase,finalExponent,result,mem,returned,cursor,self,value,data,observations); }
  }
}

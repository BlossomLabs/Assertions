// SPDX-License-Identifier: MIT
// Complete fitting raw admission composition; native checks remain unlaunched.
include "SSAccepted.generated.dfy"
include "SSArgs.generated.dfy"
include "SSNonzero.generated.dfy"
include "SSShort.generated.dfy"
include "SUAccepted.generated.dfy"
include "SUArgs.generated.dfy"
include "SUNonzero.generated.dfy"
include "SUShort.generated.dfy"
include "USAccepted.generated.dfy"
include "USArgs.generated.dfy"
include "USNonzero.generated.dfy"
include "USShort.generated.dfy"
include "UUAccepted.generated.dfy"
include "UUArgs.generated.dfy"
include "UUNonzero.generated.dfy"
include "UUShort.generated.dfy"
module OperationsModularPowerRawAdmission {
  import S = BytecodeScanMachine
  import M = BytecodeExternalMachine
  import E = OperationsModularPowerExecution
  import UUNonzero = OperationsModularPowerRawUUNonzero
  import UUShort = OperationsModularPowerRawUUShort
  import UUArgs = OperationsModularPowerRawUUArgs
  import UUAccepted = OperationsModularPowerRawUUAccepted
  import USNonzero = OperationsModularPowerRawUSNonzero
  import USShort = OperationsModularPowerRawUSShort
  import USArgs = OperationsModularPowerRawUSArgs
  import USAccepted = OperationsModularPowerRawUSAccepted
  import SUNonzero = OperationsModularPowerRawSUNonzero
  import SUShort = OperationsModularPowerRawSUShort
  import SUArgs = OperationsModularPowerRawSUArgs
  import SUAccepted = OperationsModularPowerRawSUAccepted
  import SSNonzero = OperationsModularPowerRawSSNonzero
  import SSShort = OperationsModularPowerRawSSShort
  import SSArgs = OperationsModularPowerRawSSArgs
  import SSAccepted = OperationsModularPowerRawSSAccepted
  datatype Family = UU | US | SU | SS
  function Selector(f:Family):S.Word { if f.UU? then 0x44852766 else if f.US? then 0xdec28c5b else if f.SU? then 0x640c3e5a else 0x08198add }
  function BodyPc(f:Family):nat { if f.UU? then 4610 else if f.US? then 8791 else if f.SU? then 5210 else 2990 }
  function Destinations():set<nat> { {15,143,213,353,655,828,909,968,1130,1211,1266,1270,1310,1324,1757,1776,1795,1809,1851,1870,1876,1895,1914,1928,2793,2807,2990,4610,5210,8791,18682,18700} }
  opaque predicate Matches(f:Family,code:seq<S.Byte>) {
    if f.UU? then UUNonzero.Matches(code) && UUShort.Matches(code) && UUArgs.Matches(code) && UUAccepted.Matches(code)
    else if f.US? then USNonzero.Matches(code) && USShort.Matches(code) && USArgs.Matches(code) && USAccepted.Matches(code)
    else if f.SU? then SUNonzero.Matches(code) && SUShort.Matches(code) && SUArgs.Matches(code) && SUAccepted.Matches(code)
    else if f.SS? then SSNonzero.Matches(code) && SSShort.Matches(code) && SSArgs.Matches(code) && SSAccepted.Matches(code)
    else false
  }
  ghost method Admit(f:Family,code:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>)
    returns(frame:E.Frame,trace:seq<E.Frame>)
    requires |data|<0x10000000000000000 && Matches(f,code)
    requires value!=0 || |data|<4 || S.ShiftRight(S.DataWord(data,0),224)==Selector(f)
    ensures value!=0 || |data|<100 ==> frame==M.Frame(S.Reverted([]),[],0)
    ensures value==0 && |data|>=100 ==> frame==M.Frame(S.Running(BodyPc(f),[Selector(f),1329,S.DataWord(data,4),S.DataWord(data,36),S.DataWord(data,68)],S.Store([],64,128)),[],0)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(0,[],[]),[],0) && trace[|trace|-1]==frame
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
  {
    reveal Matches();
    if f.UU? {
      if value!=0 { frame,trace:=UUNonzero.Run(code,Destinations(),self,value,data,observations); }
      else if |data|<4 { frame,trace:=UUShort.Run(code,Destinations(),self,value,data,observations); }
      else if |data|<100 { frame,trace:=UUArgs.Run(code,Destinations(),self,value,data,observations); }
      else { frame,trace:=UUAccepted.Run(code,Destinations(),self,value,data,observations); }
    }
    else if f.US? {
      if value!=0 { frame,trace:=USNonzero.Run(code,Destinations(),self,value,data,observations); }
      else if |data|<4 { frame,trace:=USShort.Run(code,Destinations(),self,value,data,observations); }
      else if |data|<100 { frame,trace:=USArgs.Run(code,Destinations(),self,value,data,observations); }
      else { frame,trace:=USAccepted.Run(code,Destinations(),self,value,data,observations); }
    }
    else if f.SU? {
      if value!=0 { frame,trace:=SUNonzero.Run(code,Destinations(),self,value,data,observations); }
      else if |data|<4 { frame,trace:=SUShort.Run(code,Destinations(),self,value,data,observations); }
      else if |data|<100 { frame,trace:=SUArgs.Run(code,Destinations(),self,value,data,observations); }
      else { frame,trace:=SUAccepted.Run(code,Destinations(),self,value,data,observations); }
    }
    else if f.SS? {
      if value!=0 { frame,trace:=SSNonzero.Run(code,Destinations(),self,value,data,observations); }
      else if |data|<4 { frame,trace:=SSShort.Run(code,Destinations(),self,value,data,observations); }
      else if |data|<100 { frame,trace:=SSArgs.Run(code,Destinations(),self,value,data,observations); }
      else { frame,trace:=SSAccepted.Run(code,Destinations(),self,value,data,observations); }
    }
  }
}

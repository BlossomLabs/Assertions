// SPDX-License-Identifier: MIT
// Compiled initialization frontiers connected to independent reduced-loop meaning.
include "Loop.generated.dfy"
include "Precompile.generated.dfy"
module OperationsModularPowerInitialConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import E = OperationsModularPowerExecution
  import K = OperationsModularPowerKernel
  import C = OperationsModularPowerKernelConnection
  import L = OperationsModularPowerInitialLoop
  import P = OperationsModularPowerInitialPrecompile
  predicate Matches(code:seq<S.Byte>) { L.Matches(code) && P.Matches(code) }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,outer:seq<S.Word>,returnPc:S.Word,
                   base:S.Word,exponent:S.Word,modulus:S.Word,mem:seq<S.Byte>,
                   returned:seq<S.Byte>,cursor:nat,self:S.Word,value:S.Word,data:seq<S.Byte>,
                   observations:seq<E.Observation>) returns(frame:E.Frame,trace:seq<E.Frame>)
    requires Matches(code) && {9256,9268,9367,20289,20303}<=destinations
    requires |outer|<=1008 && modulus>0 && |mem|<G.Modulus()
    ensures frame==M.Frame(S.Running(if exponent<0x100000000 then 9367 else 9283,
                                     outer+[returnPc,base%modulus,exponent,modulus,1%modulus],mem),returned,cursor)
    ensures |trace|>0
    ensures trace[0]==M.Frame(S.Running(9244,outer+[returnPc,base,exponent,modulus],mem),returned,cursor)
    ensures trace[|trace|-1]==frame && E.Trace(code,destinations,self,value,data,observations,trace)
    ensures K.Loop(base%modulus,exponent,1%modulus,modulus)==E.Power(base,exponent)%modulus
  {
    if exponent<0x100000000 {
      frame,trace:=L.Run(code,destinations,outer,returnPc,base,exponent,modulus,mem,returned,cursor,self,value,data,observations);
    } else {
      frame,trace:=P.Run(code,destinations,outer,returnPc,base,exponent,modulus,mem,returned,cursor,self,value,data,observations);
    }
    K.ReducedEntry(base,exponent,modulus);C.SamePower(base,exponent);
  }
}

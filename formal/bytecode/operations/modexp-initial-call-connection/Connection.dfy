// SPDX-License-Identifier: MIT
// Compiled initialization plus optional full precompile attempt, before the open loop/return.
include "../modexp-initial-controls/Connection.dfy"
include "../modexp-call-engine/Engine.dfy"
module OperationsModularPowerInitialCallConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import B = BytecodeExternalMemory
  import E = OperationsModularPowerExecution
  import K = OperationsModularPowerKernel
  import C = OperationsModularPowerKernelConnection
  import I = OperationsModularPowerInitialConnection
  import R = OperationsModularPowerRequestConnection
  import P = OperationsModularPowerPacketMemory
  import A = OperationsModularPowerCallEngine
  predicate Matches(code:seq<S.Byte>) { I.Matches(code) && A.Matches(code) }
  lemma ReducedPower(base:S.Word,exponent:S.Word,modulus:S.Word)
    requires modulus>0
    ensures E.Power(base%modulus,exponent)%modulus==E.Power(base,exponent)%modulus
  {
    K.PowerResidue(base%modulus,base,exponent,modulus);
    C.SamePower(base%modulus,exponent);C.SamePower(base,exponent);
  }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,outer:seq<S.Word>,returnPc:S.Word,
                   base:S.Word,exponent:S.Word,modulus:S.Word,oldReturn:seq<S.Byte>,
                   returned:seq<S.Byte>,success:bool,cursor:nat,self:S.Word,gas:S.Word,
                   value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>)
    returns(frame:E.Frame,trace:seq<E.Frame>)
    requires Matches(code) && {9256,9268,9351,9367,20289,20303}<=destinations
    requires |outer|<=1008 && modulus>0
    requires exponent>=0x100000000 ==> |returned|<G.Modulus() && M.Context(self) && cursor+1<|observations|
    requires exponent>=0x100000000 ==> observations[cursor]==M.Gas(gas) && observations[cursor+1]==
                                                                           M.StaticCall(self,gas,5,B.Input(P.Packet(R.Initial(),128,base%modulus,exponent,modulus),128,192),success,returned)
    requires E.FaithfulHistory(observations)
    ensures exponent<0x100000000 ==> frame==M.Frame(S.Running(9367,outer+[returnPc,base%modulus,exponent,modulus,1%modulus],R.Initial()),oldReturn,cursor)
    ensures exponent>=0x100000000 ==> frame==M.Frame(S.Running(9354,
                                                               outer+[returnPc,base%modulus,exponent,modulus,if success && |returned|==32 then E.Power(base,exponent)%modulus else 1%modulus,if success && |returned|==32 then 1 else 0],
                                                               B.Output(P.Packet(R.Initial(),128,base%modulus,exponent,modulus),128,192,128,32,returned)),returned,cursor+2)
    ensures K.Loop(base%modulus,exponent,1%modulus,modulus)==E.Power(base,exponent)%modulus
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(9244,outer+[returnPc,base,exponent,modulus],R.Initial()),oldReturn,cursor)
    ensures trace[|trace|-1]==frame && E.Trace(code,destinations,self,value,data,observations,trace)
  {
    frame,trace:=I.Run(code,destinations,outer,returnPc,base,exponent,modulus,R.Initial(),oldReturn,cursor,self,value,data,observations);
    if exponent>=0x100000000 {
      var tail:seq<E.Frame>;
      frame,tail:=A.Run(code,destinations,outer,returnPc,base%modulus,exponent,modulus,1%modulus,oldReturn,returned,success,cursor,self,gas,value,data,observations);
      assert trace[|trace|-1]==tail[0];
      A.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
      if success && |returned|==32 { ReducedPower(base,exponent,modulus); }
    }
  }
}

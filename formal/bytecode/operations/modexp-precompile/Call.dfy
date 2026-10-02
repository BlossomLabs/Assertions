// SPDX-License-Identifier: MIT
// Actual call effect, independent exact packet, and explicit faithful reply premise.
include "Site.generated.dfy"
include "../modexp-packet/Memory.dfy"
module OperationsModularPowerPrecompileCall {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import B = BytecodeExternalMemory
  import E = OperationsModularPowerExecution
  import P = OperationsModularPowerPacketMemory
  import I = OperationsModularPowerPrecompileSite
  lemma Call(code:seq<S.Byte>,prefix:seq<S.Word>,mem:seq<S.Byte>,heap:S.Word,
             a:S.Word,e:S.Word,m:S.Word,self:S.Word,gas:S.Word,oldReturn:seq<S.Byte>,
             returned:seq<S.Byte>,success:bool,cursor:nat,observations:seq<E.Observation>,
             value:S.Word,data:seq<S.Byte>)
    requires I.Matches(code) && M.Context(self) && |prefix|<=1018
    requires P.Admitted(mem,heap) && |returned|<G.Modulus()
    requires cursor<|observations| && observations[cursor]==
                                      M.StaticCall(self,gas,5,B.Input(P.Packet(mem,heap,a,e,m),heap,192),success,returned)
    ensures E.Execute(code,{},M.Frame(S.Running(I.Pc,prefix+[32,heap,192,heap,5,gas],P.Packet(mem,heap,a,e,m)),oldReturn,cursor),self,value,data,observations)==
            M.Frame(S.Running(I.Pc+1,prefix+[if success then 1 else 0],B.Output(P.Packet(mem,heap,a,e,m),heap,192,heap,32,returned)),returned,cursor+1)
  {
    P.Request(mem,heap,a,e,m);
    M.StaticStep(code,I.Pc,prefix,P.Packet(mem,heap,a,e,m),self,gas,5,heap,192,heap,32,oldReturn,returned,success,cursor,observations,value,data);
    E.Delegate(code,{},M.Frame(S.Running(I.Pc,prefix+[32,heap,192,heap,5,gas],P.Packet(mem,heap,a,e,m)),oldReturn,cursor),self,value,data,observations);
  }
  lemma SuccessfulReply(mem:seq<S.Byte>,heap:S.Word,a:S.Word,e:S.Word,m:S.Word,
                        self:S.Word,gas:S.Word,returned:seq<S.Byte>,cursor:nat,
                        observations:seq<E.Observation>)
    requires P.Admitted(mem,heap) && m>0 && |returned|==32
    requires cursor<|observations| && observations[cursor]==
                                      M.StaticCall(self,gas,5,B.Input(P.Packet(mem,heap,a,e,m),heap,192),true,returned)
    requires E.FaithfulHistory(observations)
    ensures S.Load(B.Output(P.Packet(mem,heap,a,e,m),heap,192,heap,32,returned),heap)==E.Power(a,e)%m
    ensures forall i:nat :: i<|P.Packet(mem,heap,a,e,m)| && (i<heap || heap+32<=i) ==>
                              B.Output(P.Packet(mem,heap,a,e,m),heap,192,heap,32,returned)[i]==P.Packet(mem,heap,a,e,m)[i]
  {
    P.Request(mem,heap,a,e,m); P.Size(mem,heap,P.Words(a,e,m),6);
    assert E.Faithful(observations[cursor]);
    P.ExactReply(P.Packet(mem,heap,a,e,m),heap,returned);
  }
}

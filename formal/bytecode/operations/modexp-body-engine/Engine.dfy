// SPDX-License-Identifier: MIT
// Prepared exact nonzero-modulus initialization, MODEXP dispatch and binary loop.
include "../modexp-initial-call-connection/Connection.dfy"
include "../modexp-fallback-controls/Success.generated.dfy"
include "../modexp-fallback-controls/Fallback.generated.dfy"
include "../modexp-loop-engine/Engine.dfy"
module OperationsModularPowerBodyEngine {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import B = BytecodeExternalMemory
  import E = OperationsModularPowerExecution
  import K = OperationsModularPowerKernel
  import R = OperationsModularPowerRequestConnection
  import F = BytecodeScanRepresentation
  import P = OperationsModularPowerPacketMemory
  import I = OperationsModularPowerInitialCallConnection
  import Success = OperationsModularPowerFallbackSuccess
  import Fallback = OperationsModularPowerFallbackFallback
  import Loop = OperationsModularPowerLoopEngine
  predicate Matches(code:seq<S.Byte>) {
    I.Matches(code) && Success.Matches(code) && Fallback.Matches(code) && Loop.Matches(code)
  }
  function Destinations():set<nat> { {3085,9256,9268,9351,9365,9367,9396,9402,9429,9435,20289,20303} }
  function Attempted(exponent:S.Word):bool { exponent>=0x100000000 }
  function Done(exponent:S.Word,success:bool,returned:seq<S.Byte>):bool {
    Attempted(exponent) && success && |returned|==32
  }
  function Memory(base:S.Word,exponent:S.Word,modulus:S.Word,returned:seq<S.Byte>):seq<S.Byte>
    requires modulus>0
  {
    if !Attempted(exponent) then R.Initial()
    else B.Output(P.Packet(R.Initial(),128,base%modulus,exponent,modulus),128,192,128,32,returned)
  }
  lemma MemoryFits(base:S.Word,exponent:S.Word,modulus:S.Word,returned:seq<S.Byte>)
    requires modulus>0
    ensures |Memory(base,exponent,modulus,returned)|%32==0 && 96<=|Memory(base,exponent,modulus,returned)|<G.Modulus()
    ensures S.Load(Memory(base,exponent,modulus,returned),64)==128
  {
    if Attempted(exponent) {
      var packet:=P.Packet(R.Initial(),128,base%modulus,exponent,modulus);
      P.Request(R.Initial(),128,base%modulus,exponent,modulus);
      P.Size(R.Initial(),128,P.Words(base%modulus,exponent,modulus),6);
      B.OutputSize(packet,128,192,128,32,returned);
      var mem:=Memory(base,exponent,modulus,returned);
      forall i:nat {:trigger mem[64+i]} | i<32
        ensures mem[64+i]==packet[64+i]
      { B.OutputFrame(packet,128,192,128,32,returned,64+i); }
      assert mem[64..96]==packet[64..96];
      F.WindowFits(mem,64,32);F.WindowFits(packet,64,32);
    }
  }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,outer:seq<S.Word>,returnPc:S.Word,
                   base:S.Word,exponent:S.Word,modulus:S.Word,oldReturn:seq<S.Byte>,
                   returned:seq<S.Byte>,success:bool,cursor:nat,self:S.Word,gas:S.Word,
                   value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>)
    returns(finalBase:S.Word,frame:E.Frame,trace:seq<E.Frame>)
    requires Matches(code) && Destinations()<=destinations
    requires |outer|<=1000 && modulus>0
    requires Attempted(exponent) ==> |returned|<G.Modulus() && M.Context(self) && cursor+1<|observations|
    requires Attempted(exponent) ==> (observations[cursor]==M.Gas(gas) && observations[cursor+1]==
                                                                          M.StaticCall(self,gas,5,B.Input(P.Packet(R.Initial(),128,base%modulus,exponent,modulus),128,192),success,returned))
    requires E.FaithfulHistory(observations)
    ensures finalBase<modulus
    ensures frame==M.Frame(S.Running(3085,outer+[returnPc,finalBase,if Done(exponent,success,returned) then exponent else 0,modulus,E.Power(base,exponent)%modulus],Memory(base,exponent,modulus,returned)),
                           if Attempted(exponent) then returned else oldReturn,if Attempted(exponent) then cursor+2 else cursor)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(9244,outer+[returnPc,base,exponent,modulus],R.Initial()),oldReturn,cursor)
    ensures trace[|trace|-1]==frame && E.Trace(code,destinations,self,value,data,observations,trace)
  {
    frame,trace:=I.Run(code,destinations,outer,returnPc,base,exponent,modulus,oldReturn,returned,success,cursor,self,gas,value,data,observations);
    assert K.Loop(base%modulus,exponent,1%modulus,modulus)==E.Power(base,exponent)%modulus;
    finalBase:=base%modulus;
    var tail:seq<E.Frame>;
    if Attempted(exponent) {
      MemoryFits(base,exponent,modulus,returned);
      var mem:=Memory(base,exponent,modulus,returned);
      if Done(exponent,success,returned) {
        frame,tail:=Success.Run(code,destinations,outer,returnPc,base%modulus,exponent,modulus,E.Power(base,exponent)%modulus,1,mem,returned,cursor+2,self,value,data,observations);
        finalBase:=base%modulus;
      } else {
        frame,tail:=Fallback.Run(code,destinations,outer,returnPc,base%modulus,exponent,modulus,1%modulus,0,mem,returned,cursor+2,self,value,data,observations);
      }
      assert trace[|trace|-1]==tail[0];
      Loop.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
      if !Done(exponent,success,returned) {
        finalBase,frame,tail:=Loop.Run(code,destinations,outer,returnPc,base%modulus,exponent,modulus,1%modulus,mem,returned,cursor+2,self,value,data,observations);
        assert trace[|trace|-1]==tail[0];
        Loop.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
      }
    } else {
      finalBase,frame,tail:=Loop.Run(code,destinations,outer,returnPc,base%modulus,exponent,modulus,1%modulus,R.Initial(),oldReturn,cursor,self,value,data,observations);
      assert trace[|trace|-1]==tail[0];
      Loop.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
    }
  }
}

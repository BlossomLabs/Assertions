// SPDX-License-Identifier: MIT
// Prepared complete signed-base raw entry; no native verification/public credit.
include "../modexp-raw-controls/Admission.dfy"
include "../modexp-signed-controls/Wrapper.dfy"
include "../modexp-unsigned-controls/Zero.generated.dfy"
include "../modexp-body-engine/Engine.dfy"
module OperationsModularPowerSignedFull {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import B = BytecodeExternalMemory
  import X = BytecodeExternalExecution
  import E = OperationsModularPowerExecution
  import K = OperationsModularPowerSignedKernel
  import A = OperationsModularPowerRawAdmission
  import W = OperationsModularPowerSignedWrapper
  import Zero = OperationsModularPowerUnsignedZero
  import Body = OperationsModularPowerBodyEngine
  import L = OperationsModularPowerUnsignedMemory
  import R = OperationsModularPowerRequestConnection
  import P = OperationsModularPowerPacketMemory
  import Q = OperationsModularPowerLoopEngine
  function Destinations():set<nat> {
    A.Destinations()+W.Destinations()+Zero.Destinations()+Body.Destinations()
  }
  predicate Matches(code:seq<S.Byte>) {
    A.Matches(A.SU,code) && W.Matches(code) && Zero.Matches(code) && Body.Matches(code)
  }
  function Result(base:S.Word,exponent:S.Word,modulusWord:S.Word):S.Word
    requires modulusWord!=0
  { K.SignedResult(E.Power(K.Magnitude(base),exponent)%K.Magnitude(modulusWord),base>=K.Half && K.Odd(exponent)) }
  lemma WidenStep(code:seq<S.Byte>,small:set<nat>,large:set<nat>,frame:E.Frame,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>)
    requires small<=large && E.Execute(code,small,frame,self,value,data,observations).state!=S.Bad
    ensures E.Execute(code,small,frame,self,value,data,observations)==E.Execute(code,large,frame,self,value,data,observations)
  {
    reveal E.Execute();
    if !frame.state.Running? || frame.state.pc>=|code| || S.Fetch(code,frame.state.pc).op !in E.Opcodes() {
      X.WidenStep(code,small,large,frame,self,value,data,observations);
    }
  }
  lemma WidenTrace(code:seq<S.Byte>,small:set<nat>,large:set<nat>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>,frames:seq<E.Frame>)
    requires small<=large && E.Trace(code,small,self,value,data,observations,frames)
    ensures E.Trace(code,large,self,value,data,observations,frames)
  {
    forall i {:trigger frames[i]} | 0<=i<|frames|-1
      ensures E.Execute(code,large,frames[i],self,value,data,observations)==frames[i+1] && frames[i+1].state!=S.Bad
    { WidenStep(code,small,large,frames[i],self,value,data,observations); }
  }
  ghost method Run(code:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>,
                   returned:seq<S.Byte>,success:bool,gas:S.Word)
    returns(frame:E.Frame,trace:seq<E.Frame>)
    requires |data|<0x10000000000000000 && Matches(code)
    requires value!=0 || |data|<4 || S.ShiftRight(S.DataWord(data,0),224)==0x640c3e5a
    requires E.FaithfulHistory(observations)
    requires value==0 && |data|>=100 && S.DataWord(data,68)!=0 && Body.Attempted(S.DataWord(data,36)) ==>
               (|returned|<G.Modulus() && M.Context(self) && 1<|observations| && observations[0]==M.Gas(gas) && observations[1]==
                                                                                                                M.StaticCall(self,gas,5,B.Input(P.Packet(R.Initial(),128,K.Magnitude(S.DataWord(data,4))%K.Magnitude(S.DataWord(data,68)),S.DataWord(data,36),K.Magnitude(S.DataWord(data,68))),128,192),success,returned))
    ensures value!=0 || |data|<100 ==> frame==M.Frame(S.Reverted([]),[],0)
    ensures value==0 && |data|>=100 && S.DataWord(data,68)==0 ==> frame==M.Frame(S.Reverted(L.PanicData()),[],0)
    ensures value==0 && |data|>=100 && S.DataWord(data,68)!=0 ==>
              frame==M.Frame(S.Returned(G.Encode(Result(S.DataWord(data,4),S.DataWord(data,36),S.DataWord(data,68)),32)),
                             if Body.Attempted(S.DataWord(data,36)) then returned else [],if Body.Attempted(S.DataWord(data,36)) then 2 else 0)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(0,[],[]),[],0) && trace[|trace|-1]==frame
    ensures E.Trace(code,Destinations(),self,value,data,observations,trace)
  {
    frame,trace:=A.Admit(A.SU,code,self,value,data,observations);
    WidenTrace(code,A.Destinations(),Destinations(),self,value,data,observations,trace);
    if value==0 && |data|>=100 {
      var a:=S.DataWord(data,4);var exponent:=S.DataWord(data,36);var m:=S.DataWord(data,68);
      K.MagnitudeIdentity(a);K.MagnitudeIdentity(m);
      var base:=K.Magnitude(a);var modulus:=K.Magnitude(m);
      var mem:=R.Initial();var tail:seq<E.Frame>;var destinations:=Destinations();
      assert L.Admitted(mem);
      frame,tail:=W.Enter(code,destinations,a,exponent,m,mem,self,value,data,observations);
      assert trace[|trace|-1]==tail[0];
      Q.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
      var outer:seq<S.Word>:=[0x640c3e5a,1329,a,exponent,m,0,3390];
      if modulus==0 {
        frame,tail:=Zero.Run(code,destinations,outer,5241,base,exponent,modulus,0,0,0,mem,[],0,self,value,data,observations);
      } else {
        var finalBase:S.Word;
        finalBase,frame,tail:=Body.Run(code,destinations,outer,5241,base,exponent,modulus,[],returned,success,0,self,gas,value,data,observations);
        assert trace[|trace|-1]==tail[0];
        Q.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
        var finalExponent:S.Word:=if Body.Done(exponent,success,returned) then exponent else 0;
        var packet:=Body.Memory(base,exponent,modulus,returned);
        Body.MemoryFits(base,exponent,modulus,returned);
        assert L.Admitted(packet);
        frame,tail:=W.Return(code,destinations,a,exponent,m,finalBase,finalExponent,E.Power(base,exponent)%modulus,packet,
                             if Body.Attempted(exponent) then returned else [],if Body.Attempted(exponent) then 2 else 0,self,value,data,observations);
      }
      assert trace[|trace|-1]==tail[0];
      Q.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
    }
  }
}

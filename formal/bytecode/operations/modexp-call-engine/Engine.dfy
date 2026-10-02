// SPDX-License-Identifier: MIT
// Compiled request, actual call effect and all complementary reply gates.
include "../modexp-request-controls/Connection.dfy"
include "../modexp-reply-controls/Exact.generated.dfy"
include "../modexp-reply-controls/Failed.generated.dfy"
include "../modexp-reply-controls/WrongSize.generated.dfy"
module OperationsModularPowerCallEngine {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import B = BytecodeExternalMemory
  import E = OperationsModularPowerExecution
  import P = OperationsModularPowerPacketMemory
  import I = OperationsModularPowerPrecompileSite
  import C = OperationsModularPowerPrecompileCall
  import R = OperationsModularPowerRequestConnection
  import Q = OperationsModularPowerRequestRequest
  import Exact = OperationsModularPowerReplyExact
  import Failed = OperationsModularPowerReplyFailed
  import Wrong = OperationsModularPowerReplyWrongSize
  predicate Matches(code:seq<S.Byte>) {
    Q.Matches(code) && I.Matches(code) && Exact.Matches(code) && Failed.Matches(code) && Wrong.Matches(code)
  }
  lemma Join(code:seq<S.Byte>,destinations:set<nat>,self:S.Word,value:S.Word,
             data:seq<S.Byte>,observations:seq<E.Observation>,left:seq<E.Frame>,right:seq<E.Frame>)
    requires E.Trace(code,destinations,self,value,data,observations,left)
    requires E.Trace(code,destinations,self,value,data,observations,right)
    requires left[|left|-1]==right[0]
    ensures E.Trace(code,destinations,self,value,data,observations,left+right[1..])
  {
    forall i:nat {:trigger (left+right[1..])[i]} | i<|left+right[1..]|-1
      ensures E.Execute(code,destinations,(left+right[1..])[i],self,value,data,observations)==(left+right[1..])[i+1] && (left+right[1..])[i+1].state!=S.Bad
    {
      if i<|left|-1 {
        assert (left+right[1..])[i]==left[i];
        assert (left+right[1..])[i+1]==left[i+1];
      } else {
        var j:=i-|left|+1;
        assert 0<=j<|right|-1;
        assert (left+right[1..])[i]==right[j];
        assert (left+right[1..])[i+1]==right[j+1];
      }
    }
  }
  lemma CallDestinations(code:seq<S.Byte>,destinations:set<nat>,prefix:seq<S.Word>,
                         packet:seq<S.Byte>,oldReturn:seq<S.Byte>,cursor:nat,
                         self:S.Word,gas:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>)
    requires I.Matches(code)
    ensures E.Execute(code,destinations,M.Frame(S.Running(9331,prefix+[32,128,192,128,5,gas],packet),oldReturn,cursor),self,value,data,observations)==
            E.Execute(code,{},M.Frame(S.Running(9331,prefix+[32,128,192,128,5,gas],packet),oldReturn,cursor),self,value,data,observations)
  { reveal E.Execute();reveal M.Step(); }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,outer:seq<S.Word>,returnPc:S.Word,
                   base:S.Word,exponent:S.Word,modulus:S.Word,result:S.Word,oldReturn:seq<S.Byte>,
                   returned:seq<S.Byte>,success:bool,cursor:nat,self:S.Word,gas:S.Word,
                   value:S.Word,data:seq<S.Byte>,observations:seq<E.Observation>)
    returns(frame:E.Frame,trace:seq<E.Frame>)
    requires Matches(code) && {9351}<=destinations
    requires |outer|<=1008 && modulus>0 && exponent>=0x100000000 && |returned|<G.Modulus()
    requires M.Context(self) && cursor+1<|observations| && observations[cursor]==M.Gas(gas)
    requires observations[cursor+1]==M.StaticCall(self,gas,5,B.Input(P.Packet(R.Initial(),128,base,exponent,modulus),128,192),success,returned)
    requires E.FaithfulHistory(observations)
    ensures frame==M.Frame(S.Running(9354,
                                     outer+[returnPc,base,exponent,modulus,if success && |returned|==32 then E.Power(base,exponent)%modulus else result,if success && |returned|==32 then 1 else 0],
                                     B.Output(P.Packet(R.Initial(),128,base,exponent,modulus),128,192,128,32,returned)),returned,cursor+2)
    ensures |trace|>0 && trace[0]==M.Frame(S.Running(9283,outer+[returnPc,base,exponent,modulus,result],R.Initial()),oldReturn,cursor)
    ensures trace[|trace|-1]==frame && E.Trace(code,destinations,self,value,data,observations,trace)
  {
    frame,trace:=R.Run(code,destinations,outer,returnPc,base,exponent,modulus,result,oldReturn,cursor,self,gas,value,data,observations);
    R.PacketDefinition(base,exponent,modulus);
    var packet:=P.Packet(R.Initial(),128,base,exponent,modulus);
    var prefix:=outer+[returnPc,base,exponent,modulus,result,0,128];
    C.Call(code,prefix,R.Initial(),128,base,exponent,modulus,self,gas,oldReturn,returned,success,cursor+1,observations,value,data);
    CallDestinations(code,destinations,prefix,packet,oldReturn,cursor+1,self,gas,value,data,observations);
    var after:=E.Execute(code,destinations,frame,self,value,data,observations);
    assert after.state!=S.Bad;
    E.Extend(code,destinations,self,value,data,observations,trace,after);trace:=trace+[after];frame:=after;
    var mem:=B.Output(packet,128,192,128,32,returned);
    P.Request(R.Initial(),128,base,exponent,modulus);
    P.Size(R.Initial(),128,P.Words(base,exponent,modulus),6);
    B.OutputSize(packet,128,192,128,32,returned);
    assert |mem|==|packet| && |mem|%32==0 && 160<=|mem|<G.Modulus();
    var tail:seq<E.Frame>;
    if success && |returned|==32 {
      C.SuccessfulReply(R.Initial(),128,base,exponent,modulus,self,gas,returned,cursor+1,observations);
      frame,tail:=Exact.Run(code,destinations,outer,returnPc,base,exponent,modulus,result,128,mem,returned,success,cursor+2,self,value,data,observations);
    } else if !success {
      frame,tail:=Failed.Run(code,destinations,outer,returnPc,base,exponent,modulus,result,128,mem,returned,success,cursor+2,self,value,data,observations);
    } else {
      frame,tail:=Wrong.Run(code,destinations,outer,returnPc,base,exponent,modulus,result,128,mem,returned,success,cursor+2,self,value,data,observations);
    }
    assert trace[|trace|-1]==tail[0];
    Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
  }
}

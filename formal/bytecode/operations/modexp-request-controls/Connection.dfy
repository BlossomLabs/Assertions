// SPDX-License-Identifier: MIT
// Actual request construction connected to the independent physical packet specification.
include "Request.generated.dfy"
module OperationsModularPowerRequestConnection {
  import S = BytecodeScanMachine
  import M = BytecodeExternalMachine
  import E = OperationsModularPowerExecution
  import P = OperationsModularPowerPacketMemory
  import Q = BytecodeScanRepresentation
  import R = OperationsModularPowerRequestRequest
  function Initial():seq<S.Byte>
    ensures P.Admitted(Initial(),128)
  { Q.StoredWord([],64,128); S.Store([],64,128) }
  lemma PacketDefinition(a:S.Word,e:S.Word,m:S.Word)
    ensures P.Admitted(Initial(),128)
    ensures P.Packet(Initial(),128,a,e,m)==
            S.Store(S.Store(S.Store(S.Store(S.Store(S.Store(Initial(),128,32),160,32),192,32),224,a),256,e),288,m)
  {
    Q.StoredWord([],64,128);
    assert P.Admitted(Initial(),128);
    var words:=P.Words(a,e,m);
    assert P.Write(Initial(),128,words,0)==Initial();
    assert P.Write(Initial(),128,words,1)==S.Store(Initial(),128,32);
    assert P.Write(Initial(),128,words,2)==S.Store(P.Write(Initial(),128,words,1),160,32);
    assert P.Write(Initial(),128,words,3)==S.Store(P.Write(Initial(),128,words,2),192,32);
    assert P.Write(Initial(),128,words,4)==S.Store(P.Write(Initial(),128,words,3),224,a);
    assert P.Write(Initial(),128,words,5)==S.Store(P.Write(Initial(),128,words,4),256,e);
    assert P.Write(Initial(),128,words,6)==S.Store(P.Write(Initial(),128,words,5),288,m);
  }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,outer:seq<S.Word>,returnPc:S.Word,
                   base:S.Word,exponent:S.Word,modulus:S.Word,result:S.Word,returned:seq<S.Byte>,
                   cursor:nat,self:S.Word,gas:S.Word,value:S.Word,data:seq<S.Byte>,
                   observations:seq<E.Observation>) returns(frame:E.Frame,trace:seq<E.Frame>)
    requires R.Matches(code) && |outer|<=1008 && modulus>0 && exponent>=0x100000000
    requires M.Context(self) && cursor<|observations| && observations[cursor]==M.Gas(gas)
    ensures frame==M.Frame(S.Running(9331,outer+[returnPc,base,exponent,modulus,result,0,128,32,128,192,128,5,gas],
                                     P.Packet(Initial(),128,base,exponent,modulus)),returned,cursor+1)
    ensures |trace|==38 && trace[0]==M.Frame(S.Running(9283,outer+[returnPc,base,exponent,modulus,result],Initial()),returned,cursor)
    ensures trace[|trace|-1]==frame && E.Trace(code,destinations,self,value,data,observations,trace)
  {
    frame,trace:=R.Run(code,destinations,outer,returnPc,base,exponent,modulus,result,returned,cursor,self,gas,value,data,observations);
    PacketDefinition(base,exponent,modulus);
  }
}

// SPDX-License-Identifier: MIT
// Exact PC-zero to decimal ABI packets for both public overloads; native pending.
include "../tostring-raw-v2/Admission.dfy"
include "../tostring-controls/SignPositive.generated.dfy"
include "../tostring-controls/SignNegative.generated.dfy"
include "../tostring-controls/Concat.generated.dfy"
include "../tostring-return/Return.generated.dfy"
module OperationsToStringFullConnection {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import R = BytecodeScanRepresentation
  import E = OperationsCaseFoldExecution
  import I = OperationsToStringInputs
  import K = OperationsToStringMemory
  import N = OperationsToStringSign
  import FillMemory = OperationsToStringFillMemory
  import F = OperationsToStringFrame
  import Q = OperationsToStringReturnKernel
  import C = OperationsToStringConcatMemory
  import Raw = OperationsToStringRawAdmission
  import Positive = OperationsToStringSignPositive
  import Negative = OperationsToStringSignNegative
  import Body = OperationsToStringBody
  import Concat = OperationsToStringConcat
  import Return = OperationsToStringReturn
  function Destinations():set<nat> {
    Raw.Destinations()+Positive.Destinations()+Negative.Destinations()+Body.Destinations(1362)+Body.Destinations(7455)+Concat.Destinations()+Return.Destinations()
  }
  predicate Matches(code:seq<S.Byte>) {
    Raw.Matches(code) && Positive.Matches(code) && Negative.Matches(code) && Body.Matches(code,1362) && Body.Matches(code,7455) && Concat.Matches(code) && Return.Matches(code)
  }
  lemma SignedLayout(mem:seq<S.Byte>,word:S.Word)
    requires FillMemory.Ready(mem,N.Free(word),Body.Length(I.Magnitude(word,true)))
    requires FillMemory.Payload(mem,N.Free(word),Body.Length(I.Magnitude(word,true)))==I.Render(I.Magnitude(word,true),false)
    requires |mem|==C.Free(word) && F.Stable(N.Initial(word),mem,N.Free(word))
    ensures C.Input(mem,word)
  {
    N.Ready(word);C.Bounds(word);
    assert mem[128..160]==N.Initial(word)[128..160];C.LoadFrame(N.Initial(word),mem,128);
    assert mem[160..160+C.Minus(word)]==N.Initial(word)[160..160+C.Minus(word)];
  }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>,signed:bool)
    returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && I.Frame(data) && I.Assigned(data,value,signed)
    ensures state==(if I.Admission(data,value)==I.Accepted then M.Frame(S.Returned(Q.Canonical(I.Result(data,signed))),[],0) else M.Frame(S.Reverted([]),[],0))
    ensures trace[0]==M.Frame(S.Running(0,[],[]),[],0) && trace[|trace|-1]==state
    ensures E.Trace(code,destinations,self,value,data,observations,trace)
  {
    state,trace:=Raw.Run(code,destinations,signed,self,value,data,observations);
    if I.Admission(data,value)==I.Accepted {
      var word:=I.RawWord(data);var tail:seq<M.Frame>;var base:S.Word;var free:S.Word;
      if signed {
        N.Ready(word);N.Magnitude(word);
        if I.Negative(word,true) { state,tail:=Negative.Run(code,destinations,[],word,self,value,data,observations); }
        else { state,tail:=Positive.Run(code,destinations,[],word,self,value,data,observations); }
        E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
        var prefix:seq<S.Word>:=[I.Selector(true),1362,word,96,128];var initial:=state.state.memory;
        assert Body.Input(initial,data,N.Free(word));
        state,tail:=Body.Run(code,destinations,prefix,7455,I.Magnitude(word,true),N.Free(word),initial,self,value,data,observations);
        E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
        SignedLayout(state.state.memory,word);
        state,tail:=Concat.Run(code,destinations,[],word,state.state.memory,self,value,data,observations);
        E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
        base:=C.Free(word);free:=C.End(word);
      } else {
        K.BaseFits();assert Body.Input(K.Base(),data,128);
        state,tail:=Body.Run(code,destinations,[I.Selector(false)],1362,word,128,K.Base(),self,value,data,observations);
        E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
        base:=128;free:=160+S.Round32(Body.Length(word));
      }
      state,tail:=Return.Run(code,destinations,I.Selector(signed),I.Result(data,signed),base,free,state.state.memory,self,value,data,observations);
      E.Join(code,destinations,self,value,data,observations,trace,tail);trace:=trace+tail[1..];
    }
  }
}

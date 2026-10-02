// SPDX-License-Identifier: MIT
// Complete raw stringAt correspondence candidate. Entire native closure pending.
include "../string-at-raw/Admission.dfy"
include "../string-at-entry-controls/Utf8Call.generated.dfy"
include "../string-at-entry-controls/IndexCall.generated.dfy"
include "../utf8-shared/Execution.generated.dfy"
include "../string-at-index-controls/Connection.dfy"
include "../string-at-body-controls/Ascii.generated.dfy"
include "../string-at-body-controls/NonAscii.generated.dfy"
include "../tostring-return/Return.generated.dfy"
module OperationsStringAtFull {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import M = BytecodeExternalMachine
  import E = OperationsCaseFoldExecution
  import I = OperationsStringAtInputs
  import K = OperationsStringAtKernel
  import Raw = OperationsStringAtRaw
  import Before = OperationsStringAtUtf8Call
  import After = OperationsStringAtIndexCall
  import UI = OperationsUtf8Inputs
  import UK = OperationsUtf8Kernel
  import U = OperationsUtf8Execution
  import N = OperationsStringAtIndexConnection
  import BM = OperationsStringAtBodyMemory
  import A = OperationsStringAtBodyAscii
  import B = OperationsStringAtBodyNonAscii
  import Q = OperationsToStringReturnKernel
  import R = OperationsToStringReturn
  predicate Matches(code:seq<S.Byte>) {
    Raw.Matches(code) && Before.Matches(code) && After.Matches(code) && U.Matches(code,7291) && N.Matches(code,7302) && A.Matches(code) && B.Matches(code) && R.Matches(code)
  }
  function Destinations():set<nat> {
    Raw.Destinations()+Before.Destinations()+After.Destinations()+U.Destinations(7291)+N.Destinations(7302)+A.Destinations()+B.Destinations()+R.Destinations()
  }
  function Expected(data:seq<S.Byte>,value:S.Word):M.Frame
    requires I.Frame(data)
  {
    var result:=I.Intended(data,value);
    if result.Success? then M.Frame(S.Returned(I.Packet(result)),[],0)
    else M.Frame(S.Reverted(I.Packet(result)),[],0)
  }
  lemma PayloadCell(data:seq<S.Byte>,value:S.Word,position:S.Word)
    requires I.Frame(data) && I.Admission(data,value)==I.Accepted && position<I.Length(data)
    ensures BM.Input(data,I.PayloadOffset(data),I.Length(data),position)
    ensures BM.Cell(data,I.PayloadOffset(data),I.Length(data),position)==I.Payload(data)[position]
  { I.AdmissionSpan(data,value); }
  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>) returns(state:M.Frame,trace:seq<M.Frame>)
    requires Matches(code) && Destinations()<=destinations && I.Frame(data) && I.Assigned(data,value)
    ensures state==Expected(data,value)
    ensures E.Trace(code,destinations,self,value,data,observations,trace) && trace[0]==M.Frame(S.Running(0,[],[]),[],0) && trace[|trace|-1]==state
  {
    state,trace:=Raw.Run(code,destinations,self,value,data,observations);
    if I.Admission(data,value)==I.Accepted {
      K.DecoderSpan(data,value);K.InitialFits();
      var offset:S.Word:=I.PayloadOffset(data);var length:=I.Length(data);var word:=I.IndexWord(data);
      var before,bt:=Before.Run(code,destinations,offset,length,word,self,value,data,observations);
      E.Join(code,destinations,self,value,data,observations,trace,bt);trace:=trace+bt[1..];state:=before;
      var utf,ut:=U.Run(code,destinations,[0xa1bc2139,1362,offset,length,word,96],7291,offset,length,K.Initial(),self,value,data,observations);
      E.Join(code,destinations,self,value,data,observations,trace,ut);trace:=trace+ut[1..];state:=utf;
      if UI.Check(I.Payload(data),0).Valid? {
        var after,at:=After.Run(code,destinations,offset,length,word,self,value,data,observations);
        E.Join(code,destinations,self,value,data,observations,trace,at);trace:=trace+at[1..];state:=after;
        var indexed,it:=N.Run(code,destinations,[0xa1bc2139,1362,offset,length,word,96,0],7302,word,length,self,value,data,observations);
        E.Join(code,destinations,self,value,data,observations,trace,it);trace:=trace+it[1..];state:=indexed;
        if I.InRange(word,length) {
          var position:S.Word:=I.Position(word,length);PayloadCell(data,value,position);
          if I.Payload(data)[position]<128 {
            var copiedState,mt:=A.Run(code,destinations,offset,length,word,position,data,self,value,observations);
            E.Join(code,destinations,self,value,data,observations,trace,mt);trace:=trace+mt[1..];state:=copiedState;
            BM.ReturnLayout(data,offset,length,position);
            var returned,rt:=R.Run(code,destinations,0xa1bc2139,[BM.Cell(data,offset,length,position)],128,192,BM.Finished(data,offset,length,position),self,value,data,observations);
            E.Join(code,destinations,self,value,data,observations,trace,rt);trace:=trace+rt[1..];state:=returned;
            assert Q.Canonical([BM.Cell(data,offset,length,position)])==I.Packet(I.Success(I.Payload(data)[position]));
          } else {
            var rejected,mt:=B.Run(code,destinations,offset,length,word,position,data,self,value,observations);
            E.Join(code,destinations,self,value,data,observations,trace,mt);trace:=trace+mt[1..];state:=rejected;
          }
        }
      }
    }
  }
}

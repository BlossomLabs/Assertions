// SPDX-License-Identifier: MIT
// PC-zero fold decoder, alignment and ordered accumulator/element admission.
include "../raw-entry/Range.generated.dfy"
include "../raw-entry/Source.generated.dfy"
include "../body-invocation/Range.generated.dfy"
include "../body-invocation/Bytes.generated.dfy"
include "../body-invocation/Words.generated.dfy"
include "../body-alignment-error/Unaligned.generated.dfy"
include "../accumulator-window/Connection.dfy"
include "../../external-calls/Execution.dfy"
module BytecodeFoldRawWindows {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import XM = BytecodeExternalMachine
  import XE = BytecodeExternalExecution
  import I = BytecodeFoldRawInputs
  import W = BytecodeFoldElementWindowInputs
  import R = BytecodeFoldRawEntryRange
  import S = BytecodeFoldRawEntrySource
  import RP = BytecodeFoldRangePrefix
  import BP = BytecodeFoldBytesPrefix
  import WP = BytecodeFoldWordsPrefix
  import BR = BytecodeFoldBodyInvokeRange
  import BB = BytecodeFoldBodyInvokeBytes
  import BW = BytecodeFoldBodyInvokeWords
  import A = BytecodeFoldBodyErrorUnaligned
  import V = BytecodeFoldWindowConnection
  predicate Matches(code: seq<Byte>) {
    R.Matches(code) && S.Matches(code) && BR.Matches(code) && BB.Matches(code) && BW.Matches(code) && A.Matches(code) && V.Matches(code)
  }
  function Destinations(): set<nat> {
    R.Destinations()+S.Destinations()+BR.Destinations()+BB.Destinations()+BW.Destinations()+A.Destinations()+V.Destinations()
  }
  predicate Admitted(data: seq<Byte>,domain: nat) {
    domain < 3 && (if domain == 0 then RP.Admitted(0,data) else if domain == 1 then BP.Admitted(0,data) else WP.Admitted(0,data))
  }
  function BodyPrefix(data: seq<Byte>,domain: nat): seq<Word>
    requires domain < 3
  {
    if domain == 0 then [4057501128,604]+BR.Decoded(data)+[0,8778]+BR.Arguments(data)+[0]
    else if domain == 1 then [1831135132,604]+BB.Decoded(data)+[0,5094]+BB.Arguments(data)+[0]
    else [1843793072,604]+BW.Decoded(data)+[0,5094]+BW.Arguments(data)+[0]
  }
  predicate Result(data: seq<Byte>,domain: nat,state: State)
    requires domain < 3
  {
    if !I.Fits(data,domain == 0) then state == Reverted([])
    else if domain == 2 && I.SourceLength(data)%32 != 0 then state == Reverted(G.Encode(0xa949d285,4)+G.Encode(I.SourceLength(data),32))
    else if I.TemplateLength(data) < 32 then state == V.Error(I.AccOffset(data),I.TemplateLength(data))
    else if I.AccOffset(data) > I.TemplateLength(data)-32 then state == V.Error(I.AccOffset(data),I.TemplateLength(data))
    else if W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data) then state == Running(12029,BodyPrefix(data,domain),Store([],64,128))
    else exists bad: Word :: bad < I.Count(data) && W.At(I.Offset(I.ArrayHead(data)),bad,data) > I.TemplateLength(data)-32 &&
                             (forall j: nat :: j < bad ==> W.At(I.Offset(I.ArrayHead(data)),j,data) <= I.TemplateLength(data)-32) && state == V.Error(W.At(I.Offset(I.ArrayHead(data)),bad,data),I.TemplateLength(data))
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,domain: nat) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,domain)
    ensures Result(data,domain,state)
    ensures E.Trace(code,Destinations(),0,data,trace) && |trace| > 0
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {
    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); hide E.Trace();
    var part: seq<State>;
    if domain == 0 {
      state,trace := R.RunRange(code,data);
      E.WidenTrace(code,R.Destinations(),Destinations(),0,data,trace);
    } else if domain == 1 {
      state,trace := S.RunBytes(code,data);
      E.WidenTrace(code,S.Destinations(),Destinations(),0,data,trace);
    } else {
      state,trace := S.RunWords(code,data);
      E.WidenTrace(code,S.Destinations(),Destinations(),0,data,trace);
    }
    if I.Fits(data,domain == 0) {
      if domain == 2 && I.SourceLength(data)%32 != 0 {
        state,part := A.Run(code,[1843793072],604,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.AccOffset(data),I.Offset(I.ArrayHead(data)),I.Count(data),I.Initial(data),I.Exit(data),0,data);
        E.WidenTrace(code,A.Destinations(),Destinations(),0,data,part);
        assert trace[|trace|-1] == part[0];
        E.Join(code,Destinations(),0,data,trace,part); trace := trace+part[1..];
      } else {
        if domain == 0 {
          reveal BR.Admitted();
          state,part := BR.Run(code,data,Store([],64,128),[4057501128],604,0);
          E.WidenTrace(code,BR.Destinations(),Destinations(),0,data,part);
        } else if domain == 1 {
          reveal BB.Admitted();
          state,part := BB.Run(code,data,Store([],64,128),[1831135132],604,0);
          E.WidenTrace(code,BB.Destinations(),Destinations(),0,data,part);
        } else {
          reveal BW.Admitted();
          state,part := BW.Run(code,data,Store([],64,128),[1843793072],604,0);
          E.WidenTrace(code,BW.Destinations(),Destinations(),0,data,part);
        }
        assert trace[|trace|-1] == part[0];
        E.Join(code,Destinations(),0,data,trace,part); trace := trace+part[1..];
        W.RawFrame(data,domain == 0);
        state,part := V.Run(code,data,BodyPrefix(data,domain),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.AccOffset(data),I.Offset(I.ArrayHead(data)),I.Count(data),0);
        E.WidenTrace(code,V.Destinations(),Destinations(),0,data,part);
        assert trace[|trace|-1] == part[0];
        E.Join(code,Destinations(),0,data,trace,part); trace := trace+part[1..];
      }
    }
  }
  ghost method ExternalRun(code: seq<Byte>,data: seq<Byte>,domain: nat,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<XM.Observation>) returns (frame: XM.Frame,trace: seq<XM.Frame>)
    requires Matches(code) && Admitted(data,domain) && XM.Context(self)
    ensures Result(data,domain,frame.state) && frame.returned == oldReturn && frame.cursor == cursor
    ensures XE.Trace(code,Destinations(),self,0,data,observations,trace) && |trace| > 0
    ensures trace[0] == XM.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    var state: State; var states: seq<State>;
    state,states := Run(code,data,domain);
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    {
      assert Step(code,Destinations(),states[i],0,data) != Bad;
      reveal Step();
    }
    C.Lift(code,Destinations(),0,data,states);
    XE.Lift(code,Destinations(),self,0,data,observations,states,oldReturn,cursor);
    trace := seq(|states|,i requires 0 <= i < |states| => XM.Frame(states[i],oldReturn,cursor));
    frame := trace[|trace|-1];
  }
}

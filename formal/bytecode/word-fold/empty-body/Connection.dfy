// SPDX-License-Identifier: MIT
// Exact raw successful empty folds return the full initial word after every window check.
include "Range.generated.dfy"
include "Bytes.generated.dfy"
include "Words.generated.dfy"
include "../raw-windows/Connection.dfy"
module BytecodeFoldRawEmpty {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import XM = BytecodeExternalMachine
  import XE = BytecodeExternalExecution
  import I = BytecodeFoldRawInputs
  import W = BytecodeFoldElementWindowInputs
  import R = BytecodeFoldRawWindows
  import ER = BytecodeFoldEmptyBodyRange
  import EB = BytecodeFoldEmptyBodyBytes
  import EW = BytecodeFoldEmptyBodyWords
  predicate Matches(code: seq<Byte>) { R.Matches(code) && ER.Matches(code) && EB.Matches(code) && EW.Matches(code) }
  function Destinations(): set<nat> { R.Destinations()+ER.Destinations()+EB.Destinations()+EW.Destinations() }
  function Count(data: seq<Byte>,domain: nat): Word
    requires domain < 3
  {
    if domain == 0 then I.RangeCount(data) else if domain == 1 then I.SourceLength(data) else (I.SourceLength(data) as nat)/32
  }
  predicate Empty(data: seq<Byte>,domain: nat)
    requires domain < 3
  {
    if domain == 0 then I.RangeCount(data) == 0 else I.SourceLength(data) == 0
  }
  lemma EmptyEquivalent(data: seq<Byte>,domain: nat)
    requires domain < 3 && (domain != 2 || I.SourceLength(data)%32 == 0)
    ensures Empty(data,domain) <==> Count(data,domain) == 0
  {}
  predicate Admitted(data: seq<Byte>,domain: nat) {
    domain < 3 && R.Admitted(data,domain) && I.Fits(data,domain == 0) && Empty(data,domain) &&
    W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data) && I.AccOffset(data) <= I.TemplateLength(data)-32
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,domain: nat) returns (state: State,trace: seq<State>)
    requires Matches(code) && Admitted(data,domain)
    ensures state == Returned(G.Encode(I.Initial(data),32))
    ensures E.Trace(code,Destinations(),0,data,trace) && |trace| > 0
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {
    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); hide E.Trace();
    state,trace := R.Run(code,data,domain);
    E.WidenTrace(code,R.Destinations(),Destinations(),0,data,trace);
    assert state == Running(12029,R.BodyPrefix(data,domain),Store([],64,128));
    var part: seq<State>;
    if domain == 0 {
      reveal ER.Admitted();
      state,part := ER.Run(code,data,Store([],64,128),[4057501128],604,0);
      E.WidenTrace(code,ER.Destinations(),Destinations(),0,data,part);
    } else if domain == 1 {
      reveal EB.Admitted();
      state,part := EB.Run(code,data,Store([],64,128),[1831135132],604,0);
      E.WidenTrace(code,EB.Destinations(),Destinations(),0,data,part);
    } else {
      reveal EW.Admitted();
      state,part := EW.Run(code,data,Store([],64,128),[1843793072],604,0);
      E.WidenTrace(code,EW.Destinations(),Destinations(),0,data,part);
    }
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),0,data,trace,part); trace := trace+part[1..];
  }
  ghost method ExternalRun(code: seq<Byte>,data: seq<Byte>,domain: nat,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<XM.Observation>) returns (frame: XM.Frame,trace: seq<XM.Frame>)
    requires Matches(code) && Admitted(data,domain) && XM.Context(self)
    ensures frame == XM.Frame(Returned(G.Encode(I.Initial(data),32)),oldReturn,cursor)
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

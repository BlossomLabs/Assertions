// SPDX-License-Identifier: MIT
// Complete raw foldWords priority: decoder accepts, then alignment error precedes windows/callbacks.
include "Unaligned.generated.dfy"
include "../raw-entry/Source.generated.dfy"
include "../../external-calls/Execution.dfy"
module BytecodeFoldRawAlignmentError {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeFoldRawInputs
  import D = BytecodeFoldRawEntrySource
  import P = BytecodeFoldWordsPrefix
  import A = BytecodeFoldBodyErrorUnaligned
  predicate Matches(code: seq<Byte>) { D.Matches(code) && A.Matches(code) }
  function Destinations(): set<nat> { D.Destinations()+A.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>) returns (state: State,trace: seq<State>)
    requires Matches(code) && P.Admitted(0,data) && I.Fits(data,false)
    requires I.SourceLength(data)%32 != 0
    ensures state == Reverted(G.Encode(0xa949d285,4)+G.Encode(I.SourceLength(data),32))
    ensures S.Trace(code,Destinations(),0,data,trace) && |trace| > 0
    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state
  {
    var part: seq<State>;
    state,trace := D.RunWords(code,data);
    S.WidenTrace(code,D.Destinations(),Destinations(),0,data,trace);
    state,part := A.Run(code,[1843793072],604,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.AccOffset(data),I.Offset(I.ArrayHead(data)),I.Count(data),I.Initial(data),I.Exit(data),0,data);
    S.WidenTrace(code,A.Destinations(),Destinations(),0,data,part);
    assert trace[|trace|-1] == part[0];
    S.Join(code,Destinations(),0,data,trace,part);
    trace := trace+part[1..];
  }
  ghost method ExternalRun(code: seq<Byte>,data: seq<Byte>,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && P.Admitted(0,data) && I.Fits(data,false)
    requires I.SourceLength(data)%32 != 0 && X.Context(self)
    ensures frame == X.Frame(Reverted(G.Encode(0xa949d285,4)+G.Encode(I.SourceLength(data),32)),oldReturn,cursor)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace) && |trace| > 0
    ensures trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    var state: State; var states: seq<State>;
    state,states := Run(code,data);
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    {
      assert Step(code,Destinations(),states[i],0,data) != Bad;
      reveal Step();
    }
    C.Lift(code,Destinations(),0,data,states);
    E.Lift(code,Destinations(),self,0,data,observations,states,oldReturn,cursor);
    trace := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor));
    frame := trace[|trace|-1];
  }
}

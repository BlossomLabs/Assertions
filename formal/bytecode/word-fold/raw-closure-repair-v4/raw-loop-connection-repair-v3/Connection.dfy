// SPDX-License-Identifier: MIT
// Complete raw successful nonempty folds through actual32-byte public RETURN.
include "../raw-loop-ready-repair-v2/Memory.dfy"
include "../../loop-connection-repair-v2/Loop.dfy"
include "../../scalar-return/Range.generated.dfy"
include "../../scalar-return/Bytes.generated.dfy"
include "../../scalar-return/Words.generated.dfy"
module BytecodeFoldRawLoopConnectionV3 {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import S = BytecodeScanExecution
  import I = BytecodeFoldRawInputs
  import T = BytecodeFoldRawTemplate
  import W = BytecodeFoldRawWindows
  import RT = BytecodeFoldRawTarget
  import P = BytecodeFoldRawLoopReadyV2
  import L = BytecodeFoldLoopModelV2
  import D = BytecodeFoldDomainConnectionV3
  import C = BytecodeFoldLoopConnectionV2
  import A = BytecodeFoldSuccessfulIterationV2
  import H = BytecodeApplyCallbackSuccessMemory
  import CB = BytecodeFoldCallbackEngine
  import RR = BytecodeFoldScalarReturnRange
  import RB = BytecodeFoldScalarReturnBytes
  import RW = BytecodeFoldScalarReturnWords
  predicate Matches(code: seq<Byte>) { T.Matches(code) && C.Matches(code) && RR.Matches(code) && RB.Matches(code) && RW.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+C.Destinations()+RR.Destinations()+RB.Destinations()+RW.Destinations() }
  lemma Initial(data: seq<Byte>,domain: nat,oldReturn: seq<Byte>,cursor: nat)
    requires RT.Admitted(data,domain)
    ensures X.Frame(Running(16484,T.LoopStack(data,domain),T.LoopMemory(data,domain)),oldReturn,cursor) ==
            C.Initial(W.BodyPrefix(data,domain)+[128],P.Config(data,domain),0,T.LoopMemory(data,domain),oldReturn,cursor)
  {
    hide DataWord();hide T.LoopMemory();hide W.BodyPrefix();
    reveal P.Config();reveal T.LoopStack();reveal C.Initial();reveal D.Fields();
    var c := P.Config(data,domain);
    var prefix := W.BodyPrefix(data,domain);
    var fields := D.Fields(12157,c.sourceOffset,c.sourceLength,c.templateOffset,c.templateLength,c.arrayOffset,c.count,c.returnWord,c.callPtr,0);
    assert fields == [12157,128,T.SourceOffset(data,domain),T.SourceLength(data,domain),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),0,320,0];
    assert T.LoopStack(data,domain) == prefix+([128]+fields);
    assert prefix+([128]+fields) == (prefix+[128])+fields;
  }
  lemma ReturnStack(data: seq<Byte>,domain: nat,word: Word)
    requires domain < 3
    ensures W.BodyPrefix(data,domain)+[128,word] ==
            (if domain == 0 then [4057501128,604]+RR.Decoded(data)+[0,8778]+RR.Arguments(data)+[0,128,word]
             else if domain == 1 then [1831135132,604]+RB.Decoded(data)+[0,5094]+RB.Arguments(data)+[0,128,word]
             else [1843793072,604]+RW.Decoded(data)+[0,5094]+RW.Arguments(data)+[0,128,word])
  { hide DataWord(); }
  lemma CallerBounds(data: seq<Byte>,domain: nat)
    requires domain < 3
    ensures |W.BodyPrefix(data,domain)+[128]| <= 970
  {
    hide DataWord();
    reveal W.BodyPrefix();
    if domain == 0 { assert |RR.Decoded(data)| == 9 && |RR.Arguments(data)| == 12; }
    else if domain == 1 { assert |RB.Decoded(data)| == 10 && |RB.Arguments(data)| == 12; }
    else { assert |RW.Decoded(data)| == 10 && |RW.Arguments(data)| == 12; }
  }
  lemma AppendReturn(prefix: seq<Word>,word: Word)
    ensures (prefix+[128])+[word] == prefix+[128,word]
  { }
  lemma FinalReady(data: seq<Byte>,mem: seq<Byte>,c: L.Configuration,index: Word,receipts: seq<L.Receipt>)
    requires L.Resources(data,mem,c,index,receipts)
    ensures L.Ready(data,L.Result(data,mem,c,index,receipts).memory,c)
    decreases |receipts|
  {
    hide L.Result();hide L.Next();
    C.ResultHead(data,mem,c,index,receipts);
    if index != c.total {
      var next := L.Next(data,mem,c,index,receipts[0]);
      L.Readmission(data,mem,c,index,receipts[0]);
      if !A.Stop(c.exit,H.Result(receipts[0].returned)) {
        FinalReady(data,next,c,index+1,receipts[1..]);
      }
    }
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,domain: nat,self: Word,codeSize: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>,receipts: seq<L.Receipt>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && RT.Admitted(data,domain) && X.Context(self) && codeSize > 0
    requires cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    requires L.Resources(data,T.LoopMemory(data,domain),P.Config(data,domain),0,receipts)
    requires L.Truthful(data,T.LoopMemory(data,domain),P.Config(data,domain),0,receipts,self,cursor+1,observations)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures |trace| > 0 && trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
    ensures var result := L.Result(data,T.LoopMemory(data,domain),P.Config(data,domain),0,receipts);
            frame == X.Frame(Returned(G.Encode(result.word,32)),L.LastReturn(receipts,result.used,oldReturn),cursor+1+3*result.used)
  {
    hide DataWord();hide ShiftRight();hide E.Trace();hide S.Trace();hide L.Result();hide L.Next();hide T.LoopMemory();hide P.Config();hide C.Initial();hide W.BodyPrefix();
    P.Ready(data,domain);
    var c := P.Config(data,domain);var initial := T.LoopMemory(data,domain);
    frame,trace := T.Run(code,data,domain,self,codeSize,oldReturn,cursor,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
    var part: seq<X.Frame>;
    CallerBounds(data,domain);
    Initial(data,domain,oldReturn,cursor+1);
    assert frame == C.Initial(W.BodyPrefix(data,domain)+[128],c,0,initial,oldReturn,cursor+1);
    frame,part := C.Run(code,data,initial,W.BodyPrefix(data,domain)+[128],c,0,receipts,self,0,oldReturn,cursor+1,observations);
    E.WidenTrace(code,C.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    FinalReady(data,initial,c,0,receipts);
    var result := L.Result(data,initial,c,0,receipts);
    var returned := L.LastReturn(receipts,result.used,oldReturn);var nextCursor := cursor+1+3*result.used;
    AppendReturn(W.BodyPrefix(data,domain),result.word);
    ReturnStack(data,domain,result.word);
    assert frame == X.Frame(Running(12157,W.BodyPrefix(data,domain)+[128,result.word],result.memory),returned,nextCursor);
    var state: State;var states: seq<State>;
    if domain == 0 {
      reveal RR.Admitted();
      state,states := RR.Run(code,data,result.memory,[4057501128],604,result.word,Load(result.memory,64),0);
      S.WidenTrace(code,RR.Destinations(),Destinations(),0,data,states);
      assert states[0] == Running(12157,W.BodyPrefix(data,domain)+[128,result.word],result.memory);
    } else if domain == 1 {
      reveal RB.Admitted();
      state,states := RB.Run(code,data,result.memory,[1831135132],604,result.word,Load(result.memory,64),0);
      S.WidenTrace(code,RB.Destinations(),Destinations(),0,data,states);
      assert states[0] == Running(12157,W.BodyPrefix(data,domain)+[128,result.word],result.memory);
    } else {
      reveal RW.Admitted();
      state,states := RW.Run(code,data,result.memory,[1843793072],604,result.word,Load(result.memory,64),0);
      S.WidenTrace(code,RW.Destinations(),Destinations(),0,data,states);
      assert states[0] == Running(12157,W.BodyPrefix(data,domain)+[128,result.word],result.memory);
    }
    CB.Lift(code,Destinations(),data,0,states,self,returned,nextCursor,observations);
    part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,nextCursor));
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    frame := part[|part|-1];
  }
}

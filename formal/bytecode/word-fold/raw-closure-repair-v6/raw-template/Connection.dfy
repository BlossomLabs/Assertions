// SPDX-License-Identifier: MIT
// PC-zero fold admission, truthful target check, six-word allocation and physical template copy.
include "../raw-target/Connection.dfy"
include "../../run-allocation-repair-v2/Range.generated.dfy"
include "../../run-allocation-repair-v2/Bytes.generated.dfy"
include "../../run-allocation-repair-v2/Words.generated.dfy"
include "../../template-copy/Copy.generated.dfy"
include "../../template-copy-frames-repair-v2/Memory.dfy"
module BytecodeFoldRawTemplate {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeFoldRawInputs
  import R = BytecodeFoldRawWindows
  import T = BytecodeFoldRawTarget
  import AR = BytecodeFoldRunAllocationRange
  import AB = BytecodeFoldRunAllocationBytes
  import AW = BytecodeFoldRunAllocationWords
  import A = BytecodeFoldRunMemory
  import P = BytecodeFoldTemplateCopy
  import H = BytecodeApplyTemplateMemory
  import F = BytecodeFoldTemplateFrames
  predicate Matches(code: seq<Byte>) { T.Matches(code) && AR.Matches(code) && AB.Matches(code) && AW.Matches(code) && P.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+AR.Destinations()+AB.Destinations()+AW.Destinations()+P.Destinations() }
  function SourceOffset(data: seq<Byte>,domain: nat): Word
    requires domain < 3
  { if domain == 0 then 0 else I.Offset(I.SourceHead(data)) }
  function SourceLength(data: seq<Byte>,domain: nat): Word
    requires domain < 3
  { if domain == 0 then 0 else I.SourceLength(data) }
  function LoopStack(data: seq<Byte>,domain: nat): seq<Word>
    requires domain < 3
  { R.BodyPrefix(data,domain)+[128,12157,128,SourceOffset(data,domain),SourceLength(data,domain),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),0,320,0] }
  function LoopMemory(data: seq<Byte>,domain: nat): seq<Byte>
    requires domain < 3 && I.Fits(data,domain == 0)
  { H.Complete(A.Heap(data,domain),320,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data) }
  lemma MemoryLayout(data: seq<Byte>,domain: nat)
    requires domain < 3 && I.Fits(data,domain == 0)
    ensures forall j: nat :: j < 6 ==> Load(LoopMemory(data,domain),128+32*j) == A.Slots(data,domain)[j]
    ensures LoopMemory(data,domain)[352..352+I.TemplateLength(data)] == data[I.Offset(I.TemplateHead(data))..I.Offset(I.TemplateHead(data))+I.TemplateLength(data)]
  {
    A.Layout(data,domain); A.Frames(data,domain,6);
    I.Pointer(I.TemplateHead(data));
    var heap := A.Heap(data,domain);
    assert F.Admitted(heap,320,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data);
    F.Payload(heap,320,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data);
    forall j: nat | j < 6
      ensures Load(LoopMemory(data,domain),128+32*j) == A.Slots(data,domain)[j]
    { F.WordFrame(heap,320,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data,128+32*j); }
  }
  ghost method ScanLift(code: seq<Byte>,data: seq<Byte>,states: seq<State>,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frames: seq<X.Frame>)
    requires S.Trace(code,Destinations(),0,data,states)
    ensures E.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames == seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor))
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    { assert Step(code,Destinations(),states[i],0,data) != Bad; reveal Step(); }
    C.Lift(code,Destinations(),0,data,states);
    E.Lift(code,Destinations(),self,0,data,observations,states,oldReturn,cursor);
    frames := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor));
  }
  lemma LiftEndpoints(states: seq<State>, returned: seq<Byte>, cursor: nat)
    requires |states| > 0
    ensures var frames := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor));
            frames[0] == X.Frame(states[0],returned,cursor) && frames[|frames|-1] == X.Frame(states[|states|-1],returned,cursor)
  {}
  lemma CopyStack(prefix: seq<Word>, sourceOffset: Word, sourceLength: Word, templateOffset: Word, templateLength: Word, arrayOffset: Word, count: Word)
    ensures prefix+[128,12157,128,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count] ==
            (prefix+[128])+[12157,128,sourceOffset,sourceLength,templateOffset,templateLength,arrayOffset,count]
  {}
  ghost method Run(code: seq<Byte>,data: seq<Byte>,domain: nat,self: Word,codeSize: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && T.Admitted(data,domain) && X.Context(self) && codeSize > 0
    requires cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    ensures frame == X.Frame(Running(16484,LoopStack(data,domain),LoopMemory(data,domain)),oldReturn,cursor+1)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace) && |trace| > 0
    ensures trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
    ensures forall j: nat :: j < 6 ==> Load(LoopMemory(data,domain),128+32*j) == A.Slots(data,domain)[j]
    ensures LoopMemory(data,domain)[352..352+I.TemplateLength(data)] == data[I.Offset(I.TemplateHead(data))..I.Offset(I.TemplateHead(data))+I.TemplateLength(data)]
  {
    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); hide S.Trace(); hide E.Trace(); hide C.Trace();
    frame,trace := T.Run(code,data,domain,self,codeSize,oldReturn,cursor,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
    var state: State; var states: seq<State>;
    if domain == 0 {
      reveal AR.Admitted();
      state,states := AR.Run(code,data,Store([],64,128),[4057501128],604,0);
      S.WidenTrace(code,AR.Destinations(),Destinations(),0,data,states);
    } else if domain == 1 {
      reveal AB.Admitted();
      state,states := AB.Run(code,data,Store([],64,128),[1831135132],604,0);
      S.WidenTrace(code,AB.Destinations(),Destinations(),0,data,states);
    } else {
      reveal AW.Admitted();
      state,states := AW.Run(code,data,Store([],64,128),[1843793072],604,0);
      S.WidenTrace(code,AW.Destinations(),Destinations(),0,data,states);
    }
    LiftEndpoints(states,oldReturn,cursor+1);
    assert states[0] == Running(12052,R.BodyPrefix(data,domain),Store([],64,128));
    var part := ScanLift(code,data,states,self,oldReturn,cursor+1,observations);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
    A.Layout(data,domain); I.Pointer(I.TemplateHead(data));
    assert state == Running(16426,R.BodyPrefix(data,domain)+[128,12157,128,SourceOffset(data,domain),SourceLength(data,domain),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data)],A.Heap(data,domain));
    assert P.Admitted(data,A.Heap(data,domain),R.BodyPrefix(data,domain)+[128],12157,128,SourceOffset(data,domain),SourceLength(data,domain),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),320);
    CopyStack(R.BodyPrefix(data,domain),SourceOffset(data,domain),SourceLength(data,domain),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data));
    var copyStart := state;
    assert trace[|trace|-1] == X.Frame(copyStart,oldReturn,cursor+1);
    state,states := P.Run(code,data,A.Heap(data,domain),R.BodyPrefix(data,domain)+[128],12157,128,SourceOffset(data,domain),SourceLength(data,domain),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),320,0);
    assert states[0] == copyStart;
    LiftEndpoints(states,oldReturn,cursor+1);
    C.WidenTrace(code,P.Destinations(),Destinations(),0,data,states);
    E.Lift(code,Destinations(),self,0,data,observations,states,oldReturn,cursor+1);
    part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor+1));
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
    frame := part[|part|-1];
    MemoryLayout(data,domain);
  }
}

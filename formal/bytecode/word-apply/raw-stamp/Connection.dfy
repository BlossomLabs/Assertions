// SPDX-License-Identifier: MIT
include "../raw-element-read/Connection.dfy"
include "../stamp-invocation/Invoke.generated.dfy"
include "../stamp-engine/Engine.dfy"
include "Memory.dfy"
module BytecodeApplyRawFirstStamp {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import W = BytecodeApplyWindowInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import R = BytecodeApplyRawAdmission
  import T = BytecodeApplyRawFirstElement
  import A = BytecodeApplyAllocationMemory
  import O = BytecodeIotaOutput
  import H = BytecodeApplyTemplateMemory
  import V = BytecodeApplyStampInvoke
  import B = BytecodeApplyStampEngine
  import M = BytecodeApplyStampMemory
  import F = BytecodeApplyRawStampMemory
  import P = BytecodeApplyFirstElementPost
  predicate Matches(code: seq<Byte>) { T.Matches(code) && V.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+V.Destinations()+B.Destinations() }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool,self: Word,returned: seq<Byte>,cursor: nat,codeSize: Word,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && I.Fits(data) && 0 < I.SourceLength(data) && I.SourceLength(data)%32 == 0
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    requires X.Context(self) && 0 < codeSize && cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    ensures var n: Word := I.SourceLength(data)/32;
            M.Fits(H.Complete(A.Heap(n),O.Extent(n),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data),O.Extent(n),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    ensures var n: Word := I.SourceLength(data)/32;
            var word := P.Original(data);
            var mem := H.Complete(A.Heap(n),O.Extent(n),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data);
            frame == X.Frame(Running(12472,[if filter then 2005396296 else 3983393726,518]+R.Fields(data)+[96,5526]+R.Fields(data)+[if filter then 1 else 0,128,n,0,O.Extent(n),0,word],M.Stamped(mem,O.Extent(n),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data,word,I.Count(data))),returned,cursor+1)
    ensures (I.Offset(I.SourceHead(data)) as nat)+32 <= |data|
    ensures P.Original(data) == G.Decode(data[I.Offset(I.SourceHead(data))..I.Offset(I.SourceHead(data))+32])
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(0,[],[]),returned,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if filter then 730 else 724)+93*(I.Count(data) as nat)
  {
    hide G.BitAnd();
    P.Decode(data);
    var n: Word := I.SourceLength(data)/32;
    var selector: Word := if filter then 2005396296 else 3983393726;
    var mode: Word := if filter then 1 else 0;
    var prefix := [selector,518]+R.Fields(data)+[96];
    var mem := H.Complete(A.Heap(n),O.Extent(n),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data);
    var word: Word := P.Original(data);
    frame,trace := T.Run(code,data,filter,self,returned,cursor,codeSize,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
    var state: State;
    var states: seq<State>;
    state,states := V.Run(code,data,mem,prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),mode,128,n,0,O.Extent(n),0,word,0);
    T.Lift(code,V.Destinations(),data,states,self,returned,cursor+1,observations);
    var part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor+1));
    E.WidenTrace(code,V.Destinations(),Destinations(),self,0,data,observations,part);
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    F.CompleteFits(n,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data);
    var stampPrefix := prefix+[5526]+R.Fields(data)+[mode,128,n,0,O.Extent(n),0,word];
    state,states := B.Run(code,data,mem,stampPrefix,O.Extent(n),I.Offset(I.ArrayHead(data)),I.Count(data),word,I.TemplateLength(data),0);
    T.Lift(code,B.Destinations(),data,states,self,returned,cursor+1,observations);
    part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor+1));
    E.WidenTrace(code,B.Destinations(),Destinations(),self,0,data,observations,part);
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];frame := part[|part|-1];
  }
}

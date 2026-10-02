// SPDX-License-Identifier: MIT
// Actual raw positive target admission through template allocation/copy and initial loop.
include "../raw-target/Connection.dfy"
include "../template-copy/Copy.generated.dfy"
include "Post.dfy"
module BytecodeApplyRawTemplateCopy {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import W = BytecodeApplyWindowInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import R = BytecodeApplyRawAdmission
  import T = BytecodeApplyRawPositiveTarget
  import M = BytecodeApplyAllocationMemory
  import O = BytecodeIotaOutput
  import C = BytecodeApplyTemplateCopy
  import H = BytecodeApplyTemplateMemory
  import F = BytecodeApplyTemplateFrame
  import P = BytecodeApplyRawTemplatePost
  predicate Matches(code: seq<Byte>) { T.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+C.Destinations() }
  ghost method Run(code: seq<Byte>, data: seq<Byte>, filter: bool, self: Word, returned: seq<Byte>, cursor: nat, codeSize: Word, observations: seq<X.Observation>)
    returns (frame: X.Frame, trace: seq<X.Frame>)
    requires Matches(code) && I.Fits(data) && 0 < I.SourceLength(data) && I.SourceLength(data)%32 == 0
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    requires X.Context(self) && 0 < codeSize && cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    ensures var n: Word := I.SourceLength(data)/32;
            frame == X.Frame(Running(12391,[if filter then 2005396296 else 3983393726,518]+R.Fields(data)+[96,5526]+R.Fields(data)+[if filter then 1 else 0,128,n,0,O.Extent(n),0],H.Complete(M.Heap(n),O.Extent(n),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data)),returned,cursor+1)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(0,[],[]),returned,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if filter then 562 else 556)+53*(I.Count(data) as nat)
    ensures var n: Word := I.SourceLength(data)/32;
            forall j: nat :: j < O.Extent(n) && (j < 64 || 96 <= j) ==> frame.state.memory[j] == M.Heap(n)[j]
    ensures var n: Word := I.SourceLength(data)/32;
            forall j: nat {:trigger frame.state.memory[O.Extent(n)+32+j]} :: j < I.TemplateLength(data) ==> frame.state.memory[O.Extent(n)+32+j] == data[I.Offset(I.TemplateHead(data))+j]
  {
    var n: Word := I.SourceLength(data)/32;
    assert 0 < n < 0x800000000000000;
    var selector: Word := if filter then 2005396296 else 3983393726;
    var mode: Word := if filter then 1 else 0;
    var prefix := [selector,518]+R.Fields(data)+[96];
    frame,trace := T.Run(code,data,filter,self,returned,cursor,codeSize,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
    F.Bounds(n,I.TemplateLength(data));
    var state: State;
    var states: seq<State>;
    state,states := C.Run(code,data,M.Heap(n),prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),mode,n,O.Extent(n),0);
    E.Lift(code,C.Destinations(),self,0,data,observations,states,returned,cursor+1);
    var part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor+1));
    E.WidenTrace(code,C.Destinations(),Destinations(),self,0,data,observations,part);
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
    frame := part[|part|-1];
    P.Original(frame,n,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data);
    P.Payload(frame,n,I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data);
  }
}

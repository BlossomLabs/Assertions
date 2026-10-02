// SPDX-License-Identifier: MIT
include "../raw-template/Connection.dfy"
include "../element-read/Read.generated.dfy"
include "Post.dfy"
module BytecodeApplyRawFirstElement {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import W = BytecodeApplyWindowInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import R = BytecodeApplyRawAdmission
  import T = BytecodeApplyRawTemplateCopy
  import M = BytecodeApplyAllocationMemory
  import O = BytecodeIotaOutput
  import H = BytecodeApplyTemplateMemory
  import C = BytecodeApplyElementRead
  import SR = BytecodeScanRepresentation
  import P = BytecodeApplyFirstElementPost
  import S = BytecodeScanExecution
  import CE = BytecodeCopyExecution
  predicate Matches(code: seq<Byte>) { T.Matches(code) && C.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+C.Destinations() }
  lemma Lift(code: seq<Byte>,small: set<nat>,data: seq<Byte>,states: seq<State>,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>)
    requires S.Trace(code,small,0,data,states)
    ensures E.Trace(code,small,self,0,data,observations,seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor)))
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    { assert Step(code,small,states[i],0,data) != Bad; reveal Step(); }
    CE.Lift(code,small,0,data,states);
    E.Lift(code,small,self,0,data,observations,states,returned,cursor);
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool,self: Word,returned: seq<Byte>,cursor: nat,codeSize: Word,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && I.Fits(data) && 0 < I.SourceLength(data) && I.SourceLength(data)%32 == 0
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
    requires X.Context(self) && 0 < codeSize && cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    ensures var n: Word := I.SourceLength(data)/32;
            frame == X.Frame(Running(12458,[if filter then 2005396296 else 3983393726,518]+R.Fields(data)+[96,5526]+R.Fields(data)+[if filter then 1 else 0,128,n,0,O.Extent(n),0,0,P.Original(data)],H.Complete(M.Heap(n),O.Extent(n),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data)),returned,cursor+1)
    ensures (I.Offset(I.SourceHead(data)) as nat)+32 <= |data|
    ensures P.Original(data) == G.Decode(data[I.Offset(I.SourceHead(data))..I.Offset(I.SourceHead(data))+32])
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(0,[],[]),returned,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if filter then 704 else 698)+53*(I.Count(data) as nat)
  {
    hide G.BitAnd();
    P.Decode(data);
    var n: Word := I.SourceLength(data)/32;
    var selector: Word := if filter then 2005396296 else 3983393726;
    var mode: Word := if filter then 1 else 0;
    var prefix := [selector,518]+R.Fields(data)+[96];
    frame,trace := T.Run(code,data,filter,self,returned,cursor,codeSize,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
    assert I.SourceLength(data) == n*32;
    var state: State;
    var states: seq<State>;
    state,states := C.Run(code,data,H.Complete(M.Heap(n),O.Extent(n),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),data),prefix,5526,I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),mode,128,n,0,O.Extent(n),0,0);
    P.Decode(data);
    Lift(code,C.Destinations(),data,states,self,returned,cursor+1,observations);
    var part := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor+1));
    E.WidenTrace(code,C.Destinations(),Destinations(),self,0,data,observations,part);
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
    frame := part[|part|-1];
  }
}

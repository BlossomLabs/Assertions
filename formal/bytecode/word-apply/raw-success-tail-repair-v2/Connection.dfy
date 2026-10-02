// SPDX-License-Identifier: MIT
// Exact loop exit and physical serializer connection with isolated memory/frame contracts.
include "../raw-success/Bindings.dfy"
include "../loop-exit/Map.generated.dfy"
include "../loop-exit/Filter.generated.dfy"
include "../serializer-repair-v2/Control.generated.dfy"
module BytecodeApplyRawSuccessfulTail {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import L = BytecodeApplyRawLoopState
  import V = BytecodeApplySuccessfulRawLoopEngine
  import B = BytecodeApplyRawIterationBounds
  import O = BytecodeIotaOutput
  import Y = BytecodeApplyRawLoopOutputBytes
  import P = BytecodeApplyRawSuccessfulOutput
  import Z = BytecodeApplyRawSuccessfulBindings
  import EM = BytecodeApplyLoopExitMap
  import EF = BytecodeApplyLoopExitFilter
  import A = BytecodeApplyBytesReturnMemory
  import AC = BytecodeApplyBytesReturnControl
  predicate Matches(code: seq<Byte>) { EM.Matches(code) && EF.Matches(code) && AC.Matches(code) }
  function Destinations(): set<nat> { EM.Destinations()+EF.Destinations()+AC.Destinations() }
  ghost method Lift(code: seq<Byte>,small: set<nat>,data: seq<Byte>,states: seq<State>,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frames: seq<X.Frame>)
    requires small <= Destinations() && S.Trace(code,small,0,data,states)
    ensures E.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames == seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor))
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    { assert Step(code,small,states[i],0,data) != Bad; reveal Step(); }
    C.Lift(code,small,0,data,states);
    E.Lift(code,small,self,0,data,observations,states,returned,cursor);
    frames := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor));
    E.WidenTrace(code,small,Destinations(),self,0,data,observations,frames);
  }
  ghost method Exit(code: seq<Byte>,data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && L.Receipts(data,filter,receipts) && X.Context(self)
    ensures frame == X.Frame(Running(518,[Z.Selector(filter),128],P.Final(data,filter,receipts)),returned,cursor)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(12391,V.Stack(data,filter,receipts,Z.Prefix(data,filter),5526,L.N(data)),L.Heap(data,filter,receipts,L.N(data))),returned,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if filter then 49 else 44)
  {
    hide G.BitAnd(); hide L.Heap(); hide P.Final(); hide E.Trace();
    var n := L.N(data); var kept := L.Kept(data,filter,receipts,n);
    Z.Stack(data,filter,receipts,n); Z.Final(data,filter,receipts);
    var state: State; var states: seq<State>;
    if filter {
      state,states := EF.Run(code,data,L.Heap(data,filter,receipts,n),[],I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),n,kept,O.Extent(n),0);
      trace := Lift(code,EF.Destinations(),data,states,self,returned,cursor,observations);
    } else {
      state,states := EM.Run(code,data,L.Heap(data,filter,receipts,n),[],I.Offset(I.SourceHead(data)),I.SourceLength(data),I.Target(data),I.Offset(I.TemplateHead(data)),I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),n,kept,O.Extent(n),0);
      trace := Lift(code,EM.Destinations(),data,states,self,returned,cursor,observations);
    }
    frame := trace[|trace|-1];
  }
  ghost method Serialize(code: seq<Byte>,data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && L.Receipts(data,filter,receipts) && X.Context(self)
    ensures frame == X.Frame(Returned(A.Bytes(L.Kept(data,filter,receipts,L.N(data)),Y.Payload(data,filter,receipts,L.N(data)))),returned,cursor)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(518,[Z.Selector(filter),128],P.Final(data,filter,receipts)),returned,cursor) && trace[|trace|-1] == frame
    ensures |trace| == 76
  {
    hide G.BitAnd(); hide L.Heap(); hide P.Final(); hide Y.Payload(); hide A.Bytes(); hide E.Trace();
    var n := L.N(data); var kept := L.Kept(data,filter,receipts,n);
    P.Ready(data,filter,receipts);
    var free := B.Free(n,I.TemplateLength(data),n);
    var state,states := AC.Run(code,P.Final(data,filter,receipts),free,kept,Y.Payload(data,filter,receipts,n),Z.Selector(filter),0,data);
    E.Lift(code,AC.Destinations(),self,0,data,observations,states,returned,cursor);
    trace := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],returned,cursor));
    E.WidenTrace(code,AC.Destinations(),Destinations(),self,0,data,observations,trace);
    frame := trace[|trace|-1];
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,self: Word,returned: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && L.Receipts(data,filter,receipts) && X.Context(self)
    ensures frame == X.Frame(Returned(A.Bytes(L.Kept(data,filter,receipts,L.N(data)),Y.Payload(data,filter,receipts,L.N(data)))),returned,cursor)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(12391,V.Stack(data,filter,receipts,Z.Prefix(data,filter),5526,L.N(data)),L.Heap(data,filter,receipts,L.N(data))),returned,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if filter then 48 else 43)+76
  {
    hide L.Heap(); hide P.Final(); hide Y.Payload(); hide A.Bytes(); hide E.Trace();
    frame,trace := Exit(code,data,filter,receipts,self,returned,cursor,observations);
    var part: seq<X.Frame>;
    frame,part := Serialize(code,data,filter,receipts,self,returned,cursor,observations);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
  }
}

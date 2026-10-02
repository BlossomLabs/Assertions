// SPDX-License-Identifier: MIT
include "../raw-success/Memory.dfy"
include "../raw-success/Bindings.dfy"
include "../raw-template/Connection.dfy"
include "../loop-engine/Engine.dfy"
include "../loop-exit/Map.generated.dfy"
include "../loop-exit/Filter.generated.dfy"
include "../serializer-repair-v2/Control.generated.dfy"
include "../raw-success-tail-repair-v2/Connection.dfy"
module BytecodeApplyRawSuccessfulEntryV2 {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeApplyRawInputs
  import MP = BytecodeWordMapPrefix
  import FP = BytecodeWordFilterPrefix
  import R = BytecodeApplyRawAdmission
  import T = BytecodeApplyRawTemplateCopy
  import L = BytecodeApplyRawLoopState
  import V = BytecodeApplySuccessfulRawLoopEngine
  import D = BytecodeApplyRawLoopBindings
  import B = BytecodeApplyRawIterationBounds
  import O = BytecodeIotaOutput
  import Y = BytecodeApplyRawLoopOutputBytes
  import P = BytecodeApplyRawSuccessfulOutput
  import EM = BytecodeApplyLoopExitMap
  import EF = BytecodeApplyLoopExitFilter
  import A = BytecodeApplyBytesReturnMemory
  import AC = BytecodeApplyBytesReturnControl
  import Z = BytecodeApplyRawSuccessfulBindings
  import Tail = BytecodeApplyRawSuccessfulTail
  predicate Matches(code: seq<Byte>) { T.Matches(code) && V.Matches(code) && EM.Matches(code) && EF.Matches(code) && AC.Matches(code) }
  function Destinations(): set<nat> { T.Destinations()+V.Destinations()+EM.Destinations()+EF.Destinations()+AC.Destinations() }
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
  ghost method Run(code: seq<Byte>,data: seq<Byte>,filter: bool,receipts: seq<seq<Byte>>,self: Word,oldReturn: seq<Byte>,cursor: nat,codeSize: Word,before: seq<Word>,requested: seq<Word>,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && L.Receipts(data,filter,receipts)
    requires if filter then FP.Admitted(0,data) else MP.Admitted(0,data)
    requires X.Context(self) && codeSize > 0 && cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    requires V.Tape(data,filter,receipts,self,cursor+1,before,requested,observations)
    ensures frame == X.Frame(Returned(A.Bytes(L.Kept(data,filter,receipts,L.N(data)),Y.Payload(data,filter,receipts,L.N(data)))),receipts[L.N(data)-1],cursor+1+3*L.N(data))
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
    ensures |trace| == (if filter then 562 else 556)+53*(I.Count(data) as nat)+(if filter then 338 else 357)*(L.N(data) as nat)+40*(I.Count(data) as nat)*(L.N(data) as nat)+(if filter then 32*(L.Kept(data,filter,receipts,L.N(data)) as nat) else 0)+(if filter then 48 else 43)+75
  {
    hide G.BitAnd();
    hide L.Heap();
    hide L.Initial();
    hide P.Final();
    hide Y.Payload();
    hide A.Bytes();
    hide E.Trace();
    var n := L.N(data);
    var kept := L.Kept(data,filter,receipts,n);
    var selector: Word := if filter then 2005396296 else 3983393726;
    var prefix := Z.Prefix(data,filter);
    Z.Initial(data,filter,receipts);
    Z.Stack(data,filter,receipts,0);
    Z.Stack(data,filter,receipts,n);
    Z.Final(data,filter,receipts);
    var part: seq<X.Frame>;
    frame,trace := T.Run(code,data,filter,self,oldReturn,cursor,codeSize,observations);
    E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
    frame,part := V.Run(code,data,filter,receipts,prefix,5526,self,oldReturn,cursor+1,before,requested,observations);
    D.StackShape(data,filter,receipts,prefix,5526,0);
    D.StackShape(data,filter,receipts,prefix,5526,n);
    E.WidenTrace(code,V.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];
    frame,part := Tail.Run(code,data,filter,receipts,self,receipts[n-1],cursor+1+3*n,observations);
    E.WidenTrace(code,Tail.Destinations(),Destinations(),self,0,data,observations,part);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part);trace := trace+part[1..];

  }
}

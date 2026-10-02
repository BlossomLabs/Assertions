// SPDX-License-Identifier: MIT
// Public raw nonempty folds reach one target observation after all ordered windows.
include "../raw-windows/Connection.dfy"
include "../../target-invocation/Range.generated.dfy"
include "../../target-invocation/Bytes.generated.dfy"
include "../../target-invocation/Words.generated.dfy"
include "../../target-check/Code.generated.dfy"
include "../../target-check/Rejected.generated.dfy"
module BytecodeFoldRawTarget {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import S = BytecodeScanExecution
  import C = BytecodeCopyExecution
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeFoldRawInputs
  import W = BytecodeFoldElementWindowInputs
  import R = BytecodeFoldRawWindows
  import IR = BytecodeFoldTargetInvokeRange
  import IB = BytecodeFoldTargetInvokeBytes
  import IW = BytecodeFoldTargetInvokeWords
  import A = BytecodeFoldTargetCode
  import B = BytecodeFoldTargetRejected
  predicate Matches(code: seq<Byte>) { R.Matches(code) && IR.Matches(code) && IB.Matches(code) && IW.Matches(code) && A.Matches(code) && B.Matches(code) }
  function Destinations(): set<nat> { R.Destinations()+IR.Destinations()+IB.Destinations()+IW.Destinations()+A.Destinations()+B.Destinations() }
  predicate Admitted(data: seq<Byte>,domain: nat) {
    domain < 3 && R.Admitted(data,domain) && I.Fits(data,domain == 0) &&
    (if domain == 0 then I.RangeCount(data) > 0 else I.SourceLength(data) > 0) &&
    (domain != 2 || I.SourceLength(data)%32 == 0) &&
    W.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data) && I.AccOffset(data) <= I.TemplateLength(data)-32
  }
  ghost method Lift(code: seq<Byte>,data: seq<Byte>,states: seq<State>,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frames: seq<X.Frame>)
    requires S.Trace(code,Destinations(),0,data,states)
    ensures E.Trace(code,Destinations(),self,0,data,observations,frames)
    ensures frames == seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor))
  {
    forall i {:trigger states[i]} | 0 <= i < |states|-1
      ensures !states[i].Running? || states[i].pc >= |code| || Fetch(code,states[i].pc).op !in {0x37,0x5e}
    {
      assert Step(code,Destinations(),states[i],0,data) != Bad;
      reveal Step();
    }
    C.Lift(code,Destinations(),0,data,states);
    E.Lift(code,Destinations(),self,0,data,observations,states,oldReturn,cursor);
    frames := seq(|states|,i requires 0 <= i < |states| => X.Frame(states[i],oldReturn,cursor));
  }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,domain: nat,self: Word,codeSize: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && Admitted(data,domain) && X.Context(self)
    requires cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize)
    ensures frame == X.Frame(if codeSize == 0 then Reverted(G.Encode(0x54b3288a,4)+G.Encode(I.Target(data),32)) else Running(12052,R.BodyPrefix(data,domain),Store([],64,128)),oldReturn,cursor+1)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace) && |trace| > 0
    ensures trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); hide S.Trace();
    frame,trace := R.ExternalRun(code,data,domain,self,oldReturn,cursor,observations);
    E.WidenTrace(code,R.Destinations(),Destinations(),self,0,data,observations,trace);
    assert frame == X.Frame(Running(12029,R.BodyPrefix(data,domain),Store([],64,128)),oldReturn,cursor);
    var state: State; var states: seq<State>;
    if domain == 0 {
      reveal IR.Admitted();
      state,states := IR.Run(code,data,Store([],64,128),[4057501128],604,0);
      S.WidenTrace(code,IR.Destinations(),Destinations(),0,data,states);
    } else if domain == 1 {
      reveal IB.Admitted();
      state,states := IB.Run(code,data,Store([],64,128),[1831135132],604,0);
      S.WidenTrace(code,IB.Destinations(),Destinations(),0,data,states);
    } else {
      reveal IW.Admitted();
      state,states := IW.Run(code,data,Store([],64,128),[1843793072],604,0);
      S.WidenTrace(code,IW.Destinations(),Destinations(),0,data,states);
    }
    var part := Lift(code,data,states,self,oldReturn,cursor,observations);
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
    if codeSize == 0 {
      frame,part := B.Run(code,I.Target(data),R.BodyPrefix(data,domain),oldReturn,cursor,observations,self,0,data);
      E.WidenTrace(code,B.Destinations(),Destinations(),self,0,data,observations,part);
    } else {
      frame,part := A.Run(code,I.Target(data),codeSize,R.BodyPrefix(data,domain),Store([],64,128),oldReturn,cursor,observations,self,0,data);
      E.WidenTrace(code,A.Destinations(),Destinations(),self,0,data,observations,part);
    }
    assert trace[|trace|-1] == part[0];
    E.Join(code,Destinations(),self,0,data,observations,trace,part); trace := trace+part[1..];
  }
}

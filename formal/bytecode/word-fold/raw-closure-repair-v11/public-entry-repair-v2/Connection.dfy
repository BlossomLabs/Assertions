// SPDX-License-Identifier: MIT
// All admitted raw fold outcomes, exact successful return or first reached rejection/failure.
include "../../raw-closure-repair-v10/empty-body/Connection.dfy"
include "../raw-loop-connection-repair-v3/Connection.dfy"
include "../first-failure-raw-repair-v3/Raw.dfy"
module BytecodeFoldPublicEntry {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import X = BytecodeExternalMachine
  import E = BytecodeExternalExecution
  import I = BytecodeFoldRawInputs
  import V = BytecodeFoldElementWindowInputs
  import W = BytecodeFoldRawWindows
  import Z = BytecodeFoldRawEmpty
  import T = BytecodeFoldRawTarget
  import A = BytecodeFoldRawTemplate
  import P = BytecodeFoldRawLoopReadyV2
  import L = BytecodeFoldLoopModelV2
  import S = BytecodeFoldRawLoopConnectionV3
  import F = BytecodeFoldRawFirstFailure
  import FM = BytecodeFoldFirstFailureModel
  import FI = BytecodeFoldFailedIteration
  datatype Schedule = Successful(receipts: seq<L.Receipt>) | Failing(prefix: seq<L.Receipt>,failure: FI.Receipt)
  predicate Matches(code: seq<Byte>) { W.Matches(code) && Z.Matches(code) && T.Matches(code) && S.Matches(code) && F.Matches(code) }
  function Destinations(): set<nat> { W.Destinations()+Z.Destinations()+T.Destinations()+S.Destinations()+F.Destinations() }
  predicate Rejected(data: seq<Byte>,domain: nat)
    requires domain < 3
  {
    !I.Fits(data,domain == 0) || (domain == 2 && I.SourceLength(data)%32 != 0) || I.TemplateLength(data) < 32 ||
    I.AccOffset(data) > I.TemplateLength(data)-32 || !V.Valid(I.TemplateLength(data),I.Offset(I.ArrayHead(data)),I.Count(data),data)
  }
  predicate Resources(data: seq<Byte>,domain: nat,codeSize: Word,schedule: Schedule)
    requires domain < 3
  {
    if Rejected(data,domain) || Z.Empty(data,domain) || codeSize == 0 then true else
    if schedule.Successful? then L.Resources(data,A.LoopMemory(data,domain),P.Config(data,domain),0,schedule.receipts)
    else FM.Resources(data,A.LoopMemory(data,domain),P.Config(data,domain),0,schedule.prefix,schedule.failure)
  }
  predicate Truthful(data: seq<Byte>,domain: nat,codeSize: Word,schedule: Schedule,self: Word,cursor: nat,observations: seq<X.Observation>)
    requires domain < 3 && Resources(data,domain,codeSize,schedule)
  {
    if Rejected(data,domain) || Z.Empty(data,domain) then true else
    cursor < |observations| && observations[cursor] == X.CodeSize(I.Target(data),codeSize) &&
    (codeSize == 0 ||
     (if schedule.Successful? then L.Truthful(data,A.LoopMemory(data,domain),P.Config(data,domain),0,schedule.receipts,self,cursor+1,observations)
      else FM.Truthful(data,A.LoopMemory(data,domain),P.Config(data,domain),0,schedule.prefix,schedule.failure,self,cursor+1,observations)))
  }
  predicate Outcome(data: seq<Byte>,domain: nat,codeSize: Word,schedule: Schedule,oldReturn: seq<Byte>,cursor: nat,frame: X.Frame)
    requires domain < 3 && Resources(data,domain,codeSize,schedule)
  {
    if Rejected(data,domain) then W.Result(data,domain,frame.state) && frame.state.Reverted? && frame.returned == oldReturn && frame.cursor == cursor
    else if Z.Empty(data,domain) then frame == X.Frame(Returned(G.Encode(I.Initial(data),32)),oldReturn,cursor)
    else if codeSize == 0 then frame == X.Frame(Reverted(G.Encode(0x54b3288a,4)+G.Encode(I.Target(data),32)),oldReturn,cursor+1)
    else if schedule.Successful? then
      var result := L.Result(data,A.LoopMemory(data,domain),P.Config(data,domain),0,schedule.receipts);
      frame == X.Frame(Returned(G.Encode(result.word,32)),L.LastReturn(schedule.receipts,result.used,oldReturn),cursor+1+3*result.used)
    else frame == X.Frame(Reverted(FM.Error(data,A.LoopMemory(data,domain),P.Config(data,domain),0,schedule.prefix,schedule.failure)),schedule.failure.returned,cursor+1+3*|schedule.prefix|+(if schedule.failure.success then 3 else 4))
  }
  lemma Admission(data: seq<Byte>,domain: nat)
    requires W.Admitted(data,domain) && !Rejected(data,domain)
    ensures if Z.Empty(data,domain) then Z.Admitted(data,domain) else T.Admitted(data,domain)
  { hide DataWord();hide ShiftRight(); }
  lemma Rejection(data: seq<Byte>,domain: nat,state: State)
    requires W.Admitted(data,domain) && Rejected(data,domain) && W.Result(data,domain,state)
    ensures state.Reverted?
  { hide DataWord();hide ShiftRight(); }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,domain: nat,codeSize: Word,schedule: Schedule,self: Word,oldReturn: seq<Byte>,cursor: nat,observations: seq<X.Observation>) returns (frame: X.Frame,trace: seq<X.Frame>)
    requires Matches(code) && W.Admitted(data,domain) && X.Context(self)
    requires Resources(data,domain,codeSize,schedule) && Truthful(data,domain,codeSize,schedule,self,cursor,observations)
    ensures Outcome(data,domain,codeSize,schedule,oldReturn,cursor,frame)
    ensures E.Trace(code,Destinations(),self,0,data,observations,trace)
    ensures |trace| > 0 && trace[0] == X.Frame(Running(0,[],[]),oldReturn,cursor) && trace[|trace|-1] == frame
  {
    hide DataWord();hide ShiftRight();hide E.Trace();hide L.Result();hide L.Next();hide FM.Error();hide A.LoopMemory();hide P.Config();
    if Rejected(data,domain) {
      frame,trace := W.ExternalRun(code,data,domain,self,oldReturn,cursor,observations);
      Rejection(data,domain,frame.state);
      E.WidenTrace(code,W.Destinations(),Destinations(),self,0,data,observations,trace);
    } else {
      Admission(data,domain);
      if Z.Empty(data,domain) {
        frame,trace := Z.ExternalRun(code,data,domain,self,oldReturn,cursor,observations);
        E.WidenTrace(code,Z.Destinations(),Destinations(),self,0,data,observations,trace);
      } else if codeSize == 0 {
        frame,trace := T.Run(code,data,domain,self,codeSize,oldReturn,cursor,observations);
        E.WidenTrace(code,T.Destinations(),Destinations(),self,0,data,observations,trace);
      } else if schedule.Successful? {
        frame,trace := S.Run(code,data,domain,self,codeSize,oldReturn,cursor,observations,schedule.receipts);
        E.WidenTrace(code,S.Destinations(),Destinations(),self,0,data,observations,trace);
      } else {
        frame,trace := F.Run(code,data,domain,self,codeSize,oldReturn,cursor,observations,schedule.prefix,schedule.failure);
        E.WidenTrace(code,F.Destinations(),Destinations(),self,0,data,observations,trace);
      }
    }
  }
}

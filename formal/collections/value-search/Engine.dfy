// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsValueSearchEngine {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import E = CollectionsEnvironmentModel
  import Replay = CollectionsValueSearchEnvironment
  import S = CollectionsValueSearchSpec
  import M = CollectionsValueSearchModel
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import ABI = AbiConstructionModel
  import VC = AbiConstructionContext
  import Validation = CollectionsValidationConnection
  import VM = CollectionsValidationModel
  import Call = CollectionsBoundCallConnection
  import B = CollectionsBoundCallModel
  import R = CollectionsCallbackResultsModel
  import Results = CollectionsCallResultsConnection
  import RM = CollectionsCallResultsModel
  datatype Record = Record(before: P.Prepared,history: seq<C.Event>,prepared: P.Prepared,lowHistory: seq<C.Event>,calls: seq<C.Outcome>,env: C.Environment,first: VC.Result,second: VC.Result)
  function Environment(k: M.Config,i: nat,c: T.Context,inputReply: T.Reply,callReply: T.Reply): T.Environment
    requires i < |k.subject.values|
  {
    T.Environment((q: T.Request,at: T.Context) =>
                    if at == c && q == T.Validate(k.subject.inputType,k.subject.values[i]) then T.Observation(inputReply,c.state)
                    else if at == T.Context(c.state,c.history+[T.Validate(k.subject.inputType,k.subject.values[i])]) && q == S.Query(k.subject,i) then T.Observation(callReply,c.state+1)
                    else T.Observation(T.Error([]),at.state))
  }
  ghost opaque predicate RecordAt(k: M.Config,i: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>,env: T.Environment,r: Record)
    requires i < |k.subject.values| && Uint(|k.subject.values|)
  {
    M.LocalRoom(k,i,p,h) && r.before == p && r.history == h && |r.calls| <= 1 &&
    (|r.calls| == 0) == VM.Reply(T.Validate(k.subject.inputType,k.subject.values[i]),0,0).Error? &&
    S.Record(k.subject,i,c,env).checked.reply == VM.Reply(T.Validate(k.subject.inputType,k.subject.values[i]),0,0) &&
    r.prepared == (if |r.calls| == 0 then p else r.calls[0].prepared) &&
    r.lowHistory == (if |r.calls| == 0 then h else r.calls[0].history) &&
    (|r.calls| == 1 ==>
       C.Admitted(r.env) && C.Valid(k.cb,p,S.Binary(k.subject)) &&
       r.env == B.Environment(k.base,B.Query(k.fs,k.cb.first,k.subject.values[i]),r.first,B.Query(k.fs,if S.Binary(k.subject) then k.cb.second else k.cb.first,if S.Binary(k.subject) then k.subject.needle else k.subject.values[i]),r.second) &&
       r.first.Success? == ABI.ValidInput(k.fs[k.cb.first],k.subject.values[i]) &&
       (S.Binary(k.subject) ==> r.second.Success? == ABI.ValidInput(k.fs[k.cb.second],k.subject.needle)) &&
       r.calls[0] == C.Run(k.cb,p,C.Context(k.operation,i,0),k.subject.values[i],if S.Binary(k.subject) then k.subject.needle else [],S.Binary(k.subject),h,r.env) &&
       |S.Record(k.subject,i,c,env).calls| == 1 &&
       S.Record(k.subject,i,c,env).calls[0].reply == RM.Reply(r.calls[0],[],R.Context(k.operation,i,0,k.cb.target),true))
  }
  ghost opaque predicate Trace(k: M.Config,i: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>,env: T.Environment,records: seq<Record>)
    requires i <= |k.subject.values| && Uint(|k.subject.values|)
    decreases |k.subject.values|-i
  {
    if i == |k.subject.values| then |records| == 0 else
    |records| > 0 && RecordAt(k,i,c,p,h,env,records[0]) &&
    (if S.Step(k.subject,i,c,env).Failed? || S.Step(k.subject,i,c,env).index != S.Missing() then |records| == 1 else
     Trace(k,i+1,S.Step(k.subject,i,c,env).context,records[0].prepared,records[0].lowHistory,env,records[1..]))
  }
  lemma RecordReplay(k: M.Config,i: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>,a: T.Environment,b: T.Environment,r: Record)
    requires i < |k.subject.values| && Uint(|k.subject.values|)
    requires E.Window(a,b,|c.history|,|S.Step(k.subject,i,c,a).context.history|) && RecordAt(k,i,c,p,h,a,r)
    ensures RecordAt(k,i,c,p,h,b,r)
  { reveal RecordAt(); Replay.RecordReplay(k.subject,i,c,a,b); }
  lemma TraceFacts(k: M.Config,i: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>,env: T.Environment,records: seq<Record>)
    requires i <= |k.subject.values| && Uint(|k.subject.values|) && Trace(k,i,c,p,h,env,records)
    ensures |records| == |S.Rows(k.subject,i,c,env)|
    decreases |k.subject.values|-i
  {
    reveal Trace();
    if i < |k.subject.values| {
      var first := S.Step(k.subject,i,c,env);
      if first.Returned? && first.index == S.Missing() {
        TraceFacts(k,i+1,first.context,records[0].prepared,records[0].lowHistory,env,records[1..]);
      }
    }
  }
  lemma TraceReplay(k: M.Config,i: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>,a: T.Environment,b: T.Environment,records: seq<Record>)
    requires i <= |k.subject.values| && Uint(|k.subject.values|) && E.Future(a,b,|c.history|)
    requires Trace(k,i,c,p,h,a,records)
    ensures Trace(k,i,c,p,h,b,records)
    decreases |k.subject.values|-i
  {
    reveal Trace();
    if i < |k.subject.values| {
      var first := S.Step(k.subject,i,c,a);
      assert E.Window(a,b,|c.history|,|first.context.history|);
      RecordReplay(k,i,c,p,h,a,b,records[0]);
      Replay.StepReplay(k.subject,i,c,a,b);
      if first.Returned? && first.index == S.Missing() {
        S.RecordFacts(k.subject,i,c,a);
        E.Restrict(a,b,|c.history|,|first.context.history|);
        TraceReplay(k,i+1,first.context,records[0].prepared,records[0].lowHistory,a,b,records[1..]);
      }
    }
  }
  ghost method Step(k: M.Config,i: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>)
    returns (env: T.Environment,out: S.Outcome,record: Record)
    requires i < |k.subject.values| && Uint(|k.subject.values|) && M.LocalRoom(k,i,p,h)
    ensures out == S.Step(k.subject,i,c,env)
    ensures RecordAt(k,i,c,p,h,env,record)
    ensures record.before == p && record.history == h && |record.calls| <= 1
    ensures (|record.calls| == 0) == VM.Reply(T.Validate(k.subject.inputType,k.subject.values[i]),0,0).Error?
    ensures record.prepared == (if |record.calls| == 0 then p else record.calls[0].prepared)
    ensures record.lowHistory == (if |record.calls| == 0 then h else record.calls[0].history)
    ensures |record.calls| == 1 ==> C.Admitted(record.env) && C.Valid(k.cb,p,S.Binary(k.subject)) &&
                                    record.env == B.Environment(k.base,B.Query(k.fs,k.cb.first,k.subject.values[i]),record.first,B.Query(k.fs,if S.Binary(k.subject) then k.cb.second else k.cb.first,if S.Binary(k.subject) then k.subject.needle else k.subject.values[i]),record.second) &&
                                    record.first.Success? == ABI.ValidInput(k.fs[k.cb.first],k.subject.values[i]) &&
                                    (S.Binary(k.subject) ==> record.second.Success? == ABI.ValidInput(k.fs[k.cb.second],k.subject.needle)) &&
                                    record.calls[0] == C.Run(k.cb,p,C.Context(k.operation,i,0),k.subject.values[i],if S.Binary(k.subject) then k.subject.needle else [],S.Binary(k.subject),h,record.env)
    ensures out.Returned? ==> |record.calls| == 1 && record.calls[0].Returned? && ABI.ValidInputs(k.fs,record.prepared.args) && record.prepared.targetChecked
    ensures out.Returned? ==> RM.Reply(record.calls[0],[],R.Context(k.operation,i,0,k.cb.target),true).Ok?
    ensures out.Returned? ==> (out.index == i) == (RM.Reply(record.calls[0],[],R.Context(k.operation,i,0,k.cb.target),true).truth == S.Wanted(k.subject))
    ensures out.Returned? ==> (out.index == S.Missing()) == (RM.Reply(record.calls[0],[],R.Context(k.operation,i,0,k.cb.target),true).truth != S.Wanted(k.subject))
  {
    reveal RecordAt();
    var checked; var reply;
    checked,reply := Validation.Input(k.subject.inputType,k.subject.values[i]);
    record := Record(p,h,p,h,[],k.base,VC.Success,VC.Success);
    env := Environment(k,i,c,reply,T.Error([]));
    if reply.Error? {
      out := S.Failed(reply.reason,T.Context(c.state,c.history+[T.Validate(k.subject.inputType,k.subject.values[i])]));
      return;
    }
    var first; var second; var callEnv; var called;
    first,second,callEnv,called := Call.Run(k.fs,p.args,p.targetChecked,k.cb,C.Context(k.operation,i,0),k.subject.values[i],if S.Binary(k.subject) then k.subject.needle else [],S.Binary(k.subject),h,k.base);
    record := Record(p,h,called.prepared,called.history,[called],callEnv,first,second);
    assert RM.Room(called,[],R.Context(k.operation,i,0,k.cb.target),true);
    var callReply; var checks; var resultReply;
    callReply,checks,resultReply := Results.Complete(called,[],R.Context(k.operation,i,0,k.cb.target),true);
    env := Environment(k,i,c,reply,resultReply);
    var after := T.Context(c.state+1,c.history+[T.Validate(k.subject.inputType,k.subject.values[i]),S.Query(k.subject,i)]);
    if resultReply.Error? { out := S.Failed(resultReply.reason,after); return; }
    assert i < S.Missing();
    out := S.Returned(if resultReply.truth == S.Wanted(k.subject) then i else S.Missing(),after);
  }
  ghost method Run(k: M.Config,i: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>)
    returns (env: T.Environment,out: S.Outcome,records: seq<Record>,prepared: P.Prepared,lowHistory: seq<C.Event>)
    requires i <= |k.subject.values| && Uint(|k.subject.values|) && M.Budget(k,i,p,h)
    ensures out == S.Tail(k.subject,i,c,env)
    ensures Trace(k,i,c,p,h,env,records)
    ensures |records| <= |k.subject.values|-i
    ensures prepared == (if |records| == 0 then p else records[|records|-1].prepared)
    ensures lowHistory == (if |records| == 0 then h else records[|records|-1].lowHistory)
    ensures i < |k.subject.values| ==> |records| > 0
    ensures |records| > 0 ==> records[0].before == p && records[0].history == h
    decreases |k.subject.values|-i
  {
    reveal M.Budget(); reveal Trace();
    env := T.Environment((q: T.Request,at: T.Context) => T.Observation(T.Error([]),at.state));
    records := []; prepared := p; lowHistory := h;
    if i == |k.subject.values| { out := S.Returned(S.Missing(),c); return; }
    var local; var first; var record;
    local,first,record := Step(k,i,c,p,h);
    records := [record]; prepared := record.prepared; lowHistory := record.lowHistory;
    var later := env;
    var rest := first;
    if first.Returned? && first.index == S.Missing() {
      assert record.first.Success? == ABI.ValidInput(k.fs[k.cb.first],k.subject.values[i]);
      assert M.Budget(k,i+1,record.prepared,record.lowHistory);
      var tailRecords: seq<Record>;
      later,rest,tailRecords,prepared,lowHistory := Run(k,i+1,first.context,record.prepared,record.lowHistory);
      records := [record]+tailRecords;
    }
    env := E.Splice(local,later,|first.context.history|);
    Replay.JoinStep(k.subject,i,c,local,later);
    E.Before(local,later,|c.history|,|first.context.history|);
    RecordReplay(k,i,c,p,h,local,env,record);
    Replay.StepReplay(k.subject,i,c,local,env);
    if first.Returned? && first.index == S.Missing() {
      E.After(local,later,|first.context.history|);
      TraceReplay(k,i+1,first.context,record.prepared,record.lowHistory,later,env,records[1..]);
    }
    out := rest;
  }

}

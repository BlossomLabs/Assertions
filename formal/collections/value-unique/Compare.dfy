// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsValueUniqueCompare {
  import opened AbiFrames
  import opened AbiByteSemantics
  import S = CollectionsValueUniqueSpec
  import M = CollectionsValueUniqueModel
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import ABI = AbiConstructionModel
  import VC = AbiConstructionContext
  import Call = CollectionsBoundCallConnection
  import R = CollectionsCallbackResultsModel
  import RM = CollectionsCallResultsModel
  import Results = CollectionsCallResultsConnection
  import E = CollectionsEnvironmentModel
  import EC = CollectionsEnvironmentConnection
  import Replay = CollectionsValueUniqueEnvironment
  datatype Record = Record(before: P.Prepared,history: seq<C.Event>,called: C.Outcome,env: C.Environment,first: VC.Result,second: VC.Result)
  function Environment(k: M.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,reply: T.Reply): T.Environment
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j < |kept|
  { T.Environment((q: T.Request,at: T.Context) => if q == S.Query(k.subject,i,kept,j) && at == c then T.Observation(reply,c.state+1) else T.Observation(T.Error([]),at.state)) }
  ghost opaque predicate RecordAt(k: M.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>,env: T.Environment,r: Record)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j < |kept|
  {
    M.CallRoom(k,i,kept,j,p,h) && r.before == p && r.history == h && C.Admitted(r.env) && C.Valid(k.cb,p,true) &&
    r.env == M.Bound(k,i,kept,j,r.first,r.second) &&
    r.first.Success? == ABI.ValidInput(k.fs[k.cb.first],M.A(k,i,kept,j)) && r.second.Success? == ABI.ValidInput(k.fs[k.cb.second],M.BArg(k,i)) &&
    r.called == C.Run(k.cb,p,C.Context(k.operation,i,j),M.A(k,i,kept,j),M.BArg(k,i),true,h,r.env) &&
    T.Ask(S.Query(k.subject,i,kept,j),c,env).reply == RM.Reply(r.called,[],R.Context(k.operation,i,j,k.cb.target),true) &&
    r.called.prepared.plan == K.Plan(k.fs) &&
    (T.Ask(S.Query(k.subject,i,kept,j),c,env).reply.Ok? ==> r.called.Returned? && ABI.ValidInputs(k.fs,r.called.prepared.args) && r.called.prepared.targetChecked)
  }
  ghost opaque predicate Trace(k: M.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>,env: T.Environment,records: seq<Record>)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j <= |kept|
    decreases |kept|-j
  {
    if j == |kept| then |records| == 0 else
    |records| > 0 && RecordAt(k,i,kept,j,c,p,h,env,records[0]) &&
    (var called := T.Ask(S.Query(k.subject,i,kept,j),c,env);
     if called.reply.Error? || called.reply.truth then |records| == 1 else
     Trace(k,i,kept,j+1,called.context,records[0].called.prepared,records[0].called.history,env,records[1..]))
  }
  lemma RecordReplay(k: M.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>,a: T.Environment,b: T.Environment,r: Record)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j < |kept|
    requires E.Window(a,b,|c.history|,|c.history|+1) && RecordAt(k,i,kept,j,c,p,h,a,r)
    ensures RecordAt(k,i,kept,j,c,p,h,b,r)
  { reveal RecordAt(); EC.AskSame(S.Query(k.subject,i,kept,j),c,a,b); }
  lemma TraceReplay(k: M.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>,a: T.Environment,b: T.Environment,records: seq<Record>)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j <= |kept| && E.Future(a,b,|c.history|)
    requires Trace(k,i,kept,j,c,p,h,a,records)
    ensures Trace(k,i,kept,j,c,p,h,b,records)
    decreases |kept|-j
  {
    reveal Trace();
    if j < |kept| {
      RecordReplay(k,i,kept,j,c,p,h,a,b,records[0]);
      EC.AskSame(S.Query(k.subject,i,kept,j),c,a,b);
      var called := T.Ask(S.Query(k.subject,i,kept,j),c,a);
      if called.reply.Ok? && !called.reply.truth {
        E.Restrict(a,b,|c.history|,|called.context.history|);
        TraceReplay(k,i,kept,j+1,called.context,records[0].called.prepared,records[0].called.history,a,b,records[1..]);
      }
    }
  }
  ghost method Step(k: M.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>)
    returns (env: T.Environment,out: S.Comparison,record: Record)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j < |kept| && M.CallRoom(k,i,kept,j,p,h)
    ensures record.before == p && record.history == h
    ensures C.Admitted(record.env) && C.Valid(k.cb,p,true)
    ensures record.env == M.Bound(k,i,kept,j,record.first,record.second)
    ensures record.first.Success? == ABI.ValidInput(k.fs[k.cb.first],M.A(k,i,kept,j)) && record.second.Success? == ABI.ValidInput(k.fs[k.cb.second],M.BArg(k,i))
    ensures record.called == C.Run(k.cb,p,C.Context(k.operation,i,j),M.A(k,i,kept,j),M.BArg(k,i),true,h,record.env)
    ensures env == Environment(k,i,kept,j,c,RM.Reply(record.called,[],R.Context(k.operation,i,j,k.cb.target),true))
    ensures out == (if T.Ask(S.Query(k.subject,i,kept,j),c,env).reply.Error? then S.CompareFailed(T.Ask(S.Query(k.subject,i,kept,j),c,env).reply.reason,T.Ask(S.Query(k.subject,i,kept,j),c,env).context) else S.Compared(T.Ask(S.Query(k.subject,i,kept,j),c,env).reply.truth,T.Ask(S.Query(k.subject,i,kept,j),c,env).context))
    ensures RecordAt(k,i,kept,j,c,p,h,env,record)
    ensures record.called.prepared.plan == K.Plan(k.fs)
    ensures out.Compared? ==> M.Constants(k,p.args,record.called.prepared.args)
    ensures out.Compared? ==> record.called.Returned? && ABI.ValidInputs(k.fs,record.called.prepared.args) && record.called.prepared.targetChecked
  {
    reveal RecordAt();
    var first; var second; var callEnv; var called;
    first,second,callEnv,called := Call.Run(k.fs,p.args,p.targetChecked,k.cb,C.Context(k.operation,i,j),M.A(k,i,kept,j),M.BArg(k,i),true,h,k.base);
    record := Record(p,h,called,callEnv,first,second);
    assert callEnv == M.Bound(k,i,kept,j,first,second);
    assert C.Admitted(callEnv) && C.Valid(k.cb,p,true);
    assert called == C.Run(k.cb,p,C.Context(k.operation,i,j),M.A(k,i,kept,j),M.BArg(k,i),true,h,callEnv);
    assert RM.Room(called,[],R.Context(k.operation,i,j,k.cb.target),true);
    var callReply; var checks; var reply;
    callReply,checks,reply := Results.Complete(called,[],R.Context(k.operation,i,j,k.cb.target),true);
    env := Environment(k,i,kept,j,c,reply);
    var after := T.Context(c.state+1,c.history+[S.Query(k.subject,i,kept,j)]);
    out := if reply.Error? then S.CompareFailed(reply.reason,after) else S.Compared(reply.truth,after);
  }
  ghost method Run(k: M.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>)
    returns (env: T.Environment,out: S.Comparison,records: seq<Record>,prepared: P.Prepared,lowHistory: seq<C.Event>)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j <= |kept| && M.CompareBudget(k,i,kept,j,p,h)
    requires p.plan == K.Plan(k.fs) && K.CanonicalExcept(k.fs,p.args,{k.cb.first,k.cb.second})
    ensures out == S.Compare(k.subject,i,kept,j,c,env)
    ensures Trace(k,i,kept,j,c,p,h,env,records)
    ensures prepared.plan == K.Plan(k.fs)
    ensures out.Compared? ==> K.CanonicalExcept(k.fs,prepared.args,{k.cb.first,k.cb.second}) && M.Constants(k,p.args,prepared.args)
    ensures |records| <= |kept|-j
    ensures prepared == (if |records| == 0 then p else records[|records|-1].called.prepared)
    ensures lowHistory == (if |records| == 0 then h else records[|records|-1].called.history)
    ensures j < |kept| ==> |records| > 0 && records[0].before == p && records[0].history == h
    decreases |kept|-j
  {
    reveal M.CompareBudget(); reveal Trace();
    env := T.Environment((q: T.Request,at: T.Context) => T.Observation(T.Error([]),at.state));
    records := []; prepared := p; lowHistory := h;
    if j == |kept| { out := S.Compared(false,c); return; }
    var local; var first; var record;
    local,first,record := Step(k,i,kept,j,c,p,h);
    records := [record]; prepared := record.called.prepared; lowHistory := record.called.history;
    var later := env;
    out := first;
    if first.Compared? && !first.duplicate {
      assert M.CompareBudget(k,i,kept,j+1,prepared,lowHistory);
      var rest;
      later,out,rest,prepared,lowHistory := Run(k,i,kept,j+1,first.context,prepared,lowHistory);
      records := [record]+rest;
    }
    env := E.Splice(local,later,|first.context.history|);
    Replay.CompareJoin(k.subject,i,kept,j,c,local,later);
    E.Before(local,later,|c.history|,|first.context.history|);
    RecordReplay(k,i,kept,j,c,p,h,local,env,record);
    EC.AskSame(S.Query(k.subject,i,kept,j),c,local,env);
    if first.Compared? && !first.duplicate {
      E.After(local,later,|first.context.history|);
      TraceReplay(k,i,kept,j+1,first.context,record.called.prepared,record.called.history,later,env,records[1..]);
    }
  }
}

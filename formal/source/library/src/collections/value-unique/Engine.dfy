// SPDX-License-Identifier: MIT
include "Compare.dfy"
include "FlowReplay.dfy"
module CollectionsValueUniqueEngine {
  import opened AbiFrames
  import opened AbiByteSemantics
  import S = CollectionsValueUniqueSpec
  import F = CollectionsValueUniqueFlow
  import M = CollectionsValueUniqueModel
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import K = CollectionsCodecStateModel
  import E = CollectionsEnvironmentModel
  import EC = CollectionsEnvironmentConnection
  import Replay = CollectionsValueUniqueFlowReplay
  import CompareReplay = CollectionsValueUniqueEnvironment
  import Compare = CollectionsValueUniqueCompare
  import Validation = CollectionsValidationConnection
  import VM = CollectionsValidationModel
  import VC = AbiConstructionContext
  datatype Record = Record(kept: seq<nat>,before: P.Prepared,history: seq<C.Event>,comparisons: seq<Compare.Record>,prepared: P.Prepared,lowHistory: seq<C.Event>)
  function Environment(k: M.Config,i: nat,c: T.Context,reply: T.Reply): T.Environment
    requires i < |k.subject.values|
  { T.Environment((q: T.Request,at: T.Context) => if q == T.Validate(k.subject.inputType,k.subject.values[i]) && at == c then T.Observation(reply,c.state) else T.Observation(T.Error([]),at.state)) }
  ghost opaque predicate RecordAt(k: M.Config,i: nat,kept: seq<nat>,c: T.Context,p: P.Prepared,h: seq<C.Event>,env: T.Environment,r: Record)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i)
  {
    Uint(|k.subject.inputType|) && Uint(|k.subject.values[i]|) && r.kept == kept && r.before == p && r.history == h &&
    T.Ask(T.Validate(k.subject.inputType,k.subject.values[i]),c,env).reply == VM.Reply(T.Validate(k.subject.inputType,k.subject.values[i]),0,0) &&
    (var checked := T.Ask(T.Validate(k.subject.inputType,k.subject.values[i]),c,env);
     if checked.reply.Error? then |r.comparisons| == 0 else Compare.Trace(k,i,kept,S.Start(k.subject,kept),checked.context,p,h,env,r.comparisons)) &&
    r.prepared == (if |r.comparisons| == 0 then p else r.comparisons[|r.comparisons|-1].called.prepared) &&
    r.lowHistory == (if |r.comparisons| == 0 then h else r.comparisons[|r.comparisons|-1].called.history)
  }
  ghost opaque predicate Trace(k: M.Config,i: nat,kept: seq<nat>,c: T.Context,p: P.Prepared,h: seq<C.Event>,env: T.Environment,records: seq<Record>)
    requires S.Indices(k.subject,kept,i)
    decreases |k.subject.values|-i
  {
    if i == |k.subject.values| then |records| == 0 else
    |records| > 0 && RecordAt(k,i,kept,c,p,h,env,records[0]) &&
    (var first := F.Step(k.subject,i,kept,c,env);
     if first.Failed? then |records| == 1 else Trace(k,i+1,first.kept,first.context,records[0].prepared,records[0].lowHistory,env,records[1..]))
  }
  lemma RecordReplay(k: M.Config,i: nat,kept: seq<nat>,c: T.Context,p: P.Prepared,h: seq<C.Event>,a: T.Environment,b: T.Environment,r: Record)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && E.Future(a,b,|c.history|)
    requires RecordAt(k,i,kept,c,p,h,a,r)
    ensures RecordAt(k,i,kept,c,p,h,b,r)
  {
    reveal RecordAt(); EC.AskSame(T.Validate(k.subject.inputType,k.subject.values[i]),c,a,b);
    var checked := T.Ask(T.Validate(k.subject.inputType,k.subject.values[i]),c,a);
    if checked.reply.Ok? {
      E.Restrict(a,b,|c.history|,|checked.context.history|);
      Compare.TraceReplay(k,i,kept,S.Start(k.subject,kept),checked.context,p,h,a,b,r.comparisons);
    }
  }
  lemma RecordWindow(k: M.Config,i: nat,kept: seq<nat>,c: T.Context,p: P.Prepared,h: seq<C.Event>,a: T.Environment,b: T.Environment,r: Record)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i)
    requires E.Window(a,b,|c.history|,|F.Step(k.subject,i,kept,c,a).context.history|) && RecordAt(k,i,kept,c,p,h,a,r)
    ensures RecordAt(k,i,kept,c,p,h,b,r)
  {
    reveal RecordAt();
    F.StepLength(k.subject,i,kept,c,a);
    Replay.StepReplay(k.subject,i,kept,c,a,b);
    EC.AskSame(T.Validate(k.subject.inputType,k.subject.values[i]),c,a,b);
    var checked := T.Ask(T.Validate(k.subject.inputType,k.subject.values[i]),c,a);
    if checked.reply.Ok? {
      CompareReplay.CompareLength(k.subject,i,kept,S.Start(k.subject,kept),checked.context,a);
      CompareWindow(k,i,kept,S.Start(k.subject,kept),checked.context,p,h,a,b,r.comparisons);
    }
  }
  lemma CompareWindow(k: M.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>,a: T.Environment,b: T.Environment,records: seq<Compare.Record>)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j <= |kept|
    requires E.Window(a,b,|c.history|,|S.Compare(k.subject,i,kept,j,c,a).context.history|) && Compare.Trace(k,i,kept,j,c,p,h,a,records)
    ensures Compare.Trace(k,i,kept,j,c,p,h,b,records)
    decreases |kept|-j
  {
    reveal Compare.Trace();
    CompareReplay.CompareLength(k.subject,i,kept,j,c,a);
    if j < |kept| {
      Compare.RecordReplay(k,i,kept,j,c,p,h,a,b,records[0]);
      EC.AskSame(S.Query(k.subject,i,kept,j),c,a,b);
      var called := T.Ask(S.Query(k.subject,i,kept,j),c,a);
      if called.reply.Ok? && !called.reply.truth { CompareWindow(k,i,kept,j+1,called.context,records[0].called.prepared,records[0].called.history,a,b,records[1..]); }
    }
  }
  lemma TraceReplay(k: M.Config,i: nat,kept: seq<nat>,c: T.Context,p: P.Prepared,h: seq<C.Event>,a: T.Environment,b: T.Environment,records: seq<Record>)
    requires S.Indices(k.subject,kept,i) && E.Future(a,b,|c.history|) && Trace(k,i,kept,c,p,h,a,records)
    ensures Trace(k,i,kept,c,p,h,b,records)
    decreases |k.subject.values|-i
  {
    reveal Trace();
    if i < |k.subject.values| {
      var first := F.Step(k.subject,i,kept,c,a);
      F.StepLength(k.subject,i,kept,c,a); F.StepFacts(k.subject,i,kept,c,a);
      RecordReplay(k,i,kept,c,p,h,a,b,records[0]);
      Replay.StepReplay(k.subject,i,kept,c,a,b);
      if first.Returned? {
        E.Restrict(a,b,|c.history|,|first.context.history|);
        TraceReplay(k,i+1,first.kept,first.context,records[0].prepared,records[0].lowHistory,a,b,records[1..]);
      }
    }
  }
  ghost method Step(k: M.Config,i: nat,kept: seq<nat>,c: T.Context,p: P.Prepared,h: seq<C.Event>)
    returns (env: T.Environment,out: S.Outcome,record: Record)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && M.Budget(k,i,kept,p,h)
    requires p.plan == K.Plan(k.fs) && K.CanonicalExcept(k.fs,p.args,{k.cb.first,k.cb.second})
    ensures out == F.Step(k.subject,i,kept,c,env) && RecordAt(k,i,kept,c,p,h,env,record)
    ensures record.prepared.plan == K.Plan(k.fs)
    ensures out.Returned? ==> K.CanonicalExcept(k.fs,record.prepared.args,{k.cb.first,k.cb.second}) && M.Constants(k,p.args,record.prepared.args)
  {
    reveal M.Budget(); reveal RecordAt();
    var checked; var reply;
    checked,reply := Validation.Input(k.subject.inputType,k.subject.values[i]);
    record := Record(kept,p,h,[],p,h);
    var local := Environment(k,i,c,reply); env := local;
    var validated := T.Ask(T.Validate(k.subject.inputType,k.subject.values[i]),c,local);
    if reply.Error? { out := S.Failed(reply.reason,validated.context); return; }
    var comparisonEnv; var compared; var comparisons; var prepared; var lowHistory;
    comparisonEnv,compared,comparisons,prepared,lowHistory := Compare.Run(k,i,kept,S.Start(k.subject,kept),validated.context,p,h);
    record := Record(kept,p,h,comparisons,prepared,lowHistory);
    env := E.Splice(local,comparisonEnv,|validated.context.history|);
    E.Before(local,comparisonEnv,|c.history|,|validated.context.history|);
    EC.AskSame(T.Validate(k.subject.inputType,k.subject.values[i]),c,local,env);
    E.After(local,comparisonEnv,|validated.context.history|);
    Compare.TraceReplay(k,i,kept,S.Start(k.subject,kept),validated.context,p,h,comparisonEnv,env,comparisons);
    CompareReplay.CompareLength(k.subject,i,kept,S.Start(k.subject,kept),validated.context,comparisonEnv);
    CompareReplay.CompareReplay(k.subject,i,kept,S.Start(k.subject,kept),validated.context,comparisonEnv,env);
    out := if compared.CompareFailed? then S.Failed(compared.reason,compared.context) else S.Returned(if compared.duplicate then kept else kept+[i],compared.context);
  }
  ghost method Run(k: M.Config,i: nat,kept: seq<nat>,c: T.Context,p: P.Prepared,h: seq<C.Event>)
    returns (env: T.Environment,out: S.Outcome,records: seq<Record>,prepared: P.Prepared,lowHistory: seq<C.Event>)
    requires S.Indices(k.subject,kept,i) && M.Budget(k,i,kept,p,h)
    requires p.plan == K.Plan(k.fs) && K.CanonicalExcept(k.fs,p.args,{k.cb.first,k.cb.second})
    ensures out == S.Tail(k.subject,i,kept,c,env) && Trace(k,i,kept,c,p,h,env,records)
    ensures |records| <= |k.subject.values|-i
    ensures out.Returned? ==> |records| == |k.subject.values|-i
    ensures prepared.plan == K.Plan(k.fs)
    ensures prepared == (if |records| == 0 then p else records[|records|-1].prepared)
    ensures lowHistory == (if |records| == 0 then h else records[|records|-1].lowHistory)
    decreases |k.subject.values|-i
  {
    reveal M.Budget(); reveal Trace();
    env := T.Environment((q: T.Request,at: T.Context) => T.Observation(T.Error([]),at.state));
    records := []; prepared := p; lowHistory := h;
    if i == |k.subject.values| { out := S.Returned(kept,c); return; }
    var local; var first; var record;
    local,first,record := Step(k,i,kept,c,p,h);
    records := [record]; prepared := record.prepared; lowHistory := record.lowHistory;
    var later := env; var rest := first;
    if first.Returned? {
      F.StepFacts(k.subject,i,kept,c,local);
      reveal RecordAt();
      assert VM.Reply(T.Validate(k.subject.inputType,k.subject.values[i]),0,0).Ok?;
      assert first.kept == kept || first.kept == kept+[i];
      assert M.Budget(k,i+1,kept,record.prepared,record.lowHistory) && M.Budget(k,i+1,kept+[i],record.prepared,record.lowHistory);
      assert M.Budget(k,i+1,first.kept,record.prepared,record.lowHistory);
      var tailRecords;
      later,rest,tailRecords,prepared,lowHistory := Run(k,i+1,first.kept,first.context,record.prepared,record.lowHistory);
      records := [record]+tailRecords;
    }
    env := E.Splice(local,later,|first.context.history|);
    Replay.JoinStep(k.subject,i,kept,c,local,later);
    F.StepLength(k.subject,i,kept,c,local);
    E.Before(local,later,|c.history|,|first.context.history|);
    RecordWindow(k,i,kept,c,p,h,local,env,record);
    Replay.StepReplay(k.subject,i,kept,c,local,env);
    if first.Returned? {
      E.After(local,later,|first.context.history|);
      TraceReplay(k,i+1,first.kept,first.context,record.prepared,record.lowHistory,later,env,records[1..]);
    }
    out := rest;
  }
}

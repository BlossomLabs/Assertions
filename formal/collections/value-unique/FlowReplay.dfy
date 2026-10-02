// SPDX-License-Identifier: MIT
include "Flow.dfy"
include "Environment.dfy"
module CollectionsValueUniqueFlowReplay {
  import opened AbiFrames
  import F = CollectionsValueUniqueFlow
  import S = CollectionsValueUniqueSpec
  import T = CollectionsTraversalModel
  import E = CollectionsEnvironmentModel
  import EC = CollectionsEnvironmentConnection
  import Compare = CollectionsValueUniqueEnvironment
  lemma StepReplay(k: S.Config,i: nat,kept: seq<nat>,c: T.Context,a: T.Environment,b: T.Environment)
    requires i < |k.values| && S.Indices(k,kept,i)
    requires E.Window(a,b,|c.history|,|F.Step(k,i,kept,c,a).context.history|)
    ensures F.Step(k,i,kept,c,a) == F.Step(k,i,kept,c,b)
  {
    F.StepLength(k,i,kept,c,a);
    EC.AskSame(T.Validate(k.inputType,k.values[i]),c,a,b);
    var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,a);
    if checked.reply.Ok? {
      Compare.CompareLength(k,i,kept,S.Start(k,kept),checked.context,a);
      Compare.CompareReplay(k,i,kept,S.Start(k,kept),checked.context,a,b);
    }
  }
  lemma TailReplay(k: S.Config,i: nat,kept: seq<nat>,c: T.Context,a: T.Environment,b: T.Environment)
    requires S.Indices(k,kept,i) && E.Future(a,b,|c.history|)
    ensures S.Tail(k,i,kept,c,a) == S.Tail(k,i,kept,c,b)
    decreases |k.values|-i
  {
    if i < |k.values| {
      F.StepFacts(k,i,kept,c,a);
      F.StepLength(k,i,kept,c,a);
      var first := F.Step(k,i,kept,c,a);
      assert E.Window(a,b,|c.history|,|first.context.history|);
      StepReplay(k,i,kept,c,a,b);
      F.StepFacts(k,i,kept,c,b);
      if first.Returned? {
        E.Restrict(a,b,|c.history|,|first.context.history|);
        TailReplay(k,i+1,first.kept,first.context,a,b);
      }
    }
  }
  lemma JoinStep(k: S.Config,i: nat,kept: seq<nat>,c: T.Context,local: T.Environment,later: T.Environment)
    requires i < |k.values| && S.Indices(k,kept,i)
    ensures var first := F.Step(k,i,kept,c,local);
            var joined := E.Splice(local,later,|first.context.history|);
            S.Tail(k,i,kept,c,joined) == (if first.Failed? then first else S.Tail(k,i+1,first.kept,first.context,later))
  {
    var first := F.Step(k,i,kept,c,local);
    var joined := E.Splice(local,later,|first.context.history|);
    F.StepLength(k,i,kept,c,local); F.StepFacts(k,i,kept,c,local);
    E.Before(local,later,|c.history|,|first.context.history|);
    StepReplay(k,i,kept,c,local,joined); F.StepFacts(k,i,kept,c,joined);
    if first.Returned? {
      E.After(local,later,|first.context.history|);
      TailReplay(k,i+1,first.kept,first.context,later,joined);
    }
  }
  lemma AdmissionReplay(k: S.Config,c: T.Context,a: T.Environment,b: T.Environment)
    requires E.Window(a,b,|c.history|,|F.Admission(k,c,a).context.history|)
    ensures F.Admission(k,c,a) == F.Admission(k,c,b)
  {
    F.AdmissionFacts(k,c,a);
    EC.AskSame(T.Prepare(true),c,a,b);
    var prepared := T.Ask(T.Prepare(true),c,a);
    if prepared.reply.Ok? { EC.AskSame(T.Shape(k.inputType),prepared.context,a,b); }
  }
  lemma JoinAdmission(k: S.Config,c: T.Context,local: T.Environment,later: T.Environment)
    ensures var admitted := F.Admission(k,c,local);
            var joined := E.Splice(local,later,|admitted.context.history|);
            S.Run(k,c,joined) == (if admitted.Failed? then admitted else S.Tail(k,0,[],admitted.context,later))
  {
    var admitted := F.Admission(k,c,local);
    var joined := E.Splice(local,later,|admitted.context.history|);
    F.AdmissionFacts(k,c,local);
    E.Before(local,later,|c.history|,|admitted.context.history|);
    AdmissionReplay(k,c,local,joined); F.AdmissionFacts(k,c,joined);
    if admitted.Returned? { E.After(local,later,|admitted.context.history|); TailReplay(k,0,[],admitted.context,later,joined); }
  }
}

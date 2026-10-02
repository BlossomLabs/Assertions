// SPDX-License-Identifier: MIT
include "Spec.dfy"
module CollectionsValueSearchEnvironment {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened CollectionsValueSearchSpec
  import T = CollectionsTraversalModel
  import E = CollectionsEnvironmentModel
  import EC = CollectionsEnvironmentConnection
  lemma StepReplay(k: Config,i: nat,c: T.Context,a: T.Environment,b: T.Environment)
    requires i < |k.values| && Uint(|k.values|)
    requires E.Window(a,b,|c.history|,|Step(k,i,c,a).context.history|)
    ensures Step(k,i,c,a) == Step(k,i,c,b)
  {
    RecordFacts(k,i,c,a);
    EC.AskSame(T.Validate(k.inputType,k.values[i]),c,a,b);
    var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,a);
    if checked.reply.Ok? { EC.AskSame(Query(k,i),checked.context,a,b); }
  }
  lemma RecordReplay(k: Config,i: nat,c: T.Context,a: T.Environment,b: T.Environment)
    requires i < |k.values| && Uint(|k.values|)
    requires E.Window(a,b,|c.history|,|Step(k,i,c,a).context.history|)
    ensures Record(k,i,c,a) == Record(k,i,c,b)
  {
    StepReplay(k,i,c,a,b);
    RecordFacts(k,i,c,a);
    EC.AskSame(T.Validate(k.inputType,k.values[i]),c,a,b);
    var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,a);
    if checked.reply.Ok? { EC.AskSame(Query(k,i),checked.context,a,b); }
  }
  lemma TailReplay(k: Config,i: nat,c: T.Context,a: T.Environment,b: T.Environment)
    requires i <= |k.values| && Uint(|k.values|) && E.Future(a,b,|c.history|)
    ensures Tail(k,i,c,a) == Tail(k,i,c,b)
    decreases |k.values|-i
  {
    if i < |k.values| {
      var first := Step(k,i,c,a);
      assert E.Window(a,b,|c.history|,|first.context.history|);
      StepReplay(k,i,c,a,b);
      if first.Returned? && first.index == Missing() {
        RecordFacts(k,i,c,a);
        E.Restrict(a,b,|c.history|,|first.context.history|);
        TailReplay(k,i+1,first.context,a,b);
      }
    }
  }
  lemma JoinStep(k: Config,i: nat,c: T.Context,local: T.Environment,later: T.Environment)
    requires i < |k.values| && Uint(|k.values|)
    ensures var first := Step(k,i,c,local);
            var joined := E.Splice(local,later,|first.context.history|);
            Tail(k,i,c,joined) == (if first.Failed? || first.index != Missing() then first else Tail(k,i+1,first.context,later))
  {
    var first := Step(k,i,c,local);
    var joined := E.Splice(local,later,|first.context.history|);
    E.Before(local,later,|c.history|,|first.context.history|);
    StepReplay(k,i,c,local,joined);
    if first.Returned? && first.index == Missing() {
      E.After(local,later,|first.context.history|);
      TailReplay(k,i+1,first.context,later,joined);
    }
  }
  lemma AdmissionLength(k: Config,c: T.Context,env: T.Environment)
    ensures c.history <= Admission(k,c,env).context.history
    ensures |c.history|+1 <= |Admission(k,c,env).context.history| <= |c.history|+2
    ensures Admission(k,c,env).Returned? ==> |Admission(k,c,env).context.history| == |c.history|+2
  {}
  lemma AdmissionReplay(k: Config,c: T.Context,a: T.Environment,b: T.Environment)
    requires E.Window(a,b,|c.history|,|Admission(k,c,a).context.history|)
    ensures Admission(k,c,a) == Admission(k,c,b)
  {
    AdmissionLength(k,c,a);
    EC.AskSame(T.Prepare(Binary(k)),c,a,b);
    var prepared := T.Ask(T.Prepare(Binary(k)),c,a);
    if prepared.reply.Ok? {
      EC.AskSame(if Binary(k) then T.Validate(k.inputType,k.needle) else T.Shape(k.inputType),prepared.context,a,b);
    }
  }
  lemma JoinAdmission(k: Config,c: T.Context,local: T.Environment,later: T.Environment)
    requires Uint(|k.values|)
    ensures var admitted := Admission(k,c,local);
            var joined := E.Splice(local,later,|admitted.context.history|);
            Run(k,c,joined) == (if admitted.Failed? then admitted else Tail(k,0,admitted.context,later))
  {
    var admitted := Admission(k,c,local);
    var joined := E.Splice(local,later,|admitted.context.history|);
    E.Before(local,later,|c.history|,|admitted.context.history|);
    AdmissionReplay(k,c,local,joined);
    if admitted.Returned? {
      E.After(local,later,|admitted.context.history|);
      TailReplay(k,0,admitted.context,later,joined);
    }
  }

}

// SPDX-License-Identifier: MIT
include "Spec.dfy"
module CollectionsValueUniqueFlow {
  import opened AbiFrames
  import S = CollectionsValueUniqueSpec
  import T = CollectionsTraversalModel
  function Step(k: S.Config,i: nat,kept: seq<nat>,c: T.Context,env: T.Environment): S.Outcome
    requires i < |k.values| && S.Indices(k,kept,i)
  {
    var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,env);
    if checked.reply.Error? then S.Failed(checked.reply.reason,checked.context) else
    var compared := S.Compare(k,i,kept,S.Start(k,kept),checked.context,env);
    if compared.CompareFailed? then S.Failed(compared.reason,compared.context) else
    S.Returned(if compared.duplicate then kept else kept+[i],compared.context)
  }
  function Admission(k: S.Config,c: T.Context,env: T.Environment): S.Outcome {
    var prepared := T.Ask(T.Prepare(true),c,env);
    if prepared.reply.Error? then S.Failed(prepared.reply.reason,prepared.context) else
    var shaped := T.Ask(T.Shape(k.inputType),prepared.context,env);
    if shaped.reply.Error? then S.Failed(shaped.reply.reason,shaped.context) else S.Returned([],shaped.context)
  }
  lemma StepLength(k: S.Config,i: nat,kept: seq<nat>,c: T.Context,env: T.Environment)
    requires i < |k.values| && S.Indices(k,kept,i)
    ensures c.history < Step(k,i,kept,c,env).context.history
  {
    var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,env);
    if checked.reply.Ok? {
      CompareLength(k,i,kept,S.Start(k,kept),checked.context,env);
    }
  }
  lemma CompareLength(k: S.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,env: T.Environment)
    requires i < |k.values| && S.Indices(k,kept,i) && j <= |kept|
    ensures c.history <= S.Compare(k,i,kept,j,c,env).context.history
    decreases |kept|-j
  {
    if j < |kept| {
      var called := T.Ask(S.Query(k,i,kept,j),c,env);
      if called.reply.Ok? && !called.reply.truth { CompareLength(k,i,kept,j+1,called.context,env); }
    }
  }
  lemma StepFacts(k: S.Config,i: nat,kept: seq<nat>,c: T.Context,env: T.Environment)
    requires i < |k.values| && S.Indices(k,kept,i)
    ensures Step(k,i,kept,c,env).Returned? ==> S.Indices(k,Step(k,i,kept,c,env).kept,i+1)
    ensures S.Tail(k,i,kept,c,env) == (if Step(k,i,kept,c,env).Failed? then Step(k,i,kept,c,env) else S.Tail(k,i+1,Step(k,i,kept,c,env).kept,Step(k,i,kept,c,env).context,env))
  { S.Append(k,kept,i); }
  lemma AdmissionFacts(k: S.Config,c: T.Context,env: T.Environment)
    ensures c.history < Admission(k,c,env).context.history
    ensures S.Run(k,c,env) == (if Admission(k,c,env).Failed? then Admission(k,c,env) else S.Tail(k,0,[],Admission(k,c,env).context,env))
  {}
}

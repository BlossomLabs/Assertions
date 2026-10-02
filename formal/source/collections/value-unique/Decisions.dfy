// SPDX-License-Identifier: MIT
include "Flow.dfy"
module CollectionsValueUniqueDecisions {
  import opened AbiFrames
  import S = CollectionsValueUniqueSpec
  import F = CollectionsValueUniqueFlow
  import T = CollectionsTraversalModel
  function Comparisons(k: S.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,env: T.Environment): seq<T.Attempt>
    requires i < |k.values| && S.Indices(k,kept,i) && j <= |kept|
    decreases |kept|-j
  {
    if j == |kept| then [] else
    var called := T.Ask(S.Query(k,i,kept,j),c,env);
    [called]+(if called.reply.Error? || called.reply.truth then [] else Comparisons(k,i,kept,j+1,called.context,env))
  }
  lemma Compared(k: S.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,env: T.Environment)
    requires i < |k.values| && S.Indices(k,kept,i) && j <= |kept|
    ensures |Comparisons(k,i,kept,j,c,env)| <= |kept|-j
    ensures S.Compare(k,i,kept,j,c,env).CompareFailed? ==> |Comparisons(k,i,kept,j,c,env)| > 0 && Comparisons(k,i,kept,j,c,env)[|Comparisons(k,i,kept,j,c,env)|-1].reply.Error?
    ensures forall at :: 0 <= at < |Comparisons(k,i,kept,j,c,env)|-1 ==> Comparisons(k,i,kept,j,c,env)[at].reply.Ok? && !Comparisons(k,i,kept,j,c,env)[at].reply.truth
    ensures S.Compare(k,i,kept,j,c,env).Compared? ==> forall at :: 0 <= at < |Comparisons(k,i,kept,j,c,env)| ==> Comparisons(k,i,kept,j,c,env)[at].reply.Ok?
    ensures S.Compare(k,i,kept,j,c,env).Compared? && S.Compare(k,i,kept,j,c,env).duplicate ==> |Comparisons(k,i,kept,j,c,env)| > 0 && Comparisons(k,i,kept,j,c,env)[|Comparisons(k,i,kept,j,c,env)|-1].reply.truth
    ensures S.Compare(k,i,kept,j,c,env).Compared? && !S.Compare(k,i,kept,j,c,env).duplicate ==> |Comparisons(k,i,kept,j,c,env)| == |kept|-j && forall at :: 0 <= at < |Comparisons(k,i,kept,j,c,env)| ==> !Comparisons(k,i,kept,j,c,env)[at].reply.truth
    decreases |kept|-j
  {
    if j < |kept| {
      var called := T.Ask(S.Query(k,i,kept,j),c,env);
      if called.reply.Ok? && !called.reply.truth {
        Compared(k,i,kept,j+1,called.context,env);
        forall at | 0 <= at < |Comparisons(k,i,kept,j,c,env)|-1
          ensures Comparisons(k,i,kept,j,c,env)[at].reply.Ok? && !Comparisons(k,i,kept,j,c,env)[at].reply.truth
        { if at > 0 { assert Comparisons(k,i,kept,j,c,env)[at] == Comparisons(k,i,kept,j+1,called.context,env)[at-1]; } }
      }
    }
  }
  datatype Row = Row(kept: seq<nat>,checked: T.Attempt,comparisons: seq<T.Attempt>)
  function RowAt(k: S.Config,i: nat,kept: seq<nat>,c: T.Context,env: T.Environment): Row
    requires i < |k.values| && S.Indices(k,kept,i)
  {
    var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,env);
    Row(kept,checked,if checked.reply.Error? then [] else Comparisons(k,i,kept,S.Start(k,kept),checked.context,env))
  }
  function Rows(k: S.Config,i: nat,kept: seq<nat>,c: T.Context,env: T.Environment): seq<Row>
    requires S.Indices(k,kept,i)
    decreases |k.values|-i
  {
    if i == |k.values| then [] else
    var first := F.Step(k,i,kept,c,env);
    [RowAt(k,i,kept,c,env)]+(if first.Failed? then [] else Rows(k,i+1,first.kept,first.context,env))
  }
  lemma Length(k: S.Config,i: nat,kept: seq<nat>,c: T.Context,env: T.Environment)
    requires S.Indices(k,kept,i)
    ensures |Rows(k,i,kept,c,env)| <= |k.values|-i
    ensures S.Tail(k,i,kept,c,env).Returned? ==> |Rows(k,i,kept,c,env)| == |k.values|-i
    ensures S.Tail(k,i,kept,c,env).Failed? ==> |Rows(k,i,kept,c,env)| > 0
    decreases |k.values|-i
  {
    if i < |k.values| {
      F.StepFacts(k,i,kept,c,env);
      var first := F.Step(k,i,kept,c,env);
      if first.Returned? { Length(k,i+1,first.kept,first.context,env); }
    }
  }
  lemma Decisions(k: S.Config,i: nat,kept: seq<nat>,c: T.Context,env: T.Environment)
    requires i < |k.values| && S.Indices(k,kept,i)
    ensures F.Step(k,i,kept,c,env).Returned? ==> RowAt(k,i,kept,c,env).checked.reply.Ok?
    ensures F.Step(k,i,kept,c,env).Returned? && F.Step(k,i,kept,c,env).kept == kept ==> |RowAt(k,i,kept,c,env).comparisons| > 0 && RowAt(k,i,kept,c,env).comparisons[|RowAt(k,i,kept,c,env).comparisons|-1].reply.Ok? && RowAt(k,i,kept,c,env).comparisons[|RowAt(k,i,kept,c,env).comparisons|-1].reply.truth
    ensures F.Step(k,i,kept,c,env).Returned? && F.Step(k,i,kept,c,env).kept != kept ==> F.Step(k,i,kept,c,env).kept == kept+[i] &&
                                                                                        |RowAt(k,i,kept,c,env).comparisons| == |kept|-S.Start(k,kept) && forall at :: 0 <= at < |RowAt(k,i,kept,c,env).comparisons| ==> RowAt(k,i,kept,c,env).comparisons[at].reply.Ok? && !RowAt(k,i,kept,c,env).comparisons[at].reply.truth
  {
    var checked := T.Ask(T.Validate(k.inputType,k.values[i]),c,env);
    if checked.reply.Ok? { Compared(k,i,kept,S.Start(k,kept),checked.context,env); }
  }
}

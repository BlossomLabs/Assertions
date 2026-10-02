// SPDX-License-Identifier: MIT
include "Entry.dfy"
include "Decisions.dfy"
module CollectionsValueUniqueFacts {
  import opened AbiFrames
  import S = CollectionsValueUniqueSpec
  import F = CollectionsValueUniqueFlow
  import D = CollectionsValueUniqueDecisions
  import M = CollectionsValueUniqueModel
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import P = CollectionsPreparationModel
  import Engine = CollectionsValueUniqueEngine
  import Compare = CollectionsValueUniqueCompare
  lemma CompareCount(k: M.Config,i: nat,kept: seq<nat>,j: nat,c: T.Context,p: P.Prepared,h: seq<C.Event>,env: T.Environment,records: seq<Compare.Record>)
    requires i < |k.subject.values| && S.Indices(k.subject,kept,i) && j <= |kept|
    requires Compare.Trace(k,i,kept,j,c,p,h,env,records)
    ensures |records| == |D.Comparisons(k.subject,i,kept,j,c,env)|
    decreases |kept|-j
  {
    reveal Compare.Trace();
    if j < |kept| {
      var called := T.Ask(S.Query(k.subject,i,kept,j),c,env);
      if called.reply.Ok? && !called.reply.truth { CompareCount(k,i,kept,j+1,called.context,records[0].called.prepared,records[0].called.history,env,records[1..]); }
    }
  }
  lemma TraceFacts(k: M.Config,i: nat,kept: seq<nat>,c: T.Context,p: P.Prepared,h: seq<C.Event>,env: T.Environment,records: seq<Engine.Record>)
    requires S.Indices(k.subject,kept,i) && Engine.Trace(k,i,kept,c,p,h,env,records)
    ensures |records| == |D.Rows(k.subject,i,kept,c,env)|
    ensures forall j :: 0 <= j < |records| ==> records[j].kept == D.Rows(k.subject,i,kept,c,env)[j].kept && |records[j].comparisons| == |D.Rows(k.subject,i,kept,c,env)[j].comparisons|
    decreases |k.subject.values|-i
  {
    reveal Engine.Trace(); reveal Engine.RecordAt();
    if i < |k.subject.values| {
      var checked := T.Ask(T.Validate(k.subject.inputType,k.subject.values[i]),c,env);
      if checked.reply.Ok? { CompareCount(k,i,kept,S.Start(k.subject,kept),checked.context,p,h,env,records[0].comparisons); }
      var first := F.Step(k.subject,i,kept,c,env);
      F.StepFacts(k.subject,i,kept,c,env); D.Decisions(k.subject,i,kept,c,env);
      if first.Returned? {
        TraceFacts(k,i+1,first.kept,first.context,records[0].prepared,records[0].lowHistory,env,records[1..]);
      }
      forall j | 0 <= j < |records|
        ensures records[j].kept == D.Rows(k.subject,i,kept,c,env)[j].kept && |records[j].comparisons| == |D.Rows(k.subject,i,kept,c,env)[j].comparisons|
      { if j > 0 { assert records[j] == records[1..][j-1]; } }
    }
  }
}

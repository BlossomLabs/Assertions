// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsValueSortEntryConnection {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import M = CollectionsValueSortEntryModel
  import C = CollectionsCallsModel
  import Calls = CollectionsCallsConnection
  import P = CollectionsPreparationModel
  import VC = AbiConstructionContext
  import K = CollectionsCodecStateModel
  import A = CollectionsSortAdmissionModel
  import Admission = CollectionsSortAdmissionConnection
  import E = CollectionsValueSortExecutionModel
  import Execute = CollectionsValueSortExecutionConnection
  import Records = CollectionsValueSortExecutionRecords
  import T = CollectionsValueSortTraceModel
  import Traversal = CollectionsTraversalModel
  import Core = CollectionsSortModel
  import VM = CollectionsValidationModel

  lemma TrivialBudget(k: M.Config,h: seq<C.Event>)
    requires M.Room(k) && |k.values| < 2
    ensures M.Budget(k,h)
  { reveal M.Budget(); reveal E.Budget(); }

  ghost method Run(k: M.Config,h: seq<C.Event>,le: (nat,nat)->bool)
    returns (out: M.Outcome,admitted: A.Verdict,prep: P.Outcome,fs: seq<Descriptor>,receipts: seq<VC.Result>,prepEnv: P.Environment,
             visited: seq<nat>,checks: seq<Traversal.Request>,env: T.Environment,tail: seq<T.Outcome>,records: seq<E.Record>,finalState: seq<P.Prepared>,history: seq<C.Event>)
    requires M.Room(k) && M.Budget(k,h)
    ensures P.Admitted(prepEnv) && prep == P.Prepare(M.Raw(k),true,[],prepEnv)
    ensures admitted == A.Judge(k.inputType,k.values,prep)
    ensures admitted.Ready? == (prep.Ready? && VM.Reply(Traversal.Shape(k.inputType),0,0).Ok? && (forall i :: 0 <= i < |k.values| ==> A.Check(k.inputType,k.values[i]).Ok?))
    ensures prep.Ready? ==> Admissible(Group(fs)) && k.cb.descriptor == Render(Group(fs)) && |fs| == |k.constants|
    ensures prep.Ready? ==> K.CanonicalExcept(fs,k.constants,{k.cb.first,k.cb.second}) && prep.prepared == P.Prepared(K.Plan(fs),k.constants,false)
    ensures |tail| <= 1 && (|tail| == 1) == admitted.Ready?
    ensures |tail| == 1 && tail[0].Success? ==> (forall i :: 0 <= i < |tail[0].ids| ==> tail[0].ids[i] < |k.values|)
    ensures out == M.Judge(k,admitted,tail)
    ensures admitted.Failure? ==> out == M.Failure(admitted.reason) && records == [] && history == h+C.CodecEvents(prep.history)
    ensures admitted.Failure? ==> finalState == (if prep.Ready? then [prep.prepared] else [])
    ensures admitted.Ready? ==> visited == A.Indices(|k.values|) && (forall i :: 0 <= i < |k.values| ==> Admission.Accepted(k.inputType,k.values[i]))
    ensures admitted.Failure? && admitted.stage == 2 ==> visited == A.Indices(admitted.index+1) && admitted.index < |k.values|
    ensures admitted.Failure? && admitted.stage == 2 ==> A.Check(k.inputType,k.values[admitted.index]).Error? && A.Check(k.inputType,k.values[admitted.index]).reason == out.reason
    ensures admitted.Failure? && admitted.stage == 2 ==> (forall i :: 0 <= i < admitted.index ==> A.Check(k.inputType,k.values[i]).Ok?)
    ensures admitted.Failure? && admitted.stage < 2 ==> visited == []
    ensures admitted.Ready? ==> E.Chain(M.MergeConfig(k,fs),prep.prepared,h+C.CodecEvents(prep.history),records)
    ensures admitted.Ready? ==> tail[0] == T.Sort(Core.Range(0,|k.values|),1,[],env) && tail[0].trace == E.Rows(records) && T.Stopped(tail[0])
    ensures admitted.Ready? ==> finalState == [E.FinalPrepared(prep.prepared,records)] && history == E.FinalHistory(h+C.CodecEvents(prep.history),records)
    ensures admitted.Ready? && out.Failure? ==> |records| > 0 && records[|records|-1].decision.Failure? && records[|records|-1].decision.reason == out.reason
    ensures out.Success? ==> admitted.Ready? && |out.ids| == |k.values| && |out.values| == |k.values|
    ensures out.Success? ==> multiset(out.ids) == multiset(Core.Range(0,|k.values|))
    ensures out.Success? ==> (forall i :: 0 <= i < |out.ids| ==> out.ids[i] < |k.values| && out.values[i] == k.values[out.ids[i]] && Admission.Accepted(k.inputType,out.values[i]))
    ensures out.Success? ==> (forall i,j :: 0 <= i < j < |out.ids| ==> out.ids[i] != out.ids[j])
    ensures out.Success? && T.Coherent(E.Rows(records),le) && Core.Order(|k.values|,le) ==>
              (forall i,j :: 0 <= i < j < |out.ids| ==> le(out.ids[i],out.ids[j]) && (le(out.ids[j],out.ids[i]) ==> out.ids[i] < out.ids[j]))
    ensures |k.values| < 2 ==> records == [] && history == h+C.CodecEvents(prep.history)
    ensures |k.values| < 2 && out.Success? ==> out.ids == Core.Range(0,|k.values|) && out.values == k.values
  {
    var localHistory;
    admitted,prep,fs,receipts,prepEnv,visited,checks,localHistory := Admission.Run(M.Raw(k),k.inputType,k.values);
    history := h+localHistory; records := []; tail := [];
    env := (t: seq<T.Row>,q: T.Request) => T.Chosen(true);
    finalState := if prep.Ready? then [prep.prepared] else [];
    if admitted.Failure? { out := M.Failure(admitted.reason); return; }
    var config := M.MergeConfig(k,fs);
    assert E.Budget(config,Execute.Cost(|k.values|,1),prep.prepared,history) by { reveal M.Budget(); }
    var sorted; var prepared;
    env,sorted,records,prepared,history := Execute.Run(config,prep.prepared,history,le);
    tail := [sorted]; finalState := [prepared];
    out := M.Judge(k,admitted,tail);
    if out.Success? {
      forall i | 0 <= i < |out.ids|
        ensures out.ids[i] < |k.values| && out.values[i] == k.values[out.ids[i]] && Admission.Accepted(k.inputType,out.values[i])
      { assert out.values[i] == k.values[out.ids[i]]; }
      if |k.values| < 2 {
        assert forall i :: 0 <= i < |k.values| ==> out.values[i] == k.values[i];
        assert out.values == k.values;
      }
    }
  }
}

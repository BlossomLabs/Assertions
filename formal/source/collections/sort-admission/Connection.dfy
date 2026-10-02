// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module CollectionsSortAdmissionConnection {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import opened CollectionsSortAdmissionModel
  import S = CollectionsSortAdmissionSource
  import Proof = CollectionsSortAdmissionProperties
  import P = CollectionsPreparationModel
  import A = CollectionsAdmissionModel
  import K = CollectionsCodecStateModel
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import Calls = CollectionsCallsConnection
  import VM = CollectionsValidationModel
  import V = CollectionsValidationConnection
  import VC = AbiConstructionContext
  import Canon = AbiValidation
  import Encoding = AbiEncoding

  ghost predicate Accepted(t: seq<Byte>,value: seq<Byte>)
    requires Uint(|t|)
  {
    Whole(t).Shaped? && Encoding.WellFormed(TypeOf(Whole(t).syntax)) && Canon.Validate(TypeOf(Whole(t).syntax),value).Parsed?
  }

  ghost method Canonical(t: seq<Byte>,value: seq<Byte>)
    requires VM.Room(t,value)
    ensures Check(t,value).Ok? == Accepted(t,value)
  {
    var receipt,reply := V.Input(t,value);
  }

  ghost method Run(cb: P.Callback,t: seq<Byte>,values: seq<seq<Byte>>)
    returns (verdict: Verdict,prep: P.Outcome,fs: seq<Descriptor>,receipts: seq<VC.Result>,env: P.Environment,visited: seq<nat>,checks: seq<T.Request>,history: seq<C.Event>)
    requires Room(cb,t,values)
    ensures P.Admitted(env) && prep == P.Prepare(cb,true,[],env)
    ensures verdict == Judge(t,values,prep)
    ensures verdict.Ready? == (prep.Ready? && VM.Reply(T.Shape(t),0,0).Ok? && (forall i :: 0 <= i < |values| ==> Check(t,values[i]).Ok?))
    ensures prep.Ready? ==> Admissible(Group(fs)) && cb.descriptor == Render(Group(fs)) && |fs| == |cb.constants|
    ensures prep.Ready? ==> K.CanonicalExcept(fs,cb.constants,{cb.first,cb.second}) && prep.prepared == P.Prepared(K.Plan(fs),cb.constants,false)
    ensures verdict.Ready? ==> P.Slots(cb,true) && Whole(t).Shaped? && (forall i :: 0 <= i < |values| ==> Accepted(t,values[i]))
    ensures verdict.Failure? && verdict.stage == 0 ==> !prep.Ready? && verdict.reason == A.FailureBytes(prep) && checks == []
    ensures verdict.Failure? && verdict.stage == 1 ==> prep.Ready? && VM.Reply(T.Shape(t),0,0).Error? && verdict.reason == VM.Reply(T.Shape(t),0,0).reason
    ensures verdict.Failure? && verdict.stage == 2 ==> prep.Ready? && Whole(t).Shaped? && verdict.index < |values|
    ensures verdict.Failure? && verdict.stage == 2 ==> (forall i :: 0 <= i < verdict.index ==> Check(t,values[i]).Ok?)
    ensures verdict.Failure? && verdict.stage == 2 ==> Check(t,values[verdict.index]).Error? && verdict.reason == Check(t,values[verdict.index]).reason
    ensures verdict.Ready? ==> visited == Indices(|values|)
    ensures verdict.Failure? && verdict.stage == 2 ==> visited == Indices(verdict.index+1)
    ensures verdict.Failure? && verdict.stage < 2 ==> visited == []
    ensures |visited| > 0 ==> |checks| == 1+|visited|
    ensures forall j :: 0 <= j < |visited| ==> visited[j] < |values| && checks[j+1] == T.Validate(t,values[visited[j]])
    ensures history == C.CodecEvents(prep.history) && Calls.Targets(history) == [] && Calls.Calls(history) == []
  {
    verdict,prep,fs,receipts,env,visited,checks,history := S.Run(cb,t,values);
    Proof.ScanVerdict(t,values,0);
    if prep.Ready? { assert P.Slots(cb,true); }
    if verdict.Ready? {
      var i: nat := 0;
      while i < |values|
        invariant i <= |values|
        invariant forall j :: 0 <= j < i ==> Accepted(t,values[j])
        decreases |values|-i
      { Canonical(t,values[i]); i := i+1; }
    }
  }
}

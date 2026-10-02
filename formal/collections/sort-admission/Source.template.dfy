// SPDX-License-Identifier: MIT
// Generated prefix of the structurally gated complete sortValues body.
include "Properties.dfy"
module CollectionsSortAdmissionSource {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiByteSemantics
  import opened CollectionsSortAdmissionModel
  import Proof = CollectionsSortAdmissionProperties
  import P = CollectionsPreparationModel
  import A = CollectionsAdmissionModel
  import Prep = CollectionsAdmissionConnection
  import K = CollectionsCodecStateModel
  import Error = CollectionsCodecErrorEncoding
  import V = CollectionsValidationConnection
  import VM = CollectionsValidationModel
  import VC = AbiConstructionContext
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import Calls = CollectionsCallsConnection
  import History = CollectionsPreparedEntryConnection

  ghost method Run(cb: P.Callback,t: seq<Byte>,values: seq<seq<Byte>>)
    returns (verdict: Verdict,prep: P.Outcome,fs: seq<Descriptor>,receipts: seq<VC.Result>,env: P.Environment,visited: seq<nat>,checks: seq<T.Request>,history: seq<C.Event>)
    requires Room(cb,t,values)
    ensures P.Admitted(env) && prep == P.Prepare(cb,true,[],env)
    ensures verdict == Judge(t,values,prep)
    ensures prep.Ready? ==> Admissible(Group(fs)) && cb.descriptor == Render(Group(fs)) && |fs| == |cb.constants|
    ensures prep.Ready? ==> K.CanonicalExcept(fs,cb.constants,{cb.first,cb.second}) && prep.prepared == P.Prepared(K.Plan(fs),cb.constants,false)
    ensures !prep.Ready? ==> checks == [] && visited == []
    ensures prep.Ready? ==> |checks| == 1+|visited| && checks[0] == T.Shape(t)
    ensures forall j :: 0 <= j < |visited| ==> visited[j] < |values| && checks[j+1] == T.Validate(t,values[visited[j]])
    ensures visited == Indices(|visited|) && |visited| <= |values|
    ensures verdict.Ready? ==> |visited| == |values|
    ensures verdict.Failure? && verdict.stage == 2 ==> |visited| == verdict.index+1
    ensures verdict.Failure? && verdict.stage < 2 ==> visited == []
    ensures history == C.CodecEvents(prep.history) && Calls.Targets(history) == [] && Calls.Calls(history) == []
  {
    visited := []; checks := [];
    prep,fs,receipts,env := Prep.Prepare(cb,$BINARY,Error.Encode);
    history := C.CodecEvents(prep.history); History.CodecHistory(prep.history);
    if !prep.Ready? { verdict := Failure(0,0,A.FailureBytes(prep)); return; }
    var shape := V.Observe(T.Shape($TYPE),T.Context(0,[]),0,0);
    checks := [T.Shape(t)];
    if shape.reply.Error? { verdict := Failure(1,0,shape.reply.reason); return; }
    var i: nat := 0;
    while $GUARD
      invariant i <= |values| && visited == Indices(i) && |visited| == i
      invariant |checks| == 1+i && checks[0] == T.Shape(t)
      invariant forall j :: 0 <= j < i ==> checks[j+1] == T.Validate(t,values[j])
      invariant Scan(t,values,0) == Scan(t,values,i)
      decreases |values|-i
    {
      var result; var reply;
      result,reply := V.Input($VALUE_TYPE,$VALUE);
      Proof.IndexAppend(i);
      visited := visited+[i]; checks := checks+[T.Validate(t,values[i])];
      if reply.Error? { verdict := Failure(2,i,reply.reason); return; }
      assert Uint(i+1);
      i := i+1;
    }
    verdict := Ready;
  }
}

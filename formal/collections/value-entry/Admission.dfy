// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsValueEntryAdmission {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import M = CollectionsValueEntryModel
  import T = CollectionsTraversalModel
  import P = CollectionsPreparationModel
  import C = CollectionsCallsModel
  import K = CollectionsCodecStateModel
  import A = CollectionsAdmissionModel
  import Prep = CollectionsAdmissionConnection
  import V = CollectionsValidationConnection
  import VM = CollectionsValidationModel
  import Error = CollectionsCodecErrorEncoding
  import VC = AbiConstructionContext

  ghost method Run(k: M.Config, c: T.Context)
    returns (env: T.Environment, out: T.Outcome, prep: P.Outcome, fs: seq<Descriptor>, checks: seq<VC.Result>, prepEnv: P.Environment)
    requires M.Room(k)
    ensures P.Admitted(prepEnv) && prep == P.Prepare(M.Raw(k),k.mode == T.Fold,[],prepEnv)
    ensures env == M.Environment(k,c,prep) && out == M.Admission(k,c,prep)
    ensures out.Success? == (prep.Ready? && M.TypesAccepted(k))
    ensures !prep.Ready? ==> out.Failure? && out.reason == A.FailureBytes(prep) && out.context == T.Context(c.state+1,c.history+[T.Prepare(k.mode == T.Fold)])
    ensures prep.Ready? ==> Admissible(Group(fs)) && k.cb.descriptor == Render(Group(fs)) && |fs| == |k.constants|
    ensures prep.Ready? ==> K.CanonicalExcept(fs,k.constants,if k.mode == T.Fold then {k.cb.first,k.cb.second} else {k.cb.first}) && prep.prepared == P.Prepared(K.Plan(fs),k.constants,false)
    ensures out.Success? ==> out.accumulator == k.initial && out.values == []
    ensures out.context.state == c.state+1 && c.history <= out.context.history
  {
    prep,fs,checks,prepEnv := Prep.Prepare(M.Raw(k),k.mode == T.Fold,Error.Encode);
    env := M.Environment(k,c,prep);
    out := M.Admission(k,c,prep);
    if !prep.Ready? { return; }
    var after := T.Context(c.state+1,c.history+[T.Prepare(k.mode == T.Fold)]);
    var input := V.Observe(T.Shape(k.inputType),after,0,0);
    if input.reply.Error? { return; }
    if k.mode == T.Filter { return; }
    var next := T.Context(after.state,after.history+[T.Shape(k.inputType)]);
    var output := V.Observe(M.LastRequest(k),next,0,0);
  }
}

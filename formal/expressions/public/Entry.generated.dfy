// SPDX-License-Identifier: MIT
include "../entry/Connection.dfy"
include "../rejections/Model.dfy"
module ExpressionPublicEntry {
  import opened ExpressionEntryConnection
  import R = ExpressionRejectionModel
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import A = ExpressionAdmission
  import C = ExpressionCache
  import Init = ExpressionCacheSource
  import B = ExpressionEvaluationBridge
  import E = ExpressionEvaluationControl
  import M = ExpressionOracleModel
  import X = ExpressionExecutionModel
  import Run = ExpressionExecutionConnection
  import S = ExpressionRecursiveSpec
  import Scalar = ExpressionScalarModel

  ghost method Evaluate(c: M.Config, result: nat, hash: seq<Byte>->nat)
    returns (out: ExpressionEntryConnection.Outcome)
    requires forall i :: 0 <= i < |c.nodes| ==> Uint(|c.nodes[i].valueType|)
    ensures out.AdmissionRejected? <==> A.Admit(c.nodes,result,hash).Rejected?
    ensures out.AdmissionRejected? ==> out.error == A.Admit(c.nodes,result,hash).error
    ensures out.Evaluated? ==> E.Program(B.Project(c.nodes)) && C.Valid(out.types,out.initial)
    ensures out.Evaluated? ==> result < |c.nodes| && |out.types| == |c.nodes| &&
                               (forall i :: 0 <= i < |c.nodes| ==> Render(out.types[i]) == c.nodes[i].valueType)
    ensures out.Evaluated? ==> out.initial == C.Cold(out.types) && B.View(out.initial) == map[] &&
                               CanonicalCache(out.types,out.updated) && C.Extends(out.initial,out.updated)
    ensures out.Evaluated? ==> X.Certified(c,out.execution.history,out.replies) && out.covered == M.Covered(c,out.execution.history)
    ensures out.Evaluated? ==> out.execution == S.Evaluate(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,R.Reject(out.types),
                                                           M.Replay(out.execution.history,out.replies),result,map[],[]) && out.raw == RawResult(out.execution)
    ensures out.Evaluated? && out.covered ==> M.ValidTrace(c,out.execution.history,out.replies)
    ensures out.Evaluated? && out.raw.Aborted? ==> B.Bytes(out.raw.error.payload)
    ensures out.Evaluated? && out.raw.Produced? ==> B.Bytes(out.raw.value) &&
                                                    Validate(TypeOf(out.types[result]),B.Narrow(out.raw.value)).Parsed? &&
                                                    WellTyped(TypeOf(out.types[result]),Validate(TypeOf(out.types[result]),B.Narrow(out.raw.value)).value) &&
                                                    B.Narrow(out.raw.value) == Encode(TypeOf(out.types[result]),Validate(TypeOf(out.types[result]),B.Narrow(out.raw.value)).value)
  {
    var prepared := Init.Begin(c.nodes,result,hash);
    if prepared.AdmissionFailed? { out := AdmissionRejected(prepared.error); return; }
    B.AdmittedGraph(c.nodes,result,hash);
    R.AllBytes(prepared.types);
    var reject := R.Reject(prepared.types);
    assert B.View(prepared.cache) == map[];
    var evaluated,replies,covered,updated := CanonicalRun(c,prepared.types,prepared.cache,reject,result);
    out := Evaluated(prepared.types,prepared.cache,updated,evaluated,replies,covered,RawResult(evaluated));
  }
}

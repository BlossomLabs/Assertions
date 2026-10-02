// SPDX-License-Identifier: MIT
// Guarded entry source composition; Expressions.sol SHA-256: dc53eb78d3550ded3d9dce3f61172a9a16e103a6be33cea95b1de04701c7124d
include "Model.dfy"
module ExpressionPublicGuardedSource {
  import Reject = ExpressionRejectionModel
  import S = ExpressionRecursiveSpec
  import Scalar = ExpressionScalarModel
  import opened AbiFrames
  import opened AbiShapeSemantics
  import M = ExpressionGuardedModel
  import W = ExpressionGuardedEncoding
  import C = ExpressionCache
  import Init = ExpressionCacheSource
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import O = ExpressionOracleModel
  import R = ResolutionModel
  import Entry = ExpressionEntryConnection

  ghost method Evaluate(c: O.Config, types: seq<Descriptor>, initial: C.Cache, index: nat,
                        caller: R.Address) returns (out: M.Outcome)
    requires caller == c.self ==> C.Types(types) && M.Ready(c,types,initial,index,Reject.Reject(types))
    ensures out.Denied? <==> caller != c.self
    ensures out.Denied? ==> out.reason == M.NotSelf(caller)
    ensures out.Attempted? ==> Entry.CanonicalCache(types,out.updated) && C.Extends(initial,out.updated) && W.WordsFit(out.updated)
    ensures out.Attempted? ==> out.covered == O.Covered(c,out.execution.history)
    ensures out.Attempted? ==> |out.execution.history| == |out.replies| &&
                               out.execution == S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,Reject.Reject(types),
                                                           O.Replay(out.execution.history,out.replies),index,B.View(initial),[])
    ensures out.Attempted? && out.covered ==> O.ValidTrace(c,out.execution.history,out.replies)
    ensures out.Attempted? && out.execution.Failure? ==> B.Bytes(out.execution.error.payload)
    ensures out.Attempted? && out.execution.Success? ==> B.Bytes(out.execution.value) &&
                                                         C.SuccessfulReceipt(types,index,initial,C.Succeeded(B.Narrow(out.execution.value),out.updated))
  {
    var allowed := Init.CheckSelf(caller,c.self);
    if !allowed { out := M.Denied(M.NotSelf(caller)); return; }
    Reject.AllBytes(types);
    var reject := Reject.Reject(types);
    var copied := initial;
    var evaluated,replies,covered,updated := Entry.CanonicalRun(c,types,copied,reject,index);
    out := M.Attempted(evaluated,updated,replies,covered);
  }
}

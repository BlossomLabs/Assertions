// SPDX-License-Identifier: MIT
include "Encoded.dfy"
include "Guarded.generated.dfy"

module ExpressionPublicGuarded {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiShapeSemantics
  import opened AbiByteSemantics
  import opened AbiDynamicSemantics
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import O = ExpressionOracleModel
  import Resolution = ResolutionModel
  import G = ExpressionGuardedModel
  import R = ExpressionRejectionModel
  import Cold = ExpressionRejectionConnection
  import V = ExpressionRejectionRun
  import F = ExpressionFramesModel
  import Scalar = ExpressionScalarModel
  import Source = ExpressionPublicGuardedSource
  import Wire = ExpressionGuardedEncoding
  import Return = ExpressionGuardedConnection
  import Entry = ExpressionEntryConnection

  ghost predicate Room(c: O.Config, types: seq<Descriptor>, initial: C.Cache, index: nat, attempt: G.Outcome)
    requires C.Types(types) && G.Ready(c,types,initial,index,R.Reject(types)) && attempt.Attempted?
    requires |attempt.execution.history| == |attempt.replies|
  {
    forall f <- F.Trace(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,R.Reject(types),
                        O.Replay(attempt.execution.history,attempt.replies),index,B.View(initial),[],-1) ::
      f.index < |c.nodes| && f.index < |types| && f.index !in f.memo ==>
        var body := Cold.Before(c,types,f,R.Reject(types),attempt.execution.history,attempt.replies);
        body.Success? ==> Uint(|body.value|) && CursorRoom(types[f.index],|body.value|)
  }

  ghost method Evaluate(c: O.Config, types: seq<Descriptor>, initial: C.Cache, index: nat, caller: Resolution.Address)
    returns (attempt: G.Outcome, complete: bool, frames: seq<F.Frame>, caches: seq<C.Cache>, validators: seq<V.Record>)
    requires caller == c.self ==> C.Types(types) && G.Ready(c,types,initial,index,R.Reject(types)) &&
                                  forall i :: 0 <= i < |types| ==> Uint(|Render(types[i])|)
    ensures attempt.Denied? <==> caller != c.self
    ensures attempt.Denied? ==> attempt.reason == G.NotSelf(caller)
    ensures attempt.Attempted? ==> |attempt.execution.history| == |attempt.replies|
    ensures complete <==> attempt.Attempted? && attempt.covered && Room(c,types,initial,index,attempt)
    ensures attempt.Attempted? ==> Entry.CanonicalCache(types,attempt.updated) && C.Extends(initial,attempt.updated) && Wire.WordsFit(attempt.updated)
    ensures attempt.Attempted? && attempt.execution.Success? ==> B.Bytes(attempt.execution.value)
    ensures attempt.Attempted? && attempt.execution.Failure? ==> B.Bytes(attempt.execution.error.payload)
    ensures complete ==> frames == F.Trace(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,R.Reject(types),
                                           O.Replay(attempt.execution.history,attempt.replies),index,B.View(initial),[],-1)
    ensures complete ==> |frames| > 0 && |frames| == |caches| && |frames| == |validators|
    ensures complete ==> forall j :: 0 <= j < |frames| ==> frames[j].index < |c.nodes| &&
                                                           V.Certified(c,types,frames[j],caches[j],attempt.execution.history,attempt.replies,validators[j])
  {
    attempt := Source.Evaluate(c,types,initial,index,caller);
    complete := false; frames := []; caches := []; validators := [];
    if attempt.Denied? { return; }
    if !attempt.covered || !Room(c,types,initial,index,attempt) { return; }
    var checked;
    checked,frames,caches,validators := V.FromRoot(c,types,initial,index,attempt.execution.history,attempt.replies);
    assert checked == attempt.execution;
    complete := true;
  }

  ghost method ReturnValue(attempt: G.Outcome) returns (raw: E.Raw)
    requires attempt.Attempted? && attempt.execution.Success? ==> B.Bytes(attempt.execution.value) && Wire.WordsFit(attempt.updated) &&
                                                                  Fits(Wire.ReturnType(),Wire.ReturnValue(B.Narrow(attempt.execution.value),attempt.updated))
    ensures attempt.Denied? ==> raw == E.Aborted(E.Error(attempt.reason))
    ensures attempt.Attempted? && attempt.execution.Failure? ==> raw == E.Aborted(attempt.execution.error)
    ensures raw.Produced? <==> attempt.Attempted? && attempt.execution.Success?
    ensures raw.Produced? ==> B.Bytes(raw.value) && Validate(Wire.ReturnType(),Word(32)+B.Narrow(raw.value)).Parsed?
    ensures raw.Produced? ==> WellTyped(Wire.ReturnType(),Validate(Wire.ReturnType(),Word(32)+B.Narrow(raw.value)).value)
    ensures raw.Produced? ==> Wire.Project(Validate(Wire.ReturnType(),Word(32)+B.Narrow(raw.value)).value) ==
                              Wire.Pair(B.Narrow(attempt.execution.value),attempt.updated)
  {
    if attempt.Denied? { raw := E.Aborted(E.Error(attempt.reason)); return; }
    if attempt.execution.Failure? { raw := E.Aborted(attempt.execution.error); return; }
    Return.SuccessWire(attempt);
    var data := Wire.Wire(B.Narrow(attempt.execution.value),attempt.updated);
    B.ByteIdentity(data);
    raw := E.Produced(data);
  }
}

// SPDX-License-Identifier: MIT
include "Completion.generated.dfy"
include "../validation/Body.generated.dfy"
module ExpressionRejectionConnection {
  import R = ExpressionRejectionModel
  import ExactReceipt = AbiExactOutcomeConnection
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiByteSemantics
  import opened AbiDynamicSemantics
  import E = ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import O = ExpressionOracleModel
  import G = ExpressionGuardedModel
  import F = ExpressionFramesModel
  import Source = ExpressionValidationSource
  import Scalar = ExpressionScalarModel
  import Bytes = ExpressionValidationBytes
  import Control = ExpressionValidationControl
  import Complete = ExpressionRejectionCompletion
  import FrameCache = ExpressionFramesConnection
  import Entry = ExpressionEntryConnection

  ghost function Before(c: O.Config, types: seq<Descriptor>, f: F.Frame, reject: (nat,E.Value)->E.Error,
                        trace: seq<E.Request>, replies: seq<O.Reply>): E.Result
    requires E.Program(B.Project(c.nodes)) && f.index < |c.nodes| && C.Types(types) && |trace| == |replies|
  { S.Body(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),f.index,f.memo,f.history) }
  lemma Extend(a: map<nat,E.Value>, b: map<nat,E.Value>, c: map<nat,E.Value>)
    requires E.Extends(a,b) && E.Extends(b,c)
    ensures E.Extends(a,c)
  {}

  ghost method Cold(c: O.Config, types: seq<Descriptor>, initial: C.Cache, f: F.Frame,
                    reject: (nat,E.Value)->E.Error, trace: seq<E.Request>, replies: seq<O.Reply>)
    returns (body: E.Result, out: E.Result, receipt: Complete.Receipt, updated: C.Cache)
    requires G.Ready(c,types,initial,f.index,reject) && B.View(initial) == f.memo && f.index !in f.memo
    requires reject == R.Reject(types)
    requires O.Covered(c,trace) && O.ValidTrace(c,trace,replies) && f.history <= trace
    requires S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),f.index,f.memo,f.history).history <= trace
    requires Uint(|Render(types[f.index])|)
    requires var candidate := Before(c,types,f,reject,trace,replies);
             candidate.Success? ==> Uint(|candidate.value|) && CursorRoom(types[f.index],|candidate.value|)
    ensures body == Before(c,types,f,reject,trace,replies) && Control.ResultBytes(body)
    ensures receipt.Checked? <==> body.Success?
    ensures body.Success? ==> receipt.raw == ExactReceipt.Receipt(types[f.index],B.Narrow(body.value))
    ensures out == S.Complete(f.index,B.Canonical(types),Complete.Reject(receipt),body)
    ensures Control.ResultBytes(out) && out.history == body.history
    ensures Entry.CanonicalCache(types,updated) && C.Extends(initial,updated)
    ensures B.View(updated) == out.memo
    ensures out.Success? ==> C.SuccessfulReceipt(types,f.index,initial,C.Succeeded(B.Narrow(out.value),updated))
    ensures body.Failure? ==> out == body
    ensures body.Success? ==> (out.Success? <==> B.Canonical(types)(f.index,body.value))
    ensures receipt.Checked? && out.Failure? ==> receipt.outcome.Invalid? && receipt.raw.Aborted? &&
                                                 out == E.Failure(receipt.raw.error,body.memo,body.history)
    ensures out == S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,O.Replay(trace,replies),f.index,f.memo,f.history)
  {
    var oracle := O.Replay(trace,replies);
    B.ViewValid(B.Project(c.nodes),types,initial);
    var confirmed := Source.Run(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,oracle,f.index,f.memo,f.history);
    body := Before(c,types,f,reject,trace,replies);
    Bytes.Replay(c,trace,replies);
    Control.Body(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,oracle,f.index,f.memo,f.history);
    out,receipt := Complete.Complete(types,f.index,body);
    Extend(f.memo,body.memo,out.memo);
    B.ReifyValid(B.Project(c.nodes),types,initial,out.memo);
    updated := B.Reify(types,initial,out.memo);
    FrameCache.EntryCache(c,types,initial,F.Frame(f.index,out.memo,out.history,-1),reject);
    if out.Success? { B.ByteIdentity(updated.values[f.index]); }
    if body.Success? && !B.Canonical(types)(f.index,body.value) && reject(f.index,body.value) != Complete.ErrorOf(receipt) {
    } else { Complete.Substitute(types,f.index,body,receipt,reject); }
  }
}

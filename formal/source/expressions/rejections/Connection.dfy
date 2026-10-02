// SPDX-License-Identifier: MIT
include "Cold.generated.dfy"

module ExpressionRejectionRun {
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
  import Bounds = ExpressionTraceBounds
  import Scalar = ExpressionScalarModel
  import Entry = ExpressionEntryConnection
  import R = ExpressionRejectionModel
  import ExactReceipt = AbiExactOutcomeConnection
  import Cold = ExpressionRejectionConnection
  import Complete = ExpressionRejectionCompletion
  import Source = ExpressionFramesSource
  import FrameCache = ExpressionFramesConnection

  datatype Record = Reused | Completed(body: E.Result, out: E.Result,
                                       receipt: Complete.Receipt, updated: C.Cache)

  ghost predicate Certified(c: O.Config, types: seq<Descriptor>, f: F.Frame,
                            cache: C.Cache, trace: seq<E.Request>, replies: seq<O.Reply>, record: Record)
    requires E.Program(B.Project(c.nodes)) && C.Types(types) && f.index < |c.nodes| && |trace| == |replies|
  {
    (record.Reused? <==> f.index in f.memo) &&
    (record.Completed? ==>
       record.body == Cold.Before(c,types,f,R.Reject(types),trace,replies) &&
       record.out == S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,
                                R.Reject(types),O.Replay(trace,replies),f.index,f.memo,f.history) &&
       (record.receipt.Checked? <==> record.body.Success?) &&
       (record.body.Success? ==> B.Bytes(record.body.value) && f.index < |types| &&
                                 record.receipt.raw == ExactReceipt.Receipt(types[f.index],B.Narrow(record.body.value))) &&
       Entry.CanonicalCache(types,record.updated) && C.Extends(cache,record.updated) &&
       B.View(record.updated) == record.out.memo &&
       (record.receipt.Checked? && record.out.Failure? ==>
          record.receipt.outcome.Invalid? && record.receipt.raw.Aborted? &&
          record.out == E.Failure(record.receipt.raw.error,record.body.memo,record.body.history)))
  }

  // The complete entry trace includes lazy selections and failed attempts.
  // Every cold entry gets an actual source-validator completion; all use the
  // same descriptor/value rejection function, including repeated failed work.
  ghost method ValidateFrames(c: O.Config, types: seq<Descriptor>, frames: seq<F.Frame>,
                              caches: seq<C.Cache>, trace: seq<E.Request>, replies: seq<O.Reply>)
    returns (records: seq<Record>)
    requires C.Types(types) && E.Program(B.Project(c.nodes))
    requires |frames| == |caches| && O.Covered(c,trace) && O.ValidTrace(c,trace,replies)
    requires Bounds.Within(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,R.Reject(types),O.Replay(trace,replies),frames,[],trace)
    requires forall j :: 0 <= j < |frames| ==>
                           frames[j].index < |types| &&
                           G.Ready(c,types,caches[j],frames[j].index,R.Reject(types)) && B.View(caches[j]) == frames[j].memo
    requires forall j :: 0 <= j < |frames| ==> Uint(|Render(types[frames[j].index])|)
    requires forall j :: 0 <= j < |frames| && frames[j].index !in frames[j].memo ==>
                           var candidate := Cold.Before(c,types,frames[j],R.Reject(types),trace,replies);
                           candidate.Success? ==> Uint(|candidate.value|) && CursorRoom(types[frames[j].index],|candidate.value|)
    ensures |records| == |frames|
    ensures forall j :: 0 <= j < |frames| ==> Certified(c,types,frames[j],caches[j],trace,replies,records[j])
  {
    records := [];
    var i: nat := 0;
    while i < |frames|
      invariant i <= |frames| && |records| == i
      invariant forall j :: 0 <= j < i ==> Certified(c,types,frames[j],caches[j],trace,replies,records[j])
      decreases |frames|-i
    {
      var f := frames[i];
      var record: Record;
      if f.index in f.memo { record := Reused; }
      else {
        var body,out,receipt,updated := Cold.Cold(c,types,caches[i],f,R.Reject(types),trace,replies);
        record := Completed(body,out,receipt,updated);
      }
      records := records+[record];
      i := i+1;
    }
  }
  ghost method FromRoot(c: O.Config, types: seq<Descriptor>, initial: C.Cache, index: nat,
                        trace: seq<E.Request>, replies: seq<O.Reply>)
    returns (out: E.Result, frames: seq<F.Frame>, caches: seq<C.Cache>, records: seq<Record>)
    requires C.Types(types)
    requires G.Ready(c,types,initial,index,R.Reject(types))
    requires O.Covered(c,trace) && O.ValidTrace(c,trace,replies)
    requires S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,R.Reject(types),O.Replay(trace,replies),index,B.View(initial),[]).history == trace
    requires forall i :: 0 <= i < |types| ==> Uint(|Render(types[i])|)
    requires forall f <- F.Trace(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,R.Reject(types),O.Replay(trace,replies),index,B.View(initial),[],-1) ::
               f.index < |c.nodes| && f.index < |types| && f.index !in f.memo ==>
                 var candidate := Cold.Before(c,types,f,R.Reject(types),trace,replies);
                 candidate.Success? ==> Uint(|candidate.value|) && CursorRoom(types[f.index],|candidate.value|)
    ensures out == S.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,R.Reject(types),O.Replay(trace,replies),index,B.View(initial),[])
    ensures out.history == trace
    ensures frames == F.Trace(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,R.Reject(types),O.Replay(trace,replies),index,B.View(initial),[],-1)
    ensures |frames| > 0 && |caches| == |frames| && |records| == |frames|
    ensures forall j :: 0 <= j < |frames| ==> frames[j].index < |c.nodes| &&
                                              G.Ready(c,types,caches[j],frames[j].index,R.Reject(types)) &&
                                              B.View(caches[j]) == frames[j].memo &&
                                              Certified(c,types,frames[j],caches[j],trace,replies,records[j])
  {
    var reject := R.Reject(types);
    var oracle := O.Replay(trace,replies);
    B.ViewValid(B.Project(c.nodes),types,initial);
    out,frames := Source.Run(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,oracle,index,B.View(initial),[],-1);
    Bounds.Evaluate(B.Project(c.nodes),B.Canonical(types),Scalar.TotalTruth,reject,oracle,index,B.View(initial),[],-1);
    caches := seq(|frames|, j requires 0 <= j < |frames| => B.Reify(types,initial,frames[j].memo));
    forall j | 0 <= j < |frames|
      ensures G.Ready(c,types,caches[j],frames[j].index,reject) && B.View(caches[j]) == frames[j].memo
    { FrameCache.EntryCache(c,types,initial,frames[j],reject); }
    records := ValidateFrames(c,types,frames,caches,trace,replies);
  }

}

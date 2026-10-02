// SPDX-License-Identifier: MIT
include "Entry.generated.dfy"
include "../rejections/Connection.dfy"
include "../guard-receipts/Connection.dfy"
include "../admission-errors/Connection.dfy"
include "../returns/Connection.dfy"

module ExpressionPublicModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiByteSemantics
  import opened AbiDynamicSemantics
  import E = ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import O = ExpressionOracleModel
  import X = ExpressionExecutionModel
  import Entry = ExpressionEntryConnection
  import R = ExpressionRejectionModel
  import V = ExpressionRejectionRun
  import Cold = ExpressionRejectionConnection
  import F = ExpressionFramesModel
  import G = ExpressionGuardedModel
  import Scalar = ExpressionScalarModel
  import Bounds = ExpressionTraceBounds
  import W = ExpressionAdmissionErrors

  ghost predicate EntryResult(c: O.Config, index: nat, out: Entry.Outcome) {
    out.Evaluated? ==>
      C.Valid(out.types,out.initial) && |out.types| == |c.nodes| && index < |c.nodes| &&
      E.Program(B.Project(c.nodes)) &&
      (forall i :: 0 <= i < |out.types| ==> Render(out.types[i]) == c.nodes[i].valueType) &&
      out.initial == C.Cold(out.types) && B.View(out.initial) == map[] &&
      Entry.CanonicalCache(out.types,out.updated) && C.Extends(out.initial,out.updated) &&
      X.Certified(c,out.execution.history,out.replies) && out.covered == O.Covered(c,out.execution.history) &&
      (out.covered ==> O.ValidTrace(c,out.execution.history,out.replies)) &&
      out.execution == S.Evaluate(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,R.Reject(out.types),
                                  O.Replay(out.execution.history,out.replies),index,map[],[]) &&
      out.raw == Entry.RawResult(out.execution)
  }

  ghost function Frames(c: O.Config, index: nat, out: Entry.Outcome): seq<F.Frame>
    requires EntryResult(c,index,out)
  {
    if out.AdmissionRejected? then [] else
    F.Trace(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,R.Reject(out.types),
            O.Replay(out.execution.history,out.replies),index,map[],[],-1)
  }

  ghost predicate Room(c: O.Config, index: nat, out: Entry.Outcome)
    requires EntryResult(c,index,out)
  {
    out.Evaluated? ==>
      forall f <- Frames(c,index,out) ::
        f.index < |c.nodes| && f.index < |out.types| && f.index !in f.memo ==>
          var body := Cold.Before(c,out.types,f,R.Reject(out.types),out.execution.history,out.replies);
          body.Success? ==> Uint(|body.value|) && CursorRoom(out.types[f.index],|body.value|)
  }

  ghost function Raw(out: Entry.Outcome): E.Raw
  {
    if out.AdmissionRejected? then E.Aborted(E.Error(W.Spec(out.error))) else out.raw
  }

  datatype Evidence = Uncovered | ResourceLimited
                    | Complete(frames: seq<F.Frame>, caches: seq<C.Cache>, validators: seq<V.Record>)

  ghost predicate Certified(c: O.Config, index: nat, out: Entry.Outcome, evidence: Evidence)
    requires EntryResult(c,index,out)
  {
    (evidence.Complete? <==> out.Evaluated? && out.covered && Room(c,index,out)) &&
    (evidence.Complete? ==>
       evidence.frames == Frames(c,index,out) && |evidence.frames| > 0 &&
       Bounds.Within(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,R.Reject(out.types),O.Replay(out.execution.history,out.replies),evidence.frames,[],out.execution.history) &&
       |evidence.caches| == |evidence.frames| && |evidence.validators| == |evidence.frames| &&
       forall j :: 0 <= j < |evidence.frames| ==>
                     evidence.frames[j].index < |c.nodes| &&
                     G.Ready(c,out.types,evidence.caches[j],evidence.frames[j].index,R.Reject(out.types)) &&
                     B.View(evidence.caches[j]) == evidence.frames[j].memo &&
                     V.Certified(c,out.types,evidence.frames[j],evidence.caches[j],out.execution.history,out.replies,evidence.validators[j]))
  }
}

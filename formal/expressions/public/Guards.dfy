// SPDX-License-Identifier: MIT
include "Model.dfy"

module ExpressionPublicGuards {
  import E = ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import O = ExpressionOracleModel
  import Entry = ExpressionEntryConnection
  import R = ExpressionRejectionModel
  import F = ExpressionFramesModel
  import G = ExpressionGuardedModel
  import Bounds = ExpressionTraceBounds
  import Window = ExpressionTraceBoundsConnection
  import Scalar = ExpressionScalarModel
  import Guard = ExpressionGuardReceiptConnection
  import Resolution = ResolutionModel
  import M = ExpressionPublicModel

  datatype Record = Unguarded | Guarded(attempt: G.Outcome, result: C.GuardResult, classified: E.Raw)

  ghost predicate Certified(c: O.Config, index: nat, out: Entry.Outcome, evidence: M.Evidence,
                            j: nat, record: Record)
    requires M.EntryResult(c,index,out) && M.Certified(c,index,out,evidence) && evidence.Complete?
    requires j < |evidence.frames|
  {
    var f := evidence.frames[j];
    (record.Guarded? <==> f.guardOwner >= 0) &&
    (record.Guarded? ==>
       record.attempt.Attempted? && record.attempt.covered &&
       record.attempt.execution == Window.Local(c,out.types,evidence.caches[j],f,R.Reject(out.types),out.execution.history,out.replies) &&
       C.Valid(out.types,record.result.cache) && C.Extends(evidence.caches[j],record.result.cache) &&
       B.View(record.result.cache) == (if record.attempt.execution.Success? then record.attempt.execution.memo else f.memo) &&
       (record.attempt.execution.Success? ==>
          record.result.Accepted? && B.Bytes(record.attempt.execution.value) &&
          record.result.value == B.Narrow(record.attempt.execution.value) && record.result.cache == record.attempt.updated &&
          record.classified == E.Produced(record.attempt.execution.value)) &&
       (record.attempt.execution.Failure? ==>
          record.result.cache == evidence.caches[j] &&
          |f.history|+|record.attempt.execution.history| < |out.execution.history| &&
          out.execution.history[|f.history|+|record.attempt.execution.history|] ==
          E.Request(f.guardOwner as nat,E.GuardFailure,[record.attempt.execution.error.payload]) &&
          record.classified == out.replies[|f.history|+|record.attempt.execution.history|].raw &&
          (record.classified.Aborted? <==> record.result.Exhaustion?) &&
          (record.classified.Produced? <==> record.result.OrdinaryFailure?) &&
          (record.classified.Aborted? ==> record.classified.error.payload == Resolution.Signal())))
  }

  ghost method All(c: O.Config, index: nat, out: Entry.Outcome, evidence: M.Evidence)
    returns (records: seq<Record>)
    requires M.EntryResult(c,index,out) && M.Certified(c,index,out,evidence) && evidence.Complete?
    ensures |records| == |evidence.frames|
    ensures forall j :: 0 <= j < |records| ==> Certified(c,index,out,evidence,j,records[j])
  {
    var oracle := O.Replay(out.execution.history,out.replies);
    B.ViewValid(B.Project(c.nodes),out.types,out.initial);
    Bounds.Evaluate(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,R.Reject(out.types),oracle,index,map[],[],-1);
    records := [];
    var i: nat := 0;
    while i < |evidence.frames|
      invariant i <= |evidence.frames| && |records| == i
      invariant forall j :: 0 <= j < i ==> Certified(c,index,out,evidence,j,records[j])
      decreases |evidence.frames|-i
    {
      var f := evidence.frames[i];
      var record: Record;
      if f.guardOwner < 0 { record := Unguarded; }
      else {
        var attempt,result,classified := Guard.FromRoot(c,out.types,evidence.caches[i],f,R.Reject(out.types),
                                                        out.execution.history,out.replies,evidence.frames,index,map[]);
        record := Guarded(attempt,result,classified);
      }
      records := records+[record];
      i := i+1;
    }
  }
}

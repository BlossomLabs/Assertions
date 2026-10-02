// SPDX-License-Identifier: MIT
include "Equivalence.dfy"
include "../public/Guarded.dfy"

module ExpressionTreeConnection {
  import E = ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import B = ExpressionEvaluationBridge
  import O = ExpressionOracleModel
  import Entry = ExpressionEntryConnection
  import Public = ExpressionPublicModel
  import R = ExpressionRejectionModel
  import Scalar = ExpressionScalarModel
  import Stable = ExpressionOracleStability
  import T = ExpressionTreeSpec
  import Eq = ExpressionTreeEquivalence

  // This is an explicit source-observation determinism premise, including
  // caller/static context, gas-sensitive calls and guard classification.
  // It is not inferred merely from Solidity's view modifier.
  ghost predicate StableConfig(c: O.Config, primitive: E.Request->E.Raw) {
    forall q: E.Request,h: seq<E.Request>,reply: O.Reply ::
      O.Eligible(c,q,h) && O.Matches(c,q,h,reply) ==> reply.raw == primitive(q)
  }

  lemma TraceAgreement(c: O.Config, trace: seq<E.Request>, replies: seq<O.Reply>, primitive: E.Request->E.Raw)
    requires O.Covered(c,trace) && O.ValidTrace(c,trace,replies) && StableConfig(c,primitive)
    ensures Stable.Agree(trace,O.Replay(trace,replies),Eq.Oracle(primitive))
  {
    forall i | 0 <= i < |trace|
      ensures O.Replay(trace,replies)(trace[i],trace[..i]) == Eq.Oracle(primitive)(trace[i],trace[..i])
    {
      assert O.Eligible(c,trace[i],trace[..i]) && O.Matches(c,trace[i],trace[..i],replies[i]);
    }
  }

  lemma FromPublic(c: O.Config, index: nat, out: Entry.Outcome, evidence: Public.Evidence,
                   primitive: E.Request->E.Raw)
    requires Public.EntryResult(c,index,out) && Public.Certified(c,index,out,evidence) && evidence.Complete?
    requires StableConfig(c,primitive)
    ensures out.raw == T.Evaluate(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,R.Reject(out.types),primitive,index)
  {
    var replay := O.Replay(out.execution.history,out.replies);
    TraceAgreement(c,out.execution.history,out.replies,primitive);
    Stable.EvaluateStable(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,R.Reject(out.types),
                          replay,Eq.Oracle(primitive),index,map[],[],out.execution.history);
    Eq.Evaluate(B.Project(c.nodes),B.Canonical(out.types),Scalar.TotalTruth,R.Reject(out.types),primitive,index,map[],[]);
  }
}

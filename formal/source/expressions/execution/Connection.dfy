// SPDX-License-Identifier: MIT
include "Run.dfy"
module ExpressionExecutionConnection {
  import opened ExpressionEvaluationControl
  import M = ExpressionOracleModel
  import X = ExpressionExecutionModel
  import R = ExpressionExecutionRun
  import S = ExpressionRecursiveSpec
  import B = ExpressionEvaluationBridge
  import T = ExpressionRequestModel
  import P = ExpressionPrimitiveConnection
  import Source = ExpressionRequestSource
  import Scalar = ExpressionScalarModel

  lemma ReceiptContracts(c: M.Config, trace: seq<Request>, replies: seq<M.Reply>, valid: (nat,Value)->bool)
    requires Program(B.Project(c.nodes)) && X.Certified(c,trace,replies)
    ensures T.Receipts(B.Project(c.nodes),valid,M.Replay(trace,replies))
  {
    var oracle := M.Replay(trace,replies);
    forall q: Request,h: seq<Request> | T.Typed(B.Project(c.nodes),valid,q)
      ensures (oracle(q,h).Aborted? ==> B.Bytes(oracle(q,h).error.payload)) &&
              (q.stage == Address && oracle(q,h).Produced? ==> Scalar.AddressSpec(q.node,B.Narrow(q.arguments[0])).Addressed?)
    {
      P.TypedRequestShape(c.nodes,valid,q);
      if |h| < |trace| && h == trace[..|h|] && q == trace[|h|] {
        if M.Eligible(c,q,h) { assert M.Matches(c,q,h,replies[|h|]); }
        else { assert replies[|h|].raw == Aborted(Error([])); }
      }
    }
  }

  ghost method Evaluate(c: M.Config, valid: (nat,Value)->bool, reject: (nat,Value)->Error,
                        index: nat, memo: map<nat,Value>)
    returns (out: Result, replies: seq<M.Reply>, covered: bool)
    requires Program(B.Project(c.nodes)) && index < |c.nodes| && Good(B.Project(c.nodes),valid,memo)
    requires forall i: nat,v: Value :: i < |c.nodes| && valid(i,v) ==> B.Bytes(v)
    requires forall i: nat,v: Value :: i < |c.nodes| ==> B.Bytes(reject(i,v).payload)
    ensures X.Certified(c,out.history,replies)
    ensures out == S.Evaluate(B.Project(c.nodes),valid,Scalar.TotalTruth,reject,M.Replay(out.history,replies),index,memo,[])
    ensures Good(B.Project(c.nodes),valid,out.memo) && Extends(memo,out.memo) && Footprint(memo,out.memo,index)
    ensures out.Success? ==> index in out.memo && out.memo[index] == out.value && valid(index,out.value)
    ensures index in memo ==> out == Success(memo[index],memo,[])
    ensures T.History(B.Project(c.nodes),valid,out.history)
    ensures out.Failure? ==> B.Bytes(out.error.payload)
    ensures covered == M.Covered(c,out.history)
    ensures covered ==> M.ValidTrace(c,out.history,replies)
    ensures covered ==> forall i :: 0 <= i < |out.history| ==>
                                      M.Matches(c,out.history[i],out.history[..i],replies[i]) &&
                                      M.Replay(out.history,replies)(out.history[i],out.history[..i]) == replies[i].raw
  {
    out,replies := R.Run(c,B.Project(c.nodes),valid,Scalar.TotalTruth,reject,index,memo,[],[]);
    ReceiptContracts(c,out.history,replies,valid);
    var confirmed := Source.Run(B.Project(c.nodes),valid,Scalar.TotalTruth,reject,M.Replay(out.history,replies),index,memo,[]);
    assert confirmed == out;
    covered := M.Covered(c,out.history);
    if covered { X.CoveredCertificate(c,out.history,replies); }
    M.ReplayEntries(out.history,replies);
  }
}

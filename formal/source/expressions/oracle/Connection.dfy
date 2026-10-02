// SPDX-License-Identifier: MIT
include "Model.dfy"
module ExpressionOracleConnection {
  import opened AbiFrames
  import M = ExpressionOracleModel
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import T = ExpressionRequestModel
  import P = ExpressionPrimitiveConnection
  import Source = ExpressionRequestSource
  import S = ExpressionRecursiveSpec
  import Scalar = ExpressionScalarModel

  lemma ReceiptContracts(c: M.Config, trace: seq<E.Request>, replies: seq<M.Reply>, valid: (nat,E.Value)->bool)
    requires E.Program(B.Project(c.nodes)) && M.Covered(c,trace) && M.ValidTrace(c,trace,replies)
    ensures T.Receipts(B.Project(c.nodes),valid,M.Replay(trace,replies))
  {
    var oracle := M.Replay(trace,replies);
    forall q: E.Request,h: seq<E.Request> | T.Typed(B.Project(c.nodes),valid,q)
      ensures (oracle(q,h).Aborted? ==> B.Bytes(oracle(q,h).error.payload)) &&
              (q.stage == E.Address && oracle(q,h).Produced? ==> Scalar.AddressSpec(q.node,B.Narrow(q.arguments[0])).Addressed?)
    {
      P.TypedRequestShape(c.nodes,valid,q);
      if |h| < |trace| && h == trace[..|h|] && q == trace[|h|] {
        assert M.Matches(c,q,h,replies[|h|]);
      }
    }

  }
  ghost method Run(c: M.Config, trace: seq<E.Request>, valid: (nat,E.Value)->bool, reject: (nat,E.Value)->E.Error,
                   index: nat, memo: map<nat,E.Value>) returns (out: E.Result, replies: seq<M.Reply>)
    requires E.Program(B.Project(c.nodes)) && index < |c.nodes| && E.Good(B.Project(c.nodes),valid,memo)
    requires M.Covered(c,trace)
    requires forall i: nat,v: E.Value :: i < |c.nodes| && valid(i,v) ==> B.Bytes(v)
    requires forall i: nat,v: E.Value :: i < |c.nodes| ==> B.Bytes(reject(i,v).payload)
    ensures M.ValidTrace(c,trace,replies)
    ensures out == S.Evaluate(B.Project(c.nodes),valid,Scalar.TotalTruth,reject,M.Replay(trace,replies),index,memo,[])
    ensures E.Good(B.Project(c.nodes),valid,out.memo) && E.Extends(memo,out.memo) && E.Footprint(memo,out.memo,index)
    ensures out.Success? ==> index in out.memo && out.memo[index] == out.value && valid(index,out.value)
    ensures index in memo ==> out == E.Success(memo[index],memo,[])
    ensures T.History(B.Project(c.nodes),valid,out.history)
    ensures out.Failure? ==> B.Bytes(out.error.payload)
    ensures out.history == trace ==> forall i :: 0 <= i < |out.history| ==>
                                                   M.Matches(c,out.history[i],out.history[..i],replies[i]) &&
                                                   M.Replay(trace,replies)(out.history[i],out.history[..i]) == replies[i].raw
  {
    replies := M.BuildTrace(c,trace);
    ReceiptContracts(c,trace,replies,valid);
    out := Source.Run(B.Project(c.nodes),valid,Scalar.TotalTruth,reject,M.Replay(trace,replies),index,memo,[]);
    M.ReplayEntries(trace,replies);
  }
}

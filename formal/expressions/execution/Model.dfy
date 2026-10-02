// SPDX-License-Identifier: MIT
include "../oracle-stability/Append.dfy"
module ExpressionExecutionModel {
  import opened ExpressionEvaluationControl
  import M = ExpressionOracleModel
  import P = ExpressionPrimitiveConnection
  import D = ExpressionPrimitiveDispatch
  import H = ExpressionOracleStability
  import S = ExpressionRecursiveSpec
  import Args = ArgumentsModel
  import CC = AbiConstructionContext

  // The fallback is proof totalization, never an asserted Solidity outcome.
  // Covered on the completed trace excludes every use of it.
  ghost predicate Certified(c: M.Config, history: seq<Request>, replies: seq<M.Reply>) {
    |history| == |replies| && forall i :: 0 <= i < |history| ==>
                                            (if M.Eligible(c,history[i],history[..i]) then M.Matches(c,history[i],history[..i],replies[i])
                                             else replies[i].raw == Aborted(Error([])))
  }
  lemma CoveredCertificate(c: M.Config, history: seq<Request>, replies: seq<M.Reply>)
    requires Certified(c,history,replies) && M.Covered(c,history)
    ensures M.ValidTrace(c,history,replies)
  {}
  ghost method Invoke(c: M.Config, q: Request, memo: map<nat,Value>, history: seq<Request>, replies: seq<M.Reply>)
    returns (out: Result, more: seq<M.Reply>)
    requires Certified(c,history,replies)
    ensures out.history == history+[q] && replies <= more
    ensures Certified(c,out.history,more)
    ensures out == S.Invoke(q,M.Replay(out.history,more),memo,history)
  {
    var reply := M.Reply(Aborted(Error([])),[],Args.NotEncoded,CC.Success,[]);
    if M.Eligible(c,q,history) {
      var f := c.frames(q,history);
      var raw,after,tuple,arrayResult,constructed := D.Dispatch(c.nodes[q.node],q.stage,P.NarrowArguments(q.arguments),q.node,
                                                                c.parameters,c.core,c.self,c.resolveSelector,c.guard,c.decode,f.env,f.history,f.boundary);
      reply := M.Reply(raw,after,tuple,arrayResult,constructed);
      assert M.Matches(c,q,history,reply);
    }
    more := replies+[reply];
    var raw := reply.raw;
    out := if raw.Aborted? then Failure(raw.error,memo,history+[q]) else Success(raw.value,memo,history+[q]);
    forall i | 0 <= i < |out.history|
      ensures if M.Eligible(c,out.history[i],out.history[..i]) then M.Matches(c,out.history[i],out.history[..i],more[i])
              else more[i].raw == Aborted(Error([]))
    {
      if i < |history| { assert out.history[..i] == history[..i]; }
      else { assert i == |history| && out.history[..i] == history; }
    }
  }

  lemma PreserveEvaluation(nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool, reject: (nat,Value)->Error,
                           index: nat, memo: map<nat,Value>, start: seq<Request>, result: Result,
                           replies: seq<M.Reply>, longer: seq<Request>, more: seq<M.Reply>)
    requires Program(nodes) && index < |nodes|
    requires |result.history| == |replies| && |longer| == |more| && result.history <= longer && replies <= more
    requires result == S.Evaluate(nodes,valid,truth,reject,M.Replay(result.history,replies),index,memo,start)
    ensures result == S.Evaluate(nodes,valid,truth,reject,M.Replay(longer,more),index,memo,start)
  {
    H.ReplayExtension(result.history,replies,longer,more);
    H.EvaluateStable(nodes,valid,truth,reject,M.Replay(result.history,replies),M.Replay(longer,more),index,memo,start,result.history);
  }
  lemma PreserveInvoke(q: Request, memo: map<nat,Value>, start: seq<Request>, result: Result,
                       replies: seq<M.Reply>, longer: seq<Request>, more: seq<M.Reply>)
    requires |result.history| == |replies| && |longer| == |more| && result.history <= longer && replies <= more
    requires result == S.Invoke(q,M.Replay(result.history,replies),memo,start)
    ensures result == S.Invoke(q,M.Replay(longer,more),memo,start)
  {
    H.ReplayExtension(result.history,replies,longer,more);
    H.InvokeStable(q,M.Replay(result.history,replies),M.Replay(longer,more),memo,start,result.history);
  }
}

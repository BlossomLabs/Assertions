// SPDX-License-Identifier: MIT
include "Connection.dfy"
module ExpressionOracleStabilityAppend {
  import opened ExpressionEvaluationControl
  import M = ExpressionOracleModel
  import P = ExpressionPrimitiveConnection
  import D = ExpressionPrimitiveDispatch
  import H = ExpressionOracleStability
  import S = ExpressionRecursiveSpec

  ghost method Append(c: M.Config, trace: seq<Request>, replies: seq<M.Reply>, request: Request)
    returns (extended: seq<M.Reply>)
    requires M.Covered(c,trace) && M.ValidTrace(c,trace,replies) && M.Eligible(c,request,trace)
    ensures M.Covered(c,trace+[request]) && M.ValidTrace(c,trace+[request],extended)
    ensures replies <= extended && |extended| == |replies|+1
    ensures H.Agree(trace,M.Replay(trace,replies),M.Replay(trace+[request],extended))
    ensures M.Replay(trace+[request],extended)(request,trace) == extended[|replies|].raw
  {
    var f := c.frames(request,trace);
    var raw,after,tuple,arrayResult,constructed := D.Dispatch(c.nodes[request.node],request.stage,P.NarrowArguments(request.arguments),request.node,
                                                              c.parameters,c.core,c.self,c.resolveSelector,c.guard,c.decode,f.env,f.history,f.boundary);
    var reply := M.Reply(raw,after,tuple,arrayResult,constructed);
    assert M.Matches(c,request,trace,reply);
    extended := replies+[reply];
    forall i | 0 <= i < |trace+[request]|
      ensures M.Eligible(c,(trace+[request])[i],(trace+[request])[..i]) &&
              M.Matches(c,(trace+[request])[i],(trace+[request])[..i],extended[i])
    {
      if i < |trace| { assert (trace+[request])[..i] == trace[..i]; }
      else { assert i == |trace| && (trace+[request])[..i] == trace; }
    }
    H.ReplayExtension(trace,replies,trace+[request],extended);
  }

  ghost method AppendPreservesEvaluation(c: M.Config, trace: seq<Request>, replies: seq<M.Reply>, request: Request,
                                         nodes: seq<Node>, valid: (nat,Value)->bool, truth: Value->bool,
                                         reject: (nat,Value)->Error, index: nat, memo: map<nat,Value>, start: seq<Request>)
    returns (extended: seq<M.Reply>)
    requires M.Covered(c,trace) && M.ValidTrace(c,trace,replies) && M.Eligible(c,request,trace)
    requires Program(nodes) && index < |nodes|
    requires S.Evaluate(nodes,valid,truth,reject,M.Replay(trace,replies),index,memo,start).history <= trace
    ensures M.Covered(c,trace+[request]) && M.ValidTrace(c,trace+[request],extended)
    ensures replies <= extended && |extended| == |replies|+1
    ensures S.Evaluate(nodes,valid,truth,reject,M.Replay(trace,replies),index,memo,start) ==
            S.Evaluate(nodes,valid,truth,reject,M.Replay(trace+[request],extended),index,memo,start)
  {
    extended := Append(c,trace,replies,request);
    H.EvaluateStable(nodes,valid,truth,reject,M.Replay(trace,replies),M.Replay(trace+[request],extended),index,memo,start,trace);
  }
}

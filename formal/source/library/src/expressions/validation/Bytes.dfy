// SPDX-License-Identifier: MIT
include "../trace-bounds/Connection.dfy"
module ExpressionValidationBytes {
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import O = ExpressionOracleModel
  import P = ExpressionPrimitiveConnection
  import M = ExpressionPrimitiveModel
  import A = ExpressionAdmission

  predicate Raw(raw: E.Raw) {
    if raw.Produced? then B.Bytes(raw.value) else B.Bytes(raw.error.payload)
  }
  lemma Reply(c: O.Config, q: E.Request, history: seq<E.Request>, reply: O.Reply)
    requires O.Eligible(c,q,history) && O.Matches(c,q,history,reply)
    ensures Raw(reply.raw)
  {
    var node := c.nodes[q.node];
    var values := P.NarrowArguments(q.arguments);
    var frame := c.frames(q,history);
    assert M.Post(node,q.stage,values,q.node,c.parameters,c.core,c.self,c.resolveSelector,c.guard,
                  c.decode,frame.env,frame.history,frame.boundary,reply.raw,reply.after,reply.tuple,reply.arrayResult,reply.constructed);
    if reply.raw.Produced? {
      match q.stage
      case Leaf =>
        if node.kind == A.Literal { B.ByteIdentity(node.data); }
      case Address => B.ByteIdentity(values[0]);
      case Boolean =>
      case GuardFailure =>
      case Finish =>
        B.ByteIdentity(reply.constructed);
    }
  }
  ghost predicate Oracle(oracle: (E.Request,seq<E.Request>)->E.Raw) {
    forall q: E.Request,h: seq<E.Request> :: Raw(oracle(q,h))
  }
  lemma Replay(c: O.Config, trace: seq<E.Request>, replies: seq<O.Reply>)
    requires O.Covered(c,trace) && O.ValidTrace(c,trace,replies)
    ensures Oracle(O.Replay(trace,replies))
  {
    forall q: E.Request,h: seq<E.Request>
      ensures Raw(O.Replay(trace,replies)(q,h))
    {
      if |h| < |trace| && h == trace[..|h|] && q == trace[|h|] {
        Reply(c,q,h,replies[|h|]);
      }
    }
  }
}

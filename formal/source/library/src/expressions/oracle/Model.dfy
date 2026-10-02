// SPDX-License-Identifier: MIT
include "../primitives/Connection.dfy"
module ExpressionOracleModel {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import A = ExpressionAdmission
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import R = ResolutionModel
  import P = ExpressionPrimitiveConnection
  import M = ExpressionPrimitiveModel
  import D = ExpressionPrimitiveDispatch
  import Args = ArgumentsModel
  import CC = AbiConstructionContext
  import Build = AbiConstructionModel
  import Resolve = ExpressionResolveModel
  import Probe = ExpressionProbeInput

  datatype Frame = Frame(env: R.Environment, history: seq<R.Request>, boundary: R.Observation)
  datatype Config = Config(nodes: seq<A.Node>, parameters: seq<seq<Byte>>, core: R.Address, self: R.Address,
                           resolveSelector: seq<Byte>, guard: seq<Byte>, decode: seq<Byte>->Resolve.Decode,
                           frames: (E.Request,seq<E.Request>)->Frame)
  datatype Reply = Reply(raw: E.Raw, after: seq<R.Request>, tuple: Args.Receipt, arrayResult: CC.Result, constructed: seq<Byte>)

  ghost predicate Eligible(c: Config, q: E.Request, h: seq<E.Request>) {
    if q.node >= |c.nodes| || !P.ByteArguments(q.arguments) then false else
    var node := c.nodes[q.node];
    var values := P.NarrowArguments(q.arguments);
    var f := c.frames(q,h);
    M.Shape(node,q.stage,values,q.node) && Uint(q.node) &&
    Uint(|node.data|) && Uint(|node.arguments|) && |node.selector| == 4 &&
    Uint(|values|) && Uint(64+Build.TotalBytes(values)) &&
    (forall i :: 0 <= i < |values| ==> Uint(|values[i]|)) &&
    |c.guard| == 4 && |c.resolveSelector| == 4 &&
    (q.stage == E.GuardFailure ==> f.boundary.data == values[0]) &&
    (q.stage == E.Finish && node.kind == A.Wrap ==> Uint(|values[0]|+96)) &&
    (q.stage == E.Finish && node.kind == A.ProbeCall ==>
       Validate(Bytes,values[1]).Parsed? && Probe.Decodable(values[1]) &&
       |f.env.call(f.history,R.Call(M.Target(q.node,values[0]),Probe.DecodeBytes(values[1]))).data|+96 < Pow256(32))
  }
  ghost predicate Matches(c: Config, q: E.Request, h: seq<E.Request>, reply: Reply)
    requires Eligible(c,q,h)
  {
    var f := c.frames(q,h);
    M.Post(c.nodes[q.node],q.stage,P.NarrowArguments(q.arguments),q.node,c.parameters,c.core,c.self,c.resolveSelector,c.guard,
           c.decode,f.env,f.history,f.boundary,reply.raw,reply.after,reply.tuple,reply.arrayResult,reply.constructed) &&
    P.Contract(c.nodes[q.node],q,reply.raw)
  }
  ghost method Available(c: Config, q: E.Request, h: seq<E.Request>)
    requires Eligible(c,q,h)
    ensures exists reply :: Matches(c,q,h,reply)
  {
    var f := c.frames(q,h);
    var raw,after,tuple,arrayResult,constructed := D.Dispatch(c.nodes[q.node],q.stage,P.NarrowArguments(q.arguments),q.node,
                                                              c.parameters,c.core,c.self,c.resolveSelector,c.guard,c.decode,f.env,f.history,f.boundary);
    var reply := Reply(raw,after,tuple,arrayResult,constructed);
    assert Matches(c,q,h,reply);
  }
  ghost predicate Covered(c: Config, history: seq<E.Request>) {
    forall i :: 0 <= i < |history| ==> Eligible(c,history[i],history[..i])
  }
  ghost predicate ValidTrace(c: Config, history: seq<E.Request>, replies: seq<Reply>)
    requires Covered(c,history)
  {
    |history| == |replies| && forall i :: 0 <= i < |history| ==> Matches(c,history[i],history[..i],replies[i])
  }
  ghost method BuildTrace(c: Config, history: seq<E.Request>) returns (replies: seq<Reply>)
    requires Covered(c,history)
    ensures ValidTrace(c,history,replies)
  {
    replies := [];
    var i := 0;
    while i < |history|
      invariant 0 <= i <= |history| && |replies| == i
      invariant forall j :: 0 <= j < i ==> Matches(c,history[j],history[..j],replies[j])
    {
      var q := history[i];
      var f := c.frames(q,history[..i]);
      var raw,after,tuple,arrayResult,constructed := D.Dispatch(c.nodes[q.node],q.stage,P.NarrowArguments(q.arguments),q.node,
                                                                c.parameters,c.core,c.self,c.resolveSelector,c.guard,c.decode,f.env,f.history,f.boundary);
      var reply := Reply(raw,after,tuple,arrayResult,constructed);
      assert Matches(c,q,history[..i],reply);
      replies := replies+[reply];
      i := i+1;
    }
  }
  function Replay(history: seq<E.Request>, replies: seq<Reply>): (E.Request,seq<E.Request>)->E.Raw
    requires |history| == |replies|
  {
    (q: E.Request,h: seq<E.Request>) =>
      if |h| < |history| && h == history[..|h|] && q == history[|h|] then replies[|h|].raw
      else E.Aborted(E.Error([]))
  }
  lemma ReplayEntries(history: seq<E.Request>, replies: seq<Reply>)
    requires |history| == |replies|
    ensures forall i :: 0 <= i < |history| ==> Replay(history,replies)(history[i],history[..i]) == replies[i].raw
  {}
}

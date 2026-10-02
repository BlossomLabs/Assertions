// SPDX-License-Identifier: MIT
include "Dispatch.dfy"
module ExpressionPrimitiveConnection {
  import opened AbiFrames
  import A = ExpressionAdmission
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import T = ExpressionRequestModel
  import M = ExpressionPrimitiveModel
  import Scalar = ExpressionScalarModel

  predicate ByteArguments(args: seq<E.Value>) {
    forall i :: 0 <= i < |args| ==> B.Bytes(args[i])
  }
  function NarrowArguments(args: seq<E.Value>): seq<seq<Byte>>
    requires ByteArguments(args)
    ensures |NarrowArguments(args)| == |args|
  { seq(|args|, i requires 0 <= i < |args| => B.Narrow(args[i])) }
  lemma NarrowIdentity(value: E.Value)
    requires B.Bytes(value)
    ensures B.Narrow(value) == value
  {}
  lemma TypedRequestShape(nodes: seq<A.Node>, valid: (nat,E.Value)->bool, request: E.Request)
    requires E.Program(B.Project(nodes)) && T.Typed(B.Project(nodes),valid,request)
    ensures ByteArguments(request.arguments)
    ensures M.Shape(nodes[request.node],request.stage,NarrowArguments(request.arguments),request.node)
  {
    var node := nodes[request.node];
    assert B.Project(nodes)[request.node] == E.Node(B.KindOf(node.kind),node.refs);
    if request.stage == E.Boolean {
      assert request.arguments[0] == [0] || request.arguments[0] == [1];
    }
    assert ByteArguments(request.arguments);
    forall i | 0 <= i < |request.arguments|
      ensures NarrowArguments(request.arguments)[i] == request.arguments[i]
    { NarrowIdentity(request.arguments[i]); }
    assert NarrowArguments(request.arguments) == request.arguments;
  }
  ghost predicate Contract(node: A.Node, request: E.Request, raw: E.Raw)
    requires ByteArguments(request.arguments)
  {
    (raw.Aborted? ==> B.Bytes(raw.error.payload)) &&
    (request.stage == E.Address && |request.arguments| == 1 && raw.Produced? ==>
       Scalar.AddressSpec(request.node,B.Narrow(request.arguments[0])).Addressed?)
  }
  lemma LiftReceiptContracts(nodes: seq<A.Node>, valid: (nat,E.Value)->bool,
                             oracle: (E.Request,seq<E.Request>)->E.Raw)
    requires E.Program(B.Project(nodes))
    requires forall q,h :: T.Typed(B.Project(nodes),valid,q) ==>
                             ByteArguments(q.arguments) && Contract(nodes[q.node],q,oracle(q,h))
    ensures T.Receipts(B.Project(nodes),valid,oracle)
  {}
}

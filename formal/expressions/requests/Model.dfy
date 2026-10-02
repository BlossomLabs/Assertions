// SPDX-License-Identifier: MIT
include "../scalars/Connection.dfy"
module ExpressionRequestModel {
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import M = ExpressionScalarModel
  predicate Typed(nodes: seq<E.Node>, valid: (nat,E.Value)->bool, q: E.Request)
    requires E.Program(nodes)
  {
    q.node < |nodes| &&
    var node := nodes[q.node];
    match q.stage
    case Leaf => node.kind in {E.Literal,E.Parameter,E.Resolve} && |q.arguments| == 0
    case Address => node.kind in {E.Call,E.ProbeCall} && |q.arguments| == 1 &&
                    valid(node.refs[0],q.arguments[0]) && B.Bytes(q.arguments[0])
    case Boolean => node.kind == E.IsValid && |q.arguments| == 1 && q.arguments[0] in {[0],[1]}
    case GuardFailure => node.kind in {E.TryOrElse,E.IsValid} && |q.arguments| == 1 && B.Bytes(q.arguments[0])
    case Finish => node.kind in {E.Wrap,E.Array,E.Tuple,E.Call,E.ProbeCall} && |q.arguments| == |node.refs| &&
                   (forall i :: 0 <= i < |node.refs| ==> valid(node.refs[i],q.arguments[i]) && B.Bytes(q.arguments[i])) &&
                   (node.kind in {E.Call,E.ProbeCall} ==> M.AddressSpec(q.node,B.Narrow(q.arguments[0])).Addressed?)
  }
  predicate History(nodes: seq<E.Node>, valid: (nat,E.Value)->bool, h: seq<E.Request>)
    requires E.Program(nodes)
  { forall i :: 0 <= i < |h| ==> Typed(nodes,valid,h[i]) }
  ghost predicate Receipts(nodes: seq<E.Node>, valid: (nat,E.Value)->bool, oracle: (E.Request,seq<E.Request>)->E.Raw)
    requires E.Program(nodes)
  {
    forall q,h :: Typed(nodes,valid,q) ==>
                    (oracle(q,h).Aborted? ==> B.Bytes(oracle(q,h).error.payload)) &&
                    (q.stage == E.Address && oracle(q,h).Produced? ==> M.AddressSpec(q.node,B.Narrow(q.arguments[0])).Addressed?)
  }
  lemma Append(nodes: seq<E.Node>, valid: (nat,E.Value)->bool, h: seq<E.Request>, q: E.Request)
    requires E.Program(nodes) && History(nodes,valid,h) && Typed(nodes,valid,q)
    ensures History(nodes,valid,h+[q])
  {}
}

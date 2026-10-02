// SPDX-License-Identifier: MIT
include "Encoding.dfy"
module ExpressionGuardedModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import C = ExpressionCache
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import O = ExpressionOracleModel
  import W = ExpressionGuardedEncoding
  import R = ResolutionModel

  function NotSelfSelector(): seq<Byte> { [0x7d,0x11,0x6e,0xd0] }
  function NotSelf(caller: R.Address): seq<Byte> { NotSelfSelector()+Word(caller) }
  ghost predicate Ready(c: O.Config, types: seq<Descriptor>, initial: C.Cache, index: nat, reject: (nat,E.Value)->E.Error) {
    E.Program(B.Project(c.nodes)) && index < |c.nodes| && |types| == |c.nodes| && C.Valid(types,initial) && W.WordsFit(initial) &&
    (forall i :: 0 <= i < |types| ==> Render(types[i]) == c.nodes[i].valueType) &&
    (forall i: nat,v: E.Value :: i < |c.nodes| ==> B.Bytes(reject(i,v).payload))
  }
  datatype Outcome = Denied(reason: seq<Byte>)
                   | Attempted(execution: E.Result, updated: C.Cache, replies: seq<O.Reply>, covered: bool)
}

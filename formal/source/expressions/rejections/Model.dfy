// SPDX-License-Identifier: MIT
include "../../abi/outcomes/Connection.dfy"
include "../validation/Completion.dfy"

module ExpressionRejectionModel {
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiByteSemantics
  import E = ExpressionEvaluationControl
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import V = AbiExactOutcomeConnection
  import Exact = AbiExactOutcomeSpec
  import Route = AbiConstructionContext
  import Wire = ExpressionCodecErrorEncoding

  ghost function Error(types: seq<Descriptor>, index: nat, value: E.Value): E.Error
    requires C.Types(types)
  {
    if index >= |types| || !B.Bytes(value) then E.Error([]) else
    var raw := V.Receipt(types[index],B.Narrow(value));
    if raw.Aborted? then raw.error else E.Error([])
  }

  ghost function Reject(types: seq<Descriptor>): (nat,E.Value)->E.Error
    requires C.Types(types)
  { (i: nat,v: E.Value) => Error(types,i,v) }

  lemma Bytes(types: seq<Descriptor>, index: nat, value: E.Value)
    requires C.Types(types)
    ensures B.Bytes(Reject(types)(index,value).payload)
  {
    if index < |types| && B.Bytes(value) {
      var outcome := Exact.Validate(types[index],B.Narrow(value));
      var routed := Route.Route(outcome,Route.Context(Route.ValueKind,0,0,0,0));
      if !routed.Success? { B.ByteIdentity(Wire.Encoded(routed)); }
    }
  }
  lemma AllBytes(types: seq<Descriptor>)
    requires C.Types(types)
    ensures forall i: nat,v: E.Value :: B.Bytes(Reject(types)(i,v).payload)
  {
    forall i: nat,v: E.Value ensures B.Bytes(Reject(types)(i,v).payload)
    { Bytes(types,i,v); }
  }
}

// SPDX-License-Identifier: MIT
// Generated from complete sortValues source gate and concrete result slots.
include "Model.dfy"
module CollectionsSortComparatorSource {
  import opened AbiFrames
  import opened CollectionsSortComparatorModel
  import T = CollectionsTraversalModel
  import C = CollectionsCallsModel
  import R = CollectionsCallbackResultsModel
  import W = CollectionsWireModel
  import WS = CollectionsWireConnection
  import B = AbiBytesSource
  import Bytes = AbiByteSemantics
  function Operation(): seq<Byte>
    ensures |Operation()| == 4
  { [0xdc,0xd9,0xdc,0x3b] }
  function Request(values: seq<seq<Byte>>,a: nat,b: nat): T.Request
    requires a < |values| && b < |values|
    ensures Request(values,a,b) == T.Call(values[a],values[b],true,a,b)
  { T.Call(values[a],values[b],true,a,b) }
  ghost method Process(out: C.Outcome,operation: seq<Byte>,a: nat,b: nat,target: nat) returns (decision: Decision)
    requires Room(out,R.Context(operation,a,b,target))
    ensures decision == Judge(out,R.Context(operation,a,b,target))
    ensures out.Failed? ==> decision == Failure(W.ErrorBytes(out.error))
    ensures out.Returned? ==> (decision.TakeLeft? == (|out.value| == 32))
  {
    if out.Failed? {
      WS.ErrorLayout(out.error);
      decision := Failure(W.ErrorBytes(out.error)); return;
    }
    var answer := out.value;
    if (|answer| != 32) {
      var context := R.Context(operation,a,b,target);
      WS.PredicateErrorSelector(context);
      decision := Failure(R.InvalidBytes(context)); return;
    }
    var loaded := B.ReadWord(answer,0);
    assert answer[0..32] == answer;
    assert loaded.Ok? && loaded.used == ReadNat(answer);
    var signed := Signed(loaded.used);
    Sign(answer);
    decision := TakeLeft(signed <= 0);
  }
}

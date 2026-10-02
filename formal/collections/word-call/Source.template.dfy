// SPDX-License-Identifier: MIT
// Generated from complete domain, target-check and word-call helper gates.
include "Model.dfy"
module CollectionsWordCallSource {
  import opened AbiFrames
  import opened CollectionsWordCallModel
  import C = CollectionsCallsModel
  import R = CollectionsCallbackResultsModel
  import Reject = CollectionsCallbackResultsSource
  import W = CollectionsWireModel
  import Wire = CollectionsWireConnection
  import B = AbiBytesSource
  ghost method DomainElement(domain: Domain,index: nat,subject: seq<Byte>) returns (value: nat)
    requires DomainRoom(domain,index,subject)
    ensures value == Element(domain,index,subject) && value < Pow256(32)
  {
    if $RANGE_GUARD { value := $RANGE_VALUE; return; }
    if $BYTE_GUARD { value := subject[$BYTE_INDEX]; assert Pow256(32) > 255; return; }
    assert index*32+32 <= |subject|;
    assert index*32 < Pow256(32) && index*32+32 < Pow256(32);
    var bytes := subject[$WORD_START..$WORD_END];
    value := ReadNat(bytes);
    BytesNatRoundTrip(bytes);
  }
  ghost method CheckTarget(target: nat,h: seq<C.Event>,code: (seq<C.Event>,nat)->nat) returns (reason: seq<Byte>,after: seq<C.Event>)
    requires target < Pow256(20)
    ensures after == h+[C.Target(target)]
    ensures reason == (if code(h,target) == 0 then W.ErrorBytes(C.InvalidTarget(target)) else [])
  {
    var length := code(h,target);
    after := h+[C.Target(target)];
    if $NO_CODE {
      Wire.ErrorLayout(C.InvalidTarget(target));
      reason := W.ErrorBytes(C.InvalidTarget(target));
    } else { reason := []; }
  }
  ghost method CallWord(operation: seq<Byte>,index: nat,target: nat,data: seq<Byte>,h: seq<C.Event>,env: Environment)
    returns (answer: Answer,after: seq<C.Event>)
    requires Room(operation,index,target,data,env(h,target,data))
    ensures answer == Judge(operation,index,target,data,env(h,target,data))
    ensures after == h+[C.External(target,data)]
    ensures answer.Word? ==> answer.value < Pow256(32)
  {
    var observed := env(h,target,data);
    after := h+[C.External(target,data)];
    if $FAILED {
      var rejected := Reject.RejectOutOfGas(observed.gasBefore,observed.gasAfter,observed.data);
      if rejected { answer := Failure(R.Signal()); return; }
      var error := C.CallbackFailed(operation,$ERROR_INDEX,$ERROR_OTHER,target,data,observed.data);
      Wire.ErrorLayout(error);
      answer := Failure(W.ErrorBytes(error)); return;
    }
    var ret := observed.data;
    if $BAD_LENGTH {
      var context := R.Context(operation,$INVALID_INDEX,$INVALID_OTHER,target);
      Wire.PredicateErrorSelector(context);
      answer := Failure(R.InvalidBytes(context)); return;
    }
    var loaded := B.ReadWord(ret,$READ_OFFSET);
    assert ret[..32] == ret;
    answer := Word(loaded.used);
    BytesNatRoundTrip(ret);
  }
}

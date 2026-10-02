// SPDX-License-Identifier: MIT
include "Model.dfy"
module ExpressionRejectionCompletion {
  import R = ExpressionRejectionModel
  import ExactReceipt = AbiExactOutcomeConnection
  import opened AbiFrames
  import opened AbiShapeSemantics
  import opened AbiByteSemantics
  import opened AbiDynamicSemantics
  import E = ExpressionEvaluationControl
  import S = ExpressionRecursiveSpec
  import B = ExpressionEvaluationBridge
  import C = ExpressionCache
  import V = ExpressionValidationControl
  import Codec = AbiExactOutcomeReceipt
  import W = ExpressionCodecErrorEncoding

  datatype Receipt = Skipped | Checked(outcome: Outcome, raw: E.Raw)
  ghost predicate Good(types: seq<Descriptor>, memo: map<nat,E.Value>)
    requires C.Types(types)
  { forall i <- memo.Keys :: i < |types| && B.Canonical(types)(i,memo[i]) }
  function ErrorOf(receipt: Receipt): E.Error {
    if receipt.Checked? && receipt.raw.Aborted? then receipt.raw.error else E.Error([])
  }
  function Reject(receipt: Receipt): (nat,E.Value)->E.Error {
    (i: nat,v: E.Value) => ErrorOf(receipt)
  }
  ghost method Complete(types: seq<Descriptor>, index: nat, body: E.Result)
    returns (out: E.Result, receipt: Receipt)
    requires C.Types(types) && index < |types| && Good(types,body.memo) && V.ResultBytes(body)
    requires body.Success? ==> index !in body.memo && Uint(|Render(types[index])|) && Uint(|body.value|) && CursorRoom(types[index],|body.value|)
    ensures receipt.Checked? <==> body.Success?
    ensures out == S.Complete(index,B.Canonical(types),Reject(receipt),body)
    ensures out == S.Complete(index,B.Canonical(types),R.Reject(types),body)
    ensures body.Success? ==> receipt.raw == ExactReceipt.Receipt(types[index],B.Narrow(body.value))
    ensures Good(types,out.memo) && V.ResultBytes(out) && E.Extends(body.memo,out.memo)
    ensures out.history == body.history
    ensures body.Failure? ==> out == body
    ensures body.Success? ==> (out.Success? <==> B.Canonical(types)(index,body.value))
    ensures out.Success? ==> out.value == body.value && out.memo == body.memo[index := body.value] && B.Canonical(types)(index,out.value)
    ensures receipt.Checked? ==> !receipt.outcome.Panic?
    ensures receipt.Checked? && out.Failure? ==> receipt.outcome.Invalid? && receipt.raw.Aborted? &&
                                                 out == E.Failure(receipt.raw.error,body.memo,body.history) &&
                                                 out.error.payload == W.InvalidValueSelector()+Word(receipt.outcome.offset)
    ensures forall i: nat,v: E.Value :: B.Bytes(Reject(receipt)(i,v).payload)
  {
    if body.Failure? { receipt := Skipped; out := body; return; }
    var value := B.Narrow(body.value);
    var checked,raw := Codec.ValidateReceipt(Render(types[index]),value,types[index],Dyn(types[index]),Width(types[index]));
    receipt := Checked(checked,raw);
    if raw.Aborted? {
      B.ByteIdentity(W.InvalidValueSelector()+Word(checked.offset));
      out := E.Failure(raw.error,body.memo,body.history);
    } else {
      out := E.Success(body.value,body.memo[index := body.value],body.history);
    }
  }
  lemma Substitute(types: seq<Descriptor>, index: nat, body: E.Result, receipt: Receipt,
                   reject: (nat,E.Value)->E.Error)
    requires C.Types(types)
    requires body.Success? && !B.Canonical(types)(index,body.value) ==> reject(index,body.value) == ErrorOf(receipt)
    ensures S.Complete(index,B.Canonical(types),reject,body) == S.Complete(index,B.Canonical(types),Reject(receipt),body)
  {}
}

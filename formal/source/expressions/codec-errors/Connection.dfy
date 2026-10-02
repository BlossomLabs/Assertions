// SPDX-License-Identifier: MIT
include "Encoding.dfy"
module ExpressionCodecErrorConnection {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import opened AbiDynamicSemantics
  import opened AbiConstructionModel
  import V = AbiConstructionValidation
  import C = AbiConstructionContext
  import W = ExpressionCodecErrorEncoding
  import E = ExpressionEvaluationControl
  import A = ArgumentsModel
  import Source = ExpressionCompoundSource

  ghost method ValidateReceipt(t: seq<Byte>, value: seq<Byte>, s: Descriptor, dynamic: bool, words: nat)
    returns (checked: Outcome, raw: E.Raw)
    requires Uint(|t|) && Uint(|value|)
    requires Admissible(s) && t == Render(s) && dynamic == Dyn(s) && words == Width(s)
    requires CursorRoom(s,|value|)
    ensures WellFormed(TypeOf(s))
    ensures !checked.Panic?
    ensures raw.Produced? == Validate(TypeOf(s),value).Parsed?
    ensures raw.Produced? ==> raw.value == value
    ensures raw.Aborted? ==> checked.Invalid? && raw.error.payload == W.InvalidValueSelector()+Word(checked.offset)
  {
    checked := V.CachedValidate(t,value,s,dynamic,words);
    var routed := C.Route(checked,C.Context(C.ValueKind,0,0,0,0));
    W.ValidationError(checked,value);
    raw := W.Receipt(routed,value);
  }
  ghost method TupleReceipt(t: seq<Byte>, values: seq<seq<Byte>>)
    returns (receipt: A.Receipt, raw: E.Raw)
    requires Uint(|t|) && Uint(|values|) && Uint(TotalBytes(values))
    requires forall i :: 0 <= i < |values| ==> Uint(|values[i]|)
    ensures A.CodecPost(t,values,receipt)
    ensures raw.Produced? == receipt.result.Success?
    ensures raw.Aborted? ==> raw.error.payload == W.Selector(receipt.result)+W.Words(W.Fields(receipt.result))
    ensures raw.Produced? && A.EmptyArguments(t,values) ==> raw.value == []
    ensures raw.Produced? && !A.EmptyArguments(t,values) ==>
              raw.value == Encode(TypeOf(Group(receipt.fields)),Items(Decoded(receipt.fields,values)))
  {
    var data;
    data,receipt := Source.Tuple(t,values);
    raw := W.Receipt(receipt.result,data);
  }
}

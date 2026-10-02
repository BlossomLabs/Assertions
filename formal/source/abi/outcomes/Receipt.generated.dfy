// SPDX-License-Identifier: MIT
include "../../expressions/codec-errors/Encoding.dfy"
include "Cached.generated.dfy"
module AbiExactOutcomeReceipt {
  import Exact = AbiExactOutcomeSpec
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import opened AbiDynamicSemantics
  import opened AbiConstructionModel
  import V = AbiExactOutcomeCached
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
    ensures checked == Exact.Validate(s,value)
    ensures raw == W.Receipt(C.Route(Exact.Validate(s,value),C.Context(C.ValueKind,0,0,0,0)),value)
    ensures raw.Produced? == Validate(TypeOf(s),value).Parsed?
    ensures raw.Produced? ==> raw.value == value
    ensures raw.Aborted? ==> checked.Invalid? && raw.error.payload == W.InvalidValueSelector()+Word(checked.offset)
  {
    checked := V.CachedValidate(t,value,s,dynamic,words);
    var routed := C.Route(checked,C.Context(C.ValueKind,0,0,0,0));
    W.ValidationError(checked,value);
    raw := W.Receipt(routed,value);
  }
}

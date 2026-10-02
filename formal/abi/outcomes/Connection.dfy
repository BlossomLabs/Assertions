// SPDX-License-Identifier: MIT
include "Receipt.generated.dfy"

module AbiExactOutcomeConnection {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiDynamicSemantics
  import Exact = AbiExactOutcomeSpec
  import Source = AbiExactOutcomeReceipt
  import C = AbiConstructionContext
  import W = ExpressionCodecErrorEncoding
  import E = ExpressionEvaluationControl

  ghost function Receipt(s: Descriptor, value: seq<Byte>): E.Raw
    requires Good(s)
  { W.Receipt(C.Route(Exact.Validate(s,value),C.Context(C.ValueKind,0,0,0,0)),value) }

  // All calls on the same descriptor and bytes return the same exact payload;
  // no execution history or independently chosen rejection witness is involved.
  ghost method Deterministic(s: Descriptor, value: seq<Byte>)
    returns (first: E.Raw, second: E.Raw)
    requires Admissible(s) && Uint(|Render(s)|) && Uint(|value|)
    requires CursorRoom(s,|value|)
    ensures first == second == Receipt(s,value)
    ensures Exact.Validate(s,value).Invalid? ==> first ==
                                                 E.Aborted(E.Error(W.InvalidValueSelector()+Word(Exact.Validate(s,value).offset)))
  {
    var a; var b;
    a,first := Source.ValidateReceipt(Render(s),value,s,Dyn(s),Width(s));
    b,second := Source.ValidateReceipt(Render(s),value,s,Dyn(s),Width(s));
    W.ValidationError(a,value);
  }
}

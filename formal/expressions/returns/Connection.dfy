// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module ExpressionReturnConnection {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import M = ExpressionReturnMemory
  import Source = ExpressionReturnSource

  ghost method CanonicalReturn(t: AbiType, value: seq<Byte>, memory: seq<Byte>, pointer: nat)
    returns (direct: seq<Byte>, encoded: seq<Byte>)
    requires WellFormed(t) && Validate(t,value).Parsed? && M.Object(memory,pointer,value)
    ensures direct == value && encoded == value
    ensures WellTyped(t,Validate(t,value).value)
    ensures direct == Encode(t,Validate(t,value).value) && encoded == Encode(t,Validate(t,value).value)
  {
    direct := Source.EvaluateReturn(memory,pointer,value);
    encoded := Source.EncodedReturn(memory,pointer,value);
    ValidationSound(t,value);
  }
}

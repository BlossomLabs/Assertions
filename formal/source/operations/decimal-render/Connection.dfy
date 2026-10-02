include "Control.generated.dfy"
module OperationsDecimalRenderConnection {
  import M = OperationsDecimalRenderModel
  import S = OperationsDecimalRenderSource
  import Signed = OperationsModularMath
  method Unsigned(value: nat) returns (out: seq<bv8>)
    requires value < M.Word
    ensures out == M.Decimal(value)
    ensures M.Value(out) == value
    ensures value > 0 ==> 49 <= (out[0] as int) <= 57
  { out := S.Unsigned(value); M.DecimalValue(value); }
  method SignedValue(value: int) returns (out: seq<bv8>)
    requires -Signed.Half <= value < Signed.Half
    ensures out == M.SignedDecimal(value)
  { out := S.SignedValue(value); }
}

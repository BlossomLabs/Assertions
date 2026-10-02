include "Control.generated.dfy"
module OperationsParseUnitsConnection {
  import M = OperationsParseUnitsModel
  import Source = OperationsParseUnitsSource
  import Signed = OperationsModularMath
  method Unsigned(value: seq<bv8>,decimals: int,rounding: int) returns (out: M.Outcome)
    requires |value| < Signed.Word && 0 <= decimals < Signed.Word && 0 <= rounding <= 2
    ensures out == M.Parse(value,decimals,rounding,false)
  { out := Source.Unsigned(value,decimals,rounding); }
  method SignedValue(value: seq<bv8>,decimals: int,rounding: int) returns (out: M.Outcome)
    requires |value| < Signed.Word && 0 <= decimals < Signed.Word && 0 <= rounding <= 2
    ensures out == M.Restore(M.Parse(value,decimals,rounding,true))
  { out := Source.SignedValue(value,decimals,rounding); }
}

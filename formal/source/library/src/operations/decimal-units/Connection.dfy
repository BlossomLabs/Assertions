include "Control.generated.dfy"
module OperationsDecimalUnitsConnection {
  import M = OperationsDecimalUnitsModel
  import S = OperationsDecimalUnitsSource
  import Signed = OperationsModularMath
  method Unsigned(value: nat,decimals: nat) returns (out: M.Outcome)
    requires value < Signed.Word && decimals < Signed.Word
    ensures out == M.Units(value,decimals)
  { out := S.Unsigned(value,decimals); }
  method SignedValue(value: int,decimals: nat) returns (out: M.Outcome)
    requires -Signed.Half <= value < Signed.Half && decimals < Signed.Word
    ensures out == M.SignedUnits(value,decimals)
  { out := S.SignedValue(value,decimals); }
}

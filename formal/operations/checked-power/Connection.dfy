include "Control.generated.dfy"
module OperationsCheckedPowerConnection {
  import M = OperationsCheckedPowerModel
  import S = OperationsCheckedPowerSource
  method Unsigned(a: nat,b: nat) returns (out: M.Outcome)
    requires a < M.Word && b < M.Word
    ensures out == M.Unsigned(a,b)
    ensures out.Value? ==> 0 <= out.result < M.Word && out.result == M.Power(a,b)
  { out := S.Unsigned(a,b); M.PowerNonnegative(a,b); }
  method Signed(a: int,b: nat) returns (out: M.Outcome)
    requires M.Signed(a) && b < M.Word
    ensures out == M.SignedSpec(a,b)
    ensures out.Value? ==> M.Signed(out.result) && out.result == M.Power(a,b)
  { out := S.Signed(a,b); }
}

include "Control.generated.dfy"
module OperationsScaledPowerConnection {
  import B = OperationsBinaryLogModel
  import M = OperationsFullMulDivModel
  import R = OperationsScaledPowerModel
  import S = OperationsScaledPowerSource
  method Connection(x: nat,n: nat,base: nat) returns (out: M.Outcome)
    requires x < B.Word && n < B.Word && base < B.Word
    ensures out == R.Spec(x,n,base)
    ensures out.Value? ==> 0 <= out.result < B.Word
    ensures out.Panic? ==> out.code == (if base == 0 then 18 else 17)
  {
    if base > 0 && x > 0 { R.TraceRange(x,n,base,base); }
    out := S.Run(x,n,base);
  }
}

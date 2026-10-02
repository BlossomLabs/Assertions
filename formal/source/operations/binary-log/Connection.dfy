include "Control.generated.dfy"
module OperationsBinaryLogConnection {
  import M = OperationsBinaryLogModel
  import S = OperationsBinaryLogSource
  method Log(x: nat) returns (out: M.Outcome)
    requires x < M.Word
    ensures out == M.Spec(x)
    ensures out.Value? ==> out.result < 256 && M.Power(out.result) <= x < M.Power(out.result+1)
  {
    out := S.Public(x);
    if x > 0 { M.Floor(x); }
  }
}

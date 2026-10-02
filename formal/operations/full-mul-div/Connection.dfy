include "Control.generated.dfy"
module OperationsFullMulDivConnection {
  import B = OperationsBinaryLogModel
  import M = OperationsFullMulDivModel
  import S = OperationsFullMulDivSource
  method UnsignedConnection(a: nat,b: nat,d: nat,rounding: nat) returns (out: M.Outcome)
    requires a < B.Word && b < B.Word && d < B.Word && rounding <= 2
    ensures out == M.UnsignedSpec(a,b,d,rounding)
    ensures out.Value? ==> 0 <= out.result < B.Word
  { out := S.Unsigned(a,b,d,rounding); }
  method SignedConnection(a: int,b: int,d: int,rounding: nat) returns (out: M.Outcome)
    requires M.Signed(a) && M.Signed(b) && M.Signed(d) && rounding <= 2
    ensures out == M.SignedSpec(a,b,d,rounding)
    ensures out.Value? ==> M.Signed(out.result)
  { out := S.Signed(a,b,d,rounding); }
}

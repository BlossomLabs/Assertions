include "Control.generated.dfy"
module OperationsFixedPointConnection {
  import M = OperationsFixedPointModel
  import S = OperationsFixedPointSource
  method Exp(entry: int) returns (out: M.Outcome)
    requires M.Signed(entry)
    ensures out == M.Exp(entry)
    ensures out.Value? ==> M.Signed(out.result)
    ensures out.Panic? ==> entry >= M.ExpUpper && out.code == 17
  { out := S.Exp(entry); }
  method Ln(entry: int) returns (out: M.Outcome)
    requires M.Signed(entry)
    ensures out == M.Ln(entry)
    ensures out.Value? ==> M.Signed(out.result)
    ensures out.Undefined? ==> entry <= 0 && out.argument == entry
    ensures !out.Panic?
  { out := S.Ln(entry); }
}

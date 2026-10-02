include "Control.generated.dfy"
module OperationsDecimalDigitsConnection {
  import M = OperationsDecimalDigitsModel
  import S = OperationsDecimalDigitsSource
  method Unsigned(s: seq<bv8>) returns (out: M.Outcome)
    requires |s| < M.Mod
    ensures out == M.Parse(s,0)
  { out := S.ParseUint(s); }
  method Signed(s: seq<bv8>) returns (out: M.Outcome)
    requires |s| < M.Mod
    ensures out == M.SignedSpec(s)
  { out := S.ParseInt(s); }
}

include "Model.dfy"
module OperationsDecimalDigitsSource {
  import M = OperationsDecimalDigitsModel
  import Signed = OperationsModularMath
  method Digits(s: seq<bv8>,start: int) returns (out: M.Outcome)
    requires 0 <= start <= |s| && |s| < M.Mod
    ensures out == M.Parse(s,start)
  {
    if (start == |s|) { out := M.Empty; return; }
    var result := 0;
    var i := start;
    while (i < |s|)
      invariant start <= i <= |s|
      invariant 0 <= result < M.Mod
      invariant M.Parse(s,start) == M.Scan(s,i,result)
      decreases |s|-i
    {
      var c := s[i];
      if ((c < 48) || (c > 57)) { out := M.Invalid(i,c); return; }
      var product := (result * 10);
      if product < 0 || product >= M.Mod { out := M.Panic(17); return; }
      var next := ((result * 10) + ((c as int) - 48));
      if next < 0 || next >= M.Mod { out := M.Panic(17); return; }
      assert M.Scan(s,i,result) == M.Scan(s,i+1,next);
      result := next;
      i := i+1;
    }
    out := M.Ok(result);
  }
  method ParseUint(s: seq<bv8>) returns (out: M.Outcome)
    requires |s| < M.Mod
    ensures out == M.Parse(s,0)
  { out := Digits(s,0); }
  method ParseInt(value: seq<bv8>) returns (out: M.Outcome)
    requires |value| < M.Mod
    ensures out == M.SignedSpec(value)
  {
    if (|value| == 0) { out := M.Empty; return; }
    var negative := (value[0] == 45);
    var start := (if (negative || (value[0] == 43)) then 1 else 0);
    out := Digits(value,start);
    if out.Ok? {
      var r := Signed.SignedMagnitudeImpl(out.value,negative);
      M.RestoreCorrect(out.value,negative);
      out := M.Convert(r);
    }
  }
}

include "Model.dfy"
module OperationsAsciiSource {
  import M = OperationsAsciiModel
  method Fold(s: seq<bv8>,low: bv8,high: bv8) returns (out: seq<bv8>)
    requires |s| < M.Mod
    ensures out == M.Fold(s,low,high)
  {
    out := s;
    var i := 0;
    while (i < |out|)
      invariant 0 <= i <= |s|
      invariant |out| == |s|
      invariant forall j | 0 <= j < i :: out[j] == M.Fold(s,low,high)[j]
      invariant forall j | i <= j < |s| :: out[j] == s[j]
      decreases |s|-i
    {
      var c := out[i];
      if ((c >= low) && (c <= high)) { out := out[i := (c ^ 32)]; }
      assert out[i] == M.Fold(s,low,high)[i];
      i := i+1;
    }
    assert out == M.Fold(s,low,high);
  }
  method ToLower(s: seq<bv8>) returns (out: seq<bv8>)
    requires |s| < M.Mod
    ensures out == M.Lower(s)
  { out := Fold(s,65,90); M.LowerFold(s); }
  method ToUpper(s: seq<bv8>) returns (out: seq<bv8>)
    requires |s| < M.Mod
    ensures out == M.Upper(s)
  { out := Fold(s,97,122); M.UpperFold(s); }
  method Charset(s: seq<bv8>,mask: bv256) returns (out: bool)
    requires |s| < M.Mod
    ensures out == M.Charset(s,mask)
  {
    var i := 0;
    while (i < |s|)
      invariant 0 <= i <= |s|
      invariant forall j | 0 <= j < i :: M.Allowed(s[j],mask)
      decreases |s|-i
    {
      if ((mask & ((1 as bv256) << (s[i] as bv256))) == 0) {
        assert !M.Allowed(s[i],mask);
        out := false; return;
      }
      i := i+1;
    }
    out := true;
  }
}

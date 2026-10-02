include "Model.dfy"
module OperationsAsciiSource {
  import M = OperationsAsciiModel
  method Fold(s: seq<bv8>,low: bv8,high: bv8) returns (out: seq<bv8>)
    requires |s| < M.Mod
    ensures out == M.Fold(s,low,high)
  {
    out := s;
    var i := 0;
    while $FOLD_LOOP$
      invariant 0 <= i <= |s|
      invariant |out| == |s|
      invariant forall j | 0 <= j < i :: out[j] == M.Fold(s,low,high)[j]
      invariant forall j | i <= j < |s| :: out[j] == s[j]
      decreases |s|-i
    {
      var c := out[i];
      if $LETTER$ { out := out[i := $TOGGLE$]; }
      assert out[i] == M.Fold(s,low,high)[i];
      i := i+1;
    }
    assert out == M.Fold(s,low,high);
  }
  method ToLower(s: seq<bv8>) returns (out: seq<bv8>)
    requires |s| < M.Mod
    ensures out == M.Lower(s)
  { out := Fold(s,$LOWER_LOW$,$LOWER_HIGH$); M.LowerFold(s); }
  method ToUpper(s: seq<bv8>) returns (out: seq<bv8>)
    requires |s| < M.Mod
    ensures out == M.Upper(s)
  { out := Fold(s,$UPPER_LOW$,$UPPER_HIGH$); M.UpperFold(s); }
  method Charset(s: seq<bv8>,mask: bv256) returns (out: bool)
    requires |s| < M.Mod
    ensures out == M.Charset(s,mask)
  {
    var i := 0;
    while $CHARSET_LOOP$
      invariant 0 <= i <= |s|
      invariant forall j | 0 <= j < i :: M.Allowed(s[j],mask)
      decreases |s|-i
    {
      if $CHARSET_BAD$ {
        assert !M.Allowed(s[i],mask);
        out := false; return;
      }
      i := i+1;
    }
    out := true;
  }
}

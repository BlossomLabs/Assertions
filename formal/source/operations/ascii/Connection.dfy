include "Control.generated.dfy"
module OperationsAsciiConnection {
  import M = OperationsAsciiModel
  import S = OperationsAsciiSource
  method Lower(s: seq<bv8>) returns (out: seq<bv8>)
    requires |s| < M.Mod
    ensures out == M.Lower(s)
    ensures |out| == |s|
    ensures forall i | 0 <= i < |s| && s[i] >= 128 :: out[i] == s[i]
  { out := S.ToLower(s); }
  method Upper(s: seq<bv8>) returns (out: seq<bv8>)
    requires |s| < M.Mod
    ensures out == M.Upper(s)
    ensures |out| == |s|
    ensures forall i | 0 <= i < |s| && s[i] >= 128 :: out[i] == s[i]
  { out := S.ToUpper(s); }
  method Charset(s: seq<bv8>,mask: bv256) returns (out: bool)
    requires |s| < M.Mod
    ensures out == (forall i | 0 <= i < |s| :: M.Allowed(s[i],mask))
  { out := S.Charset(s,mask); }
}

module OperationsAsciiModel {
  const Mod: int := 0x10000000000000000000000000000000000000000000000000000000000000000
  function Fold(s: seq<bv8>,low: bv8,high: bv8): seq<bv8> {
    seq(|s|,i requires 0 <= i < |s| => if low <= s[i] <= high then s[i] ^ 32 else s[i])
  }
  function Lower(s: seq<bv8>): seq<bv8> {
    seq(|s|,i requires 0 <= i < |s| => if 65 <= s[i] <= 90 then s[i]+32 else s[i])
  }
  function Upper(s: seq<bv8>): seq<bv8> {
    seq(|s|,i requires 0 <= i < |s| => if 97 <= s[i] <= 122 then s[i]-32 else s[i])
  }
  predicate Allowed(c: bv8,mask: bv256) { (mask & ((1 as bv256) << (c as bv256))) != 0 }
  predicate Charset(s: seq<bv8>,mask: bv256) { forall i | 0 <= i < |s| :: Allowed(s[i],mask) }
  lemma LowerByte(c: bv8)
    ensures (if 65 <= c <= 90 then c ^ 32 else c) == (if 65 <= c <= 90 then c+32 else c)
  { }
  lemma UpperByte(c: bv8)
    ensures (if 97 <= c <= 122 then c ^ 32 else c) == (if 97 <= c <= 122 then c-32 else c)
  { }
  lemma LowerFold(s: seq<bv8>)
    ensures Fold(s,65,90) == Lower(s)
  { forall i | 0 <= i < |s| { LowerByte(s[i]); } }
  lemma UpperFold(s: seq<bv8>)
    ensures Fold(s,97,122) == Upper(s)
  { forall i | 0 <= i < |s| { UpperByte(s[i]); } }
}

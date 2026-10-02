// SPDX-License-Identifier: MIT
// Generated from the complete suffixes AST skeleton. Do not edit.
// Source SHA256: 485f0d49f35528cc4c9be7767c631be6903ff57b5cb95bcbb25d6cd04ce5fed6
include "Semantics.dfy"

module AbiSuffixSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiSuffixSemantics

  ghost method Digit(k: nat, c: Byte) returns (next: nat)
    requires k < 0x100000000 && 48 <= c <= 57
    ensures next == 10*k+c-48
  {
    DecimalMachineStep(k,c);
    next := ((((((k * 10) % Limit()) + c) % Limit()) - 48) % Limit());
    // A reachable nonzero prefix also gives a direct fault-sensitivity witness.
    if k == 1 && c == 48 { assert next == 10; }
  }

  ghost method ReadSuffix(t: seq<Byte>, start: nat, ds: seq<Byte>)
    returns (end: nat, k: nat)
    requires Uint(|t|) && Digits(ds) && Decimal(ds) < 0x100000000
    requires start+2+|ds| <= |t|
    requires t[start+1..start+1+|ds|] == ds && t[start+1+|ds|] == 93
    ensures end == start+2+|ds| && k == Decimal(ds)
  {
    end := start;
    k := 0;
    var i: nat := 0;
    while true
      invariant 0 <= i <= |ds| && end == start+i
      invariant k == Decimal(ds[..i])
      decreases |ds|-i
    {
      NoWrap(end+1);
      end := (end+1)%Limit();
      assert end == start+i+1;
      if t[end] == 93 {
        if i < |ds| { assert t[end] == ds[i]; }
        assert i == |ds| && ds[..i] == ds;
        break;
      }
      assert i < |ds| && t[end] == ds[i];
      DecimalStep(ds,i);
      DecimalPrefix(ds,i);
      k := Digit(k,t[end]);
      i := i+1;
    }
    NoWrap(end+1);
    end := (end+1)%Limit();
  }

  ghost method {:isolate_assertions} Suffixes(t: seq<Byte>, start: nat, limit: nat, ss: seq<seq<Byte>>)
    returns (end: nat, product: nat)
    requires Uint(|t|) && At(t,start,limit,ss)
    requires SuffixList(ss) && Product(ss) < 0x100000000
    ensures end == start+|Text(ss)| && product == Product(ss)
    ensures end <= limit && 0 < product < 0x100000000
  {
    assert Limit() > 0x100000000;
    end := start;
    product := 1;
    var remaining := ss;
    while end < limit && t[end] == 91
      invariant At(t,end,limit,remaining) && SuffixList(remaining)
      invariant end+|Text(remaining)| == start+|Text(ss)|
      invariant 0 < product && product*Product(remaining) == Product(ss)
      decreases |remaining|
    {
      assert |remaining| > 0;
      SuffixStep(t,end,limit,remaining);
      var opening := end;
      var ds := remaining[0];
      var k: nat;
      end, k := ReadSuffix(t,end,ds);
      assert Product(remaining) == k*Product(remaining[1..]);
      ExtendProduct(product,k,Product(remaining[1..]),Product(ss));
      var nextProduct := product*k;
      NoWrap(product*k);
      product := ((product * k) % Limit());
      assert product == nextProduct;
      assert product*Product(remaining[1..]) == Product(ss);
      remaining := remaining[1..];
    }
    assert |remaining| == 0;
  }
}

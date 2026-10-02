// SPDX-License-Identifier: MIT
// Generated from pinned solc AST by words/generate.py. Do not edit.
// Source SHA256: 485f0d49f35528cc4c9be7767c631be6903ff57b5cb95bcbb25d6cd04ce5fed6
// Loop skeletons checked exactly; predicates normalized by retained SMT proofs.
include "Semantics.dfy"

module AbiWordSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiWordSemantics

  ghost method ScanName(t: seq<Byte>, p: nat, limit: nat) returns (q: nat)
    requires p <= limit <= |t| && Uint(|t|)
    ensures q == NameEnd(t,p,limit)
    ensures p <= q <= limit
  {
    q := p;
    while q < limit
      invariant p <= q <= limit
      invariant NameEnd(t,p,limit) == NameEnd(t,q,limit)
      decreases limit-q
    {
      var c := t[q];
      if !NameByte(c) { break; }
      assert Uint(q+1);
      q := q+1;
    }
  }

  ghost method CheckRule(rule: WordRule, v: seq<Byte>, p: nat, n: nat) returns (r: Outcome)
    requires ClassifiedRule(rule) && !rule.Opaque?
    requires p+32*n <= |v| && Uint(|v|)
    ensures r == (if FirstBad(rule,v,p,n,0) == n then Ok(0) else Invalid(p+32*FirstBad(rule,v,p,n,0)))
  {
    var bad := n;
    var i: nat := 0;
    while i < n
      invariant 0 <= i <= n && bad == n
      invariant FirstBad(rule,v,p,n,0) == FirstBad(rule,v,p,n,i)
      decreases n-i
    {
      assert Uint(p+32*i) && Uint(32*i);
      var x := ReadNat(v[p+32*i..p+32*i+32]);
      BytesNatRoundTrip(v[p+32*i..p+32*i+32]);
      var ok := CanonicalWord(rule,x);
      if !ok { bad := i; break; }
      assert Uint(i+1);
      i := i+1;
    }
    assert bad == FirstBad(rule,v,p,n,0);
    assert Uint(p+bad*32);
    if bad != n { r := Invalid(p+bad*32); return; }
    r := Ok(0);
  }
}

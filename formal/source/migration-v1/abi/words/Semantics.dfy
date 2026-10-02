// SPDX-License-Identifier: MIT
include "../source/Correspondence.dfy"

module AbiWordSemantics {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics

  predicate NameByte(c: Byte) { 48 <= c <= 57 || 97 <= c <= 122 }

  function NameEnd(t: seq<Byte>, p: nat, limit: nat): nat
    requires p <= limit <= |t|
    ensures p <= NameEnd(t,p,limit) <= limit
    decreases limit-p
  {
    if p == limit || !NameByte(t[p]) then p else NameEnd(t,p+1,limit)
  }

  lemma NamePrefix(t: seq<Byte>, p: nat, limit: nat)
    requires p <= limit <= |t|
    ensures forall i :: p <= i < NameEnd(t,p,limit) ==> NameByte(t[i])
    ensures NameEnd(t,p,limit) < limit ==> !NameByte(t[NameEnd(t,p,limit)])
    decreases limit-p
  {
    if p < limit && NameByte(t[p]) { NamePrefix(t,p+1,limit); }
  }

  function FirstBad(rule: WordRule, v: seq<Byte>, p: nat, n: nat, i: nat): nat
    requires ValidRule(rule) && p+32*n <= |v| && i <= n
    ensures i <= FirstBad(rule,v,p,n,i) <= n
    decreases n-i
  {
    if i == n || !CanonicalWord(rule,ReadNat(v[p+32*i..p+32*i+32])) then i
    else FirstBad(rule,v,p,n,i+1)
  }

  lemma FirstBadMeaning(rule: WordRule, v: seq<Byte>, p: nat, n: nat, i: nat)
    requires ValidRule(rule) && p+32*n <= |v| && i <= n
    ensures forall j :: i <= j < FirstBad(rule,v,p,n,i) ==> CanonicalWord(rule,ReadNat(v[p+32*j..p+32*j+32]))
    ensures FirstBad(rule,v,p,n,i) < n ==> !CanonicalWord(rule,ReadNat(v[p+32*FirstBad(rule,v,p,n,i)..p+32*FirstBad(rule,v,p,n,i)+32]))
    ensures FirstBad(rule,v,p,n,i) == n <==> forall j :: i <= j < n ==> CanonicalWord(rule,ReadNat(v[p+32*j..p+32*j+32]))
    decreases n-i
  {
    if i < n && CanonicalWord(rule,ReadNat(v[p+32*i..p+32*i+32])) {
      FirstBadMeaning(rule,v,p,n,i+1);
    }
  }

  // The SMT classification maps full-width spellings to Opaque. This covers
  // exactly the rules returned by that classifier, not every syntactic model
  // constructor (Unsigned(256), Signed(256), HighBytes(32) are aliases).
  predicate ClassifiedRule(rule: WordRule) {
    ValidRule(rule) &&
    (rule.Unsigned? ==> rule.bits < 256) &&
    (rule.Signed? ==> rule.bits < 256) &&
    (rule.HighBytes? ==> rule.count < 32)
  }

  lemma OpaqueWords(v: seq<Byte>, p: nat, n: nat)
    requires p+32*n <= |v|
    ensures FirstBad(Opaque,v,p,n,0) == n
  {
    forall i | 0 <= i < n
      ensures CanonicalWord(Opaque,ReadNat(v[p+32*i..p+32*i+32]))
    {
      BytesNatRoundTrip(v[p+32*i..p+32*i+32]);
    }
    FirstBadMeaning(Opaque,v,p,n,0);
  }
}

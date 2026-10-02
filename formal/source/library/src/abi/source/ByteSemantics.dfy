// SPDX-License-Identifier: MIT
include "../Validation.dfy"

// Semantic boundary for the generated Solidity source slice. The input is a
// valid Solidity bytes-memory object, represented by its contents. Gas,
// allocation and compiler/bytecode equivalence are outside this source proof.
module AbiByteSemantics {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation

  function Limit(): nat { Pow256(32) }
  predicate Uint(x: int) { 0 <= x < Limit() }
  datatype Outcome = Ok(used: nat) | Invalid(offset: nat) | Panic(code: nat)
  function WordSpec(v: seq<Byte>, p: nat): Outcome
  {
    if p > |v| || |v|-p < 32 then Invalid(p)
    else Ok(ReadNat(v[p..p+32]))
  }

  function FirstDirty(v: seq<Byte>, start: nat, end: nat): nat
    requires start <= end <= |v|
    ensures start <= FirstDirty(v,start,end) <= end
    decreases end-start
  {
    if start == end || v[start] != 0 then start
    else FirstDirty(v,start+1,end)
  }

  function BodySpec(v: seq<Byte>, p: nat): Outcome
  {
    if p > |v| || |v|-p < 32 then Invalid(p) else
    var n := ReadNat(v[p..p+32]);
    var end := p+32+n+Padding(n);
    if end > |v| then Invalid(p) else
    var bad := FirstDirty(v,p+32+n,end);
    if bad < end then Invalid(bad) else Ok(end-p)
  }

  function ValidationSpec(v: seq<Byte>): Outcome
  {
    if |v| < 32 || ReadNat(v[..32]) != 32 then Invalid(0) else
    var r := BodySpec(v,32);
    if !r.Ok? then r else
    if r.used != |v|-32 then Invalid(32+r.used) else Ok(0)
  }

  lemma RoundedExtent(n: nat)
    ensures (n+31)/32*32 == n+Padding(n)
    ensures n <= (n+31)/32*32 <= n+31
    ensures 0 <= (n+31)/32*32-n < 32
  {
    assert n == n/32*32+n%32;
    if n%32 == 0 {
      assert (n+31)/32 == n/32;
    } else { assert (n+31)/32 == n/32+1; }
  }

  lemma ReadAppend(a: seq<Byte>, b: seq<Byte>)
    ensures ReadNat(a+b) == ReadNat(a)*Pow256(|b|)+ReadNat(b)
    decreases |b|
  {
    if |b| > 0 {
      var init := b[..|b|-1];
      assert (a+b)[..|a+b|-1] == a+init;
      assert (a+b)[|a+b|-1] == b[|b|-1];
      ReadAppend(a,init);
    } else { assert b == []; assert a+b == a; }
  }

  lemma ModuloOfDecomposition(q: nat, d: nat, r: nat)
    requires d > 0 && r < d
    ensures (q*d+r)%d == r
  {
    var x := q*d+r;
    var quotient := x/d;
    var remainder := x%d;
    assert x == quotient*d+remainder;
    assert 0 <= remainder < d;
    if quotient < q {
      assert quotient+1 <= q;
      assert (quotient+1)*d <= q*d;
      assert x < (quotient+1)*d;
    } else if quotient > q {
      assert q+1 <= quotient;
      assert (q+1)*d <= quotient*d;
      assert x < (q+1)*d;
    }
    assert quotient == q;
  }

  lemma LowSuffix(v: seq<Byte>, n: nat)
    requires n <= |v|
    ensures ReadNat(v)%Pow256(n) == ReadNat(v[|v|-n..])
  {
    var a := v[..|v|-n];
    var b := v[|v|-n..];
    assert v == a+b;
    ReadAppend(a,b);
    BytesNatRoundTrip(b);
    assert |b| == n;
    var d := Pow256(n);
    assert ReadNat(v) == ReadNat(a)*d+ReadNat(b);
    ModuloOfDecomposition(ReadNat(a),d,ReadNat(b));
  }

  lemma ZeroRead(v: seq<Byte>)
    ensures ReadNat(v) == 0 <==> forall i :: 0 <= i < |v| ==> v[i] == 0
    decreases |v|
  {
    if |v| > 0 {
      var init := v[..|v|-1];
      ZeroRead(init);
      assert ReadNat(v) == ReadNat(init)*256+v[|v|-1];
    }
  }

  // After the separately checked 256-bit mask normalization, the loaded
  // word's low padding bytes are exactly the payload's trailing padding.
  lemma PaddingMask(v: seq<Byte>, p: nat, n: nat, padded: nat)
    requires p+32+padded <= |v| && padded == n+Padding(n)
    ensures ReadNat(v[p+padded..p+padded+32])%Pow256(padded-n) == 0
       <==> ZeroRegion(v,p+32+n,p+32+padded)
  {
    var block := v[p+padded..p+padded+32];
    var count := padded-n;
    LowSuffix(block,count);
    var suffix := block[32-count..];
    assert suffix == v[p+32+n..p+32+padded];
    ZeroRead(suffix);
    assert (forall i :: 0 <= i < |suffix| ==> suffix[i] == 0)
      <==> ZeroRegion(v,p+32+n,p+32+padded);
  }

  lemma FirstDirtyCharacterization(v: seq<Byte>, start: nat, end: nat)
    requires start <= end <= |v|
    ensures ZeroRegion(v,start,FirstDirty(v,start,end))
    ensures FirstDirty(v,start,end) < end ==> v[FirstDirty(v,start,end)] != 0
    ensures FirstDirty(v,start,end) == end <==> ZeroRegion(v,start,end)
    decreases end-start
  {
    if start < end && v[start] == 0 {
      FirstDirtyCharacterization(v,start+1,end);
    }
  }

  lemma FirstDirtyAt(v: seq<Byte>, start: nat, end: nat, i: nat)
    requires start <= i < end <= |v|
    requires ZeroRegion(v,start,i) && v[i] != 0
    ensures FirstDirty(v,start,end) == i
    decreases i-start
  {
    if start < i { FirstDirtyAt(v,start+1,end,i); }
  }

  lemma BodySpecMatchesWalker(v: seq<Byte>, p: nat)
    ensures !BodySpec(v,p).Panic?
    ensures BodySpec(v,p).Ok? <==> p <= |v| && WalkBytes(v[p..]).Parsed?
    ensures BodySpec(v,p).Ok? ==> BodySpec(v,p).used == WalkBytes(v[p..]).used
  {
    if p <= |v| && |v|-p >= 32 {
      var n := ReadNat(v[p..p+32]);
      assert v[p..][..32] == v[p..p+32];
      var end := p+32+n+Padding(n);
      if end <= |v| {
        FirstDirtyCharacterization(v,p+32+n,end);
        assert ZeroRegion(v,p+32+n,end) <==> ZeroRegion(v[p..],32+n,end-p);
      }
    }
  }

  lemma ValidationSpecMatchesModel(v: seq<Byte>)
    ensures !ValidationSpec(v).Panic?
    ensures ValidationSpec(v).Ok? <==> Validate(Bytes,v).Parsed?
    ensures ValidationSpec(v).Ok? <==> Validate(String,v).Parsed?
  {
    if |v| >= 32 && ReadNat(v[..32]) == 32 {
      BodySpecMatchesWalker(v,32);
    }
  }
}

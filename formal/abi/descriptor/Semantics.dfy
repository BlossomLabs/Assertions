// SPDX-License-Identifier: MIT
include "../words/Refinement.dfy"

// Accepted static suffix syntax, independent of the source scanner. Establishing
// this predicate from typeShape remains a separate parser correspondence task.
module AbiSuffixSemantics {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics

  predicate Digits(ds: seq<Byte>) {
    |ds| > 0 && forall i :: 0 <= i < |ds| ==> 48 <= ds[i] <= 57
  }

  function Decimal(ds: seq<Byte>): nat
    requires forall i :: 0 <= i < |ds| ==> 48 <= ds[i] <= 57
    decreases |ds|
  {
    if |ds| == 0 then 0 else 10*Decimal(ds[..|ds|-1])+(ds[|ds|-1]-48)
  }

  predicate SuffixList(ss: seq<seq<Byte>>) {
    forall i :: 0 <= i < |ss| ==> Digits(ss[i]) && 0 < Decimal(ss[i]) < 0x100000000
  }

  function Text(ss: seq<seq<Byte>>): seq<Byte>
    decreases |ss|
  {
    if |ss| == 0 then [] else [91]+ss[0]+[93]+Text(ss[1..])
  }

  function Product(ss: seq<seq<Byte>>): nat
    requires SuffixList(ss)
    ensures Product(ss) > 0
    decreases |ss|
  {
    if |ss| == 0 then 1 else Decimal(ss[0])*Product(ss[1..])
  }

  predicate At(t: seq<Byte>, start: nat, limit: nat, ss: seq<seq<Byte>>) {
    start+|Text(ss)| <= limit <= |t| &&
    t[start..start+|Text(ss)|] == Text(ss) &&
    (start+|Text(ss)| == limit || t[start+|Text(ss)|] != 91)
  }

  lemma DecimalStep(ds: seq<Byte>, i: nat)
    requires Digits(ds) && i < |ds|
    ensures Decimal(ds[..i+1]) == 10*Decimal(ds[..i])+(ds[i]-48)
  {
    assert ds[..i+1][..i] == ds[..i];
  }

  lemma DecimalPrefix(ds: seq<Byte>, i: nat)
    requires Digits(ds) && i <= |ds|
    ensures Decimal(ds[..i]) <= Decimal(ds)
    decreases |ds|-i
  {
    if i < |ds| {
      DecimalStep(ds,i);
      DecimalPrefix(ds,i+1);
      assert Decimal(ds[..i]) <= 10*Decimal(ds[..i])+(ds[i]-48);
      assert Decimal(ds[..i]) <= Decimal(ds[..i+1]) <= Decimal(ds);
    } else { assert ds[..i] == ds; }
  }

  lemma SuffixStep(t: seq<Byte>, start: nat, limit: nat, ss: seq<seq<Byte>>)
    requires At(t,start,limit,ss) && |ss| > 0
    ensures start < limit && t[start] == 91
    ensures t[start+1..start+1+|ss[0]|] == ss[0]
    ensures t[start+1+|ss[0]|] == 93
    ensures At(t,start+2+|ss[0]|,limit,ss[1..])
  {
    assert Text(ss)[..|ss[0]|+2] == [91]+ss[0]+[93];
    assert Text(ss)[|ss[0]|+2..] == Text(ss[1..]);
    assert t[start..start+|Text(ss)|][1..1+|ss[0]|] == ss[0];
    forall i | 0 <= i < |ss[0]|
      ensures t[start+1..start+1+|ss[0]|][i] == ss[0][i]
    {
      assert t[start..start+|Text(ss)|][1+i] == ss[0][i];
      assert t[start+1..start+1+|ss[0]|][i] == t[start+1+i];
    }
    assert t[start+1..start+1+|ss[0]|] == ss[0];
    assert t[start..start+|Text(ss)|][|ss[0]|+2..] == Text(ss[1..]);
  }

  lemma MultiplyAtLeast(a: nat, b: nat)
    requires b >= 1
    ensures a*b >= a
  {
    assert a*(b-1) >= 0;
    assert a*b == a+a*(b-1);
  }

  lemma MultiplyMonotone(a: nat, b: nat, c: nat)
    requires b <= c
    ensures a*b <= a*c
  {
    assert a*(c-b) >= 0;
    assert a*c == a*b+a*(c-b);
  }

  lemma ExtendProduct(a: nat, b: nat, c: nat, total: nat)
    requires a > 0 && b > 0 && c > 0 && a*(b*c) == total
    ensures 0 < a*b <= total && (a*b)*c == total
  {
    assert a*(b*c) == (a*b)*c;
    MultiplyAtLeast(a*b,c);
  }

  lemma NoWrap(x: int)
    requires Uint(x)
    ensures x%Limit() == x
  {
    assert 0 <= x < Limit();
    ModuloOfDecomposition(0,Limit(),x);
  }

  lemma DecimalMachineStep(k: nat, c: Byte)
    requires k < 0x100000000 && 48 <= c <= 57
    ensures (((k*10)%Limit()+c)%Limit()-48)%Limit() == 10*k+c-48
  {
    assert Limit() > 0x100000000*10+256;
    NoWrap(k*10);
    NoWrap(k*10+c);
    NoWrap(k*10+c-48);
  }

  // Suffixes associate from left to right: T[2][3] has three T[2] values.
  ghost function Wrap(base: AbiType, ss: seq<seq<Byte>>): AbiType
    requires SuffixList(ss)
    decreases |ss|
  {
    if |ss| == 0 then base else Wrap(FixedArray(base,Decimal(ss[0])),ss[1..])
  }

  lemma WrapShape(base: AbiType, ss: seq<seq<Byte>>)
    requires WellFormed(base) && !IsDynamic(base) && SuffixList(ss)
    requires HeadWords(base)*Product(ss) < 0x100000000
    ensures WellFormed(Wrap(base,ss)) && !IsDynamic(Wrap(base,ss))
    ensures HeadWords(Wrap(base,ss)) == HeadWords(base)*Product(ss)
    decreases |ss|
  {
    assert Pow256(4) == 0x100000000;
    if |ss| > 0 {
      NonemptyHead(base);
      var child := FixedArray(base,Decimal(ss[0]));
      assert Product(ss[1..]) >= 1;
      assert Product(ss) == Decimal(ss[0])*Product(ss[1..]);
      MultiplyAtLeast(Decimal(ss[0]),Product(ss[1..]));
      MultiplyMonotone(HeadWords(base),Decimal(ss[0]),Product(ss));
      assert HeadWords(child)*Product(ss[1..]) == HeadWords(base)*Product(ss);
      WrapShape(child,ss[1..]);
    }
  }
}

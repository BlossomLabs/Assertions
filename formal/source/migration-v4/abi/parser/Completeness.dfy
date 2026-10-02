// SPDX-License-Identifier: MIT
include "Parser.generated.dfy"

module AbiParserCompleteness {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiShapeSemantics
  import opened AbiSuffixSemantics
  import opened AbiParserSpec
  import opened AbiParserSource

  predicate Boundary(t: seq<Byte>, e: nat, limit: nat)
  { e <= limit <= |t| && (e == limit || t[e] == 44 || t[e] == 41) }

  function Add(s: Descriptor, ds: seq<Byte>): Descriptor
  { if |ds| == 0 then Dynamic(s) else Fixed(s,ds) }

  function Build(s: Descriptor, ss: seq<seq<Byte>>): Descriptor
    decreases |ss|
  { if |ss| == 0 then s else Build(Add(s,ss[0]),ss[1..]) }

  predicate SuffixSafe(s: Descriptor, ss: seq<seq<Byte>>)
    decreases |ss|
  { Admissible(s) && (|ss| == 0 || SuffixSafe(Add(s,ss[0]),ss[1..])) }

  function Stem(s: Descriptor): Descriptor
    decreases s
  { if s.Fixed? || s.Dynamic? then Stem(s.element) else s }

  function SuffixesOf(s: Descriptor): seq<seq<Byte>>
    decreases s
  { if s.Fixed? then SuffixesOf(s.element)+[s.digits] else
    if s.Dynamic? then SuffixesOf(s.element)+[[]] else [] }

  lemma BuildAppend(s: Descriptor, ss: seq<seq<Byte>>, ds: seq<Byte>)
    ensures Build(s,ss+[ds]) == Add(Build(s,ss),ds)
    ensures Text(ss+[ds]) == Text(ss)+[91]+ds+[93]
    ensures SuffixSafe(s,ss) && Admissible(Add(Build(s,ss),ds)) ==> SuffixSafe(s,ss+[ds])
    decreases |ss|
  {
    if |ss| > 0 {
      assert (ss+[ds])[1..] == ss[1..]+[ds];
      BuildAppend(Add(s,ss[0]),ss[1..],ds);
    }
  }

  lemma Decompose(s: Descriptor)
    requires Admissible(s)
    ensures Stem(s).Name? || Stem(s).Group?
    ensures Stem(s) == s || Stem(s) < s
    ensures SuffixSafe(Stem(s),SuffixesOf(s))
    ensures Build(Stem(s),SuffixesOf(s)) == s
    ensures Render(s) == Render(Stem(s))+Text(SuffixesOf(s))
    decreases s
  {
    if s.Fixed? || s.Dynamic? {
      Decompose(s.element);
      var ds := if s.Fixed? then s.digits else [];
      if s.Fixed? { assert |ds| > 0; }
      BuildAppend(Stem(s.element),SuffixesOf(s.element),ds);
    }
  }

  lemma Subslice(t: seq<Byte>, p: nat, e: nat, a: nat, b: nat)
    requires p <= e <= |t| && a <= b <= e-p
    ensures t[p..e][a..b] == t[p+a..p+b]
  {
    assert forall i :: 0 <= i < b-a ==> t[p..e][a..b][i] == t[p+a..p+b][i];
  }

  lemma NameKnown(t: seq<Byte>, p: nat, e: nat, limit: nat)
    requires p <= e <= limit <= |t|
    requires forall i :: p <= i < e ==> NameByte(t[i])
    requires e == limit || !NameByte(t[e])
    ensures NameEnd(t,p,limit) == e
    decreases e-p
  { if p < e { NameKnown(t,p+1,e,limit); } }

  lemma DigitPrefix(ds: seq<Byte>, i: nat)
    requires i <= |ds| && (forall j :: 0 <= j < |ds| ==> 48 <= ds[j] <= 57)
    ensures Number(ds[..i]) <= Number(ds)
  {
    DecimalNumber(ds); DecimalNumber(ds[..i]);
    if |ds| > 0 { DecimalPrefix(ds,i); }
  }

  lemma DigitsKnown(t: seq<Byte>, q: nat, limit: nat, ds: seq<Byte>, i: nat)
    requires q+|ds| < limit <= |t| && i <= |ds|
    requires t[q..q+|ds|] == ds && t[q+|ds|] == 93
    requires (forall j :: 0 <= j < |ds| ==> 48 <= ds[j] <= 57) && Number(ds) < 0x100000000
    requires Number(ds[..i]) < 0x100000000
    ensures DigitsFrom(t,q+i,limit,Number(ds[..i])) == (q+|ds|,Number(ds))
    decreases |ds|-i
  {
    if i < |ds| {
      DigitPrefix(ds,i+1);
      NumberStep(ds[..i],ds[i]);
      assert ds[..i+1] == ds[..i]+[ds[i]];
      assert t[q+i] == ds[i];
      DigitsKnown(t,q,limit,ds,i+1);
      assert DigitsFrom(t,q+i,limit,Number(ds[..i])) == DigitsFrom(t,q+i+1,limit,Number(ds[..i+1]));
    } else {
      assert ds[..i] == ds && t[q+i] == 93;
      assert DigitsFrom(t,q+i,limit,Number(ds[..i])) == (q+i,Number(ds[..i]));
    }
  }

  lemma {:isolate_assertions} SuffixAccepts(t: seq<Byte>, q: nat, limit: nat, s: Descriptor, ss: seq<seq<Byte>>)
    requires SuffixSafe(s,ss)
    requires q+|Text(ss)| <= limit <= |t|
    requires t[q..q+|Text(ss)|] == Text(ss) && Boundary(t,q+|Text(ss)|,limit)
    ensures Suffix(t,q,limit,s,Dyn(s),Width(s)) ==
            Shaped(q+|Text(ss)|,Dyn(Build(s,ss)),Width(Build(s,ss)),Build(s,ss))
    decreases |ss|
  {
    if |ss| > 0 {
      var ds := ss[0];
      assert t[q] == 91 && t[q+1+|ds|] == 93;
      var encoded := t[q..q+|Text(ss)|];
      assert encoded[1..1+|ds|] == ds;
      Subslice(t,q,q+|Text(ss)|,1,1+|ds|);
      assert t[q+1..q+1+|ds|] == encoded[1..1+|ds|];
      if |ds| > 0 { assert Digits(ds) && 0 < Number(ds) < 0x100000000; }
      DigitsKnown(t,q+1,limit,ds,0);
      var next := Add(s,ds);
      Positive(s);
      assert Dyn(next) == (|ds| == 0 || Dyn(s));
      assert Width(next) == (if |ds| == 0 then 1 else if Dyn(s) then Width(s) else Width(s)*Number(ds));
      assert Width(next) < 0x100000000;
      var e := q+2+|ds|;
      assert encoded == [91]+ds+[93]+Text(ss[1..]);
      assert encoded[2+|ds|..] == Text(ss[1..]);
      Subslice(t,q,q+|Text(ss)|,2+|ds|,|Text(ss)|);
      assert t[e..q+|Text(ss)|] == Text(ss[1..]);
      SuffixAccepts(t,e,limit,next,ss[1..]);
    }
  }

  lemma WidthConcat(a: seq<Descriptor>, b: seq<Descriptor>)
    ensures WidthSum(a+b) == WidthSum(a)+WidthSum(b)
    decreases |a|
  {
    if |a| > 0 {
      assert (a+b)[0] == a[0];
      assert (a+b)[1..] == a[1..]+b;
      WidthConcat(a[1..],b);
    } else { assert a == [] && a+b == b; }
  }

  lemma {:isolate_assertions} Accept(t: seq<Byte>, p: nat, limit: nat, s: Descriptor)
    requires Uint(|t|) && Admissible(s)
    requires p+|Render(s)| <= limit <= |t| && t[p..p+|Render(s)|] == Render(s)
    requires Boundary(t,p+|Render(s)|,limit)
    ensures Parse(t,p,limit) == Shaped(p+|Render(s)|,Dyn(s),Width(s),s)
    decreases s, 1
  {
    Positive(s); Decompose(s);
    var base := Stem(s);
    var ss := SuffixesOf(s);
    assert Admissible(base);
    Positive(base);
    var e := p+|Render(base)|;
    var encoded := t[p..p+|Render(s)|];
    Subslice(t,p,p+|Render(s)|,0,|Render(base)|);
    Subslice(t,p,p+|Render(s)|,|Render(base)|,|Render(s)|);
    assert encoded[..|Render(base)|] == Render(base);
    assert t[p..e] == encoded[..|Render(base)|];
    assert t[e..p+|Render(s)|] == Text(ss);
    if base.Name? {
      assert t[p] == base.text[0] && t[p] != 40;
      assert forall i :: p <= i < e ==> NameByte(t[i]);
      if |ss| > 0 {
        assert Text(ss) == [91]+ss[0]+[93]+Text(ss[1..]);
        assert (t[e..p+|Render(s)|])[0] == 91;
        assert t[e] == (t[e..p+|Render(s)|])[0];
      }
      NameKnown(t,p,e,limit);
      assert Width(base) == 1;
    } else {
      assert base.Group?;
      assert Render(base) == [40]+FieldsText(base.fields)+[41];
      assert (t[p..e])[0] == 40;
      assert t[p] == (t[p..e])[0];
      assert t[p] == 40;
      Subslice(t,p,e,1,|Render(base)|);
      assert t[p+1..e] == FieldsText(base.fields)+[41];
      assert forall i :: 0 <= i < |base.fields| ==> Admissible(base.fields[i]);
      assert Uint(WidthSum(base.fields));
      var prefix: seq<Descriptor> := [];
      assert prefix+base.fields == base.fields;
      assert WidthSum(prefix) == 0 && !Dyn(Group(prefix));
      FieldsAccept(t,p+1,limit,prefix,base.fields);
      assert Fields(t,p+1,limit,[],0,false) == Shaped(e,Dyn(base),Width(base),base);
    }
    assert Parse(t,p,limit) == Suffix(t,e,limit,base,Dyn(base),Width(base));
    SuffixAccepts(t,e,limit,base,ss);
  }

  lemma Delimiter(a: seq<Byte>, rest: seq<Byte>, last: bool)
    ensures (a+(if last then [] else [44]+rest)+[41])[|a|] == (if last then 41 else 44)
  { if last { assert a+[]+[41] == a+[41]; } }

  lemma {:isolate_assertions} FieldsAccept(t: seq<Byte>, q: nat, limit: nat, prefix: seq<Descriptor>, remaining: seq<Descriptor>)
    requires Uint(|t|) && |remaining| > 0
    requires forall i :: 0 <= i < |remaining| ==> Admissible(remaining[i])
    requires Uint(WidthSum(prefix)) && Uint(WidthSum(prefix+remaining))
    requires q+|FieldsText(remaining)| < limit <= |t|
    requires t[q..q+|FieldsText(remaining)|+1] == FieldsText(remaining)+[41]
    ensures Fields(t,q,limit,prefix,WidthSum(prefix),Dyn(Group(prefix))) ==
            Shaped(q+|FieldsText(remaining)|+1,Dyn(Group(prefix+remaining)),Width(Group(prefix+remaining)),Group(prefix+remaining))
    decreases remaining, 0
  {
    WidthConcat(prefix,remaining);
    var first := remaining[0];
    Positive(first);
    var e := q+|Render(first)|;
    var encoded := t[q..q+|FieldsText(remaining)|+1];
    Subslice(t,q,q+|FieldsText(remaining)|+1,0,|Render(first)|);
    assert encoded[..|Render(first)|] == Render(first);
    assert t[q..e] == encoded[..|Render(first)|];
    assert FieldsText(remaining) == Render(first)+(if |remaining| == 1 then [] else [44]+FieldsText(remaining[1..]));
    assert encoded == Render(first)+(if |remaining| == 1 then [] else [44]+FieldsText(remaining[1..]))+[41];
    Delimiter(Render(first),FieldsText(remaining[1..]),|remaining| == 1);
    assert encoded[|Render(first)|] == (if |remaining| == 1 then 41 else 44);
    assert t[e] == encoded[|Render(first)|];
    assert t[e] == (if |remaining| == 1 then 41 else 44);
    Accept(t,q,limit,first);
    AppendFields(prefix,first);
    WidthConcat(prefix+[first],remaining[1..]);
    assert prefix+remaining == (prefix+[first])+remaining[1..];
    if |remaining| > 1 {
      Subslice(t,q,q+|FieldsText(remaining)|+1,|Render(first)|+1,|FieldsText(remaining)|+1);
      assert t[e+1..q+|FieldsText(remaining)|+1] == FieldsText(remaining[1..])+[41];
      FieldsAccept(t,e+1,limit,prefix+[first],remaining[1..]);
    } else { assert remaining == [first]; }
  }

  // Full acceptance/rejection characterization for whole descriptors.
  ghost method WholeCorrespondence(t: seq<Byte>) returns (r: ShapeResult)
    requires Uint(|t|)
    ensures r == Whole(t)
    ensures r.Shaped? <==> exists s :: Admissible(s) && Render(s) == t
    ensures forall s :: Admissible(s) && Render(s) == t ==>
                          r == Shaped(|t|,Dyn(s),Width(s),s)
  {
    r := Shape(t);
    forall s | Admissible(s) && Render(s) == t
      ensures r == Shaped(|t|,Dyn(s),Width(s),s)
    { Accept(t,0,|t|,s); }
    if r.Shaped? { assert Admissible(r.syntax) && Render(r.syntax) == t; }
  }
}

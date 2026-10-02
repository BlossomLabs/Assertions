// SPDX-License-Identifier: MIT
include "Names.generated.dfy"

module AbiTupleSemantics {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiShapeSemantics
  import opened AbiShapeRefinement
  import opened AbiSuffixSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import opened AbiTupleWords
  import opened AbiTupleNames

  function Rules(s: Descriptor): seq<WordRule>
    decreases s, 1
  {
    match s
    case Name(n) => [Rule(n)]
    case Group(fs) => FieldRules(fs)
    case Fixed(e,ds) => Repeat(Rules(e),Number(ds))
    case Dynamic(_) => []
  }

  function FieldRules(fs: seq<Descriptor>): seq<WordRule>
    decreases fs, 0
  { if |fs| == 0 then [] else Rules(fs[0])+FieldRules(fs[1..]) }

  lemma FieldAppend(a: seq<Descriptor>, b: seq<Descriptor>)
    ensures FieldRules(a+b) == FieldRules(a)+FieldRules(b)
    decreases |a|
  {
    if |a| > 0 {
      assert (a+b)[0] == a[0] && (a+b)[1..] == a[1..]+b;
      FieldAppend(a[1..],b);
    } else { assert a == [] && a+b == b; }
  }

  lemma StaticRules(s: Descriptor)
    requires Good(s) && !Dyn(s)
    ensures Admissible(s)
    ensures |Rules(s)| == Width(s) && Width(s) > 0
    ensures RulesValid(Rules(s))
    decreases s, 1
  {
    Positive(s);
    match s
    case Name(n) => RuleClassified(n);
    case Group(fs) => StaticFields(fs);
    case Fixed(e,ds) =>
      StaticRules(e);
      RepeatValid(Rules(e),Number(ds));
    case Dynamic(e) => assert false;
  }

  lemma StaticFields(fs: seq<Descriptor>)
    requires forall i :: 0 <= i < |fs| ==> Good(fs[i]) && !Dyn(fs[i])
    ensures |FieldRules(fs)| == WidthSum(fs)
    ensures RulesValid(FieldRules(fs))
    ensures forall i :: 0 <= i < |fs| ==> Admissible(fs[i])
    decreases fs, 0
  {
    if |fs| > 0 {
      StaticRules(fs[0]); StaticFields(fs[1..]);
      ValidConcat(Rules(fs[0]),FieldRules(fs[1..]));
    }
  }

  lemma {:isolate_assertions} StaticDecompose(s: Descriptor)
    requires Good(s) && !Dyn(s)
    ensures Admissible(s) && Good(Stem(s)) && !Dyn(Stem(s))
    ensures Stem(s).Name? || Stem(s).Group?
    ensures Stem(s) == s || Stem(s) < s
    ensures SuffixList(SuffixesOf(s)) && Product(SuffixesOf(s)) < 0x100000000
    ensures Render(s) == Render(Stem(s))+Text(SuffixesOf(s))
    ensures Width(s) == Width(Stem(s))*Product(SuffixesOf(s))
    ensures Rules(s) == Repeat(Rules(Stem(s)),Product(SuffixesOf(s)))
    decreases s
  {
    StaticRules(s); Decompose(s);
    if s.Fixed? {
      StaticDecompose(s.element);
      DecimalNumber(s.digits);
      SuffixAppend(SuffixesOf(s.element),s.digits);
      RepeatMultiply(Rules(Stem(s)),Product(SuffixesOf(s.element)),Number(s.digits));
      assert Width(Stem(s)) > 0 by { Positive(Stem(s)); }
      var a := Width(Stem(s));
      var b := Product(SuffixesOf(s.element));
      var c := Number(s.digits);
      assert Stem(s) == Stem(s.element);
      assert Width(s.element) == a*b;
      assert Width(s) == c*Width(s.element);
      ProductAssoc(a,b,c);
      assert c*(a*b) == (a*b)*c;
      assert Width(s) == a*(b*c);
      assert Product(SuffixesOf(s)) == b*c;
      MultiplyAtLeast(Product(SuffixesOf(s)),Width(Stem(s)));
      assert Product(SuffixesOf(s)) <= Width(Stem(s))*Product(SuffixesOf(s));
    } else {
      assert Stem(s) == s && SuffixesOf(s) == [];
      assert Repeat(Rules(s),1) == Rules(s);
    }
  }

  lemma Span(s: Descriptor, v: seq<Byte>, p: nat, count: nat)
    requires Good(s) && !Dyn(s) && Uint(|v|) && Uint(p+32*Width(s))
    requires count == 0 || p+32*Width(s)*count <= |v|
    ensures Uint(p) && Uint(32*Width(s)) && Uint(Width(s)*count)
    ensures count == 0 || p+32*|Repeat(Rules(s),count)| <= |v|
    ensures RulesValid(Repeat(Rules(s),count))
  {
    StaticRules(s); RepeatValid(Rules(s),count);
    SpanArithmetic(p,Width(s),count,|v|);
  }
  predicate Located(t: seq<Byte>, ts: nat, limit: nat, s: Descriptor)
  {
    ts+|Render(s)| <= limit <= |t| && t[ts..ts+|Render(s)|] == Render(s) &&
    Boundary(t,ts+|Render(s)|,limit)
  }

  lemma LocateStem(t: seq<Byte>, ts: nat, limit: nat, s: Descriptor)
    requires Good(s) && !Dyn(s) && Located(t,ts,limit,s)
    ensures ts+|Render(Stem(s))| <= limit
    ensures t[ts..ts+|Render(Stem(s))|] == Render(Stem(s))
    ensures At(t,ts+|Render(Stem(s))|,limit,SuffixesOf(s))
  {
    StaticDecompose(s);
    Subslice(t,ts,ts+|Render(s)|,0,|Render(Stem(s))|);
    Subslice(t,ts,ts+|Render(s)|,|Render(Stem(s))|,|Render(s)|);
  }

  lemma FieldsTextAppend(a: seq<Descriptor>, b: seq<Descriptor>)
    ensures FieldsText(a+b) == FieldsText(a)+(if |a| == 0 || |b| == 0 then [] else [44])+FieldsText(b)
    decreases |a|
  {
    if |a| > 0 {
      assert (a+b)[0] == a[0] && (a+b)[1..] == a[1..]+b;
      FieldsTextAppend(a[1..],b);
    } else { assert a == [] && a+b == b; }
  }

  function FieldStart(ts: nat, fs: seq<Descriptor>, i: nat): nat
    requires i <= |fs|
  { ts+1+|FieldsText(fs[..i])|+(if i == 0 then 0 else 1) }

  lemma LocateField(t: seq<Byte>, ts: nat, limit: nat, fs: seq<Descriptor>, i: nat)
    requires i < |fs| && (forall j :: 0 <= j < |fs| ==> Good(fs[j]))
    requires ts+|Render(Group(fs))| <= limit <= |t|
    requires t[ts..ts+|Render(Group(fs))|] == Render(Group(fs))
    ensures Located(t,FieldStart(ts,fs,i),limit,fs[i])
    ensures FieldStart(ts,fs,i)+|Render(fs[i])| == ts+1+|FieldsText(fs[..i+1])|
    ensures FieldStart(ts,fs,i)+|Render(fs[i])| < limit
    ensures t[FieldStart(ts,fs,i)+|Render(fs[i])|] == (if i+1 < |fs| then 44 else 41)
    ensures i+1 < |fs| ==> FieldStart(ts,fs,i)+|Render(fs[i])|+1 == FieldStart(ts,fs,i+1)
    ensures i+1 == |fs| ==> FieldStart(ts,fs,i)+|Render(fs[i])| == ts+|Render(Group(fs))|-1
  {
    assert fs == fs[..i]+fs[i..];
    FieldsTextAppend(fs[..i],fs[i..]);
    AppendFields(fs[..i],fs[i]);
    assert fs[..i+1] == fs[..i]+[fs[i]];
    assert fs[i..] == [fs[i]]+fs[i+1..];
    FieldsTextAppend([fs[i]],fs[i+1..]);
    Positive(fs[i]);
    var q := FieldStart(ts,fs,i);
    var e := q+|Render(fs[i])|;
    var all := t[ts..ts+|Render(Group(fs))|];
    assert all[q-ts..e-ts] == Render(fs[i]);
    Subslice(t,ts,ts+|Render(Group(fs))|,q-ts,e-ts);
    FieldsTextAppend(fs[..i+1],fs[i+1..]);
    assert e-ts == 1+|FieldsText(fs[..i+1])|;
    if i+1 < |fs| {
      assert |fs[..i+1]| > 0 && |fs[i+1..]| > 0;
      assert all == [40]+FieldsText(fs[..i+1])+[44]+FieldsText(fs[i+1..])+[41];
    } else {
      assert fs[..i+1] == fs && fs[i+1..] == [];
      assert all == [40]+FieldsText(fs)+[41];
    }
    assert all[e-ts] == (if i+1 < |fs| then 44 else 41);
    assert t[e] == all[e-ts];
  }
}


// SPDX-License-Identifier: MIT
include "TypeShape.generated.dfy"

module AbiShapeRefinement {
  import opened AbiFrames
  import opened AbiAggregateRefinement
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiShapeSource
  import opened AbiSuffixSemantics

  // Shape erasure intentionally leaves narrow-word classification to wordRule.
  // Every static leaf has the same head width, irrespective of its word rule.
  ghost function ShapeType(s: Descriptor): AbiType
    decreases s
  {
    match s
    case Name(n) => if n == [98,121,116,101,115] then Bytes else
    if n == [115,116,114,105,110,103] then String else Scalar(Opaque)
    case Group(fs) => Tuple(seq(|fs|, i requires 0 <= i < |fs| => ShapeType(fs[i])))
    case Fixed(e,ds) => FixedArray(ShapeType(e),Number(ds))
    case Dynamic(e) => Array(ShapeType(e))
  }

  lemma WidthMapping(fs: seq<Descriptor>)
    requires forall i :: 0 <= i < |fs| ==> Width(fs[i]) == HeadWords(ShapeType(fs[i]))
    ensures WidthSum(fs) == Sum(seq(|fs|, i requires 0 <= i < |fs| => HeadWords(ShapeType(fs[i]))))
    decreases |fs|
  {
    if |fs| > 0 {
      WidthMapping(fs[1..]);
      var ws := seq(|fs|, i requires 0 <= i < |fs| => HeadWords(ShapeType(fs[i])));
      assert ws[1..] == seq(|fs|-1, i requires 0 <= i < |fs|-1 => HeadWords(ShapeType(fs[1..][i])));
    }
  }

  lemma ModelShape(s: Descriptor)
    requires Good(s)
    ensures WellFormed(ShapeType(s)) && ShapesFit(ShapeType(s))
    ensures Dyn(s) == IsDynamic(ShapeType(s))
    ensures Width(s) == HeadWords(ShapeType(s))
    decreases s
  {
    match s
    case Group(fs) =>
      forall i | 0 <= i < |fs|
        ensures WellFormed(ShapeType(fs[i])) && ShapesFit(ShapeType(fs[i]))
        ensures Dyn(fs[i]) == IsDynamic(ShapeType(fs[i]))
        ensures Width(fs[i]) == HeadWords(ShapeType(fs[i]))
      { ModelShape(fs[i]); }
      var ts := seq(|fs|, i requires 0 <= i < |fs| => ShapeType(fs[i]));
      assert forall i :: 0 <= i < |fs| ==> Dyn(fs[i]) == IsDynamic(ts[i]);
      assert (exists i :: 0 <= i < |fs| && Dyn(fs[i])) ==
             (exists i :: 0 <= i < |ts| && IsDynamic(ts[i]));
      assert Dyn(s) == IsDynamic(ShapeType(s));
      WidthMapping(fs);
      assert seq(|ts|, i requires 0 <= i < |ts| => HeadWords(ts[i])) ==
             seq(|fs|, i requires 0 <= i < |fs| => HeadWords(ShapeType(fs[i])));
    case Fixed(e,ds) => ModelShape(e);
    case Dynamic(e) => ModelShape(e);
    case _ =>
  }

  predicate FixedChain(s: Descriptor)
    decreases s
  { s.Name? || (s.Fixed? && FixedChain(s.element)) }

  function BaseName(s: Descriptor): seq<Byte>
    requires FixedChain(s)
    decreases s
  { if s.Name? then s.text else BaseName(s.element) }

  function Counts(s: Descriptor): seq<seq<Byte>>
    requires FixedChain(s)
    decreases s
  { if s.Name? then [] else Counts(s.element)+[s.digits] }

  lemma SuffixAppend(ss: seq<seq<Byte>>, ds: seq<Byte>)
    requires SuffixList(ss) && Digits(ds) && 0 < Decimal(ds) < 0x100000000
    ensures SuffixList(ss+[ds])
    ensures Text(ss+[ds]) == Text(ss)+[91]+ds+[93]
    ensures Product(ss+[ds]) == Product(ss)*Decimal(ds)
    decreases |ss|
  {
    if |ss| > 0 {
      assert (ss+[ds])[1..] == ss[1..]+[ds];
      SuffixAppend(ss[1..],ds);
      calc {
         Product(ss+[ds]);
      == Decimal(ss[0])*(Product(ss[1..])*Decimal(ds));
      == (Decimal(ss[0])*Product(ss[1..]))*Decimal(ds);
      == Product(ss)*Decimal(ds);
      }
    }
  }

  lemma ChainShape(s: Descriptor)
    requires Good(s) && FixedChain(s) && !Dyn(s)
    ensures SuffixList(Counts(s)) && Product(Counts(s)) < 0x100000000
    ensures Render(s) == BaseName(s)+Text(Counts(s))
    ensures Width(s) == Product(Counts(s)) && |BaseName(s)| > 0
    decreases s
  {
    if s.Fixed? {
      ChainShape(s.element);
      DecimalNumber(s.digits);
      SuffixAppend(Counts(s.element),s.digits);
    }
  }

  // The earlier suffix theorem's syntax and product premises now follow from
  // successful source parsing for static, non-tuple descriptors.
  ghost method ParsedShape(t: seq<Byte>, p: nat, limit: nat) returns (r: ShapeResult)
    requires Uint(|t|) && Uint(p) && Uint(limit)
    ensures r.Shaped? ==> p < r.end <= limit <= |t|
    ensures r.Shaped? ==> Good(r.syntax) && Render(r.syntax) == t[p..r.end]
    ensures r.Shaped? ==> WellFormed(ShapeType(r.syntax)) && ShapesFit(ShapeType(r.syntax))
    ensures r.Shaped? ==> r.dynamic == IsDynamic(ShapeType(r.syntax)) && r.words == HeadWords(ShapeType(r.syntax))
    ensures r.Shaped? && !r.dynamic && FixedChain(r.syntax) ==>
              SuffixList(Counts(r.syntax)) && Product(Counts(r.syntax)) < 0x100000000 &&
              r.words == Product(Counts(r.syntax)) &&
              At(t,p+|BaseName(r.syntax)|,limit,Counts(r.syntax))
  {
    r := TypeShape(t,p,limit);
    if r.Shaped? {
      ModelShape(r.syntax);
      if !r.dynamic && FixedChain(r.syntax) {
        ChainShape(r.syntax);
        assert r.end == p+|BaseName(r.syntax)|+|Text(Counts(r.syntax))|;
        assert t[p+|BaseName(r.syntax)|..r.end] == Text(Counts(r.syntax));
      }
    }
  }
}

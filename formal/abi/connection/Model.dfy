// SPDX-License-Identifier: MIT
include "../tuples/Refinement.dfy"

module AbiConnectionModel {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiAggregateRefinement
  import opened AbiShapeSemantics
  import opened AbiTupleNames
  import opened AbiTupleWords
  import opened AbiTupleSemantics

  // Unlike ShapeType, this mapping retains the proved narrow-word classifier.
  ghost function TypeOf(s: Descriptor): AbiType
    decreases s, 1
  {
    match s
    case Name(n) => if n == [98,121,116,101,115] then Bytes else
    if n == [115,116,114,105,110,103] then String else Scalar(Rule(n))
    case Group(fs) => Tuple(TypesOf(fs))
    case Fixed(e,ds) => FixedArray(TypeOf(e),Number(ds))
    case Dynamic(e) => Array(TypeOf(e))
  }

  ghost function TypesOf(fs: seq<Descriptor>): seq<AbiType>
    ensures |TypesOf(fs)| == |fs|
    decreases fs, 0
  { if |fs| == 0 then [] else [TypeOf(fs[0])]+TypesOf(fs[1..]) }

  lemma TypesIndex(fs: seq<Descriptor>)
    ensures forall i :: 0 <= i < |fs| ==> TypesOf(fs)[i] == TypeOf(fs[i])
    decreases |fs|
  { if |fs| > 0 { TypesIndex(fs[1..]); } }

  lemma ModelType(s: Descriptor)
    requires Good(s)
    ensures ShapesFit(TypeOf(s)) && WellFormed(TypeOf(s))
    ensures IsDynamic(TypeOf(s)) == Dyn(s)
    ensures HeadWords(TypeOf(s)) == Width(s)
    decreases s, 1
  {
    match s
    case Name(n) => RuleClassified(n);
    case Group(fs) =>
      ModelFields(fs); TypesIndex(fs);
      assert (exists i :: 0 <= i < |fs| && Dyn(fs[i])) ==
             (exists i :: 0 <= i < |TypesOf(fs)| && IsDynamic(TypesOf(fs)[i]));
      assert IsDynamic(TypeOf(s)) == Dyn(s);
      assert TypeOf(s).fields == TypesOf(fs);
      if Dyn(s) { assert HeadWords(TypeOf(s)) == 1 && Width(s) == 1; }
      else {
        assert TypeOf(s) == Tuple(TypesOf(fs));
        var fields := TypeOf(s).fields;
        assert HeadWords(TypeOf(s)) == Sum(seq(|fields|,i requires 0 <= i < |fields| => HeadWords(fields[i])));
        assert seq(|fields|,i requires 0 <= i < |fields| => HeadWords(fields[i])) ==
               seq(|TypesOf(fs)|,i requires 0 <= i < |TypesOf(fs)| => HeadWords(TypesOf(fs)[i]));
        assert HeadWords(TypeOf(s)) == Sum(seq(|TypesOf(fs)|,i requires 0 <= i < |TypesOf(fs)| => HeadWords(TypesOf(fs)[i])));
        assert Width(s) == WidthSum(fs);
      }
    case Fixed(e,ds) => ModelType(e);
    case Dynamic(e) => ModelType(e);
  }

  lemma ModelFields(fs: seq<Descriptor>)
    requires forall i :: 0 <= i < |fs| ==> Good(fs[i])
    ensures Types(TypesOf(fs))
    ensures forall i :: 0 <= i < |fs| ==> ShapesFit(TypeOf(fs[i])) &&
                                          IsDynamic(TypeOf(fs[i])) == Dyn(fs[i]) && HeadWords(TypeOf(fs[i])) == Width(fs[i])
    ensures Sum(seq(|TypesOf(fs)|,i requires 0 <= i < |TypesOf(fs)| => HeadWords(TypesOf(fs)[i]))) == WidthSum(fs)
    ensures ListHead(TypesOf(fs)) == 32*WidthSum(fs)
    decreases fs, 0
  {
    if |fs| > 0 {
      ModelType(fs[0]); ModelFields(fs[1..]); TypesIndex(fs);
      var ws := seq(|TypesOf(fs)|,i requires 0 <= i < |TypesOf(fs)| => HeadWords(TypesOf(fs)[i]));
      assert ws[1..] == seq(|TypesOf(fs[1..])|,i requires 0 <= i < |TypesOf(fs[1..])| => HeadWords(TypesOf(fs[1..])[i]));
    }
  }

  function Copies(s: Descriptor, n: nat): seq<Descriptor>
    ensures |Copies(s,n)| == n
    ensures forall i :: 0 <= i < n ==> Copies(s,n)[i] == s
    decreases n
  { if n == 0 then [] else [s]+Copies(s,n-1) }

  lemma CopyLayout(s: Descriptor, n: nat)
    ensures WidthSum(Copies(s,n)) == Width(s)*n
    ensures FieldRules(Copies(s,n)) == Repeat(Rules(s),n)
    ensures TypesOf(Copies(s,n)) == seq(n,i requires 0 <= i < n => TypeOf(s))
    decreases n
  {
    if n > 0 {
      CopyLayout(s,n-1);
      var ts := seq(n,i requires 0 <= i < n => TypeOf(s));
      assert ts[1..] == seq(n-1,i requires 0 <= i < n-1 => TypeOf(s));
    }
  }
}

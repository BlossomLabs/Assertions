// SPDX-License-Identifier: MIT
include "CheckWords.generated.dfy"

module AbiTupleRefinement {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import AbiParserSource
  import opened AbiTupleWords
  import opened AbiTupleSemantics
  import opened AbiTupleSource

  // The successful parser result supplies the descriptor witness to the
  // source-derived traversal. Bounds remain caller obligations, including
  // representable tuple cursors when zero copies suppress every data read.
  ghost method ParsedWords(t: seq<Byte>, v: seq<Byte>, p: nat, count: nat)
    returns (syntax: Descriptor, end: nat, words: nat, r: Outcome)
    requires Uint(|t|) && Uint(|v|) && Uint(count)
    requires Whole(t).Shaped? && !Whole(t).dynamic
    requires Uint(p+32*Whole(t).words)
    requires count == 0 || p+32*Whole(t).words*count <= |v|
    ensures syntax == Whole(t).syntax
    ensures Good(syntax) && !Dyn(syntax) && RulesValid(Repeat(Rules(syntax),count))
    ensures count == 0 || p+32*|Repeat(Rules(syntax),count)| <= |v|
    ensures r == Scan(Repeat(Rules(syntax),count),v,p)
    ensures r.Ok? ==> end == |t| && words == Width(syntax)
    ensures !r.Panic?
    ensures count == 0 ==> r == Ok(0)
    ensures r.Ok? <==> forall i :: 0 <= i < |Repeat(Rules(syntax),count)| ==>
                                     CanonicalWord(Repeat(Rules(syntax),count)[i],ReadNat(v[p+32*i..p+32*i+32]))
    ensures r.Invalid? ==> (exists i :: 0 <= i < |Repeat(Rules(syntax),count)| &&
                                        r == Invalid(p+32*i) &&
                                        !CanonicalWord(Repeat(Rules(syntax),count)[i],ReadNat(v[p+32*i..p+32*i+32])) &&
                                        (forall j :: 0 <= j < i ==>
                                                       CanonicalWord(Repeat(Rules(syntax),count)[j],ReadNat(v[p+32*j..p+32*j+32]))))
  {
    var parsed := AbiParserSource.Shape(t);
    syntax := parsed.syntax;
    assert Located(t,0,|t|,syntax);
    end,words,r := CheckWords(t,0,|t|,count,v,p,syntax);
    FirstError(Repeat(Rules(syntax),count),v,p);
  }
}

// SPDX-License-Identifier: MIT
include "Suffixes.generated.dfy"

module AbiDescriptorRefinement {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiWordRefinement
  import opened AbiSuffixSemantics
  import opened AbiSuffixSource

  // The complete checkWords non-tuple branch is AST-checked by generate.py.
  // Inputs rule/nameEnd are the wordRule interface, checked separately by the
  // retained SMT gate; this does not establish typeShape's syntax precondition.
  ghost method WordCopies(rule: WordRule, t: seq<Byte>, nameEnd: nat, limit: nat,
                          ss: seq<seq<Byte>>, v: seq<Byte>, p: nat, count: nat)
    returns (end: nat, words: nat, r: Outcome)
    requires ClassifiedRule(rule) && Uint(|t|) && Uint(|v|)
    requires At(t,nameEnd,limit,ss) && SuffixList(ss) && Product(ss) < 0x100000000
    requires p+32*(Product(ss)*count) <= |v|
    ensures end == nameEnd+|Text(ss)| && words == Product(ss)
    ensures p <= |v| && p+32*(words*count) <= |v|
    ensures WellFormed(Wrap(Scalar(rule),ss)) && !IsDynamic(Wrap(Scalar(rule),ss))
    ensures words == HeadWords(Wrap(Scalar(rule),ss))
    ensures !r.Panic?
    ensures r.Ok? <==> forall i :: 0 <= i < words*count ==>
                                     CanonicalWord(rule,ReadNat(v[p+32*i..p+32*i+32]))
    ensures r == (if FirstBad(rule,v,p,words*count,0) == words*count then Ok(0)
                  else Invalid(p+32*FirstBad(rule,v,p,words*count,0)))
  {
    end := nameEnd;
    words := 1;
    if end < limit { end, words := Suffixes(t,end,limit,ss); }
    else {
      assert |Text(ss)| == 0;
      if |ss| > 0 { assert |Text(ss)| >= 2; }
      assert |ss| == 0;
    }
    WrapShape(Scalar(rule),ss);
    assert 0 < words && Uint(words*count);
    if !rule.Opaque? { r := CheckRun(rule,v,p,words*count); }
    else {
      OpaqueWords(v,p,words*count);
      FirstBadMeaning(rule,v,p,words*count,0);
      r := Ok(0);
    }
  }
}

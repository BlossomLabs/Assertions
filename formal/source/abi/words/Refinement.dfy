// SPDX-License-Identifier: MIT
include "Scanners.generated.dfy"
include "../aggregate/Refinement.dfy"

module AbiWordRefinement {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiBytesSource
  import opened AbiWordSemantics
  import opened AbiWordSource

  ghost method CheckRun(rule: WordRule, v: seq<Byte>, p: nat, n: nat) returns (r: Outcome)
    requires ClassifiedRule(rule) && p+32*n <= |v| && Uint(|v|)
    ensures !r.Panic?
    ensures r.Ok? <==> forall i :: 0 <= i < n ==> CanonicalWord(rule,ReadNat(v[p+32*i..p+32*i+32]))
    ensures r == (if FirstBad(rule,v,p,n,0) == n then Ok(0) else Invalid(p+32*FirstBad(rule,v,p,n,0)))
  {
    if rule.Opaque? { OpaqueWords(v,p,n); r := Ok(0); }
    else { r := CheckRule(rule,v,p,n); }
    FirstBadMeaning(rule,v,p,n,0);
  }

  // Source-derived replacement for the scalar interface in typed recursion.
  // The descriptor-to-rule connection is a separate SMT gate. Its historical
  // counterexample is retained; this theorem alone does not close that gate.
  ghost method ScalarWalk(rule: WordRule, v: seq<Byte>) returns (r: Parsed)
    requires ClassifiedRule(rule) && Uint(|v|)
    ensures r == Walk(Scalar(rule),v)
  {
    var head := ReadWord(v,0);
    if !head.Ok? { r := Rejected; return; }
    var check := CheckRun(rule,v,0,1);
    if !check.Ok? { r := Rejected; return; }
    r := Parsed(Atom(head.used),32);
  }

  ghost method ScanNameMeaning(t: seq<Byte>, p: nat, limit: nat) returns (end: nat)
    requires p <= limit <= |t| && Uint(|t|)
    ensures p <= end <= limit
    ensures forall i :: p <= i < end ==> NameByte(t[i])
    ensures end < limit ==> !NameByte(t[end])
    ensures end == p <==> p == limit || !NameByte(t[p])
  {
    end := ScanName(t,p,limit);
    NamePrefix(t,p,limit);
  }
}

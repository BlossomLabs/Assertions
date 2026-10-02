// SPDX-License-Identifier: MIT
include "Static.dfy"

module AbiConnectionDescriptor {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import opened AbiTupleSemantics

  datatype SuffixResult = Found(at: nat) | Malformed(at: nat)

  predicate DecimalByte(c: Byte) { 48 <= c <= 57 }

  function Back(t: seq<Byte>, ts: nat, j: nat): nat
    requires ts <= j < |t|
    ensures ts <= Back(t,ts,j) <= j
    decreases j-ts
  { if j > ts && DecimalByte(t[j]) then Back(t,ts,j-1) else j }

  function SuffixSpec(t: seq<Byte>, ts: nat, te: nat): SuffixResult
    requires ts+2 <= te <= |t|
  { var j := Back(t,ts,te-2); if t[j] == 91 then Found(j) else Malformed(j) }

  lemma BackDigits(t: seq<Byte>, ts: nat, opening: nat, j: nat)
    requires ts <= opening <= j < |t| && t[opening] == 91
    requires forall i :: opening < i <= j ==> DecimalByte(t[i])
    ensures Back(t,ts,j) == opening
    decreases j-opening
  { if j > opening { BackDigits(t,ts,opening,j-1); } }

  lemma LastByte(s: Descriptor)
    requires Good(s)
    ensures |Render(s)| > 0
    ensures (Render(s)[|Render(s)|-1] == 93) == (s.Fixed? || s.Dynamic?)
  {
    Positive(s);
    match s
    case Name(n) => assert NameByte(n[|n|-1]);
    case Group(fs) =>
    case Fixed(e,ds) =>
    case Dynamic(e) =>
  }

  lemma ArraySpan(t: seq<Byte>, ts: nat, te: nat, s: Descriptor)
    requires Admissible(s) && (s.Fixed? || s.Dynamic?)
    requires ts <= te <= |t| && t[ts..te] == Render(s)
    ensures ts+2 <= te
    ensures ts < ts+|Render(s.element)| < te
    ensures t[ts..ts+|Render(s.element)|] == Render(s.element)
    ensures Admissible(s.element)
    ensures SuffixSpec(t,ts,te) == Found(ts+|Render(s.element)|)
    ensures t[te-1] == 93
    ensures (ts+|Render(s.element)|+1 == te-1) == s.Dynamic?
    ensures s.Fixed? ==> t[ts+|Render(s.element)|+1..te-1] == s.digits
  {
    Positive(s.element);
    var ds := if s.Fixed? then s.digits else [];
    var j := ts+|Render(s.element)|;
    assert Render(s) == Render(s.element)+[91]+ds+[93];
    Subslice(t,ts,te,0,|Render(s.element)|);
    Subslice(t,ts,te,|Render(s.element)|+1,te-ts-1);
    assert t[j] == 91;
    assert forall i :: j < i < te-1 ==> DecimalByte(t[i]);
    BackDigits(t,ts,j,te-2);
  }

  function ArrayPrelude(v: seq<Byte>, p: nat, s: Descriptor): Outcome
    requires Good(s) && (s.Fixed? || s.Dynamic?)
  {
    if p > |v| || (s.Dynamic? && |v|-p < 32) then Invalid(p) else
    var base := p+(if s.Dynamic? then 32 else 0);
    var count := if s.Dynamic? then ReadNat(v[p..p+32]) else Number(s.digits);
    var head := count*Width(s.element)*32;
    if head > |v|-base then Invalid(base) else Ok(head)
  }

  lemma FieldRoom(t: seq<Byte>, ts: nat, te: nat, fs: seq<Descriptor>, i: nat)
    requires Good(Group(fs)) && i < |fs|
    requires ts <= te <= |t| && t[ts..te] == Render(Group(fs))
    ensures FieldStart(ts,fs,i) < te-1
  { LocateField(t,ts,te,fs,i); Positive(fs[i]); }
}

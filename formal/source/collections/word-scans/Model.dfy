// SPDX-License-Identifier: MIT
include "../word-memory/Connection.dfy"
module CollectionsWordScansModel {
  import opened AbiFrames
  import Mem = CollectionsWordMemoryModel
  function Limit(): nat { Pow256(32) }
  datatype Outcome = Returned(value: nat) | Failed(reason: seq<Byte>)
  predicate Basic(s: seq<Byte>,needle: nat) { Mem.Fits(|s|) && Mem.Fits(needle) }
  predicate Aligned(s: seq<Byte>) { |s| % 32 == 0 }
  function Count(s: seq<Byte>): nat { |s|/32 }
  function Element(s: seq<Byte>,i: nat): nat
    requires i < Count(s)
  { ReadNat(s[32*i..32*i+32]) }
  function Find(s: seq<Byte>,needle: nat,i: nat): nat
    requires i <= Count(s)
    decreases Count(s)-i
  { if i == Count(s) then Count(s) else if Element(s,i) == needle then i else Find(s,needle,i+1) }
  function Sum(s: seq<Byte>,i: nat): nat
    requires i <= Count(s)
    decreases i
  { if i == 0 then 0 else Sum(s,i-1)+Element(s,i-1) }
  function Panic(): seq<Byte> { [78,72,123,113]+Word(17) }
  function Total(s: seq<Byte>,i: nat,acc: nat): Outcome
    requires i <= Count(s) && acc < Limit()
    decreases Count(s)-i
  {
    if i == Count(s) then Returned(acc) else
    if acc+Element(s,i) >= Limit() then Failed(Panic()) else Total(s,i+1,acc+Element(s,i))
  }
  lemma FindFacts(s: seq<Byte>,needle: nat,i: nat)
    requires i <= Count(s)
    ensures i <= Find(s,needle,i) <= Count(s)
    ensures Find(s,needle,i) < Count(s) ==> Element(s,Find(s,needle,i)) == needle
    ensures forall j :: i <= j < Find(s,needle,i) ==> Element(s,j) != needle
    decreases Count(s)-i
  { if i < Count(s) && Element(s,i) != needle { FindFacts(s,needle,i+1); } }
  lemma TotalFacts(s: seq<Byte>,i: nat,acc: nat)
    requires i <= Count(s) && acc < Limit()
    ensures Sum(s,i) <= Sum(s,Count(s))
    ensures Total(s,i,acc) == (if acc+Sum(s,Count(s))-Sum(s,i) < Limit() then Returned(acc+Sum(s,Count(s))-Sum(s,i)) else Failed(Panic()))
    decreases Count(s)-i
  {
    SumMonotone(s,i,Count(s));
    if i < Count(s) {
      assert Sum(s,i+1) == Sum(s,i)+Element(s,i);
      if acc+Element(s,i) < Limit() { TotalFacts(s,i+1,acc+Element(s,i)); }
      else { SumMonotone(s,i+1,Count(s)); }
    }
  }
  lemma SumMonotone(s: seq<Byte>,a: nat,b: nat)
    requires a <= b <= Count(s)
    ensures Sum(s,a) <= Sum(s,b)
    decreases b-a
  { if a < b { SumMonotone(s,a,b-1); } }
}

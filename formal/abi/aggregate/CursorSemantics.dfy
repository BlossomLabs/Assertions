// SPDX-License-Identifier: MIT
include "../source/Correspondence.dfy"

module AbiCursorSemantics {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics

  lemma QuotientBound(n: nat, k: nat, d: nat)
    requires d > 0
    ensures k <= n/d <==> k*d <= n
  {
    var q := n/d;
    var r := n%d;
    assert n == q*d+r && 0 <= r < d;
    if k <= q {
      assert k*d <= q*d;
    } else {
      assert q+1 <= k;
      assert (q+1)*d <= k*d;
      assert n < (q+1)*d;
    }
  }

  lemma DivisionBound(available: nat, count: nat, words: nat)
    requires words > 0
    ensures count <= available/32/words <==> count*words*32 <= available
  {
    QuotientBound(available/32,count,words);
    QuotientBound(available,count*words,32);
  }

  lemma ProductNonnegative(a: nat, b: nat)
    ensures a*b >= 0
  {}

  lemma DivisionShrinks(n: nat, d: nat)
    requires d > 0
    ensures 0 <= n/d <= n
  {
    var q := n/d;
    assert n == q*d+n%d;
    if q < 0 {
      assert q <= -1;
      assert q*d <= -d;
      assert n%d < d;
      assert n < 0;
    }
    assert q >= 0 && d >= 1;
    ProductNonnegative(q,d-1);
    assert q*d == q+q*(d-1);
    assert q <= q*d;
  }

  lemma ProductFits(count: nat, words: nat, available: nat)
    requires words > 0 && Uint(available) && count*words*32 <= available
    ensures Uint(count*words) && Uint(count*words*32)
  {}

  lemma PositionFits(base: nat, count: nat, words: nat, index: nat, length: nat)
    requires words > 0 && index < count && base+count*words*32 <= length && Uint(length)
    ensures Uint(index*words) && Uint(index*words*32)
    ensures base+index*words*32+32*words <= length
    ensures Uint(base+index*words*32)
  {
    assert index+1 <= count;
    assert (index+1)*words*32 <= count*words*32;
  }

  ghost function Widths(ts: seq<AbiType>): seq<nat>
    requires Types(ts)
    ensures |Widths(ts)| == |ts|
  { seq(|ts|, i requires 0 <= i < |ts| => HeadWords(ts[i])) }

  function SumWidths(ws: seq<nat>): nat
    decreases |ws|
  { if |ws| == 0 then 0 else ws[0]*32+SumWidths(ws[1..]) }

  lemma WidthsHead(ts: seq<AbiType>)
    requires Types(ts)
    ensures SumWidths(Widths(ts)) == ListHead(ts)
    decreases |ts|
  {
    if |ts| > 0 {
      assert Widths(ts)[1..] == Widths(ts[1..]);
      WidthsHead(ts[1..]);
    }
  }

  lemma HeadAppend(ts: seq<AbiType>, i: nat)
    requires i < |ts|
    ensures ListHead(ts[..i+1]) == ListHead(ts[..i])+32*HeadWords(ts[i])
    ensures ListHead(ts) == ListHead(ts[..i])+ListHead(ts[i..])
    decreases i
  {
    if i > 0 {
      HeadAppend(ts[1..],i-1);
      assert ts[..i+1][1..] == ts[1..][..i];
      assert ts[..i][1..] == ts[1..][..i-1];
    }
  }

  lemma RepeatedHead(t: AbiType, n: nat)
    requires WellFormed(t)
    ensures ListHead(seq(n,i requires 0 <= i < n => t)) == n*HeadWords(t)*32
    decreases n
  {
    if n > 0 {
      var ts := seq(n,i requires 0 <= i < n => t);
      assert ts[1..] == seq(n-1,i requires 0 <= i < n-1 => t);
      RepeatedHead(t,n-1);
    }
  }

  lemma StaticExtent(t: AbiType, bs: seq<Byte>)
    requires WellFormed(t) && !IsDynamic(t) && Walk(t,bs).Parsed?
    ensures Walk(t,bs).used == 32*HeadWords(t)
  {
    WalkSound(t,bs);
    HeadFootprint(t,Walk(t,bs).value);
  }

  ghost function Prefix(vs: seq<Value>, result: FieldsResult): FieldsResult
  { if result.BadFields? then BadFields else Fields(vs+result.values,result.end) }

  lemma PrefixStep(vs: seq<Value>, v: Value, result: FieldsResult)
    ensures Prefix(vs,Prefix([v],result)) == Prefix(vs+[v],result)
  {}
}

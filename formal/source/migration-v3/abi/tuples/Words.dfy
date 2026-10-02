// SPDX-License-Identifier: MIT
include "../parser/Completeness.dfy"

module AbiTupleWords {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiShapeSemantics

  function Repeat(xs: seq<WordRule>, n: nat): seq<WordRule>
    ensures |Repeat(xs,n)| == |xs|*n
    ensures RulesValid(xs) ==> RulesValid(Repeat(xs,n))
    decreases n
  { if n == 0 then [] else xs+Repeat(xs,n-1) }

  predicate RulesValid(xs: seq<WordRule>)
  { forall i :: 0 <= i < |xs| ==> ClassifiedRule(xs[i]) }

  lemma RepeatOne(xs: seq<WordRule>)
    ensures Repeat(xs,0) == [] && Repeat(xs,1) == xs
  { assert Repeat(xs,0) == []; }

  lemma RepeatValid(xs: seq<WordRule>, n: nat)
    requires RulesValid(xs)
    ensures RulesValid(Repeat(xs,n))
    decreases n
  { if n > 0 { RepeatValid(xs,n-1); } }

  lemma RepeatAdd(xs: seq<WordRule>, a: nat, b: nat)
    ensures Repeat(xs,a+b) == Repeat(xs,a)+Repeat(xs,b)
    decreases a
  { if a > 0 { RepeatAdd(xs,a-1,b); } }

  lemma RepeatMultiply(xs: seq<WordRule>, a: nat, b: nat)
    ensures Repeat(Repeat(xs,a),b) == Repeat(xs,a*b)
    decreases b
  {
    if b > 0 {
      RepeatMultiply(xs,a,b-1);
      RepeatAdd(xs,a,a*(b-1));
      assert a*b == a+a*(b-1);
    }
  }

  // Empty runs never read v and need no origin within the allocation.
  function Scan(xs: seq<WordRule>, v: seq<Byte>, p: nat): Outcome
    requires RulesValid(xs)
    requires |xs| == 0 || p+32*|xs| <= |v|
    ensures !Scan(xs,v,p).Panic?
    ensures Scan(xs,v,p).Ok? ==> Scan(xs,v,p) == Ok(0)
    decreases |xs|
  {
    if |xs| == 0 then Ok(0) else
    if CanonicalWord(xs[0],ReadNat(v[p..p+32])) then Scan(xs[1..],v,p+32)
    else Invalid(p)
  }

  lemma ValidConcat(a: seq<WordRule>, b: seq<WordRule>)
    requires RulesValid(a) && RulesValid(b)
    ensures RulesValid(a+b)
  {}

  lemma ScanAppend(a: seq<WordRule>, b: seq<WordRule>, v: seq<Byte>, p: nat)
    requires RulesValid(a) && RulesValid(b)
    requires |a+b| == 0 || p+32*|a+b| <= |v|
    ensures Scan(a+b,v,p) == (if Scan(a,v,p).Ok? then Scan(b,v,p+32*|a|) else Scan(a,v,p))
    decreases |a|
  {
    ValidConcat(a,b);
    if |a| > 0 {
      assert (a+b)[0] == a[0] && (a+b)[1..] == a[1..]+b;
      if CanonicalWord(a[0],ReadNat(v[p..p+32])) { ScanAppend(a[1..],b,v,p+32); }
    } else { assert a == [] && a+b == b; }
  }

  lemma UniformFirstBad(rule: WordRule, v: seq<Byte>, p: nat, n: nat, i: nat)
    requires ClassifiedRule(rule) && p+32*n <= |v| && i <= n
    ensures RulesValid(Repeat([rule],n-i))
    ensures Scan(Repeat([rule],n-i),v,p+32*i) ==
            (if FirstBad(rule,v,p,n,i) == n then Ok(0) else Invalid(p+32*FirstBad(rule,v,p,n,i)))
    decreases n-i
  {
    RepeatValid([rule],n-i);
    if i < n && CanonicalWord(rule,ReadNat(v[p+32*i..p+32*i+32])) {
      UniformFirstBad(rule,v,p,n,i+1);
    }
  }

  lemma FirstError(xs: seq<WordRule>, v: seq<Byte>, p: nat)
    requires RulesValid(xs) && (|xs| == 0 || p+32*|xs| <= |v|)
    ensures !Scan(xs,v,p).Panic?
    ensures Scan(xs,v,p).Ok? <==> forall i :: 0 <= i < |xs| ==>
                                                CanonicalWord(xs[i],ReadNat(v[p+32*i..p+32*i+32]))
    ensures Scan(xs,v,p).Invalid? ==> (exists i :: 0 <= i < |xs| &&
                                                   Scan(xs,v,p) == Invalid(p+32*i) &&
                                                   !CanonicalWord(xs[i],ReadNat(v[p+32*i..p+32*i+32])) &&
                                                   (forall j :: 0 <= j < i ==> CanonicalWord(xs[j],ReadNat(v[p+32*j..p+32*j+32]))))
    decreases |xs|
  {
    if |xs| > 0 && CanonicalWord(xs[0],ReadNat(v[p..p+32])) {
      FirstError(xs[1..],v,p+32);
      if Scan(xs[1..],v,p+32).Invalid? {
        var i :| 0 <= i < |xs[1..]| && Scan(xs[1..],v,p+32) == Invalid(p+32+32*i) &&
                 !CanonicalWord(xs[1..][i],ReadNat(v[p+32+32*i..p+32+32*i+32])) &&
                 (forall j :: 0 <= j < i ==> CanonicalWord(xs[1..][j],ReadNat(v[p+32+32*j..p+32+32*j+32])));
        assert !CanonicalWord(xs[i+1],ReadNat(v[p+32*(i+1)..p+32*(i+1)+32]));
      }
    } else if |xs| > 0 { assert Scan(xs,v,p) == Invalid(p); }
  }
  lemma {:isolate_assertions} Advance(xs: seq<WordRule>, n: nat, i: nat, v: seq<Byte>, p: nat)
    requires RulesValid(xs) && |xs| > 0 && i < n
    requires p+32*|xs|*n <= |v|
    requires p+32*|xs|*i+32*|xs| <= |v|
    requires Scan(Repeat(xs,i),v,p) == Ok(0)
    ensures RulesValid(Repeat(xs,i+1))
    ensures Scan(xs,v,p+32*|xs|*i).Ok? ==> Scan(Repeat(xs,i+1),v,p) == Ok(0)
    ensures !Scan(xs,v,p+32*|xs|*i).Ok? ==> Scan(Repeat(xs,n),v,p) == Scan(xs,v,p+32*|xs|*i)
  {
    RepeatValid(xs,i); RepeatValid(xs,i+1); RepeatValid(xs,n-i); RepeatValid(xs,n-i-1);
    RepeatAdd(xs,i,1); RepeatAdd(xs,i,n-i);
    assert Repeat(xs,1) == xs;
    ScanAppend(Repeat(xs,i),xs,v,p);
    ScanAppend(Repeat(xs,i),Repeat(xs,n-i),v,p);
    ScanAppend(xs,Repeat(xs,n-i-1),v,p+32*|xs|*i);
  }

  lemma ScanSegment(a: seq<WordRule>, b: seq<WordRule>, c: seq<WordRule>, v: seq<Byte>, p: nat)
    requires RulesValid(a) && RulesValid(b) && RulesValid(c)
    requires p+32*|a+b+c| <= |v|
    requires Scan(a,v,p) == Ok(0)
    ensures Scan(b,v,p+32*|a|).Ok? ==> Scan(a+b,v,p) == Ok(0)
    ensures !Scan(b,v,p+32*|a|).Ok? ==> Scan(a+b+c,v,p) == Scan(b,v,p+32*|a|)
  {
    ValidConcat(b,c); ValidConcat(a,b);
    assert (a+b)+c == a+(b+c);
    ScanAppend(a,b,v,p); ScanAppend(a,b+c,v,p); ScanAppend(b,c,v,p+32*|a|);
  }

  lemma ProductAssoc(a: nat, b: nat, c: nat)
    ensures (a*b)*c == a*(b*c)
  {}

  lemma CursorArithmetic(p: nat, w: nat, i: nat)
    ensures p+i*w*32 == p+32*w*i
    ensures p+32*(w*i) == p+32*w*i
  {
    ProductAssoc(i,w,32); ProductAssoc(32,w,i);
    assert i*w*32 == 32*(w*i);
  }

  lemma SpanArithmetic(p: nat, w: nat, n: nat, size: nat)
    requires w > 0 && Uint(p+32*w) && Uint(size)
    requires n == 0 || p+32*w*n <= size
    ensures Uint(p) && Uint(32*w) && Uint(w*n) && Uint(n)
  {
    if n > 0 {
      ProductAssoc(32,w,n);
      assert w*n <= 32*(w*n);
      assert n <= w*n by {
        assert (w-1)*n >= 0;
        assert w*n == n+(w-1)*n;
      }
    }
  }

  lemma CopyBounds(p: nat, w: nat, n: nat, i: nat, size: nat)
    requires i < n && p+32*w*n <= size
    ensures p+32*w*i+32*w <= size
    ensures p+32*w*(i+1) <= size
  {
    assert 0 <= n-i-1;
    assert 0 <= 32*w;
    assert (32*w)*(n-i-1) >= 0;
    assert (32*w)*n == (32*w)*(i+1)+(32*w)*(n-i-1);
    assert (32*w)*(i+1) == (32*w)*i+32*w;
  }

  lemma ExpandCopies(p: nat, w: nat, copies: nat, count: nat, size: nat)
    requires w > 0 && copies > 0 && Uint(size)
    requires Uint(p+32*(w*copies))
    requires count == 0 || p+32*(w*copies)*count <= size
    ensures Uint(p+32*w) && Uint(copies*count)
    ensures count == 0 || p+32*w*(copies*count) <= size
    ensures count == 0 || p+32*w <= size
  {
    ProductAssoc(32,w,copies); ProductAssoc(32*w,copies,count);
    assert w*copies >= w by {
      assert w*(copies-1) >= 0;
      assert w*copies == w+w*(copies-1);
    }
    if count > 0 {
      SpanArithmetic(p,w,copies*count,size);
      assert copies*count >= 1;
      CopyBounds(p,w,copies*count,0,size);
    }
  }

}

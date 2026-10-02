// SPDX-License-Identifier: MIT
include "Merge.dfy"
module CollectionsSortRanges {
  import opened CollectionsSortModel
  import MergeProof = CollectionsSortMerge
  lemma Scale(a: nat,b: nat,w: nat)
    requires a <= b
    ensures a*w <= b*w
  { assert (b-a)*w >= 0; }
  lemma RangeBounds(start: nat,size: nat)
    ensures forall x: nat :: x in Range(start,size) ==> start <= x < start+size
  {
    forall x: nat | x in Range(start,size)
      ensures start <= x < start+size
    {
      var i :| 0 <= i < size && Range(start,size)[i] == x;
    }
  }
  lemma RangeSlice(start: nat,size: nat,lo: nat,hi: nat)
    requires lo <= hi <= size
    ensures Range(start,size)[lo..hi] == Range(start+lo,hi-lo)
  {
    assert forall i :: 0 <= i < hi-lo ==> Range(start,size)[lo..hi][i] == Range(start+lo,hi-lo)[i];
  }
  lemma RangeJoin(start: nat,a: nat,b: nat)
    ensures Range(start,a+b) == Range(start,a)+Range(start+a,b)
  {
    forall i {:trigger Range(start,a+b)[i]} | 0 <= i < a+b
      ensures Range(start,a+b)[i] == (Range(start,a)+Range(start+a,b))[i]
    {
      if i >= a { assert (Range(start,a)+Range(start+a,b))[i] == Range(start+a,b)[i-a]; }
    }
  }
  lemma Initial(n: nat,le: (nat,nat)->bool)
    ensures Runs(n,le,Range(0,n),1)
  {
    reveal Runs();
    forall block: nat {:trigger Range(0,n)[block]} | block < n
      ensures var end := Min(block+1,n); multiset(Range(0,n)[block..end]) == multiset(Range(block,end-block)) && Sorted(le,Range(0,n)[block..end])
    {
      RangeSlice(0,n,block,block+1);
    }
  }
  lemma Block(n: nat,le: (nat,nat)->bool,source: seq<nat>,width: nat,block: nat)
    requires |source| == n && width > 0 && Order(n,le) && Runs(n,le,source,width) && block*(2*width) < n
    ensures var start := block*(2*width); var middle := Min(start+width,n); var end := Min(start+2*width,n);
                                                                            var merged := Merge(le,source[start..middle],source[middle..end]);
                                                                            Sorted(le,merged) && multiset(merged) == multiset(Range(start,end-start))
  {
    reveal Runs();
    var start := block*(2*width);
    var middle := Min(start+width,n);
    var end := Min(start+2*width,n);
    assert start == (2*block)*width;
    var left := source[start..middle]; var right := source[middle..end];
    assert Sorted(le,left) && multiset(left) == multiset(Range(start,middle-start));
    if middle < n {
      assert middle == (2*block+1)*width;
      assert end == Min(middle+width,n);
      assert Sorted(le,right) && multiset(right) == multiset(Range(middle,end-middle));
    } else { assert right == [] && Range(middle,end-middle) == []; }
    RangeBounds(start,middle-start); RangeBounds(middle,end-middle);
    forall x: nat | x in left ensures start <= x < middle { MergeProof.SameMember(left,Range(start,middle-start),x); }
    forall x: nat | x in right ensures middle <= x < end { MergeProof.SameMember(right,Range(middle,end-middle),x); }
    assert Well(n,left) && Well(n,right) && Separated(left,right);
    MergeProof.Ordered(n,le,left,right);
    RangeJoin(start,middle-start,end-middle);
  }
  lemma Count(start: nat,size: nat,x: nat)
    ensures multiset(Range(start,size))[x] == (if start <= x < start+size then 1 else 0)
    decreases size
  {
    if size > 0 {
      RangeJoin(start,1,size-1);
      assert Range(start,1) == [start];
      Count(start+1,size-1,x);
    } else { assert Range(start,size) == []; }
  }
  lemma Distinct(n: nat,a: seq<nat>,i: nat,j: nat)
    requires multiset(a) == multiset(Range(0,n)) && i < j < |a|
    ensures a[i] != a[j]
  {
    Count(0,n,a[i]);
    assert a == a[..i]+[a[i]]+a[i+1..j]+[a[j]]+a[j+1..];
    if a[i] == a[j] { assert multiset(a)[a[i]] >= 2; }
  }
  lemma Verdict(n: nat,le: (nat,nat)->bool,a: seq<nat>)
    requires multiset(a) == multiset(Range(0,n))
    ensures Well(n,a)
    ensures forall i :: 0 <= i < |a| ==> a[i] < n
    ensures forall i,j :: 0 <= i < j < |a| ==> a[i] != a[j]
    ensures Sorted(le,a) ==> (forall i,j :: 0 <= i < j < |a| ==> le(a[i],a[j]) && (le(a[j],a[i]) ==> a[i] < a[j]))
  {
    RangeBounds(0,n);
    forall x: nat | x in a ensures x < n { MergeProof.SameMember(a,Range(0,n),x); }
    forall i | 0 <= i < |a| ensures a[i] < n { assert a[i] in a; }
    forall i,j | 0 <= i < j < |a|
      ensures a[i] != a[j]
      ensures Sorted(le,a) ==> le(a[i],a[j]) && (le(a[j],a[i]) ==> a[i] < a[j])
    { Distinct(n,a,i,j); }
  }
}

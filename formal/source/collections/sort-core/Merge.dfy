// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsSortMerge {
  import opened CollectionsSortModel

  lemma SliceMember(a: seq<nat>,lo: nat,hi: nat,x: nat)
    requires lo <= hi <= |a| && x in a[lo..hi]
    ensures x in a
  {
    var i :| 0 <= i < hi-lo && a[lo..hi][i] == x;
    assert a[lo+i] == x;
  }
  lemma SameMember(a: seq<nat>,b: seq<nat>,x: nat)
    requires multiset(a) == multiset(b) && x in a
    ensures x in b
  { assert multiset(a)[x] > 0; assert multiset(b)[x] > 0; }
  lemma UnionMember(out: seq<nat>,a: seq<nat>,b: seq<nat>,x: nat)
    requires multiset(out) == multiset(a)+multiset(b) && x in out
    ensures x in a || x in b
  { assert multiset(out)[x] > 0; assert multiset(a)[x]+multiset(b)[x] > 0; }
  lemma Tails(n: nat,a: seq<nat>,b: seq<nat>)
    requires |a| > 0 && |b| > 0 && Well(n,a) && Well(n,b) && Separated(a,b)
    ensures Well(n,a[1..]) && Well(n,b[1..]) && Separated(a[1..],b) && Separated(a,b[1..])
  {
    forall x: nat | x in a[1..] ensures x < n { SliceMember(a,1,|a|,x); }
    forall x: nat | x in b[1..] ensures x < n { SliceMember(b,1,|b|,x); }
    forall x: nat,y: nat | x in a[1..] && y in b ensures x < y { SliceMember(a,1,|a|,x); }
    forall x: nat,y: nat | x in a && y in b[1..] ensures x < y { SliceMember(b,1,|b|,y); }
  }

  lemma Transitive(n: nat, le: (nat,nat)->bool, x: nat, y: nat, z: nat)
    requires Order(n,le) && x < n && y < n && z < n
    requires Before(le,x,y) && Before(le,y,z)
    ensures Before(le,x,z)
  {
    if le(z,x) { assert le(y,x) && le(z,y); }
  }
  lemma Head(le: (nat,nat)->bool, a: seq<nat>)
    requires |a| > 0 && Sorted(le,a)
    ensures Sorted(le,a[1..]) && Below(le,a[0],a[1..])
  {
    forall y: nat | y in a[1..]
      ensures Before(le,a[0],y)
    {
      var i :| 0 <= i < |a[1..]| && a[1..][i] == y;
      assert a[i+1] == y;
    }
  }
  lemma Prepend(le: (nat,nat)->bool, x: nat, a: seq<nat>)
    requires Sorted(le,a) && Below(le,x,a)
    ensures Sorted(le,[x]+a)
  {
    forall i,j | 0 <= i < j < |[x]+a|
      ensures Before(le,([x]+a)[i],([x]+a)[j])
    {
      if i > 0 { assert ([x]+a)[i] == a[i-1]; }
      assert ([x]+a)[j] == a[j-1];
    }
  }
  lemma Permutation(le: (nat,nat)->bool, a: seq<nat>, b: seq<nat>)
    ensures multiset(Merge(le,a,b)) == multiset(a)+multiset(b)
    ensures |Merge(le,a,b)| == |a|+|b|
    decreases |a|+|b|
  {
    if |a| == 0 || |b| == 0 { return; }
    if le(a[0],b[0]) {
      Permutation(le,a[1..],b);
      assert a == [a[0]]+a[1..];
    } else {
      Permutation(le,a,b[1..]);
      assert b == [b[0]]+b[1..];
    }
  }
  lemma Ordered(n: nat, le: (nat,nat)->bool, a: seq<nat>, b: seq<nat>)
    requires Order(n,le) && Well(n,a) && Well(n,b)
    requires Sorted(le,a) && Sorted(le,b) && Separated(a,b)
    ensures Sorted(le,Merge(le,a,b)) && Well(n,Merge(le,a,b))
    ensures multiset(Merge(le,a,b)) == multiset(a)+multiset(b)
    ensures |Merge(le,a,b)| == |a|+|b|
    decreases |a|+|b|
  {
    Permutation(le,a,b);
    if |a| == 0 || |b| == 0 { return; }
    assert a == [a[0]]+a[1..] && b == [b[0]]+b[1..];
    assert a[0] in a && b[0] in b;
    assert a[0] < n && b[0] < n && a[0] < b[0];
    Head(le,a); Head(le,b); Tails(n,a,b);
    if le(a[0],b[0]) {
      Ordered(n,le,a[1..],b);
      var rest := Merge(le,a[1..],b);
      assert Before(le,a[0],b[0]);
      forall x: nat | x in rest
        ensures Before(le,a[0],x)
      {
        UnionMember(rest,a[1..],b,x);
        if x !in a[1..] {
          assert x in b;
          if x != b[0] {
            assert x in b[1..];
            Transitive(n,le,a[0],b[0],x);
          }
        }
      }
      Prepend(le,a[0],rest);
    } else {
      Ordered(n,le,a,b[1..]);
      var rest := Merge(le,a,b[1..]);
      assert Before(le,b[0],a[0]);
      forall x: nat | x in rest
        ensures Before(le,b[0],x)
      {
        UnionMember(rest,a,b[1..],x);
        if x !in b[1..] {
          assert x in a;
          if x != a[0] {
            assert x in a[1..];
            Transitive(n,le,b[0],a[0],x);
          }
        }
      }
      Prepend(le,b[0],rest);
    }
  }
}

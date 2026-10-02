// SPDX-License-Identifier: MIT
module CollectionsSortModel {
  // IDs denote original occurrences, not just values; order may identify ties.
  ghost predicate Order(n: nat, le: (nat,nat)->bool) {
    (forall x: nat :: x < n ==> le(x,x)) &&
    (forall x: nat,y: nat :: x < n && y < n ==> le(x,y) || le(y,x)) &&
    (forall x: nat,y: nat,z: nat :: x < n && y < n && z < n && le(x,y) && le(y,z) ==> le(x,z))
  }
  predicate Before(le: (nat,nat)->bool, x: nat, y: nat) {
    le(x,y) && (le(y,x) ==> x <= y)
  }
  predicate Well(n: nat, a: seq<nat>) { forall x: nat :: x in a ==> x < n }
  predicate Sorted(le: (nat,nat)->bool, a: seq<nat>) {
    forall i,j :: 0 <= i < j < |a| ==> Before(le,a[i],a[j])
  }
  predicate Below(le: (nat,nat)->bool, x: nat, a: seq<nat>) {
    forall y: nat :: y in a ==> Before(le,x,y)
  }
  predicate Separated(a: seq<nat>, b: seq<nat>) {
    forall x: nat,y: nat :: x in a && y in b ==> x < y
  }
  function Merge(le: (nat,nat)->bool, a: seq<nat>, b: seq<nat>): seq<nat>
    decreases |a|+|b|
  {
    if |a| == 0 then b else if |b| == 0 then a else
    if le(a[0],b[0]) then [a[0]]+Merge(le,a[1..],b)
    else [b[0]]+Merge(le,a,b[1..])
  }
  function Range(start: nat, size: nat): seq<nat> { seq(size,i requires 0 <= i < size => start+i) }
  function Min(a: nat,b: nat): nat { if a < b then a else b }
  // Each block still contains exactly its original occurrence IDs.
  ghost opaque predicate Runs(n: nat, le: (nat,nat)->bool, a: seq<nat>, width: nat)
    requires width > 0
  {
    |a| == n && forall block: nat :: block*width < n ==>
                                       var start := block*width;
                                       var end := Min(start+width,n);
                                       multiset(a[start..end]) == multiset(Range(start,end-start)) && Sorted(le,a[start..end])
  }
}

// SPDX-License-Identifier: MIT
include "Ranges.dfy"
module CollectionsSortConnection {
  import opened CollectionsSortModel
  import R = CollectionsSortRanges
  import MP = CollectionsSortMerge

  lemma Write(buffer: seq<nat>,start: nat,dest: nat,end: nat,value: nat)
    requires start <= dest < end <= |buffer|
    ensures buffer[dest := value][start..dest+1] == buffer[start..dest]+[value]
    ensures buffer[dest := value][..start] == buffer[..start]
    ensures buffer[dest := value][end..] == buffer[end..]
  {}
  ghost method MergeRange(le: (nat,nat)->bool,source: seq<nat>,initial: seq<nat>,start: nat,middle: nat,end: nat) returns (scratch: seq<nat>)
    requires |initial| == |source| && start <= middle <= end <= |source|
    ensures |scratch| == |source| && scratch[..start] == initial[..start] && scratch[end..] == initial[end..]
    ensures scratch[start..end] == Merge(le,source[start..middle],source[middle..end])
    ensures multiset(scratch[start..end]) == multiset(source[start..end])
  {
    scratch := initial;
    var a := start; var b := middle;
    var dest := start;
    while dest < end
      invariant start <= a <= middle <= b <= end
      invariant start <= dest <= end && (a-start)+(b-middle) == dest-start
      invariant |scratch| == |source| && scratch[..start] == initial[..start] && scratch[end..] == initial[end..]
      invariant scratch[start..dest]+Merge(le,source[a..middle],source[b..end]) == Merge(le,source[start..middle],source[middle..end])
      decreases end-dest
    {
      var takeA := b == end;
      if a < middle && b < end { takeA := le(source[a],source[b]); }
      if a == middle { takeA := false; }
      var prefix := scratch[start..dest];
      var value: nat;
      if takeA {
        assert a < middle;
        value := source[a];
        assert source[a..middle] == [source[a]]+source[a+1..middle];
        assert Merge(le,source[a..middle],source[b..end]) == [value]+Merge(le,source[a+1..middle],source[b..end]);
        a := a+1;
      } else {
        assert b < end;
        value := source[b];
        assert source[b..end] == [source[b]]+source[b+1..end];
        assert Merge(le,source[a..middle],source[b..end]) == [value]+Merge(le,source[a..middle],source[b+1..end]);
        b := b+1;
      }
      Write(scratch,start,dest,end,value);
      scratch := scratch[dest := value];
      dest := dest+1;
    }
    assert a == middle && b == end;
    MP.Permutation(le,source[start..middle],source[middle..end]);
    assert source[start..end] == source[start..middle]+source[middle..end];
  }

  lemma Prefix(a: seq<nat>,b: seq<nat>,limit: nat,lo: nat,hi: nat)
    requires |a| == |b| && lo <= hi <= limit <= |a| && a[..limit] == b[..limit]
    ensures a[lo..hi] == b[lo..hi]
  {
    assert a[lo..hi] == a[..limit][lo..hi];
    assert b[lo..hi] == b[..limit][lo..hi];
  }

  ghost method Pass(le: (nat,nat)->bool,source: seq<nat>,initial: seq<nat>,width: nat) returns (scratch: seq<nat>)
    requires width > 0 && |initial| == |source|
    ensures |scratch| == |source| && multiset(scratch) == multiset(source)
    ensures Order(|source|,le) && Runs(|source|,le,source,width) ==> Runs(|source|,le,scratch,2*width)
  {
    var n := |source|;
    scratch := initial;
    var start: nat := 0; var block: nat := 0;
    while start < n
      invariant start == block*(2*width) && |scratch| == n
      invariant multiset(scratch[..Min(start,n)]) == multiset(source[..Min(start,n)])
      invariant Order(n,le) && Runs(n,le,source,width) ==>
                  (forall j: nat :: j < block && j*(2*width) < n ==>
                                      var lo := j*(2*width); var hi := Min(lo+2*width,n);
                                                             Sorted(le,scratch[lo..hi]) && multiset(scratch[lo..hi]) == multiset(Range(lo,hi-lo)))
      decreases n-start
    {
      var middle := Min(start+width,n); var end := Min(start+2*width,n);
      var previous := scratch;
      scratch := MergeRange(le,source,scratch,start,middle,end);
      assert scratch[..end] == scratch[..start]+scratch[start..end];
      assert source[..end] == source[..start]+source[start..end];
      if Order(n,le) && Runs(n,le,source,width) {
        R.Block(n,le,source,width,block);
        forall j: nat | j < block && j*(2*width) < n
          ensures var lo := j*(2*width); var hi := Min(lo+2*width,n); scratch[lo..hi] == previous[lo..hi]
        {
          R.Scale(j+1,block,2*width);
          var lo := j*(2*width); var hi := Min(lo+2*width,n);
          assert lo+2*width == (j+1)*(2*width);
          assert hi <= start;
          Prefix(scratch,previous,start,lo,hi);
        }

      }
      start := start+2*width; block := block+1;
    }
    assert Min(start,n) == n && scratch[..n] == scratch && source[..n] == source;
    if Order(n,le) && Runs(n,le,source,width) {
      reveal Runs();
      forall j: nat | j*(2*width) < n
        ensures var lo := j*(2*width); var hi := Min(lo+2*width,n);
                                       Sorted(le,scratch[lo..hi]) && multiset(scratch[lo..hi]) == multiset(Range(lo,hi-lo))
      {
        if j >= block { R.Scale(block,j,2*width); assert false; }
      }
    }
  }
  ghost method Sort(n: nat,le: (nat,nat)->bool) returns (out: seq<nat>)
    ensures |out| == n && multiset(out) == multiset(Range(0,n))
    ensures Order(n,le) ==> Sorted(le,out)
    ensures Well(n,out)
    ensures forall i :: 0 <= i < |out| ==> out[i] < n
    ensures forall i,j :: 0 <= i < j < |out| ==> out[i] != out[j]
    ensures Order(n,le) ==> (forall i,j :: 0 <= i < j < |out| ==> le(out[i],out[j]) && (le(out[j],out[i]) ==> out[i] < out[j]))
  {
    out := Range(0,n);
    var scratch: seq<nat> := seq(n,i => 0);
    var width: nat := 1;
    R.Initial(n,le);
    while width < n
      invariant width > 0 && |out| == n && |scratch| == n
      invariant multiset(out) == multiset(Range(0,n))
      invariant Order(n,le) ==> Runs(n,le,out,width)
      decreases n-width
    {
      var previous := out;
      out := Pass(le,out,scratch,width);
      scratch := previous;
      width := width*2;
    }
    if n > 0 && Order(n,le) {
      assert Sorted(le,out) by { reveal Runs(); assert 0*width < n && Min(0+width,n) == n; }
    }
    R.Verdict(n,le,out);
  }
  function KeyOrder(keys: seq<nat>,a: nat,b: nat): bool {
    a < |keys| && b < |keys| && keys[a] <= keys[b]
  }
  ghost method SortKeys(keys: seq<nat>) returns (out: seq<nat>)
    ensures |out| == |keys| && multiset(out) == multiset(Range(0,|keys|)) && Well(|keys|,out)
    ensures forall i :: 0 <= i < |out| ==> out[i] < |keys|
    ensures forall i,j :: 0 <= i < j < |out| ==> keys[out[i]] <= keys[out[j]] && (keys[out[i]] == keys[out[j]] ==> out[i] < out[j])
  {
    var le := (a: nat,b: nat) => KeyOrder(keys,a,b);
    assert Order(|keys|,le);
    out := Sort(|keys|,le);
  }
  lemma UntrustedComparator()
    ensures Merge((a: nat,b: nat) => false,[0],[1]) == [1,0]
    ensures !Order(2,(a: nat,b: nat) => false)
  {}
}

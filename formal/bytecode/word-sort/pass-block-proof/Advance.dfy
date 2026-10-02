// SPDX-License-Identifier: MIT
include "../../../collections/sort-core/Connection.dfy"
module BytecodeSortPassBlocks {
  import S = CollectionsSortModel
  import R = CollectionsSortRanges
  import C = CollectionsSortConnection
  lemma Advance(previous: seq<nat>, scratch: seq<nat>, n: nat, width: nat, start: nat, end: nat, block: nat, le: (nat,nat)->bool)
    requires |previous| == |scratch| == n && 0 < width
    requires start == block*(2*width) && start < n && end == S.Min(start+2*width,n)
    requires scratch[..start] == previous[..start]
    requires S.Sorted(le,scratch[start..end]) && multiset(scratch[start..end]) == multiset(S.Range(start,end-start))
    requires forall j: nat :: j < block && j*(2*width) < n ==>
                                var lo := j*(2*width); var hi := S.Min(lo+2*width,n);
                                                       S.Sorted(le,previous[lo..hi]) && multiset(previous[lo..hi]) == multiset(S.Range(lo,hi-lo))
    ensures forall j: nat :: j < block+1 && j*(2*width) < n ==>
                               var lo := j*(2*width); var hi := S.Min(lo+2*width,n);
                                                      S.Sorted(le,scratch[lo..hi]) && multiset(scratch[lo..hi]) == multiset(S.Range(lo,hi-lo))
  {
    forall j: nat | j < block+1 && j*(2*width) < n
      ensures var lo := j*(2*width); var hi := S.Min(lo+2*width,n);
                                     S.Sorted(le,scratch[lo..hi]) && multiset(scratch[lo..hi]) == multiset(S.Range(lo,hi-lo))
    {
      var lo := j*(2*width); var hi := S.Min(lo+2*width,n);
      if j < block {
        R.Scale(j+1,block,2*width);
        assert lo+2*width == (j+1)*(2*width);
        assert hi <= start;
        C.Prefix(scratch,previous,start,lo,hi);
      } else {
        assert j == block && lo == start && hi == end;
      }
    }
  }
}

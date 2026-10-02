// SPDX-License-Identifier: MIT
// Transfer the checked model block theorem to an exact physical merge slice.
include "../../../collections/sort-core/Ranges.dfy"
module BytecodeSortMergedBlock {
  import S = CollectionsSortModel
  import R = CollectionsSortRanges
  lemma SortedBlock(n: nat,le: (nat,nat)->bool,source: seq<nat>,merged: seq<nat>,width: nat,start: nat,middle: nat,end: nat,block: nat)
    requires |source| == n && 0 < width && start < n
    requires start == block*(2*width) && middle == S.Min(start+width,n) && end == S.Min(start+2*width,n)
    requires S.Order(n,le) && S.Runs(n,le,source,width)
    requires merged == S.Merge(le,source[start..middle],source[middle..end])
    ensures S.Sorted(le,merged) && multiset(merged) == multiset(S.Range(start,end-start))
  {
    R.Block(n,le,source,width,block);
  }
}

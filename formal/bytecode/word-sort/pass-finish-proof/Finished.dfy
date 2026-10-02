// SPDX-License-Identifier: MIT
// Factor the exact final run invariant, without weakening the pass contract.
include "../../../collections/sort-core/Ranges.dfy"
module BytecodeSortFinishedPass {
  import S = CollectionsSortModel
  import R = CollectionsSortRanges
  lemma Finished(n: nat, le: (nat,nat)->bool, scratch: seq<nat>, width: nat, start: nat, blocks: nat)
    requires |scratch| == n && 0 < width && n <= start && start == blocks*(2*width)
    requires forall j: nat :: j < blocks && j*(2*width) < n ==>
                                var lo := j*(2*width); var hi := S.Min(lo+2*width,n);
                                                       S.Sorted(le,scratch[lo..hi]) && multiset(scratch[lo..hi]) == multiset(S.Range(lo,hi-lo))
    ensures S.Runs(n,le,scratch,2*width)
  {
    reveal S.Runs();
    forall j: nat | j*(2*width) < n
      ensures var lo := j*(2*width); var hi := S.Min(lo+2*width,n);
                                     S.Sorted(le,scratch[lo..hi]) && multiset(scratch[lo..hi]) == multiset(S.Range(lo,hi-lo))
    {
      if blocks <= j {
        R.Scale(blocks,j,2*width);
        assert n <= j*(2*width);
        assert false;
      }
      assert j < blocks;
    }
  }
}

// SPDX-License-Identifier: MIT
// Model-independent prefix sums for signed carrier sequences with explicit nonnegative/positive premises.
module SharedFoundationSequenceTotals {
  function Sum(values: seq<int>, count: nat): int
    requires count <= |values|
    decreases count
  { if count == 0 then 0 else Sum(values,count-1)+values[count-1] }
  lemma Step(values: seq<int>, count: nat)
    requires count < |values|
    ensures Sum(values,count+1) == Sum(values,count)+values[count]
  {}
  lemma Nonnegative(values: seq<int>, count: nat)
    requires count <= |values|
    requires forall i :: 0 <= i < |values| ==> values[i] >= 0
    ensures Sum(values,count) >= 0
    decreases count
  { if count > 0 { Nonnegative(values,count-1); } }
  lemma Monotone(values: seq<int>, left: nat, right: nat)
    requires left <= right <= |values|
    requires forall i :: 0 <= i < |values| ==> values[i] >= 0
    ensures Sum(values,left) <= Sum(values,right)
    decreases right-left
  {
    if left < right {
      Monotone(values,left,right-1);
      Step(values,right-1);
    }
  }
  lemma PositiveLowerBound(values: seq<int>, count: nat)
    requires count <= |values|
    requires forall i :: 0 <= i < |values| ==> values[i] >= 1
    ensures Sum(values,count) >= count
    decreases count
  { if count > 0 { PositiveLowerBound(values,count-1); } }
}

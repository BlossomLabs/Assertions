// SPDX-License-Identifier: MIT
// Independent tuple semantics: dynamic iff any field is dynamic; static footprint is the sum.
module AssertionsNavigationTupleSpec {
  datatype Field = Field(end: nat,dynamic: bool,words: nat)
  function Sum(fields: seq<Field>,count: nat): nat
    requires count <= |fields|
    decreases count
  { if count == 0 then 0 else Sum(fields,count-1)+fields[count-1].words }
  function Dynamic(fields: seq<Field>,count: nat): bool
    requires count <= |fields|
    decreases count
  { count > 0 && (Dynamic(fields,count-1) || fields[count-1].dynamic) }
  function Footprint(fields: seq<Field>): nat
  { if Dynamic(fields,|fields|) then 1 else Sum(fields,|fields|) }
  predicate Positive(fields: seq<Field>)
  { forall i :: 0 <= i < |fields| ==> fields[i].words >= 1 && (fields[i].dynamic ==> fields[i].words == 1) }
  lemma PositiveSum(fields: seq<Field>,count: nat)
    requires Positive(fields) && count <= |fields|
    ensures Sum(fields,count) >= count
    decreases count
  { if count > 0 { PositiveSum(fields,count-1); } }
  lemma SumMonotone(fields: seq<Field>,left: nat,right: nat)
    requires left <= right <= |fields|
    ensures Sum(fields,left) <= Sum(fields,right)
    decreases right-left
  { if left < right { SumMonotone(fields,left,right-1); } }
  lemma Step(fields: seq<Field>,count: nat)
    requires count < |fields|
    ensures Sum(fields,count+1) == Sum(fields,count)+fields[count].words
    ensures Dynamic(fields,count+1) == (Dynamic(fields,count) || fields[count].dynamic)
  {}
  lemma Complete(fields: seq<Field>)
    requires |fields| > 0 && Positive(fields)
    ensures Footprint(fields) >= 1
    ensures Dynamic(fields,|fields|) ==> Footprint(fields) == 1
    ensures !Dynamic(fields,|fields|) ==> Footprint(fields) == Sum(fields,|fields|)
  { PositiveSum(fields,|fields|); }
}

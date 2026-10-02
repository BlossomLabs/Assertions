// SPDX-License-Identifier: MIT
// Independent flat OR semantics: complete structural check precedes short-circuiting.
include "../../Spec.dfy"
module AssertionsConstraintOrSpec {
  import J = AssertionsConstraintSpec
  import S = BytecodeScanMachine
  type Word = S.Word
  datatype Alternative = Leaf(kind: Word, length: Word, lower: Word, upper: Word)
  datatype Result = InvalidOr | Evaluated(verdict: J.Verdict)
  predicate Legal(alternatives: seq<Alternative>) {
    forall i {:trigger alternatives[i]} :: 0 <= i < |alternatives| ==> alternatives[i].kind <= 8 && alternatives[i].kind != 6
  }
  function LeafVerdict(actual: Word, alternative: Alternative): J.Verdict
    requires alternative.kind <= 8 && alternative.kind != 6
  { J.Judge(alternative.kind,alternative.length,actual,alternative.lower,alternative.upper) }
  function Evaluate(actual: Word, alternatives: seq<Alternative>): J.Verdict
    requires Legal(alternatives)
    decreases |alternatives|
  {
    if |alternatives| == 0 then J.Fails
    else var verdict := LeafVerdict(actual,alternatives[0]);
         if verdict == J.Fails then Evaluate(actual,alternatives[1..]) else verdict
  }
  function Judge(actual: Word, alternatives: seq<Alternative>): Result
    requires forall i {:trigger alternatives[i]} :: 0 <= i < |alternatives| ==> alternatives[i].kind <= 8
  {
    if |alternatives| == 0 || !Legal(alternatives) then InvalidOr
    else Evaluated(Evaluate(actual,alternatives))
  }
  lemma LegalSlice(alternatives: seq<Alternative>, begin: nat, end: nat)
    requires Legal(alternatives) && begin <= end <= |alternatives|
    ensures Legal(alternatives[begin..end])
  {
    forall i {:trigger alternatives[begin..end][i]} | 0 <= i < |alternatives[begin..end]|
      ensures alternatives[begin..end][i].kind <= 8 && alternatives[begin..end][i].kind != 6
    { assert alternatives[begin..end][i] == alternatives[begin+i]; }
  }
  lemma AllFalse(actual: Word, alternatives: seq<Alternative>)
    requires Legal(alternatives)
    requires forall i {:trigger alternatives[i]} :: 0 <= i < |alternatives| ==> LeafVerdict(actual,alternatives[i]) == J.Fails
    ensures Evaluate(actual,alternatives) == J.Fails
    decreases |alternatives|
  {
    if |alternatives| > 0 {
      LegalSlice(alternatives,1,|alternatives|);
      AllFalse(actual,alternatives[1..]);
    }
  }
  lemma FirstTerminal(actual: Word, alternatives: seq<Alternative>, index: nat)
    requires Legal(alternatives) && index < |alternatives|
    requires forall i {:trigger alternatives[i]} :: 0 <= i < index ==> LeafVerdict(actual,alternatives[i]) == J.Fails
    requires LeafVerdict(actual,alternatives[index]) != J.Fails
    ensures Evaluate(actual,alternatives) == LeafVerdict(actual,alternatives[index])
    decreases index
  {
    if index > 0 {
      LegalSlice(alternatives,1,|alternatives|);
      assert alternatives[1..][index-1] == alternatives[index];
      forall i {:trigger alternatives[1..][i]} | 0 <= i < index-1
        ensures LeafVerdict(actual,alternatives[1..][i]) == J.Fails
      { assert alternatives[1..][i] == alternatives[i+1]; }
      FirstTerminal(actual,alternatives[1..],index-1);
    }
  }
  lemma StructuralPriority(actual: Word, alternatives: seq<Alternative>, nested: nat)
    requires nested < |alternatives| && alternatives[nested].kind == 6
    requires forall i {:trigger alternatives[i]} :: 0 <= i < |alternatives| ==> alternatives[i].kind <= 8
    ensures Judge(actual,alternatives) == InvalidOr
  {}
}

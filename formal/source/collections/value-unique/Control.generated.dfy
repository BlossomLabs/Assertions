// SPDX-License-Identifier: MIT
// Generated from the complete public uniqueValues compiler body; edit the template.
include "Spec.dfy"
module CollectionsValueUniqueControl {
  import opened AbiFrames
  predicate Loop(i: nat,length: nat) { (i < length) }
  function Validate(i: nat): int { i }
  function Start(ordered: bool,count: nat): int { (if (ordered && (count != 0)) then (count - 1) else 0) }
  predicate CompareLoop(j: nat,count: nat) { (j < count) }
  function First(j: nat): int { j }
  function Second(i: nat): int { i }
  predicate Binary() { true }
  function Index(i: nat): int { i }
  function Other(i: nat,j: nat): int { j }
  predicate Keep(duplicate: bool) { !(duplicate) }
  function Write(i: nat): int { i }
  function Shrink(count: nat): int { count }
  function uniqueValuesSelector(): seq<Byte> { [28, 105, 72, 204] }
}

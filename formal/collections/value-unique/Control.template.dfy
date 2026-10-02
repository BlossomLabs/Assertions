// SPDX-License-Identifier: MIT
// Generated from the complete public uniqueValues compiler body; edit the template.
include "Spec.dfy"
module CollectionsValueUniqueControl {
  import opened AbiFrames
  predicate Loop(i: nat,length: nat) { $LOOP$ }
  function Validate(i: nat): int { $VALIDATE$ }
  function Start(ordered: bool,count: nat): int { $START$ }
  predicate CompareLoop(j: nat,count: nat) { $COMPARE_LOOP$ }
  function First(j: nat): int { $FIRST$ }
  function Second(i: nat): int { $SECOND$ }
  predicate Binary() { $BINARY$ }
  function Index(i: nat): int { $INDEX$ }
  function Other(i: nat,j: nat): int { $OTHER$ }
  predicate Keep(duplicate: bool) { $KEEP$ }
  function Write(i: nat): int { $WRITE$ }
  function Shrink(count: nat): int { $SHRINK$ }
  function uniqueValuesSelector(): seq<Byte> { $uniqueValuesSelector$ }
}

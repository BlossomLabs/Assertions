// SPDX-License-Identifier: MIT
// Generated from complete value search compiler bodies; edit this template only.
include "Spec.dfy"
module CollectionsValueSearchControl {
  import opened AbiFrames
  import S = CollectionsValueSearchSpec
  predicate IndexLoop(i: nat,length: nat) { $INDEX_LOOP$ }
  function IndexValidate(i: nat): int { $INDEX_VALIDATE$ }
  predicate IndexMatch(truth: bool) { $INDEX_MATCH$ }
  function IndexResult(i: nat): int { $INDEX_RESULT$ }
  function IndexMissing(): int { $INDEX_MISSING$ }
  predicate FindLoop(i: nat,length: nat) { $FIND_LOOP$ }
  function FindValidate(i: nat): int { $FIND_VALIDATE$ }
  predicate FindMatch(truth: bool,wanted: bool) { $FIND_MATCH$ }
  function FindResult(i: nat): int { $FIND_RESULT$ }
  function FindMissing(): int { $FIND_MISSING$ }
  predicate AnyWanted() { $ANY_WANTED$ }
  predicate AllWanted() { $ALL_WANTED$ }
  predicate FindWanted() { $FIND_WANTED$ }
  predicate AnyResult(index: nat) { $ANY_RESULT$ }
  predicate AllResult(index: nat) { $ALL_RESULT$ }
  function indexOfValuesSelector(): seq<Byte> { $indexOfValuesSelector$ }
  function anyValuesSelector(): seq<Byte> { $anyValuesSelector$ }
  function allValuesSelector(): seq<Byte> { $allValuesSelector$ }
  function findValuesSelector(): seq<Byte> { $findValuesSelector$ }
}

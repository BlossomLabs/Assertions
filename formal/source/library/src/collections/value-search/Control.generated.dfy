// SPDX-License-Identifier: MIT
// Generated from complete value search compiler bodies; edit this template only.
include "Spec.dfy"
module CollectionsValueSearchControl {
  import opened AbiFrames
  import S = CollectionsValueSearchSpec
  predicate IndexLoop(i: nat,length: nat) { (i < length) }
  function IndexValidate(i: nat): int { i }
  predicate IndexMatch(truth: bool) { truth }
  function IndexResult(i: nat): int { i }
  function IndexMissing(): int { S.Missing() }
  predicate FindLoop(i: nat,length: nat) { (i < length) }
  function FindValidate(i: nat): int { i }
  predicate FindMatch(truth: bool,wanted: bool) { (truth == wanted) }
  function FindResult(i: nat): int { i }
  function FindMissing(): int { S.Missing() }
  predicate AnyWanted() { true }
  predicate AllWanted() { false }
  predicate FindWanted() { true }
  predicate AnyResult(index: nat) { (index != S.Missing()) }
  predicate AllResult(index: nat) { (index == S.Missing()) }
  function indexOfValuesSelector(): seq<Byte> { [178, 231, 98, 49] }
  function anyValuesSelector(): seq<Byte> { [202, 104, 178, 130] }
  function allValuesSelector(): seq<Byte> { [18, 78, 172, 96] }
  function findValuesSelector(): seq<Byte> { [143, 209, 156, 111] }
}

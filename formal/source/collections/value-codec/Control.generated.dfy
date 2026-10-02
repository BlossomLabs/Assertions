// SPDX-License-Identifier: MIT
// Generated from complete wrapper and codec bodies; edit this template only.
include "Model.dfy"
module CollectionsValueCodecControl {
  function PackValidate(i: nat): int { i }
  predicate ArrayMode() { true }
  predicate FirstMismatch(first: nat) { (first != 32) }
  predicate TailMismatch(tail: nat,length: nat) { ((64 + tail) != length) }
}

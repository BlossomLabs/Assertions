// SPDX-License-Identifier: MIT
// Generated from complete wrapper and codec bodies; edit this template only.
include "Model.dfy"
module CollectionsValueCodecControl {
  function PackValidate(i: nat): int { $PACK_VALIDATE$ }
  predicate ArrayMode() { $ARRAY_MODE$ }
  predicate FirstMismatch(first: nat) { $FIRST_MISMATCH$ }
  predicate TailMismatch(tail: nat,length: nat) { $TAIL_MISMATCH$ }
}

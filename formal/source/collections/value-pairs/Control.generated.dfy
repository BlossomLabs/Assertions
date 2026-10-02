// SPDX-License-Identifier: MIT
// Generated from complete pairing compiler ASTs. Edit this template only.
include "Model.dfy"
module CollectionsValuePairsControl {
  import opened AbiFrames
  predicate LengthMismatch(left: nat,right: nat) { (left != right) }
  function ZipLeft(i: nat): int { i }
  function ZipRight(i: nat): int { i }
  function LeftSlot(): int { 0 }
  function RightSlot(): int { 1 }
  predicate ArrayMode() { false }
  predicate Envelope(a: bool,b: bool) { (a || b) }
  predicate LaneBad(lane: nat) { (lane > 1) }
  function Selected(lane: nat): int { lane }
  function UnzipLeft(): int { 0 }
  function UnzipRight(): int { 1 }
  function Head(aw: nat,bw: nat): int { ((aw + bw) * 32) }
  function Base(a: bool,b: bool): int { (if (a || b) then 32 else 0) }
  predicate EnvelopeWrong(first: nat) { (first != 32) }
  predicate Loop(i: nat) { (i < 2) }
  predicate OffsetWrong(offset: nat,tail: nat) { (offset != tail) }
  predicate NextBoundary(i: nat,b: bool) { ((i == 0) && b) }
  predicate BoundaryWrong(end: nat,tail: nat) { (end < tail) }
  function Span(end: nat,tail: nat): int { (end - tail) }
  predicate TailWrong(base: nat,tail: nat,length: nat) { ((base + tail) != length) }
  function LengthMismatchSelector(): seq<Byte> { [171, 139, 103, 198] }
  function InvalidLaneSelector(): seq<Byte> { [28, 19, 56, 3] }
}

// SPDX-License-Identifier: MIT
// Generated from complete pairing compiler ASTs. Edit this template only.
include "Model.dfy"
module CollectionsValuePairsControl {
  import opened AbiFrames
  predicate LengthMismatch(left: nat,right: nat) { $ZIP_LENGTH$ }
  function ZipLeft(i: nat): int { $ZIP_LEFT$ }
  function ZipRight(i: nat): int { $ZIP_RIGHT$ }
  function LeftSlot(): int { $LEFT_SLOT$ }
  function RightSlot(): int { $RIGHT_SLOT$ }
  predicate ArrayMode() { $ARRAY_MODE$ }
  predicate Envelope(a: bool,b: bool) { $ENVELOPE$ }
  predicate LaneBad(lane: nat) { $LANE_BAD$ }
  function Selected(lane: nat): int { $SELECTED$ }
  function UnzipLeft(): int { $UNZIP_LEFT$ }
  function UnzipRight(): int { $UNZIP_RIGHT$ }
  function Head(aw: nat,bw: nat): int { $HEAD$ }
  function Base(a: bool,b: bool): int { $BASE$ }
  predicate EnvelopeWrong(first: nat) { $ENVELOPE_WRONG$ }
  predicate Loop(i: nat) { $LOOP$ }
  predicate OffsetWrong(offset: nat,tail: nat) { $OFFSET_WRONG$ }
  predicate NextBoundary(i: nat,b: bool) { $NEXT_BOUNDARY$ }
  predicate BoundaryWrong(end: nat,tail: nat) { $BOUNDARY_WRONG$ }
  function Span(end: nat,tail: nat): int { $SPAN$ }
  predicate TailWrong(base: nat,tail: nat,length: nat) { $TAIL_WRONG$ }
  function LengthMismatchSelector(): seq<Byte> { $LengthMismatchSelector$ }
  function InvalidLaneSelector(): seq<Byte> { $InvalidLaneSelector$ }
}

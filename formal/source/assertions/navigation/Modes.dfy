// SPDX-License-Identifier: MIT
include "Traversal.dfy"

module NavigationModes {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened NavigationRuntime
  import opened NavigationCursorSpec

  datatype ReturnResult = BytesReturned(bytes: seq<Byte>) | Rejected(error: Error)

  // LEN intentionally reads before refusing dynamic tuples/fixed arrays.
  // It bounds the footprint, but does not validate narrow words or array tails.
  ghost function CursorLength(data: seq<Byte>, c: Cursor): NumberResult
    requires Admissible(c.syntax) && Uint(c.base) && Uint(|data|)
  {
    if !Dyn(c.syntax) then Failed(InvalidNavigation(c.typeStart)) else
    var read := WordAt(data,c.base);
    if read.Failed? then read else
    var available := |data|-c.base-32;
    if c.syntax.Fixed? || c.syntax.Group? then Failed(InvalidNavigation(c.typeStart)) else
    if c.syntax.Dynamic? then
      (Positive(c.syntax.element);
       if read.value > available/32/Width(c.syntax.element)
       then Failed(ReturnDataOutOfBounds(c.base/32,|data|)) else read)
    else if read.value > available-available%32 then Failed(ReturnDataOutOfBounds(c.base/32,|data|)) else read
  }

  // PAYLOAD refuses non-byte terminals before reading, and accepts an exact
  // unpadded byte span. It must not acquire LEN's rounded-footprint condition.
  ghost function CursorPayload(data: seq<Byte>, c: Cursor): ReturnResult
    requires Admissible(c.syntax) && Uint(c.base) && Uint(|data|)
  {
    if !Dyn(c.syntax) || !c.syntax.Name? then Rejected(InvalidNavigation(c.typeStart)) else
    var read := WordAt(data,c.base);
    if read.Failed? then Rejected(read.error) else
    if read.value > |data|-c.base-32 then Rejected(ReturnDataOutOfBounds(c.base/32,|data|)) else
    BytesReturned(data[c.base+32..c.base+32+read.value])
  }
}

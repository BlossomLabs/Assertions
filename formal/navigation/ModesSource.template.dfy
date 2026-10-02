// SPDX-License-Identifier: MIT
// Source-derived navigation terminal modes; Assertions.sol SHA-256: $HASH
include "Modes.dfy"
include "Traverse.generated.dfy"

module NavigationModeSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import AbiParserSource
  import opened AbiConnectionDescriptor
  import AbiConnectionSource
  import opened NavigationRuntime
  import opened NavigationKernels
  import opened NavigationCursorSpec
  import opened NavigationTraversal
  import opened NavigationModes

  ghost method LengthAt(t: seq<Byte>, data: seq<Byte>, c: Cursor) returns (r: NumberResult)
    requires Span(t,c) && Uint(c.base) && Uint(|data|) && Uint(|t|)
    ensures r == CursorLength(data,c)
    ensures r.Number? ==> Uint(r.value)
  {
    if !Dyn(c.syntax) { r := Failed(InvalidNavigation(c.typeStart)); return; }
    var pos,ts,te := c.base,c.typeStart,c.typeStart+|Render(c.syntax)|;
    var read := ReadWord(data,pos);
    if read.Failed? { r := read; return; }
    WordBounds(data,pos);
    var length := read.value;
    var available := |data|-pos-32;
    assert Uint(available);
    Dispatch(t,c);
    if t[te-1] == 93 {
      ArraySpan(t,ts,te,c.syntax);
      var found := AbiConnectionSource.SuffixStart(t,ts,te);
      var suffix := found.at;
      if suffix+1 != te-1 { r := Failed(InvalidNavigation(ts)); return; }
      Accept(t,ts,suffix,c.syntax.element);
      var parsed := AbiParserSource.TypeShape(t,ts,suffix);
      var elemWords := parsed.words;
      assert elemWords > 0;
      if $LENGTH_ARRAY_BOUND {
        r := Failed(ReturnDataOutOfBounds(pos/32,|data|)); return;
      }
    } else if t[ts] == 40 { r := Failed(InvalidNavigation(ts)); return; }
    else if $LENGTH_BYTES_BOUND {
      r := Failed(ReturnDataOutOfBounds(pos/32,|data|)); return;
    }
    r := NavigationRuntime.Number(length);
  }

  ghost method PayloadAt(t: seq<Byte>, data: seq<Byte>, c: Cursor) returns (r: ReturnResult)
    requires Span(t,c) && Uint(c.base) && Uint(|data|) && Uint(|t|)
    ensures r == CursorPayload(data,c)
  {
    if !Dyn(c.syntax) { r := Rejected(InvalidNavigation(c.typeStart)); return; }
    var pos,ts,te := c.base,c.typeStart,c.typeStart+|Render(c.syntax)|;
    Dispatch(t,c);
    if t[te-1] == 93 || t[ts] == 40 { r := Rejected(InvalidNavigation(ts)); return; }
    var read := ReadWord(data,pos);
    if read.Failed? { r := Rejected(read.error); return; }
    var length := read.value;
    if $PAYLOAD_BOUND { r := Rejected(ReturnDataOutOfBounds(pos/32,|data|)); return; }
    var start := pos+32;
    assert Uint(start) && Uint(start+length);
    r := BytesReturned(data[start..start+length]);
  }
}

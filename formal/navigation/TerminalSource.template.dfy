// SPDX-License-Identifier: MIT
// Source-derived static and bytes terminal validation; Assertions.sol SHA-256: $HASH
include "Terminals.dfy"
include "Traverse.generated.dfy"

module NavigationTerminalSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiTupleWords
  import opened AbiTupleSemantics
  import opened AbiDynamicSemantics
  import opened NavigationRuntime
  import opened NavigationCursorSpec
  import opened NavigationTraversal
  import opened NavigationModes
  import opened NavigationTerminals
  import NavigationKernels

  ghost method StaticAt(t: seq<Byte>, data: seq<Byte>, c: Cursor) returns (r: ReturnResult)
    requires NavigationTraversal.Span(t,c) && !Dyn(c.syntax) && Uint(c.base) && Uint(|t|) && Uint(|data|)
    ensures r == StaticValue(data,c)
  {
    var pos := c.base;
    var words := Width(c.syntax);
    if pos > |data| || words > (|data|-pos)/32 {
      r := ReturnResult.Rejected(ReturnDataOutOfBounds(pos/32,|data|)); return;
    }
    StaticRules(c.syntax);
    var checked := StaticCopies(t,c.typeStart,c.typeStart+|Render(c.syntax)|,data,pos,c.syntax,1);
    assert Repeat(Rules(c.syntax),1) == Rules(c.syntax);
    if checked.Invalid? { r := ReturnResult.Rejected(Error.InvalidValue(checked.offset)); return; }
    var size := words*32;
    assert Uint(size);
    r := BytesReturned(data[pos..pos+size]);
  }

  ghost method BytesExtent(data: seq<Byte>, pos: nat) returns (r: NumberResult)
    requires Uint(|data|) && Uint(pos)
    ensures r == BytesSize(data,pos)
  {
    var read := NavigationKernels.ReadWord(data,pos);
    if read.Failed? { r := read; return; }
    var len := read.value;
    if len > |data|-pos-32 { r := Failed(ReturnDataOutOfBounds(pos/32,|data|)); return; }
    assert Uint(len+31);
    var payloadBytes := $PAYLOAD_ROUND;
    RoundedExtent(len);
    assert Uint(payloadBytes);
    if payloadBytes > |data|-pos-32 { r := Failed(ReturnDataOutOfBounds(pos/32,|data|)); return; }
    var padding := payloadBytes-len;
    var dirty := false;
    if padding != 0 {
      assert Uint(pos+payloadBytes);
      var last := NavigationKernels.ReadWord(data,pos+payloadBytes);
      assert last.Number?;
      assert Uint((32-padding)*8);
      // Same 256-bit mask normalization as the source-connected ABI bytes
      // validator: low padding bytes are modulo 256^padding. The AST gate
      // retains the exact max >> ((32-padding)*8) Solidity expression.
      PaddingMask(data,pos,len,payloadBytes);
      dirty := last.value%Pow256(padding) != 0;
    }
    FirstDirtyCharacterization(data,pos+32+len,pos+32+payloadBytes);
    if dirty {
      var i := pos+32+len;
      var first := FirstDirty(data,pos+32+len,pos+32+payloadBytes);
      while true
        invariant pos+32+len <= i <= first < pos+32+payloadBytes <= |data|
        invariant ZeroRegion(data,pos+32+len,i)
        decreases first-i
      {
        assert Uint(i) && i < |data|;
        if data[i] != 0 {
          FirstDirtyAt(data,pos+32+len,pos+32+payloadBytes,i);
          r := Failed(Error.InvalidValue(i)); return;
        }
        assert Uint(i+1);
        i := i+1;
      }
    }
    if padding == 0 { assert ZeroRegion(data,pos+32+len,pos+32+payloadBytes); }
    assert Uint(32+payloadBytes);
    r := NavigationRuntime.Number(32+payloadBytes);
  }
}

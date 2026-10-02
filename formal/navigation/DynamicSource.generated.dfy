// SPDX-License-Identifier: MIT
// Navigation dynamic-terminal branches; Assertions.sol SHA-256: 8fa122e5e5750ca115c66898c22186e076eac9d95e7c91c228928a5b09ad273a
include "TerminalSource.generated.dfy"

module NavigationDynamicSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import AbiParserSource
  import opened AbiTupleWords
  import opened AbiTupleSemantics
  import opened AbiConnectionModel
  import opened AbiConnectionDescriptor
  import AbiConnectionSource
  import opened AbiDynamicSemantics
  import AbiDynamicSource
  import opened NavigationRuntime
  import opened NavigationCursorSpec
  import opened NavigationTraversal
  import opened NavigationTerminals
  import NavigationKernels
  import NavigationTerminalSource

  lemma ProductBound(n: nat, width: nat, available: nat)
    requires width > 0
    ensures (n <= available/width) == (n*width <= available)
  {
    assert available == available/width*width+available%width;
    if n <= available/width { assert n*width <= available/width*width; }
    else { assert n >= available/width+1; assert n*width >= (available/width+1)*width; }
  }

  lemma BytesSizeWalker(data: seq<Byte>, pos: nat)
    requires Uint(|data|) && Uint(pos)
    ensures BytesSize(data,pos).Number? == (pos <= |data| && WalkBytes(data[pos..]).Parsed?)
    ensures BytesSize(data,pos).Number? ==> BytesSize(data,pos).value == WalkBytes(data[pos..]).used
  { BodySpecMatchesWalker(data,pos); }

  function FromCodec(r: Outcome): NumberResult
  {
    match r
    case Ok(n) => NavigationRuntime.Number(n)
    case Invalid(p) => Failed(Error.InvalidValue(p))
    case Panic(code) => Failed(Error.Panic(code))
  }

  // Default ContextKind.Value preserves each codec error's exact byte offset;
  // no argument-index or callback-error wrapper is introduced here.
  ghost method CodecExtent(t: seq<Byte>, data: seq<Byte>, c: Cursor)
    returns (r: NumberResult, codec: Outcome)
    requires NavigationTraversal.Span(t,c) && Dyn(c.syntax) && Uint(c.base) && Uint(|t|) && Uint(|data|)
    ensures r == FromCodec(codec)
    ensures WellFormed(TypeOf(c.syntax))
    ensures codec.Panic? ==> codec.code == 17 && !CursorRoom(c.syntax,|data|)
    ensures !codec.Panic? ==> r.Number? == (c.base <= |data| && Walk(TypeOf(c.syntax),data[c.base..]).Parsed?)
    ensures r.Number? ==> r.value == Walk(TypeOf(c.syntax),data[c.base..]).used && c.base+r.value <= |data|
  {
    codec := AbiDynamicSource.FullBody(t,c.typeStart,c.typeStart+|Render(c.syntax)|,data,c.base,c.syntax);
    r := FromCodec(codec);
  }

  ghost method {:isolate_assertions} Extent(t: seq<Byte>, data: seq<Byte>, c: Cursor)
    returns (r: NumberResult)
    requires NavigationTraversal.Span(t,c) && Dyn(c.syntax) && Uint(c.base) && Uint(|t|) && Uint(|data|)
    ensures WellFormed(TypeOf(c.syntax))
    ensures r.Failed? && r.error.Panic? ==> r.error.code == 17 && !CursorRoom(c.syntax,|data|)
    ensures !(r.Failed? && r.error.Panic?) ==>
              r.Number? == (c.base <= |data| && Walk(TypeOf(c.syntax),data[c.base..]).Parsed?)
    ensures r.Number? ==> r.value == Walk(TypeOf(c.syntax),data[c.base..]).used && c.base+r.value <= |data|
  {
    var s := c.syntax;
    var pos,ts,te := c.base,c.typeStart,c.typeStart+|Render(s)|;
    ModelType(s); Dispatch(t,c);
    if t[te-1] == 93 {
      ArraySpan(t,ts,te,s);
      var found := AbiConnectionSource.SuffixStart(t,ts,te);
      var suffix := found.at;
      Accept(t,ts,suffix,s.element);
      var parsed := AbiParserSource.TypeShape(t,ts,suffix);
      var elemWords := parsed.words;
      if parsed.dynamic {
        var codec: Outcome;
        r,codec := CodecExtent(t,data,c); return;
      }
      assert s.Dynamic?;
      var read := NavigationKernels.ReadWord(data,pos);
      if read.Failed? { r := read; return; }
      WordBounds(data,pos);
      var len := read.value;
      assert Uint(len);
      ModelType(s.element); Positive(s.element);
      var stride := elemWords*32;
      if !Uint(stride) { r := Failed(Error.Panic(17)); return; }
      ProductBound(len,stride,|data|-pos-32);
      ArrayView(s,data,pos,len);
      ProductAssoc(len,elemWords,32);
      ProductAssoc(32,elemWords,len);
      assert len*stride == 32*Width(s.element)*len;
      if len > (|data|-pos-32)/stride {
        r := Failed(ReturnDataOutOfBounds(pos/32,|data|)); return;
      }
      assert Uint(len*elemWords) && Uint(len*elemWords*32) && Uint(32+len*elemWords*32);
      var checked := StaticCopies(t,ts,suffix,data,pos+32,s.element,len);
      if checked.Panic? { r := FromCodec(checked); return; }
      StaticFrame(s.element,len,TypeOf(s),data,pos+32);
      if checked.Invalid? { r := FromCodec(checked); return; }
      r := NavigationRuntime.Number(32+len*elemWords*32); return;
    }
    if t[ts] == 40 {
      var codec: Outcome;
      r,codec := CodecExtent(t,data,c); return;
    }
    r := NavigationTerminalSource.BytesExtent(data,pos);
    BytesSizeWalker(data,pos);
  }
}

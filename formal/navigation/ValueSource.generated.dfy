// SPDX-License-Identifier: MIT
// Navigation value-return dispatch; Assertions.sol SHA-256: 8fa122e5e5750ca115c66898c22186e076eac9d95e7c91c228928a5b09ad273a
include "DynamicSource.generated.dfy"
include "ReturnMemory.generated.dfy"
include "Layout.dfy"

module NavigationValueSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiTupleWords
  import opened AbiTupleSemantics
  import opened AbiConnectionModel
  import opened AbiConnectionStatic
  import opened AbiDynamicSemantics
  import opened NavigationRuntime
  import opened NavigationCursorSpec
  import opened NavigationModes
  import opened NavigationTraversal
  import opened NavigationTerminals
  import NavigationTerminalSource
  import NavigationDynamicSource
  import NavigationReturnSource
  import NavigationLayout

  lemma StaticMinimum(s: Descriptor, data: seq<Byte>)
    requires Good(s) && !Dyn(s)
    ensures WellFormed(TypeOf(s))
    ensures Walk(TypeOf(s),data).Parsed? ==> Walk(TypeOf(s),data).used == 32*Width(s)
  {
    ModelType(s);
    if Walk(TypeOf(s),data).Parsed? {
      WalkSound(TypeOf(s),data);
      var value := Walk(TypeOf(s),data).value;
      HeadFootprint(TypeOf(s),value);
    }
  }

  ghost method {:isolate_assertions} ValueAt(t: seq<Byte>, data: seq<Byte>, c: Cursor)
    returns (r: ReturnResult)
    requires NavigationTraversal.Span(t,c) && Uint(c.base) && Uint(|t|) && Uint(|data|+32)
    ensures WellFormed(TypeOf(c.syntax))
    ensures !Dyn(c.syntax) ==> r == StaticValue(data,c)
    ensures r.Rejected? && r.error.Panic? ==> r.error.code == 17 && !CursorRoom(c.syntax,|data|)
    ensures !(r.Rejected? && r.error.Panic?) ==>
              r.BytesReturned? == (c.base <= |data| && Walk(TypeOf(c.syntax),data[c.base..]).Parsed?)
    ensures r.BytesReturned? ==> r.bytes == (if Dyn(c.syntax) then Word(32) else [])+
                                            data[c.base..c.base+Walk(TypeOf(c.syntax),data[c.base..]).used]
  {
    var s := c.syntax;
    var pos := c.base;
    ModelType(s);
    if !Dyn(s) {
      r := NavigationTerminalSource.StaticAt(t,data,c);
      if pos > |data| { return; }
      StaticMinimum(s,data[pos..]);
      if Width(s) > (|data|-pos)/32 { return; }
      StaticWalk(s,data[pos..]);
      ScanSlice(Rules(s),data,pos,0);
      return;
    }
    var size := NavigationDynamicSource.Extent(t,data,c);
    if size.Failed? { r := ReturnResult.Rejected(size.error); return; }
    WalkSound(TypeOf(s),data[pos..]);
    var selected := Walk(TypeOf(s),data[pos..]).value;
    BodiesAreFrames(TypeOf(s),selected);
    assert size.value%32 == 0;
    var out := NavigationReturnSource.DynamicReturn(data,pos,size.value,Zeros(32+size.value));
    r := BytesReturned(out);
  }

  ghost method {:isolate_assertions} CanonicalValue(t: seq<Byte>, data: seq<Byte>, c: Cursor, v: Value)
    returns (r: ReturnResult)
    requires NavigationTraversal.Span(t,c) && Uint(c.base) && Uint(|t|) && Uint(|data|+32)
    requires CursorRoom(c.syntax,|data|)
    requires WellTyped(TypeOf(c.syntax),v) && Fits(TypeOf(c.syntax),v)
    requires NavigationLayout.Located(TypeOf(c.syntax),v,data,c.base)
    ensures r == BytesReturned(Encode(TypeOf(c.syntax),v))
  {
    var s := c.syntax;
    ModelType(s);
    var body := Body(TypeOf(s),v);
    assert data[c.base..] == body+data[c.base+|body|..];
    WalkComplete(TypeOf(s),v,data[c.base+|body|..]);
    r := ValueAt(t,data,c);
    assert data[c.base..c.base+|body|] == body;
  }
}

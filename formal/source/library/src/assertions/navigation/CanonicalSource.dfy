// SPDX-License-Identifier: MIT
include "Canonical.dfy"
include "Traverse.generated.dfy"
include "ModesSource.generated.dfy"

module NavigationCanonicalSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import opened AbiConnectionModel
  import AbiTupleWords
  import opened NavigationModel
  import opened NavigationLayout
  import opened NavigationRuntime
  import opened NavigationCursorSpec
  import opened NavigationTraversal
  import opened NavigationModes
  import opened NavigationCanonical
  import NavigationTraverseSource

  lemma DividedHead(count: nat, words: nat, available: nat)
    requires words > 0 && count*words*32 <= available
    ensures count <= available/32/words
  {
    assert count*words <= available/32;
    var q := available/32;
    if count > q/words {
      assert count >= q/words+1;
      assert count*words >= (q/words+1)*words;
      assert q == q/words*words+q%words;
      assert q%words < words;
      assert false;
    }
  }

  ghost method {:isolate_assertions} CanonicalNavigate(s: Descriptor, v: Value, path: seq<int>)
    returns (r: CursorResult)
    requires Admissible(s) && s.Group? && WellTyped(TypeOf(s),v) && Fits(TypeOf(s),v)
    requires Uint(|Render(s)|) && Uint(|Body(TypeOf(s),v)|) && Uint(|path|) && |path| > 0
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    requires Select(TypeOf(s),v,path).Selected?
    ensures r == Navigation(Render(s),Body(TypeOf(s),v),path)
    ensures r.Moved? && Span(Render(s),r.cursor) && Uint(r.cursor.base)
    ensures TypeOf(r.cursor.syntax) == Select(TypeOf(s),v,path).selectedType
    ensures WellTyped(TypeOf(r.cursor.syntax),Select(TypeOf(s),v,path).selectedValue)
    ensures NavigationLayout.Located(TypeOf(r.cursor.syntax),Select(TypeOf(s),v,path).selectedValue,Body(TypeOf(s),v),r.cursor.base)
    ensures Fits(TypeOf(r.cursor.syntax),Select(TypeOf(s),v,path).selectedValue)
  {
    var t := Render(s);
    var data := Body(TypeOf(s),v);
    assert data[0..|data|] == data;
    Accept(t,0,|t|,s);
    PathCanonical(data,Cursor(s,0,0),v,path);
    r := NavigationTraverseSource.Navigate(t,data,path);
  }

  lemma {:isolate_assertions} LengthCanonical(data: seq<Byte>, c: Cursor, v: Value)
    requires Admissible(c.syntax) && Uint(c.base) && Uint(|data|)
    requires WellTyped(TypeOf(c.syntax),v) && Fits(TypeOf(c.syntax),v)
    requires NavigationLayout.Located(TypeOf(c.syntax),v,data,c.base)
    requires HasLength(TypeOf(c.syntax))
    ensures CursorLength(data,c) == NavigationRuntime.Number(Length(TypeOf(c.syntax),v))
  {
    var s := c.syntax;
    var t := TypeOf(s);
    ModelType(s); LengthWord(t,v,data,c.base);
    var available := |data|-c.base-32;
    if s.Dynamic? {
      ModelType(s.element); Positive(s.element);
      BodiesAreFrames(t,v); ArrayHead(t,v,|v.values|);
      Sizes(Parts(t,v),HeadSize(Parts(t,v)));
      assert Parts(t,v)[..|v.values|] == Parts(t,v);
      assert HeadSize(Parts(t,v)) == 32*|v.values|*HeadWords(t.element);
      assert HeadWords(t.element) == Width(s.element);
      assert |Body(t,v)| == 32+HeadSize(Parts(t,v))+TailSize(Parts(t,v));
      AbiTupleWords.ProductAssoc(|v.values|,Width(s.element),32);
      AbiTupleWords.ProductAssoc(32,|v.values|,Width(s.element));
      assert |v.values|*Width(s.element)*32 == HeadSize(Parts(t,v));
      DividedHead(|v.values|,Width(s.element),available);
    } else {
      BytePayload(t,v.payload);
      PaddingLayout(v.payload);
      assert |v.payload|+Padding(|v.payload|) <= available;
      assert (|v.payload|+Padding(|v.payload|))%32 == 0;
      assert |v.payload|+Padding(|v.payload|) <= available-available%32;
    }
  }

  lemma {:isolate_assertions} PayloadCanonical(data: seq<Byte>, c: Cursor, v: Value)
    requires Admissible(c.syntax) && Uint(c.base) && Uint(|data|)
    requires WellTyped(TypeOf(c.syntax),v) && Fits(TypeOf(c.syntax),v)
    requires NavigationLayout.Located(TypeOf(c.syntax),v,data,c.base)
    requires TypeOf(c.syntax).Bytes? || TypeOf(c.syntax).String?
    ensures CursorPayload(data,c) == BytesReturned(v.payload)
  {
    var t := TypeOf(c.syntax);
    ModelType(c.syntax); LengthWord(t,v,data,c.base);
    BytePayload(t,v.payload); PaddingLayout(v.payload);
    Subrange(data,c.base,c.base+|Body(t,v)|,32,32+|v.payload|);
    assert Body(t,v)[32..32+|v.payload|] == v.payload;
  }
}

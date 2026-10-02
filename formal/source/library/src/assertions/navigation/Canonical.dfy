// SPDX-License-Identifier: MIT
include "Traversal.dfy"
include "Layout.dfy"

module NavigationCanonical {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import opened AbiTupleSemantics
  import AbiTupleWords
  import opened AbiConnectionModel
  import opened NavigationModel
  import opened NavigationLayout
  import opened NavigationRuntime
  import opened NavigationCursorSpec

  ghost function ChildSyntax(s: Descriptor, i: nat): Descriptor
    requires Good(s) && (s.Group? || s.Fixed? || s.Dynamic?)
    requires s.Group? ==> i < |s.fields|
    ensures Good(ChildSyntax(s,i))
  { if s.Group? then s.fields[i] else s.element }

  lemma ChildType(s: Descriptor, v: Value, i: nat)
    requires Good(s) && WellTyped(TypeOf(s),v) && Aggregate(TypeOf(s)) && i < |v.values|
    ensures TypeOf(ChildSyntax(s,i)) == Child(TypeOf(s),i)
  { if s.Group? { TypesIndex(s.fields); } }

  lemma TupleHead(s: Descriptor, v: Value, i: nat)
    requires Good(s) && s.Group? && WellTyped(TypeOf(s),v) && i <= |v.values|
    ensures HeadSize(Parts(TypeOf(s),v)[..i]) == 32*WidthSum(s.fields[..i])
  {
    HeadPrefix(TypeOf(s),v,i);
    ModelFields(s.fields[..i]);
    TypesIndex(s.fields); TypesIndex(s.fields[..i]);
    assert seq(i,j requires 0 <= j < i => HeadWords(Child(TypeOf(s),j))) ==
           seq(|TypesOf(s.fields[..i])|,j requires 0 <= j < |TypesOf(s.fields[..i])| => HeadWords(TypesOf(s.fields[..i])[j]));
  }

  // The whole canonical body supplies all bounds. No arbitrary array-count
  // or path-length bound is used to make the Solidity arithmetic safe.
  lemma {:isolate_assertions} StepCanonical(data: seq<Byte>, c: Cursor, v: Value, index: int)
    requires Admissible(c.syntax) && Uint(|data|) && Uint(c.base) && Sint(index)
    requires WellTyped(TypeOf(c.syntax),v) && Fits(TypeOf(c.syntax),v)
    requires NavigationLayout.Located(TypeOf(c.syntax),v,data,c.base)
    requires InRange(TypeOf(c.syntax),v,index)
    ensures Step(data,c,index).Moved?
    ensures TypeOf(Step(data,c,index).cursor.syntax) == Child(TypeOf(c.syntax),Position(index,|v.values|))
    ensures WellTyped(TypeOf(Step(data,c,index).cursor.syntax),v.values[Position(index,|v.values|)])
    ensures NavigationLayout.Located(TypeOf(Step(data,c,index).cursor.syntax),v.values[Position(index,|v.values|)],data,Step(data,c,index).cursor.base)
    ensures Fits(TypeOf(Step(data,c,index).cursor.syntax),v.values[Position(index,|v.values|)])
  {
    var s := c.syntax;
    var t := TypeOf(s);
    var i := Position(index,|v.values|);
    ModelType(s); ChildType(s,v,i); ModelType(ChildSyntax(s,i));
    ChildLocation(t,v,data,c.base,i);
    var child := ChildSyntax(s,i);
    Positive(child);
    var h := c.base+HeadOffset(t,v,i);
    var p := c.base+ChildOffset(t,v,i);
    var frame := c.base+Prefix(t);
    assert Uint(h) && Uint(p) && Uint(frame);
    assert Fits(TypeOf(child),v.values[i]);
    if s.Group? {
      TupleHead(s,v,i);
      assert index == i;
    } else {
      ArrayHead(t,v,i);
      AbiTupleWords.ProductAssoc(i,Width(child),32);
      AbiTupleWords.ProductAssoc(32,i,Width(child));
      assert h == frame+i*Width(child)*32;
      assert i*Width(child) <= i*Width(child)*32 <= h < |data|;
      assert Uint(i*Width(child)) && Uint(i*Width(child)*32);
      if s.Dynamic? {
        LengthWord(t,v,data,c.base);
        BodiesAreFrames(t,v); MinimumHead(Parts(t,v));
        Sizes(Parts(t,v),HeadSize(Parts(t,v)));
        assert |v.values| <= |data|/32;
        LengthBoundsCount(|data|,|v.values|);
      } else { FixedBoundsCount(AbiShapeSemantics.Number(s.digits)); }
      NormalizedIndex(index,|v.values|);
      assert Normalize(index,|v.values|) == NavigationRuntime.Number(i);
    }
    if Dyn(child) {
      assert WordAt(data,h) == NavigationRuntime.Number(p-frame);
      assert p-frame <= |data|;
      assert DynamicChild(data,frame,h,child,
                          if s.Group? then FieldStart(c.typeStart,s.fields,i) else c.typeStart).Moved?;
    } else {
      assert p == h;
      if !s.Group? {
        assert StaticChild(frame,i,Width(child),child,c.typeStart).Moved?;
      }
    }
    assert Step(data,c,index).Moved?;
    assert Step(data,c,index).cursor.base == p;
    assert Step(data,c,index).cursor.syntax == child;
  }

  lemma {:isolate_assertions} PathCanonical(data: seq<Byte>, c: Cursor, v: Value, path: seq<int>)
    requires Admissible(c.syntax) && Uint(|data|) && Uint(c.base)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    requires WellTyped(TypeOf(c.syntax),v) && Fits(TypeOf(c.syntax),v)
    requires NavigationLayout.Located(TypeOf(c.syntax),v,data,c.base)
    requires Select(TypeOf(c.syntax),v,path).Selected?
    ensures Steps(data,c,path).Moved?
    ensures TypeOf(Steps(data,c,path).cursor.syntax) == Select(TypeOf(c.syntax),v,path).selectedType
    ensures NavigationLayout.Located(Select(TypeOf(c.syntax),v,path).selectedType,
                                     Select(TypeOf(c.syntax),v,path).selectedValue,data,Steps(data,c,path).cursor.base)
    ensures Fits(Select(TypeOf(c.syntax),v,path).selectedType,Select(TypeOf(c.syntax),v,path).selectedValue)
    decreases |path|
  {
    if |path| > 0 {
      StepCanonical(data,c,v,path[0]);
      var next := Step(data,c,path[0]).cursor;
      var i := Position(path[0],|v.values|);
      PathCanonical(data,next,v.values[i],path[1..]);
    }
  }

  lemma StepRefused(data: seq<Byte>, c: Cursor, v: Value, index: int)
    requires Admissible(c.syntax) && Uint(|data|) && Uint(c.base) && Sint(index)
    requires WellTyped(TypeOf(c.syntax),v) && Fits(TypeOf(c.syntax),v)
    requires NavigationLayout.Located(TypeOf(c.syntax),v,data,c.base)
    requires !InRange(TypeOf(c.syntax),v,index)
    ensures Step(data,c,index).Stopped?
  {
    var s := c.syntax;
    if s.Fixed? || s.Dynamic? {
      var count := |v.values|;
      if s.Dynamic? {
        LengthWord(TypeOf(s),v,data,c.base);
        if count > |data|/32 { return; }
        LengthBoundsCount(|data|,count);
      } else { FixedBoundsCount(AbiShapeSemantics.Number(s.digits)); }
      NormalizedIndex(index,count);
      assert Normalize(index,count).Failed?;
    }
  }

  lemma {:isolate_assertions} PathRefused(data: seq<Byte>, c: Cursor, v: Value, path: seq<int>)
    requires Admissible(c.syntax) && Uint(|data|) && Uint(c.base)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    requires WellTyped(TypeOf(c.syntax),v) && Fits(TypeOf(c.syntax),v)
    requires NavigationLayout.Located(TypeOf(c.syntax),v,data,c.base)
    requires Select(TypeOf(c.syntax),v,path).Absent?
    ensures Steps(data,c,path).Stopped?
    decreases |path|
  {
    if !InRange(TypeOf(c.syntax),v,path[0]) {
      StepRefused(data,c,v,path[0]);
    } else {
      StepCanonical(data,c,v,path[0]);
      var next := Step(data,c,path[0]).cursor;
      var i := Position(path[0],|v.values|);
      PathRefused(data,next,v.values[i],path[1..]);
    }
  }
}

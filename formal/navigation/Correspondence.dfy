// SPDX-License-Identifier: MIT
include "CanonicalSource.dfy"
include "NavSource.generated.dfy"

module NavigationCorrespondence {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import opened AbiConnectionModel
  import opened AbiDynamicSemantics
  import opened NavigationModel
  import opened NavigationRuntime
  import opened NavigationCursorSpec
  import opened NavigationTraversal
  import opened NavigationModes
  import opened NavigationEntry
  import opened NavigationLayout
  import opened NavigationCanonical
  import opened NavigationCanonicalSource
  import NavigationSource

  function AnswerOf(r: ReturnResult): Answer {
    if r.BytesReturned? then Returned(r.bytes) else Refused
  }

  lemma SelectedRoom(t: seq<Byte>, data: seq<Byte>, c: Cursor)
    requires Span(t,c) && Uint(|data|+32*0x100000000*|t|)
    ensures CursorRoom(c.syntax,|data|)
  {
    assert Uint(|data|+32*0x100000000*|Render(c.syntax)|);
    RoomFromText(c.syntax,|data|);
  }

  lemma IndexNotSentinel(t: AbiType, v: Value, data: seq<Byte>, pos: nat, index: int)
    requires WellTyped(t,v) && Fits(t,v) && NavigationLayout.Located(t,v,data,pos)
    requires Uint(|data|) && InRange(t,v,index)
    ensures index != LenSentinel() && index != PayloadSentinel()
  {
    if !t.Tuple? {
      BodiesAreFrames(t,v); MinimumHead(Parts(t,v)); Sizes(Parts(t,v),HeadSize(Parts(t,v)));
      assert |v.values|*32 <= |Body(t,v)| <= |data|;
      assert |v.values| <= |data|/32;
      assert Limit() > 64 && Limit()%32 == 0;
      assert |v.values| < Half()-1;
    }
  }

  lemma {:isolate_assertions} PathHasNoMode(data: seq<Byte>, c: Cursor, v: Value, path: seq<int>)
    requires Admissible(c.syntax) && Uint(c.base) && Uint(|data|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    requires WellTyped(TypeOf(c.syntax),v) && Fits(TypeOf(c.syntax),v)
    requires NavigationLayout.Located(TypeOf(c.syntax),v,data,c.base)
    requires Select(TypeOf(c.syntax),v,path).Selected?
    ensures LastMode(path) == ValueMode
    decreases |path|
  {
    if |path| > 0 {
      IndexNotSentinel(TypeOf(c.syntax),v,data,c.base,path[0]);
      if |path| == 1 { assert path[|path|-1] == path[0]; }
      else {
        StepCanonical(data,c,v,path[0]);
        var next := Step(data,c,path[0]).cursor;
        var i := Position(path[0],|v.values|);
        PathHasNoMode(data,next,v.values[i],path[1..]);
        assert path[1..][|path[1..]|-1] == path[|path|-1];
      }
    }
  }

  // Arbitrary finite nesting/path length, with a sufficient uint256 arithmetic
  // budget covering zero-copy static scans and dynamic return allocation.
  ghost method {:isolate_assertions} CanonicalQuery(s: Descriptor, v: Value, path: seq<int>, mode: Mode)
    returns (r: ReturnResult)
    requires Admissible(s) && s.Group? && WellTyped(TypeOf(s),v) && Fits(TypeOf(s),v)
    requires Uint(|Render(s)|) && Uint(|Body(TypeOf(s),v)|+32*0x100000000*|Render(s)|)
    requires Uint(|path|+1) && forall i :: 0 <= i < |path| ==> Sint(path[i])
    requires mode == ValueMode ==> LastMode(path) == ValueMode
    ensures AnswerOf(r) == Query(TypeOf(s),v,path,mode)
  {
    var t := Render(s);
    var data := Body(TypeOf(s),v);
    Positive(s); ModelType(s);
    assert Uint(|data|+32);
    assert data[0..|data|] == data;
    if Select(TypeOf(s),v,path).Selected? { PathHasNoMode(data,Cursor(s,0,0),v,path); }
    var encodedPath := if mode == ValueMode then path else
    path+[if mode == LengthMode then LenSentinel() else PayloadSentinel()];
    assert forall i :: 0 <= i < |encodedPath| ==> Sint(encodedPath[i]);
    r := NavigationSource.NavResolved(t,data,encodedPath);
    if |path| == 0 { return; }
    var selected := Select(TypeOf(s),v,path);
    Accept(t,0,|t|,s);
    if selected.Absent? {
      PathRefused(data,Cursor(s,0,0),v,path);
      assert Navigation(t,data,path).Stopped?;
      return;
    }
    var c := CanonicalNavigate(s,v,path);
    assert c == Navigation(t,data,path);
    SelectedRoom(t,data,c.cursor);
    if mode == LengthMode {
      if HasLength(selected.selectedType) {
        LengthCanonical(data,c.cursor,selected.selectedValue);
      } else {
        ModelType(c.cursor.syntax);
        assert CursorLength(data,c.cursor).Failed?;
      }
    } else if mode == PayloadMode {
      if selected.selectedType.Bytes? || selected.selectedType.String? {
        PayloadCanonical(data,c.cursor,selected.selectedValue);
      } else {
        ModelType(c.cursor.syntax);
        assert CursorPayload(data,c.cursor).Rejected?;
      }
    } else {
      var body := Body(selected.selectedType,selected.selectedValue);
      assert data[c.cursor.base..] == body+data[c.cursor.base+|body|..];
      AbiValidation.WalkComplete(selected.selectedType,selected.selectedValue,data[c.cursor.base+|body|..]);
      ModelType(c.cursor.syntax);
    }
  }
}

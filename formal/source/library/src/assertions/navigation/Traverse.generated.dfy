// SPDX-License-Identifier: MIT
// Source-derived navigation loop; Assertions.sol SHA-256: 8fa122e5e5750ca115c66898c22186e076eac9d95e7c91c228928a5b09ad273a
include "Traversal.dfy"
include "Cursor.generated.dfy"

module NavigationTraverseSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import AbiParserSource
  import opened NavigationRuntime
  import opened NavigationCursorSpec
  import opened NavigationTraversal
  import NavigationCursorSource

  // The root's initial dyn=true/words=1 fields are overwritten by the first
  // successful step. The path is nonempty, so they never reach a terminal.
  ghost method Traverse(t: seq<Byte>, data: seq<Byte>, root: Cursor, path: seq<int>)
    returns (r: CursorResult)
    requires Span(t,root) && Uint(root.base) && Uint(|t|) && Uint(|data|) && Uint(|path|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    ensures r == Steps(data,root,path)
    ensures r.Moved? ==> Span(t,r.cursor) && Uint(r.cursor.base)
  {
    var c := root;
    var i: nat := 0;
    while i < |path|
      invariant i <= |path|
      invariant Span(t,c) && Uint(c.base)
      invariant Steps(data,c,path[i..]) == Steps(data,root,path)
      decreases |path|-i
    {
      Dispatch(t,c);
      var te := c.typeStart+|Render(c.syntax)|;
      var next: CursorResult;
      if t[te-1] == 93 {
        next := NavigationCursorSource.ArrayStep(t,data,c,path[i]);
      } else if t[c.typeStart] == 40 {
        next := NavigationCursorSource.TupleStep(t,data,c,path[i]);
      } else { next := Stopped(InvalidNavigation(c.typeStart)); }
      assert next == Step(data,c,path[i]);
      assert path[i..][0] == path[i] && path[i..][1..] == path[i+1..];
      if next.Stopped? { r := next; return; }
      StepSpan(t,data,c,path[i]);
      c := next.cursor;
      assert Uint(i+1);
      i := i+1;
    }
    assert path[i..] == [];
    r := Moved(c);
  }

  // These postconditions partition all inputs in source rejection order.
  // A root beginning with '(' may itself have array suffixes; the source
  // accepts those too. The canonical return-tuple theorem is narrower.
  ghost method Navigate(t: seq<Byte>, data: seq<Byte>, path: seq<int>)
    returns (r: CursorResult)
    requires Uint(|t|) && Uint(|data|) && Uint(|path|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    ensures r == Navigation(t,data,path)
    ensures |t| == 0 || t[0] != 40 ==> r == Stopped(InvalidTypeDescriptor(0))
    ensures |t| > 0 && t[0] == 40 && |path| == 0 ==> r == Stopped(InvalidNavigation(0))
    ensures |t| > 0 && t[0] == 40 && |path| > 0 ==>
              (var top := Parse(t,0,|t|);
               if top.BadDescriptor? then r == Stopped(InvalidTypeDescriptor(top.at))
               else if top.ArithmeticPanic? then r == Stopped(Error.Panic(17))
               else if top.end != |t| then r == Stopped(InvalidTypeDescriptor(top.end))
               else Admissible(top.syntax) && r == Steps(data,Cursor(top.syntax,0,0),path))
    ensures r.Moved? ==> Span(t,r.cursor) && Uint(r.cursor.base)
  {
    if |t| == 0 || t[0] != 40 { r := Stopped(InvalidTypeDescriptor(0)); return; }
    if |path| == 0 { r := Stopped(InvalidNavigation(0)); return; }
    var top := AbiParserSource.TypeShape(t,0,|t|);
    if top.BadDescriptor? { r := Stopped(InvalidTypeDescriptor(top.at)); return; }
    if top.ArithmeticPanic? { r := Stopped(Error.Panic(17)); return; }
    if top.end != |t| { r := Stopped(InvalidTypeDescriptor(top.end)); return; }
    r := Traverse(t,data,Cursor(top.syntax,0,0),path);
  }
}

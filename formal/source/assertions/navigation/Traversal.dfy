// SPDX-License-Identifier: MIT
include "CursorSpec.dfy"

module NavigationTraversal {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiWordSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import opened AbiTupleSemantics
  import opened AbiConnectionDescriptor
  import opened NavigationRuntime
  import opened NavigationCursorSpec

  predicate Span(t: seq<Byte>, c: Cursor)
  {
    Admissible(c.syntax) && c.typeStart+|Render(c.syntax)| <= |t| &&
    t[c.typeStart..c.typeStart+|Render(c.syntax)|] == Render(c.syntax)
  }

  ghost function Navigation(t: seq<Byte>, data: seq<Byte>, path: seq<int>): CursorResult
    requires Uint(|t|) && Uint(|data|) && Uint(|path|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    ensures Navigation(t,data,path).Moved? ==>
              Admissible(Navigation(t,data,path).cursor.syntax) && Uint(Navigation(t,data,path).cursor.base)
  {
    if |t| == 0 || t[0] != 40 then Stopped(InvalidTypeDescriptor(0)) else
    if |path| == 0 then Stopped(InvalidNavigation(0)) else
    var top := Parse(t,0,|t|);
    if top.BadDescriptor? then Stopped(InvalidTypeDescriptor(top.at)) else
    if top.ArithmeticPanic? then Stopped(Error.Panic(17)) else
    if top.end != |t| then Stopped(InvalidTypeDescriptor(top.end)) else
    // Totalize the reference's cursor precondition. The source parser's
    // unconditional soundness theorem proves this branch unreachable, and
    // Navigate's separate postcondition explicitly establishes Admissible.
    if !Admissible(top.syntax) then Stopped(Error.Panic(17)) else
    Steps(data,Cursor(top.syntax,0,0),path)
  }

  lemma Dispatch(t: seq<Byte>, c: Cursor)
    requires Span(t,c)
    ensures c.typeStart < c.typeStart+|Render(c.syntax)| <= |t|
    ensures (t[c.typeStart+|Render(c.syntax)|-1] == 93) ==
            (c.syntax.Fixed? || c.syntax.Dynamic?)
    ensures !c.syntax.Fixed? && !c.syntax.Dynamic? ==>
              (t[c.typeStart] == 40) == c.syntax.Group?
  {
    LastByte(c.syntax);
    if c.syntax.Name? { assert NameByte(c.syntax.text[0]); }
  }

  lemma StepSpan(t: seq<Byte>, data: seq<Byte>, c: Cursor, index: int)
    requires Span(t,c) && Uint(|data|) && Uint(c.base) && Sint(index)
    ensures Step(data,c,index).Moved? ==> Span(t,Step(data,c,index).cursor)
  {
    var s := c.syntax;
    var te := c.typeStart+|Render(s)|;
    if s.Fixed? || s.Dynamic? {
      ArraySpan(t,c.typeStart,te,s);
    } else if s.Group? && 0 <= index < |s.fields| {
      LocateField(t,c.typeStart,te,s.fields,index);
    }
  }

  lemma StepsSpan(t: seq<Byte>, data: seq<Byte>, c: Cursor, path: seq<int>)
    requires Span(t,c) && Uint(|data|) && Uint(c.base)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    ensures Steps(data,c,path).Moved? ==> Span(t,Steps(data,c,path).cursor)
    decreases |path|
  {
    if |path| > 0 {
      StepSpan(t,data,c,path[0]);
      var r := Step(data,c,path[0]);
      if r.Moved? { StepsSpan(t,data,r.cursor,path[1..]); }
    }
  }
}

// SPDX-License-Identifier: MIT
include "Runtime.dfy"
include "../../abi/connection/Descriptor.dfy"

module NavigationCursorSpec {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiTupleSemantics
  import opened NavigationRuntime

  datatype Cursor = Cursor(syntax: Descriptor, typeStart: nat, base: nat)
  datatype CursorResult = Moved(cursor: Cursor) | Stopped(error: Error)

  lemma FieldCount(fs: seq<Descriptor>)
    requires forall i :: 0 <= i < |fs| ==> Good(fs[i])
    ensures |fs| <= |FieldsText(fs)|
    decreases |fs|
  {
    if |fs| > 0 { Positive(fs[0]); FieldCount(fs[1..]); }
  }

  // Reads only the chosen head. Unvisited siblings and parent tight-offset
  // ordering are intentionally not checked by navigation.
  function DynamicChild(data: seq<Byte>, frame: nat, head: nat, child: Descriptor, ts: nat): CursorResult
    requires Uint(frame) && Uint(|data|)
    requires Admissible(child)
    ensures DynamicChild(data,frame,head,child,ts).Moved? ==>
              Uint(DynamicChild(data,frame,head,child,ts).cursor.base) &&
              Admissible(DynamicChild(data,frame,head,child,ts).cursor.syntax)
  {
    if !Uint(head) then Stopped(Error.Panic(17)) else
    var offset := WordAt(data,head);
    if offset.Failed? then Stopped(offset.error) else
    if offset.value > |data| then Stopped(ReturnDataOutOfBounds(head/32,|data|)) else
    if !Uint(frame+offset.value) then Stopped(Error.Panic(17)) else
    Moved(Cursor(child,ts,frame+offset.value))
  }

  function StaticChild(frame: nat, wanted: nat, words: nat, child: Descriptor, ts: nat): CursorResult
    requires Admissible(child)
    ensures StaticChild(frame,wanted,words,child,ts).Moved? ==>
              Uint(StaticChild(frame,wanted,words,child,ts).cursor.base) &&
              Admissible(StaticChild(frame,wanted,words,child,ts).cursor.syntax)
  {
    if !Uint(wanted*words) || !Uint(wanted*words*32) || !Uint(frame+wanted*words*32)
    then Stopped(Error.Panic(17)) else Moved(Cursor(child,ts,frame+wanted*words*32))
  }

  function ArrayAfterCount(data: seq<Byte>, c: Cursor, index: int, count: nat, frame: nat): CursorResult
    requires Admissible(c.syntax) && (c.syntax.Fixed? || c.syntax.Dynamic?)
    requires Sint(index) && Uint(count) && Uint(frame) && Uint(|data|)
    ensures ArrayAfterCount(data,c,index,count,frame).Moved? ==>
              Uint(ArrayAfterCount(data,c,index,count,frame).cursor.base) &&
              Admissible(ArrayAfterCount(data,c,index,count,frame).cursor.syntax)
  {
    var normalized := Normalize(index,count);
    if normalized.Failed? then Stopped(normalized.error) else
    var child := c.syntax.element;
    if Dyn(child) then
      DynamicChild(data,frame,frame+normalized.value*32,child,c.typeStart)
    else StaticChild(frame,normalized.value,Width(child),child,c.typeStart)
  }

  function ArrayStep(data: seq<Byte>, c: Cursor, index: int): CursorResult
    requires Admissible(c.syntax) && (c.syntax.Fixed? || c.syntax.Dynamic?)
    requires Uint(c.base) && Uint(|data|) && Sint(index)
    ensures ArrayStep(data,c,index).Moved? ==>
              Uint(ArrayStep(data,c,index).cursor.base) && Admissible(ArrayStep(data,c,index).cursor.syntax)
  {
    if c.syntax.Fixed? then ArrayAfterCount(data,c,index,AbiShapeSemantics.Number(c.syntax.digits),c.base)
    else
      var count := WordAt(data,c.base);
      if count.Failed? then Stopped(count.error) else
      if count.value > |data|/32 then Stopped(ReturnDataOutOfBounds(c.base/32,|data|)) else
      ArrayAfterCount(data,c,index,count.value,c.base+32)
  }

  function TupleStep(data: seq<Byte>, c: Cursor, index: int): CursorResult
    requires Admissible(c.syntax) && c.syntax.Group?
    requires Uint(c.base) && Uint(|data|) && Sint(index)
    ensures TupleStep(data,c,index).Moved? ==>
              Uint(TupleStep(data,c,index).cursor.base) && Admissible(TupleStep(data,c,index).cursor.syntax)
  {
    var fs := c.syntax.fields;
    if index < 0 || index >= |fs| then Stopped(ElementIndexOutOfBounds(index,|fs|)) else
    var i: nat := index;
    var before := WidthSum(fs[..i]);
    var child := fs[i];
    var ts := FieldStart(c.typeStart,fs,i);
    if !Uint(before*32) || !Uint(c.base+before*32) then Stopped(Error.Panic(17)) else
    if Dyn(child) then DynamicChild(data,c.base,c.base+before*32,child,ts)
    else Moved(Cursor(child,ts,c.base+before*32))
  }

  function Step(data: seq<Byte>, c: Cursor, index: int): CursorResult
    requires Admissible(c.syntax) && Uint(c.base) && Uint(|data|) && Sint(index)
    ensures Step(data,c,index).Moved? ==>
              Uint(Step(data,c,index).cursor.base) && Admissible(Step(data,c,index).cursor.syntax)
  {
    if c.syntax.Fixed? || c.syntax.Dynamic? then ArrayStep(data,c,index)
    else if c.syntax.Group? then TupleStep(data,c,index)
    else Stopped(InvalidNavigation(c.typeStart))
  }

  function Steps(data: seq<Byte>, c: Cursor, path: seq<int>): CursorResult
    requires Admissible(c.syntax) && Uint(c.base) && Uint(|data|)
    requires forall i :: 0 <= i < |path| ==> Sint(path[i])
    ensures Steps(data,c,path).Moved? ==>
              Uint(Steps(data,c,path).cursor.base) && Admissible(Steps(data,c,path).cursor.syntax)
    decreases |path|
  {
    if |path| == 0 then Moved(c) else
    var step := Step(data,c,path[0]);
    if step.Stopped? then step else Steps(data,step.cursor,path[1..])
  }
}

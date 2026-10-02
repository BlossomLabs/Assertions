// SPDX-License-Identifier: MIT
// Source-derived cursor helpers; Assertions.sol SHA-256: 8fa122e5e5750ca115c66898c22186e076eac9d95e7c91c228928a5b09ad273a
include "CursorSpec.dfy"
include "Kernels.generated.dfy"
include "../abi/connection/Bridge.generated.dfy"

module NavigationCursorSource {
  import opened AbiFrames
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import AbiParserSource
  import opened AbiTupleSemantics
  import opened AbiConnectionDescriptor
  import AbiConnectionSource
  import opened NavigationRuntime
  import opened NavigationKernels
  import opened NavigationCursorSpec

  ghost method DynamicMove(data: seq<Byte>, frame: nat, head: nat, child: Descriptor, ts: nat)
    returns (r: CursorResult)
    requires Uint(frame) && Uint(|data|) && Admissible(child)
    ensures r == DynamicChild(data,frame,head,child,ts)
  {
    if !Uint(head) { r := Stopped(Error.Panic(17)); return; }
    var read := ReadWord(data,head);
    if read.Failed? { r := Stopped(read.error); return; }
    var off := read.value;
    if off > |data| { r := Stopped(ReturnDataOutOfBounds(head/32,|data|)); return; }
    var next: int := (frame + off);
    if !Uint(next) { r := Stopped(Error.Panic(17)); return; }
    r := Moved(Cursor(child,ts,next));
  }

  ghost method StaticMove(frame: nat, wanted: nat, words: nat, child: Descriptor, ts: nat)
    returns (r: CursorResult)
    requires Admissible(child)
    ensures r == StaticChild(frame,wanted,words,child,ts)
  {
    if !Uint(wanted*words) || !Uint(wanted*words*32) {
      r := Stopped(Error.Panic(17)); return;
    }
    var next: int := (frame + ((wanted * words) * 32));
    if !Uint(next) { r := Stopped(Error.Panic(17)); return; }
    r := Moved(Cursor(child,ts,next));
  }

  ghost method ArrayStep(t: seq<Byte>, data: seq<Byte>, c: Cursor, index: int)
    returns (r: CursorResult)
    requires Uint(|t|) && Uint(|data|) && Uint(c.base) && Sint(index)
    requires Admissible(c.syntax) && (c.syntax.Fixed? || c.syntax.Dynamic?)
    requires c.typeStart+|Render(c.syntax)| <= |t|
    requires t[c.typeStart..c.typeStart+|Render(c.syntax)|] == Render(c.syntax)
    ensures r == NavigationCursorSpec.ArrayStep(data,c,index)
  {
    var ts := c.typeStart;
    var te := ts+|Render(c.syntax)|;
    ArraySpan(t,ts,te,c.syntax);
    var found := AbiConnectionSource.SuffixStart(t,ts,te);
    var suffix := found.at;
    Accept(t,ts,suffix,c.syntax.element);
    var element := AbiParserSource.TypeShape(t,ts,suffix);
    assert element.Shaped? && element.syntax == c.syntax.element;
    var words := element.words;
    var count: nat;
    var frame: nat;
    if suffix+1 == te-1 {
      var read := ReadWord(data,c.base);
      if read.Failed? { r := Stopped(read.error); return; }
      count := read.value;
      WordBounds(data,c.base);
      if count > |data|/32 {
        r := Stopped(ReturnDataOutOfBounds(c.base/32,|data|)); return;
      }
      frame := c.base+32;
    } else {
      count := AbiConnectionSource.FixedCount(t,suffix,te,c.syntax.digits);
      frame := c.base;
    }
    var normalized := NormalizeIndex(index,count);
    if normalized.Failed? { r := Stopped(normalized.error); return; }
    var wanted := normalized.value;
    if element.dynamic {
      if !Uint(wanted*32) { r := Stopped(Error.Panic(17)); return; }
      var head: int := (frame + (wanted * 32));
      if !Uint(head) { r := Stopped(Error.Panic(17)); return; }
      r := DynamicMove(data,frame,head,c.syntax.element,ts);
    } else {
      r := StaticMove(frame,wanted,words,c.syntax.element,ts);
    }
  }

  ghost method TupleStep(t: seq<Byte>, data: seq<Byte>, c: Cursor, index: int)
    returns (r: CursorResult)
    requires Uint(|t|) && Uint(|data|) && Uint(c.base) && Sint(index)
    requires Admissible(c.syntax) && c.syntax.Group?
    requires c.typeStart+|Render(c.syntax)| <= |t|
    requires t[c.typeStart..c.typeStart+|Render(c.syntax)|] == Render(c.syntax)
    ensures r == NavigationCursorSpec.TupleStep(data,c,index)
  {
    var fs := c.syntax.fields;
    var ts := c.typeStart;
    var te := ts+|Render(c.syntax)|;
    var j: nat := 0;
    var q := ts+1;
    var acc: nat := 0;
    FieldCount(fs);
    assert Uint(q) && Uint(|fs|);
    while true
      invariant j < |fs|
      invariant q == FieldStart(ts,fs,j)
      invariant acc == (if index < 0 then 0 else WidthSum(fs[..j]))
      invariant Uint(acc) && Uint(q) && Uint(j)
      invariant index >= 0 ==> j <= index
      decreases |fs|-j
    {
      LocateField(t,ts,te,fs,j);
      Accept(t,q,te,fs[j]);
      var parsed := AbiParserSource.TypeShape(t,q,te);
      assert parsed.Shaped? && parsed.syntax == fs[j];
      var end := parsed.end;
      if index >= 0 && j == index {
        assert acc == WidthSum(fs[..index]);
        if !Uint(acc*32) { r := Stopped(Error.Panic(17)); return; }
        var frame := c.base;
        if parsed.dynamic {
          var head: int := (frame + (acc * 32));
          if !Uint(head) { r := Stopped(Error.Panic(17)); return; }
          r := DynamicMove(data,frame,head,fs[j],q);
        } else {
          var start: int := (frame + (acc * 32));
          if !Uint(start) { r := Stopped(Error.Panic(17)); return; }
          r := Moved(Cursor(fs[j],q,start));
        }
        return;
      }
      if index >= 0 {
        assert fs[..j+1] == fs[..j]+[fs[j]];
        AppendFields(fs[..j],fs[j]);
        assert fs == fs[..j+1]+fs[j+1..];
        WidthConcat(fs[..j+1],fs[j+1..]);
        assert Uint(acc+parsed.words);
        acc := acc+parsed.words;
      }
      assert Uint(j+1);
      j := j+1;
      if t[end] == 41 {
        assert j == |fs|;
        r := Stopped(ElementIndexOutOfBounds(index,j)); return;
      }
      assert Uint(end+1);
      q := end+1;
    }
  }
}

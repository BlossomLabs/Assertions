// SPDX-License-Identifier: MIT
// Full body composition under the source AST gate. Solidity SHA256: $HASH
include "Semantics.dfy"

module AbiDynamicSource {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiBytesSource
  import opened AbiBytesCorrespondence
  import opened AbiCursorSemantics
  import opened AbiCursorSource
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import AbiParserSource
  import opened AbiTupleSemantics
  import opened AbiConnectionModel
  import opened AbiConnectionStatic
  import opened AbiConnectionDescriptor
  import AbiConnectionSource
  import opened AbiDynamicZero
  import opened AbiDynamicSemantics

  ghost method SecondNext(next: nat) returns (j: nat)
    ensures j == next+1
  { j := $SECOND_NEXT; }

  ghost method BodyExtent(base: nat, p: nat, tail: nat, length: nat) returns (used: nat)
    requires p <= base && base+tail <= length && Uint(length)
    ensures used == base-p+tail && Uint(used)
  { used := $BODY_EXTENT; }

  ghost method TupleAdvance(head: nat, words: nat, limit: nat) returns (next: nat)
    requires head+32*words <= limit && Uint(limit)
    ensures next == head+32*words && Uint(next)
  { next := $TUPLE_ADVANCE; }

  ghost method {:isolate_assertions} FullBody(t: seq<Byte>, ts: nat, te: nat, v: seq<Byte>, p: nat, s: Descriptor)
    returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|) && Uint(p)
    requires Admissible(s) && Dyn(s)
    requires ts <= te <= |t| && t[ts..te] == Render(s)
    ensures WellFormed(TypeOf(s))
    ensures r.Panic? ==> r.code == 17 && !CursorRoom(s,|v|)
    ensures !r.Panic? ==> r.Ok? == (p <= |v| && Walk(TypeOf(s),v[p..]).Parsed?)
    ensures r.Ok? ==> r.used == Walk(TypeOf(s),v[p..]).used && p+r.used <= |v|
    decreases TypeOf(s), 2, 0
  {
    ModelType(s); LastByte(s); FirstByte(s);
    if p > |v| { r := Invalid(p); return; }
    if t[te-1] == 93 {
      assert s.Fixed? || s.Dynamic?;
      var j: nat; var base: nat; var count: nat; var dynamic: bool; var words: nat;
      var head: Outcome;
      j,base,count,dynamic,words,head := AbiConnectionSource.ArrayHead(t,ts,te,v,p,s);
      if s.Dynamic? && |v|-p < 32 { r := head; return; }
      var n := if s.Dynamic? then ReadNat(v[p..p+32]) else Number(s.digits);
      var start := p+(if s.Dynamic? then 32 else 0);
      var fs := Copies(s.element,n);
      CopyLayout(s.element,n); ModelFields(fs); ModelType(s.element);
      ArrayView(s,v,p,n);
      assert TypesOf(fs) == Children(TypeOf(s),n);
      assert Below(TypeOf(s),TypesOf(fs));
      assert v[p..][(start-p)..] == v[start..];
      if !head.Ok? { r := head; return; }
      assert count == n && base == start;
      ArraySpan(t,ts,te,s);
      Positive(s.element);
      HeadCountFits(count,words,|v|);
      AbiTupleWords.CursorArithmetic(base,words,count);
      assert Located(t,ts,j,s.element);
      assert base+32*Width(s.element)*count <= |v|;
      if !dynamic {
        r := StaticCopies(t,ts,j,v,base,s.element,count);
        if r.Panic? { return; }
        StaticFrame(s.element,count,TypeOf(s),v,base);
        if !r.Ok? { return; }
        var used := BodyExtent(base,p,head.used,|v|);
        r := Ok(used); return;
      }
      var tailResult := ArrayLoop(t,ts,j,v,base,count,words,head.used,s);
      if !tailResult.Ok? { r := tailResult; return; }
      var used := BodyExtent(base,p,tailResult.used,|v|);
      r := Ok(used); return;
    }
    if t[ts] == 40 {
      assert s.Group?;
      ModelFields(s.fields);
      var head := AbiConnectionSource.TupleHead(t,ts,te,v,p,s.fields);
      if !head.Ok? { r := head; return; }
      r := TupleLoop(t,ts,te,v,p,head.used,s.fields); return;
    }
    assert s.Name? && (TypeOf(s).Bytes? || TypeOf(s).String?);
    r := BodyRefinesWalker(v,p);
  }

  ghost method {:isolate_assertions} ArrayLoop(t: seq<Byte>, ts: nat, te: nat, v: seq<Byte>, base: nat,
                                               count: nat, words: nat, initialTail: nat, owner: Descriptor)
    returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|) && Uint(count)
    requires Admissible(owner) && (owner.Fixed? || owner.Dynamic?) && Dyn(owner.element)
    requires owner.Fixed? ==> count == Number(owner.digits)
    requires ts <= te <= |t| && t[ts..te] == Render(owner.element)
    requires words == Width(owner.element) && initialTail == count*words*32 && base+initialTail <= |v|
    ensures WellFormed(TypeOf(owner))
    ensures Types(TypesOf(Copies(owner.element,count))) && Below(TypeOf(owner),TypesOf(Copies(owner.element,count)))
    ensures r.Panic? ==> r.code == 17 && !CursorRoom(owner,|v|)
    ensures !r.Panic? ==> r.Ok? == WalkFrame(TypeOf(owner),TypesOf(Copies(owner.element,count)),v[base..]).Parsed?
    ensures r.Ok? ==> r.used == WalkFrame(TypeOf(owner),TypesOf(Copies(owner.element,count)),v[base..]).used && base+r.used <= |v|
    decreases TypeOf(owner), 1, 0
  {
    ModelType(owner); ModelType(owner.element); ArrayTypes(owner,count);
    var fs := Copies(owner.element,count);
    CopyLayout(owner.element,count); ModelFields(fs);
    var types := TypesOf(fs);
    assert types == Children(TypeOf(owner),count);
    var bs := v[base..];
    var values: seq<Value> := [];
    var i: nat := 0;
    var tail := initialTail;
    while i < count
      invariant i <= count && initialTail <= tail && base+tail <= |v|
      invariant i*words*32+ListHead(types[i..]) == initialTail
      invariant WalkFields(TypeOf(owner),types,bs,0,initialTail) ==
                Prefix(values,WalkFields(TypeOf(owner),types[i..],bs,i*words*32,tail))
      decreases count-i
    {
      var rest := types[i..];
      assert rest[0] == TypeOf(owner.element) && rest[1..] == types[i+1..];
      HeadAppend(types,i);
      var position := ArrayPosition(v,base,count,words,i);
      var offset := ArrayOffset(v,position.used,tail);
      assert bs[i*words*32..i*words*32+32] == v[position.used..position.used+32];
      if !offset.Ok? { r := offset; return; }
      var child := FullBody(t,ts,te,v,base+tail,owner.element);
      if child.Panic? { r := child; return; }
      assert bs[tail..] == v[base+tail..];
      if !child.Ok? { r := child; return; }
      var parsed := Walk(TypeOf(owner.element),bs[tail..]);
      var next := ArrayTailAdvance(v,base,tail,child.used);
      var remaining := WalkFields(TypeOf(owner),rest[1..],bs,(i+1)*words*32,next.used);
      assert WalkFields(TypeOf(owner),rest,bs,i*words*32,tail) == Prefix([parsed.value],remaining);
      PrefixStep(values,parsed.value,remaining);
      values := values+[parsed.value];
      tail := next.used;
      i := i+1;
    }
    r := Ok(tail);
  }

  ghost method {:isolate_assertions} TupleLoop(t: seq<Byte>, ts: nat, te: nat, v: seq<Byte>, p: nat,
                                               initialTail: nat, fs: seq<Descriptor>)
    returns (r: Outcome)
    requires Uint(|t|) && Uint(|v|)
    requires Admissible(Group(fs)) && Dyn(Group(fs))
    requires ts <= te <= |t| && t[ts..te] == Render(Group(fs))
    requires initialTail == 32*WidthSum(fs) && p+initialTail <= |v|
    ensures WellFormed(TypeOf(Group(fs)))
    ensures r.Panic? ==> r.code == 17 && !CursorRoom(Group(fs),|v|)
    ensures !r.Panic? ==> r.Ok? == WalkFrame(TypeOf(Group(fs)),TypesOf(fs),v[p..]).Parsed?
    ensures r.Ok? ==> r.used == WalkFrame(TypeOf(Group(fs)),TypesOf(fs),v[p..]).used && p+r.used <= |v|
    decreases TypeOf(Group(fs)), 1, 0
  {
    ModelType(Group(fs)); ModelFields(fs); TypesIndex(fs);
    var owner := TypeOf(Group(fs));
    var types := TypesOf(fs);
    assert Below(owner,types);
    var bs := v[p..];
    var values: seq<Value> := [];
    var i: nat := 0;
    var j := ts+1;
    var head: nat := 0;
    var tail := initialTail;
    FieldRoom(t,ts,te,fs,0);
    while j < te-1
      invariant i <= |fs|
      invariant j == (if i < |fs| then FieldStart(ts,fs,i) else te)
      invariant i < |fs| ==> j < te-1
      invariant head == 32*WidthSum(fs[..i]) && head == ListHead(types[..i])
      invariant head+ListHead(types[i..]) == initialTail <= tail && p+tail <= |v|
      invariant WalkFields(owner,types,bs,0,initialTail) == Prefix(values,WalkFields(owner,types[i..],bs,head,tail))
      decreases |fs|-i
    {
      assert i < |fs|;
      var rest := types[i..];
      assert rest[0] == TypeOf(fs[i]) && rest[1..] == types[i+1..];
      LocateField(t,ts,te,fs,i); Accept(t,j,te-1,fs[i]);
      var field := AbiParserSource.TypeShape(t,j,te-1);
      assert field.Shaped? && field.syntax == fs[i];
      var next,dynamic,w := field.end,field.dynamic,field.words;
      var child: Outcome;
      var start := if dynamic then tail else head;
      if dynamic {
        var offset := TupleOffset(v,p,head,tail);
        assert bs[head..head+32] == v[p+head..p+head+32];
        if !offset.Ok? { r := offset; return; }
        child := FullBody(t,j,next,v,p+tail,fs[i]);
        if child.Panic? { r := child; return; }
      } else {
        child := StaticCopies(t,j,next,v,p+head,fs[i],1);
        assert !child.Panic?;
        StaticWalk(fs[i],bs[head..]);
        ScanSlice(Rules(fs[i]),v,p+head,0);
        AbiTupleWords.RepeatOne(Rules(fs[i]));
      }
      assert bs[start..] == v[p+start..];
      if !child.Ok? { r := child; return; }
      var parsed := Walk(TypeOf(fs[i]),bs[start..]);
      assert parsed.Parsed?;
      var previous := tail;
      if dynamic {
        var advanced := TupleTailAdvance(v,p,tail,child.used);
        tail := advanced.used;
      } else { StaticExtent(TypeOf(fs[i]),bs[start..]); }
      var nextHead := TupleAdvance(head,w,initialTail);
      var remaining := WalkFields(owner,rest[1..],bs,nextHead,tail);
      assert WalkFields(owner,rest,bs,head,previous) == Prefix([parsed.value],remaining);
      PrefixStep(values,parsed.value,remaining);
      values := values+[parsed.value];
      head := nextHead;
      j := SecondNext(next);
      HeadAppend(types,i); AppendFields(fs[..i],fs[i]);
      assert fs[..i+1] == fs[..i]+[fs[i]];
      i := i+1;
      if i < |fs| { FieldRoom(t,ts,te,fs,i); }
    }
    assert i == |fs|;
    r := Ok(tail);
  }
}

// SPDX-License-Identifier: MIT
include "Cursors.generated.dfy"

// Typed recursion composed with source-derived checked cursor kernels.
// Descriptor traversal and static-word classification remain explicit boundary
// assumptions; this is not a translation of the complete Solidity functions.
module AbiAggregateRefinement {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiBytesSource
  import opened AbiCursorSemantics
  import opened AbiCursorSource

  ghost predicate ShapesFit(t: AbiType)
    decreases t
  {
    WellFormed(t) && Uint(HeadWords(t)) &&
    match t
    case Tuple(ts) => forall i :: 0 <= i < |ts| ==> ShapesFit(ts[i])
    case FixedArray(e,_) => ShapesFit(e)
    case Array(e) => ShapesFit(e)
    case _ => true
  }

  ghost method TupleHead(bs: seq<Byte>, ts: seq<AbiType>) returns (r: Outcome)
    requires Uint(|bs|) && Types(ts)
    requires forall i :: 0 <= i < |ts| ==> Uint(HeadWords(ts[i]))
    ensures r == (if ListHead(ts) > |bs| then Invalid(0) else Ok(ListHead(ts)))
  {
    var i: nat := 0;
    var tail: nat := 0;
    while i < |ts|
      invariant 0 <= i <= |ts|
      invariant tail <= |bs| && tail == ListHead(ts[..i])
      invariant ListHead(ts) == tail+ListHead(ts[i..])
      decreases |ts|-i
    {
      HeadAppend(ts,i);
      NonemptyHead(ts[i]);
      var w := HeadWords(ts[i]);
      var next := TupleHeadStep(bs,0,tail,w);
      if !next.Ok? { r := next; return; }
      tail := next.used;
      i := i+1;
      assert ts[i-1..][1..] == ts[i..];
    }
    r := Ok(tail);
  }

  ghost method ComposedWalk(t: AbiType, bs: seq<Byte>) returns (r: Parsed)
    requires ShapesFit(t) && Uint(|bs|)
    ensures r == Walk(t,bs)
    decreases t, 2
  {
    match t
    case Scalar(_) =>
      // Interface to checkWords: scalar classification is still an assumption
      // in the source correspondence, not a proved translation of assembly.
      r := Walk(t,bs);
    case Bytes =>
      var result := BytesBody(bs,0);
      BodySpecMatchesWalker(bs,0);
      r := if result.Ok? then WalkBytes(bs) else Rejected;
    case String =>
      var result := BytesBody(bs,0);
      BodySpecMatchesWalker(bs,0);
      r := if result.Ok? then WalkBytes(bs) else Rejected;
    case Tuple(ts) =>
      var result := TupleHead(bs,ts);
      if !result.Ok? { r := Rejected; return; }
      var fields := Scan(t,ts,bs,result.used,false);
      r := if fields.BadFields? then Rejected else Parsed(Items(fields.values),fields.end);
    case _ =>
      var base: nat := 0;
      var count: nat := 0;
      if t.Array? {
        var word := ReadWord(bs,0);
        if !word.Ok? { r := Rejected; return; }
        base := 32;
        count := word.used;
      } else {
        count := t.count;
        assert Uint(count);
      }
      var elem := t.element;
      NonemptyHead(elem);
      var head := ArrayHead(bs,base,count,HeadWords(elem));
      var ts := Children(t,count);
      assert ts == seq(count,i requires 0 <= i < count => elem);
      RepeatedHead(elem,count);
      if !head.Ok? { r := Rejected; return; }
      var frame := bs[base..];
      var fields := Scan(t,ts,frame,head.used,true);
      r := if fields.BadFields? then Rejected else Parsed(Items(fields.values),base+fields.end);
  }

  ghost method Scan(owner: AbiType, ts: seq<AbiType>, bs: seq<Byte>, initialTail: nat, uniform: bool)
    returns (r: FieldsResult)
    requires Types(ts) && Below(owner,ts) && Uint(|bs|)
    requires forall i :: 0 <= i < |ts| ==> ShapesFit(ts[i])
    requires initialTail == ListHead(ts) && initialTail <= |bs|
    requires uniform && |ts| > 0 ==> forall i :: 0 <= i < |ts| ==> ts[i] == ts[0]
    ensures r == WalkFields(owner,ts,bs,0,initialTail)
    decreases owner, 1
  {
    var i: nat := 0;
    var head: nat := 0;
    var tail: nat := initialTail;
    var values: seq<Value> := [];
    while i < |ts|
      invariant 0 <= i <= |ts|
      invariant head == ListHead(ts[..i])
      invariant head+ListHead(ts[i..]) == initialTail <= tail <= |bs|
      invariant WalkFields(owner,ts,bs,0,initialTail) == Prefix(values,WalkFields(owner,ts[i..],bs,head,tail))
      decreases |ts|-i
    {
      var rest := ts[i..];
      assert rest[0] == ts[i] && rest[1..] == ts[i+1..];
      HeadAppend(ts,i);
      NonemptyHead(ts[i]);
      var dynamic := IsDynamic(ts[i]);
      var width := 32*HeadWords(ts[i]);
      if uniform {
        assert ts == seq(|ts|,j requires 0 <= j < |ts| => ts[0]);
        assert ts[..i] == seq(i,j requires 0 <= j < i => ts[0]);
        RepeatedHead(ts[0],|ts|);
        RepeatedHead(ts[0],i);
        var position := ArrayPosition(bs,0,|ts|,HeadWords(ts[0]),i);
        assert position.used == head;
      }
      if dynamic {
        var offset: Outcome;
        if uniform { offset := ArrayOffset(bs,head,tail); }
        else { offset := TupleOffset(bs,0,head,tail); }
        if !offset.Ok? { r := BadFields; return; }
      }
      var start := if dynamic then tail else head;
      var child := ComposedWalk(ts[i],bs[start..]);
      if child.Rejected? { r := BadFields; return; }
      if !dynamic { StaticExtent(ts[i],bs[start..]); }
      var next := tail;
      if dynamic {
        var advanced: Outcome;
        if uniform { advanced := ArrayTailAdvance(bs,0,tail,child.used); }
        else { advanced := TupleTailAdvance(bs,0,tail,child.used); }
        next := advanced.used;
      }
      var remaining := WalkFields(owner,rest[1..],bs,head+width,next);
      assert WalkFields(owner,rest,bs,head,tail) == Prefix([child.value],remaining);
      PrefixStep(values,child.value,remaining);
      values := values+[child.value];
      head := head+width;
      assert Uint(head);
      tail := next;
      i := i+1;
    }
    r := Fields(values,tail);
  }

  ghost method CanonicalAggregate(t: AbiType, bs: seq<Byte>) returns (accepted: bool)
    requires ShapesFit(t) && Uint(|bs|)
    ensures accepted <==> Validate(t,bs).Parsed?
    ensures accepted <==> exists value :: WellTyped(t,value) && Fits(t,value) && Encode(t,value) == bs
  {
    var prefix: nat := if IsDynamic(t) then 32 else 0;
    if |bs| < prefix {
      accepted := false;
    } else if IsDynamic(t) && ReadNat(bs[..32]) != 32 {
      accepted := false;
    } else {
      var r := ComposedWalk(t,bs[prefix..]);
      accepted := r.Parsed? && prefix+r.used == |bs|;
    }
    AcceptedIffCanonical(t,bs);
  }
}

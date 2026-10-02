// SPDX-License-Identifier: MIT
include "Encoding.dfy"

// Independent prefix walker: no encoder or encoded-value equality appears in
// its decisions. Integers/sequences are mathematical, not EVM allocations.
module AbiValidation {
  import opened AbiFrames
  import opened AbiEncoding

  datatype Parsed = Rejected | Parsed(value: Value, used: nat)
  datatype FieldsResult = BadFields | Fields(values: seq<Value>, end: nat)

  ghost predicate Types(ts: seq<AbiType>)
  { forall i :: 0 <= i < |ts| ==> WellFormed(ts[i]) }

  ghost predicate Below(owner: AbiType, ts: seq<AbiType>)
  { forall i :: 0 <= i < |ts| ==> ts[i] < owner }

  ghost predicate TypedList(ts: seq<AbiType>, vs: seq<Value>)
  { |ts| == |vs| && forall i :: 0 <= i < |ts| ==> WellTyped(ts[i],vs[i]) }

  ghost function ListHead(ts: seq<AbiType>): nat
    decreases |ts|
  { if |ts| == 0 then 0 else 32 * HeadWords(ts[0]) + ListHead(ts[1..]) }

  ghost function Children(t: AbiType, n: nat): seq<AbiType>
    requires WellFormed(t) && (t.Tuple? || t.FixedArray? || t.Array?)
    requires t.Tuple? ==> n == |t.fields|
    requires t.FixedArray? ==> n == t.count
    ensures |Children(t,n)| == n
    ensures Types(Children(t,n)) && Below(t,Children(t,n))
  { seq(n, i requires 0 <= i < n => Child(t,i)) }

  ghost function ListParts(ts: seq<AbiType>, vs: seq<Value>): seq<Piece>
    requires TypedList(ts,vs)
  { seq(|ts|, i requires 0 <= i < |ts| => Piece(IsDynamic(ts[i]),Body(ts[i],vs[i]))) }

  lemma SplitList(ts: seq<AbiType>, vs: seq<Value>)
    requires TypedList(ts,vs) && |ts| > 0
    ensures TypedList(ts[1..],vs[1..])
    ensures ListParts(ts,vs) == [Piece(IsDynamic(ts[0]),Body(ts[0],vs[0]))] + ListParts(ts[1..],vs[1..])
  {
    assert ListParts(ts,vs)[1..] == ListParts(ts[1..],vs[1..]);
  }

  lemma ListHeadMatches(ts: seq<AbiType>, vs: seq<Value>)
    requires TypedList(ts,vs)
    ensures Types(ts)
    ensures ListHead(ts) == HeadSize(ListParts(ts,vs))
    decreases |ts|
  {
    if |ts| > 0 {
      SplitList(ts,vs);
      HeadFootprint(ts[0],vs[0]);
      ListHeadMatches(ts[1..],vs[1..]);
    }
  }

  lemma AggregateParts(t: AbiType, vs: seq<Value>)
    requires WellFormed(t) && (t.Tuple? || t.FixedArray? || t.Array?)
    requires t.Tuple? ==> |vs| == |t.fields|
    requires t.FixedArray? ==> |vs| == t.count
    requires TypedList(Children(t,|vs|),vs)
    ensures WellTyped(t,Items(vs))
    ensures Parts(t,Items(vs)) == ListParts(Children(t,|vs|),vs)
  {}

  ghost function Walk(t: AbiType, bs: seq<Byte>): Parsed
    requires WellFormed(t)
    ensures Walk(t,bs).Parsed? ==> Walk(t,bs).used <= |bs|
    decreases t, 2, 0
  {
    match t
    case Scalar(r) =>
      if |bs| < 32 || !CanonicalWord(r,ReadNat(bs[..32])) then Rejected
      else Parsed(Atom(ReadNat(bs[..32])),32)
    case Bytes => WalkBytes(bs)
    case String => WalkBytes(bs)
    case Tuple(ts) => WalkFrame(t,ts,bs)
    case FixedArray(e,n) => WalkFrame(t,Children(t,n),bs)
    case Array(e) =>
      if |bs| < 32 then Rejected else
      var n := ReadNat(bs[..32]);
      var r := WalkFrame(t,Children(t,n),bs[32..]);
      if r.Rejected? then Rejected else Parsed(r.value,32+r.used)
  }

  ghost function WalkFrame(owner: AbiType, ts: seq<AbiType>, bs: seq<Byte>): Parsed
    requires Types(ts) && Below(owner,ts)
    ensures WalkFrame(owner,ts,bs).Parsed? ==> WalkFrame(owner,ts,bs).used <= |bs|
    decreases owner, 1, 0
  {
    var size := ListHead(ts);
    if size > |bs| then Rejected else
    var r := WalkFields(owner,ts,bs,0,size);
    if r.BadFields? then Rejected else Parsed(Items(r.values),r.end)
  }

  // Public single-value validation requires the dynamic envelope and exact
  // consumption. The prefix walker deliberately permits following siblings.
  ghost function Validate(t: AbiType, bs: seq<Byte>): Parsed
    requires WellFormed(t)
    ensures Validate(t,bs).Parsed? ==> Validate(t,bs).used == |bs|
  {
    var prefix := if IsDynamic(t) then 32 else 0;
    if prefix > |bs| || (IsDynamic(t) && ReadNat(bs[..32]) != 32) then Rejected else
    var r := Walk(t,bs[prefix..]);
    if r.Rejected? || prefix+r.used != |bs| then Rejected else Parsed(r.value,|bs|)
  }

  // head and tail are relative to the start of this frame, including when the
  // frame follows a dynamic array's count word. The next offset must equal tail.
  ghost function WalkFields(owner: AbiType, ts: seq<AbiType>, bs: seq<Byte>, head: nat, tail: nat): FieldsResult
    requires Types(ts) && Below(owner,ts)
    requires head + ListHead(ts) <= tail <= |bs|
    ensures WalkFields(owner,ts,bs,head,tail).Fields? ==>
              tail <= WalkFields(owner,ts,bs,head,tail).end <= |bs|
    decreases owner, 0, |ts|
  {
    if |ts| == 0 then Fields([],tail) else
    var dynamic := IsDynamic(ts[0]);
    var width := 32 * HeadWords(ts[0]);
    if dynamic && ReadNat(bs[head..head+32]) != tail then BadFields else
    var child := Walk(ts[0],bs[(if dynamic then tail else head)..]);
    if child.Rejected? || (!dynamic && child.used != width) then BadFields else
    var rest := WalkFields(owner,ts[1..],bs,head+width,tail+(if dynamic then child.used else 0));
    if rest.BadFields? then BadFields else Fields([child.value]+rest.values,rest.end)
  }

  predicate ZeroRegion(bs: seq<Byte>, start: nat, end: nat)
    requires start <= end <= |bs|
  { forall i :: start <= i < end ==> bs[i] == 0 }

  function WalkBytes(bs: seq<Byte>): Parsed
    ensures WalkBytes(bs).Parsed? ==> WalkBytes(bs).used <= |bs|
  {
    if |bs| < 32 then Rejected else
    var n := ReadNat(bs[..32]);
    var end := 32 + n + Padding(n);
    if end > |bs| || !ZeroRegion(bs, 32+n, end) then Rejected
    else Parsed(Buffer(bs[32..32+n]), end)
  }

  lemma ZeroRegionIsZeros(bs: seq<Byte>, start: nat, end: nat)
    requires start <= end <= |bs| && ZeroRegion(bs,start,end)
    ensures bs[start..end] == Zeros(end-start)
  {
    assert forall i :: 0 <= i < end-start ==> bs[start..end][i] == Zeros(end-start)[i];
  }

  lemma BytesSound(bs: seq<Byte>)
    requires WalkBytes(bs).Parsed?
    ensures WalkBytes(bs).used <= |bs|
    ensures WellTyped(Bytes, WalkBytes(bs).value)
    ensures bs[..WalkBytes(bs).used] == Body(Bytes,WalkBytes(bs).value)
  {
    var n := ReadNat(bs[..32]);
    var end := 32+n+Padding(n);
    BytesNatRoundTrip(bs[..32]);
    ZeroRegionIsZeros(bs,32+n,end);
    assert bs[..end] == bs[..32]+bs[32..32+n]+bs[32+n..end];
  }

  lemma BytesComplete(payload: seq<Byte>, suffix: seq<Byte>)
    requires |payload| < Pow256(32)
    ensures WalkBytes(Body(Bytes,Buffer(payload))+suffix)
         == Parsed(Buffer(payload), |Body(Bytes,Buffer(payload))|)
  {
    var body := Body(Bytes,Buffer(payload));
    BytePayload(Bytes,payload);
    assert (body+suffix)[..32] == body[..32];
    assert (body+suffix)[32..32+|payload|] == payload;
    assert ZeroRegion(body+suffix,32+|payload|,|body|);
  }

  lemma WalkSound(t: AbiType, bs: seq<Byte>)
    requires WellFormed(t) && Walk(t,bs).Parsed?
    ensures WellTyped(t,Walk(t,bs).value)
    ensures bs[..Walk(t,bs).used] == Body(t,Walk(t,bs).value)
    decreases t, 2, 0
  {
    match t
    case Scalar(r) => BytesNatRoundTrip(bs[..32]);
    case Bytes => BytesSound(bs);
    case String => BytesSound(bs);
    case _ =>
      var n := if t.Array? then ReadNat(bs[..32]) else if t.Tuple? then |t.fields| else t.count;
      var ts := Children(t,n);
      var frame := if t.Array? then bs[32..] else bs;
      if t.Tuple? { assert ts == t.fields; }
      FrameSound(t,ts,frame);
      var r := WalkFrame(t,ts,frame);
      AggregateParts(t,r.value.values);
      if t.Array? {
        BytesNatRoundTrip(bs[..32]);
        assert bs[..32+r.used] == bs[..32]+frame[..r.used];
      }
  }

  lemma FrameSound(owner: AbiType, ts: seq<AbiType>, bs: seq<Byte>)
    requires Types(ts) && Below(owner,ts) && WalkFrame(owner,ts,bs).Parsed?
    ensures WalkFrame(owner,ts,bs).value.Items?
    ensures TypedList(ts,WalkFrame(owner,ts,bs).value.values)
    ensures bs[..WalkFrame(owner,ts,bs).used] == Frame(ListParts(ts,WalkFrame(owner,ts,bs).value.values))
    decreases owner, 1, 0
  {
    var size := ListHead(ts);
    FieldsSound(owner,ts,bs,0,size);
    var r := WalkFields(owner,ts,bs,0,size);
    ListHeadMatches(ts,r.values);
    assert bs[..r.end] == bs[..size]+bs[size..r.end];
  }

  lemma FieldsSound(owner: AbiType, ts: seq<AbiType>, bs: seq<Byte>, head: nat, tail: nat)
    requires Types(ts) && Below(owner,ts)
    requires head + ListHead(ts) <= tail <= |bs|
    requires WalkFields(owner,ts,bs,head,tail).Fields?
    ensures TypedList(ts,WalkFields(owner,ts,bs,head,tail).values)
    ensures var ps := ListParts(ts,WalkFields(owner,ts,bs,head,tail).values);
            head+HeadSize(ps) <= |bs| &&
            bs[head..head+HeadSize(ps)] == Heads(ps,tail) &&
            WalkFields(owner,ts,bs,head,tail).end == tail+TailSize(ps) &&
            bs[tail..WalkFields(owner,ts,bs,head,tail).end] == Tails(ps)
    decreases owner, 0, |ts|
  {
    if |ts| > 0 {
      var dynamic := IsDynamic(ts[0]);
      var width := 32*HeadWords(ts[0]);
      var start := if dynamic then tail else head;
      var child := Walk(ts[0],bs[start..]);
      WalkSound(ts[0],bs[start..]);
      var next := tail+(if dynamic then child.used else 0);
      FieldsSound(owner,ts[1..],bs,head+width,next);
      var rest := WalkFields(owner,ts[1..],bs,head+width,next);
      var vs := [child.value]+rest.values;
      assert TypedList(ts,vs);
      SplitList(ts,vs);
      ListHeadMatches(ts,vs);
      var ps := ListParts(ts,vs);
      var body := Body(ts[0],child.value);
      assert bs[start..start+child.used] == body;
      assert |body| == child.used;
      if dynamic { BytesNatRoundTrip(bs[head..head+32]); }
      assert bs[head..head+HeadSize(ps)] == bs[head..head+width]+bs[head+width..head+HeadSize(ps)];
      assert bs[tail..rest.end] == bs[tail..next]+bs[next..rest.end];
    }
  }

  lemma WalkComplete(t: AbiType, v: Value, suffix: seq<Byte>)
    requires WellTyped(t,v) && Fits(t,v)
    ensures Walk(t,Body(t,v)+suffix) == Parsed(v,|Body(t,v)|)
    decreases t, 2, 0
  {
    EncodedLengthsFit(t,v);
    match t
    case Scalar(r) => NatBytesRoundTrip(v.word,32);
    case Bytes => BytesComplete(v.payload,suffix);
    case String => BytesComplete(v.payload,suffix);
    case _ =>
      var ts := Children(t,|v.values|);
      assert TypedList(ts,v.values);
      AggregateParts(t,v.values);
      if t.Tuple? { assert ts == t.fields; }
      FrameComplete(t,ts,v.values,suffix);
      if t.Array? {
        NatBytesRoundTrip(|v.values|,32);
        assert (Body(t,v)+suffix)[..32] == Word(|v.values|);
        assert (Body(t,v)+suffix)[32..] == Frame(Parts(t,v))+suffix;
      }
  }

  lemma FrameComplete(owner: AbiType, ts: seq<AbiType>, vs: seq<Value>, suffix: seq<Byte>)
    requires TypedList(ts,vs) && Below(owner,ts)
    requires forall i :: 0 <= i < |ts| ==> Fits(ts[i],vs[i])
    requires HeadSize(ListParts(ts,vs))+TailSize(ListParts(ts,vs)) < Pow256(32)
    ensures WalkFrame(owner,ts,Frame(ListParts(ts,vs))+suffix) == Parsed(Items(vs),|Frame(ListParts(ts,vs))|)
    decreases owner, 1, 0
  {
    var ps := ListParts(ts,vs);
    var bs := Frame(ps)+suffix;
    ListHeadMatches(ts,vs);
    Sizes(ps,HeadSize(ps));
    assert bs[..HeadSize(ps)] == Heads(ps,HeadSize(ps));
    assert bs[HeadSize(ps)..HeadSize(ps)+TailSize(ps)] == Tails(ps);
    FieldsComplete(owner,ts,vs,bs,0,HeadSize(ps));
  }

  lemma SplitSlice(bs: seq<Byte>, start: nat, a: seq<Byte>, b: seq<Byte>)
    requires start+|a|+|b| <= |bs|
    requires bs[start..start+|a|+|b|] == a+b
    ensures bs[start..start+|a|] == a
    ensures bs[start+|a|..start+|a|+|b|] == b
  {
    var whole := bs[start..start+|a|+|b|];
    assert whole[..|a|] == a;
    assert whole[|a|..] == b;
  }

  lemma FieldsComplete(owner: AbiType, ts: seq<AbiType>, vs: seq<Value>, bs: seq<Byte>, head: nat, tail: nat)
    requires TypedList(ts,vs) && Types(ts) && Below(owner,ts)
    requires forall i :: 0 <= i < |ts| ==> Fits(ts[i],vs[i])
    requires head+ListHead(ts) <= tail <= |bs|
    requires head+HeadSize(ListParts(ts,vs)) <= tail
    requires tail+TailSize(ListParts(ts,vs)) <= |bs|
    requires tail+TailSize(ListParts(ts,vs)) < Pow256(32)
    requires bs[head..head+HeadSize(ListParts(ts,vs))] == Heads(ListParts(ts,vs),tail)
    requires bs[tail..tail+TailSize(ListParts(ts,vs))] == Tails(ListParts(ts,vs))
    ensures WalkFields(owner,ts,bs,head,tail) == Fields(vs,tail+TailSize(ListParts(ts,vs)))
    decreases owner, 0, |ts|
  {
    if |ts| > 0 {
      SplitList(ts,vs);
      var ps := ListParts(ts,vs);
      var rest := ListParts(ts[1..],vs[1..]);
      var body := Body(ts[0],vs[0]);
      var dynamic := IsDynamic(ts[0]);
      var width := 32*HeadWords(ts[0]);
      var next := tail+(if dynamic then |body| else 0);
      var start := if dynamic then tail else head;
      HeadFootprint(ts[0],vs[0]);
      ListHeadMatches(ts[1..],vs[1..]);
      Sizes(rest,next);
      assert ps[0] == Piece(dynamic,body) && ps[1..] == rest;
      assert Heads(ps,tail) == (if dynamic then Word(tail) else body) + Heads(rest,next);
      assert Tails(ps) == (if dynamic then body else []) + Tails(rest);
      assert TailSize(ps) == (if dynamic then |body| else 0) + TailSize(rest);
      assert head+HeadSize(ps) == head+width+HeadSize(rest);
      SplitSlice(bs,head,(if dynamic then Word(tail) else body),Heads(rest,next));
      SplitSlice(bs,tail,(if dynamic then body else []),Tails(rest));
      assert bs[head+width..head+width+HeadSize(rest)] == Heads(rest,next);
      assert bs[next..next+TailSize(rest)] == Tails(rest);
      assert start+|body| <= |bs|;
      assert bs[start..start+|body|] == body;
      assert bs[start..] == body+bs[start+|body|..];
      WalkComplete(ts[0],vs[0],bs[start+|body|..]);
      if dynamic {
        assert bs[head..head+32] == Word(tail);
        NatBytesRoundTrip(tail,32);
      }
      FieldsComplete(owner,ts[1..],vs[1..],bs,head+width,next);
      assert vs == [vs[0]]+vs[1..];
    } else { assert vs == []; }
  }

  lemma ValidationSound(t: AbiType, bs: seq<Byte>)
    requires WellFormed(t) && Validate(t,bs).Parsed?
    ensures WellTyped(t,Validate(t,bs).value)
    ensures Encode(t,Validate(t,bs).value) == bs
  {
    var prefix := if IsDynamic(t) then 32 else 0;
    WalkSound(t,bs[prefix..]);
    if IsDynamic(t) { BytesNatRoundTrip(bs[..32]); }
    assert bs == bs[..prefix]+bs[prefix..];
  }

  lemma ValidationComplete(t: AbiType, v: Value)
    requires WellTyped(t,v) && Fits(t,v)
    ensures Validate(t,Encode(t,v)) == Parsed(v,|Encode(t,v)|)
  {
    SingleValueEnvelope(t,v);
    WalkComplete(t,v,[]);
    var bs := Encode(t,v);
    var prefix := if IsDynamic(t) then 32 else 0;
    assert bs[prefix..] == Body(t,v)+[];
    assert Walk(t,bs[prefix..]) == Parsed(v,|Body(t,v)|);
    assert prefix+|Body(t,v)| == |bs|;
  }

  lemma EncodingInjective(t: AbiType, a: Value, b: Value)
    requires WellTyped(t,a) && Fits(t,a) && WellTyped(t,b) && Fits(t,b)
    requires Encode(t,a) == Encode(t,b)
    ensures a == b
  {
    ValidationComplete(t,a);
    ValidationComplete(t,b);
  }

  lemma AcceptedIffCanonical(t: AbiType, bs: seq<Byte>)
    requires WellFormed(t) && |bs| < Pow256(32)
    ensures Validate(t,bs).Parsed? <==>
            exists v :: WellTyped(t,v) && Fits(t,v) && Encode(t,v) == bs
  {
    if Validate(t,bs).Parsed? {
      ValidationSound(t,bs);
      var v := Validate(t,bs).value;
      FitsFromSize(t,v);
      assert WellTyped(t,v) && Fits(t,v) && Encode(t,v) == bs;
      assert exists w :: WellTyped(t,w) && Fits(t,w) && Encode(t,w) == bs;
    } else if exists v :: WellTyped(t,v) && Fits(t,v) && Encode(t,v) == bs {
      var v :| WellTyped(t,v) && Fits(t,v) && Encode(t,v) == bs;
      ValidationComplete(t,v);
    }
  }

  lemma RejectTrailing(t: AbiType, v: Value, suffix: seq<Byte>)
    requires WellTyped(t,v) && Fits(t,v) && |suffix| > 0
    ensures Validate(t,Encode(t,v)+suffix).Rejected?
  {
    var bs := Encode(t,v)+suffix;
    WalkComplete(t,v,suffix);
    if IsDynamic(t) {
      assert bs[32..] == Body(t,v)+suffix;
    }
    var prefix := if IsDynamic(t) then 32 else 0;
    assert bs[prefix..] == Body(t,v)+suffix;
    assert Walk(t,bs[prefix..]) == Parsed(v,|Body(t,v)|);
    assert prefix+|Body(t,v)| < |bs|;
  }

  lemma RejectEnvelope(t: AbiType, header: seq<Byte>, rest: seq<Byte>)
    requires WellFormed(t) && IsDynamic(t)
    requires |header| == 32 && ReadNat(header) != 32
    ensures Validate(t,header+rest).Rejected?
  { assert (header+rest)[..32] == header; }

  lemma RejectTruncatedBytes(bs: seq<Byte>)
    requires |bs| < 32 || 32+ReadNat(bs[..32])+Padding(ReadNat(bs[..32])) > |bs|
    ensures WalkBytes(bs).Rejected?
  {}

  lemma RejectDirtyPadding(bs: seq<Byte>, i: nat)
    requires |bs| >= 32
    requires var n := ReadNat(bs[..32]); 32+n <= i < 32+n+Padding(n) <= |bs|
    requires bs[i] != 0
    ensures WalkBytes(bs).Rejected?
  {}

  lemma RejectNoncanonicalScalar(r: WordRule, w: nat)
    requires ValidRule(r) && w < Pow256(32) && !CanonicalWord(r,w)
    ensures Validate(Scalar(r),Word(w)).Rejected?
  {
    NatBytesRoundTrip(w,32);
    assert Word(w)[..32] == Word(w);
    assert Walk(Scalar(r),Word(w)) == Rejected;
  }

  lemma RejectLooseOffset(owner: AbiType, ts: seq<AbiType>, bs: seq<Byte>, head: nat, tail: nat)
    requires Types(ts) && Below(owner,ts) && |ts| > 0 && IsDynamic(ts[0])
    requires head+ListHead(ts) <= tail <= |bs|
    requires ReadNat(bs[head..head+32]) != tail
    ensures WalkFields(owner,ts,bs,head,tail).BadFields?
  {}
}

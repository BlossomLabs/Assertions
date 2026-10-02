// SPDX-License-Identifier: MIT
include "Frames.dfy"

module AbiEncoding {
  import opened AbiFrames

  // Names are classified separately by the Solidity parser. Opaque represents
  // full-width words and unrecognized names, not a claim that solc accepts them.
  datatype WordRule = Opaque | Unsigned(bits: nat) | Signed(bits: nat)
                    | HighBytes(count: nat) | Address | Boolean | Function
  datatype AbiType = Scalar(rule: WordRule) | Bytes | String
                   | Tuple(fields: seq<AbiType>)
                   | FixedArray(element: AbiType, count: nat)
                   | Array(element: AbiType)
  datatype Value = Atom(word: nat) | Buffer(payload: seq<Byte>) | Items(values: seq<Value>)

  function Pow2(n: nat): nat
    ensures Pow2(n) > 0
    decreases n
  { if n == 0 then 1 else 2 * Pow2(n-1) }

  predicate ValidRule(r: WordRule) {
    match r
    case Unsigned(b) => 8 <= b <= 256 && b % 8 == 0
    case Signed(b) => 8 <= b <= 256 && b % 8 == 0
    case HighBytes(n) => 1 <= n <= 32
    case _ => true
  }

  predicate CanonicalWord(r: WordRule, w: nat)
    requires ValidRule(r)
  {
    w < Pow256(32) &&
    match r
    case Opaque => true
    case Unsigned(b) => w < Pow2(b)
    case Signed(b) => w < Pow2(b-1) || w >= Pow256(32)-Pow2(b-1)
    case HighBytes(n) => w % Pow256(32-n) == 0
    case Address => w < Pow256(20)
    case Boolean => w <= 1
    case Function => w % Pow256(8) == 0
  }

  ghost predicate WellFormed(t: AbiType)
    decreases t
  {
    match t
    case Scalar(r) => ValidRule(r)
    case Bytes => true
    case String => true
    case Tuple(ts) => |ts| > 0 && forall i :: 0 <= i < |ts| ==> WellFormed(ts[i])
    case FixedArray(e, n) => 0 < n < Pow256(4) && WellFormed(e) && (IsDynamic(e) || n * HeadWords(e) < Pow256(4))
    case Array(e) => WellFormed(e)
  }

  ghost predicate WellTyped(t: AbiType, v: Value)
    decreases t
  {
    WellFormed(t) &&
    match t
    case Scalar(r) => v.Atom? && CanonicalWord(r, v.word)
    case Bytes => v.Buffer?
    case String => v.Buffer?
    case Tuple(ts) => v.Items? && |v.values| == |ts| &&
                      forall i :: 0 <= i < |ts| ==> WellTyped(ts[i], v.values[i])
    case FixedArray(e, n) => v.Items? && |v.values| == n &&
                             forall i :: 0 <= i < n ==> WellTyped(e, v.values[i])
    case Array(e) => v.Items? && (forall i :: 0 <= i < |v.values| ==> WellTyped(e, v.values[i]))
  }

  ghost function IsDynamic(t: AbiType): bool
    decreases t
  {
    match t
    case Scalar(_) => false
    case Bytes => true
    case String => true
    case Tuple(ts) => exists i :: 0 <= i < |ts| && IsDynamic(ts[i])
    case FixedArray(e, _) => IsDynamic(e)
    case Array(_) => true
  }

  function Sum(ns: seq<nat>): nat
    decreases |ns|
  { if |ns| == 0 then 0 else ns[0] + Sum(ns[1..]) }

  ghost function HeadWords(t: AbiType): nat
    decreases t
  {
    if IsDynamic(t) then 1 else
    match t
    case Scalar(_) => 1
    case Tuple(ts) => Sum(seq(|ts|, i requires 0 <= i < |ts| => HeadWords(ts[i])))
    case FixedArray(e, n) => n * HeadWords(e)
    case _ => 1
  }

  ghost function Child(t: AbiType, i: nat): AbiType
    requires t.Tuple? || t.FixedArray? || t.Array?
    requires t.Tuple? ==> i < |t.fields|
    ensures Child(t, i) < t
  { if t.Tuple? then t.fields[i] else t.element }

  ghost function Parts(t: AbiType, v: Value): seq<Piece>
    requires WellTyped(t, v) && (t.Tuple? || t.FixedArray? || t.Array?)
    decreases t, 0
  {
    seq(|v.values|, i requires 0 <= i < |v.values| => Piece(IsDynamic(Child(t,i)), Body(Child(t,i),v.values[i])))
  }

  // Body never writes an enclosing offset. Dynamic arrays alone add a count
  // before their element frame; fixed arrays and tuples do not.
  ghost function Body(t: AbiType, v: Value): seq<Byte>
    requires WellTyped(t, v)
    decreases t, 1
  {
    match t
    case Scalar(_) => Word(v.word)
    case Bytes => Word(|v.payload|) + Padded(v.payload)
    case String => Word(|v.payload|) + Padded(v.payload)
    case Array(_) => Word(|v.values|) + Frame(Parts(t,v))
    case _ => Frame(Parts(t,v))
  }

  ghost function Encode(t: AbiType, v: Value): seq<Byte>
    requires WellTyped(t, v)
  { (if IsDynamic(t) then Word(32) else []) + Body(t,v) }

  // This is a representability condition, not an implementation validation
  // predicate. It prevents truncation of length and offset words at every level.
  ghost predicate Fits(t: AbiType, v: Value)
    requires WellTyped(t,v)
    decreases t
  {
    |Encode(t,v)| < Pow256(32) &&
    if t.Tuple? || t.FixedArray? || t.Array? then
      forall i :: 0 <= i < |v.values| ==> Fits(Child(t,i),v.values[i])
    else true
  }

  lemma NonemptyHead(t: AbiType)
    requires WellFormed(t)
    ensures HeadWords(t) > 0
    decreases t
  {
    if !IsDynamic(t) {
      match t
      case Tuple(ts) =>
        NonemptyHead(ts[0]);
        assert seq(|ts|, i requires 0 <= i < |ts| => HeadWords(ts[i]))[0] == HeadWords(ts[0]);
      case FixedArray(e,n) => NonemptyHead(e);
      case _ =>
    }
  }

  lemma BodiesAreFrames(t: AbiType, v: Value)
    requires WellTyped(t,v)
    ensures |Body(t,v)| > 0 && |Body(t,v)| % 32 == 0
    ensures |Encode(t,v)| > 0 && |Encode(t,v)| % 32 == 0
    ensures t.Tuple? || t.FixedArray? || t.Array? ==> ValidPieces(Parts(t,v))
    decreases t
  {
    match t
    case Scalar(_) =>
    case Bytes => PaddingLayout(v.payload);
    case String => PaddingLayout(v.payload);
    case _ =>
      forall i | 0 <= i < |v.values|
        ensures |Body(Child(t,i),v.values[i])| > 0
                && |Body(Child(t,i),v.values[i])| % 32 == 0
      {
        BodiesAreFrames(Child(t,i),v.values[i]);
      }
      assert ValidPieces(Parts(t,v));
      FrameAligned(Parts(t,v));
      Sizes(Parts(t,v), HeadSize(Parts(t,v)));
      if !t.Array? {
        assert |Parts(t,v)| > 0;
        assert HeadSize(Parts(t,v)) > 0;
      }
  }

  lemma SingleValueEnvelope(t: AbiType, v: Value)
    requires WellTyped(t,v)
    ensures IsDynamic(t) ==> Encode(t,v)[..32] == Word(32)
    ensures IsDynamic(t) ==> Encode(t,v)[32..] == Body(t,v)
    ensures !IsDynamic(t) ==> Encode(t,v) == Body(t,v)
    ensures IsDynamic(t) ==> ReadNat(Encode(t,v)[..32]) == 32
  { NatBytesRoundTrip(32,32); }

  lemma BytePayload(t: AbiType, data: seq<Byte>)
    requires t.Bytes? || t.String?
    requires |data| < Pow256(32)
    ensures ReadNat(Body(t,Buffer(data))[..32]) == |data|
    ensures Body(t,Buffer(data))[32..32+|data|] == data
    ensures forall i :: 32+|data| <= i < |Body(t,Buffer(data))| ==> Body(t,Buffer(data))[i] == 0
  {
    NatBytesRoundTrip(|data|,32);
    PaddingLayout(data);
  }
  lemma HeadSum(ps: seq<Piece>, ws: seq<nat>)
    requires |ps| == |ws|
    requires forall i :: 0 <= i < |ps| ==>
                           (if ps[i].dynamic then 32 else |ps[i].data|) == 32 * ws[i]
    ensures HeadSize(ps) == 32 * Sum(ws)
    decreases |ps|
  {
    if |ps| > 0 { HeadSum(ps[1..],ws[1..]); }
  }

  lemma NoStaticTails(ps: seq<Piece>)
    requires forall i :: 0 <= i < |ps| ==> !ps[i].dynamic
    ensures TailSize(ps) == 0
    decreases |ps|
  {
    if |ps| > 0 { NoStaticTails(ps[1..]); }
  }

  lemma SumRepeated(n: nat, w: nat)
    ensures Sum(seq(n, i => w)) == n * w
    decreases n
  {
    if n > 0 {
      assert seq(n, i => w)[1..] == seq(n-1, i => w);
      SumRepeated(n-1,w);
    }
  }

  // Static footprints hold for arbitrary nesting, not only word-sized leaves.
  lemma StaticFootprint(t: AbiType, v: Value)
    requires WellTyped(t,v)
    ensures !IsDynamic(t) ==> |Body(t,v)| == 32 * HeadWords(t)
    decreases t
  {
    if !IsDynamic(t) {
      match t
      case Scalar(_) =>
      case Tuple(ts) =>
        var ps := Parts(t,v);
        var ws := seq(|ts|, i requires 0 <= i < |ts| => HeadWords(ts[i]));
        forall i | 0 <= i < |ts|
          ensures !ps[i].dynamic && |ps[i].data| == 32 * ws[i]
        {
          StaticFootprint(ts[i],v.values[i]);
        }
        HeadSum(ps,ws);
        NoStaticTails(ps);
        Sizes(ps,HeadSize(ps));
      case FixedArray(e,n) =>
        var ps := Parts(t,v);
        var ws := seq(n, i => HeadWords(e));
        forall i | 0 <= i < n
          ensures !ps[i].dynamic && |ps[i].data| == 32 * ws[i]
        {
          StaticFootprint(e,v.values[i]);
        }
        HeadSum(ps,ws);
        SumRepeated(n,HeadWords(e));
        NoStaticTails(ps);
        Sizes(ps,HeadSize(ps));
      case _ =>
    }
  }

  lemma HeadFootprint(t: AbiType, v: Value)
    requires WellTyped(t,v)
    ensures (if IsDynamic(t) then 32 else |Body(t,v)|) == 32 * HeadWords(t)
  { StaticFootprint(t,v); }

  // Both empty dynamic arrays and arrays of dynamic elements use this frame.
  // The count is outside it: element offsets MUST NOT include that word.
  lemma ArrayCount(t: AbiType, v: Value)
    requires WellTyped(t,v) && t.Array?
    requires |v.values| < Pow256(32)
    ensures |Body(t,v)| >= 32
    ensures ReadNat(Body(t,v)[..32]) == |v.values|
    ensures Body(t,v)[32..] == Frame(Parts(t,v))
  { NatBytesRoundTrip(|v.values|,32); }

  lemma EncodedLengthsFit(t: AbiType, v: Value)
    requires WellTyped(t,v) && Fits(t,v)
    ensures t.Array? ==> |v.values| < Pow256(32)
    ensures t.Bytes? || t.String? ==> |v.payload| < Pow256(32)
    ensures t.Tuple? || t.FixedArray? || t.Array? ==>
              HeadSize(Parts(t,v)) + TailSize(Parts(t,v)) < Pow256(32)
  {
    if t.Tuple? || t.FixedArray? || t.Array? {
      BodiesAreFrames(t,v);
      MinimumHead(Parts(t,v));
      Sizes(Parts(t,v),HeadSize(Parts(t,v)));
    }
  }

  lemma ChildEncodingBound(t: AbiType, v: Value, i: nat)
    requires WellTyped(t,v) && (t.Tuple? || t.FixedArray? || t.Array?)
    requires i < |v.values|
    ensures |Encode(Child(t,i),v.values[i])| <= |Encode(t,v)|
  {
    var ps := Parts(t,v);
    BodiesAreFrames(t,v);
    MinimumHead(ps);
    Sizes(ps,HeadSize(ps));
    ComponentLayout(ps,i);
    if ps[i].dynamic {
      assert HeadSize(ps) >= 32;
      assert |ps[i].data| <= TailSize(ps);
    }
  }

  // Nested values cannot exceed their enclosing single-value encoding. This
  // derives the recursive fit predicate from one top-level byte-length bound.
  lemma FitsFromSize(t: AbiType, v: Value)
    requires WellTyped(t,v) && |Encode(t,v)| < Pow256(32)
    ensures Fits(t,v)
    decreases t
  {
    if t.Tuple? || t.FixedArray? || t.Array? {
      forall i | 0 <= i < |v.values|
        ensures Fits(Child(t,i),v.values[i])
      {
        ChildEncodingBound(t,v,i);
        FitsFromSize(Child(t,i),v.values[i]);
      }
    }
  }

  // Returned coordinates are relative to the element frame. The equation for
  // Body explicitly supplies the parent prefix, making relocation compositional.
  lemma RecursiveChildLayout(t: AbiType, v: Value, i: nat)
    returns (frame: seq<Byte>, head: nat, offset: nat, child: seq<Byte>)
    requires WellTyped(t,v) && (t.Tuple? || t.FixedArray? || t.Array?)
    requires i < |v.values| && IsDynamic(Child(t,i))
    requires Fits(t,v)
    ensures frame == Frame(Parts(t,v))
    ensures Body(t,v) == (if t.Array? then Word(|v.values|) else []) + frame
    ensures head == HeadSize(Parts(t,v)[..i])
    ensures offset == HeadSize(Parts(t,v)) + TailSize(Parts(t,v)[..i])
    ensures child == Body(Child(t,i),v.values[i])
    ensures head+32 <= |frame| && offset+|child| <= |frame|
    ensures ReadNat(frame[head..head+32]) == offset
    ensures frame[offset..offset+|child|] == child
    ensures Word(32)+child == Encode(Child(t,i),v.values[i])
  {
    var ps := Parts(t,v);
    frame := Frame(ps);
    head := HeadSize(ps[..i]);
    offset := HeadSize(ps)+TailSize(ps[..i]);
    child := ps[i].data;
    Sizes(ps,HeadSize(ps));
    assert HeadSize(ps)+TailSize(ps) < Pow256(32);
    ComponentLayout(ps,i);
    TightOffsets(ps,i);
    SingleValueEnvelope(Child(t,i),v.values[i]);
  }
}

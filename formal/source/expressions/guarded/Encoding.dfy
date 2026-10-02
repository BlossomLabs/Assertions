// SPDX-License-Identifier: MIT
include "../entry/Connection.dfy"
module ExpressionGuardedEncoding {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import C = ExpressionCache
  import W = ExpressionReceiptEncoding

  function CacheType(): AbiType
    ensures WellFormed(CacheType()) && IsDynamic(CacheType())
  { var t := Tuple([Array(Bytes),Array(Scalar(Boolean)),Array(Scalar(Boolean)),Array(Scalar(Unsigned(256)))]);
    assert IsDynamic(t.fields[0]);
    assert exists i :: 0 <= i < |t.fields| && IsDynamic(t.fields[i]);
    t }
  function ReturnType(): AbiType
    ensures WellFormed(ReturnType()) && IsDynamic(ReturnType())
  { var t := Tuple([Bytes,CacheType()]);
    assert IsDynamic(t.fields[0]);
    assert exists i :: 0 <= i < |t.fields| && IsDynamic(t.fields[i]);
    t }
  ghost function ByteValues(values: seq<seq<Byte>>): Value
    ensures WellTyped(Array(Bytes),ByteValues(values))
  { Items(seq(|values|, i requires 0 <= i < |values| => Buffer(values[i]))) }
  ghost function BoolValues(values: seq<bool>): Value
    ensures WellTyped(Array(Scalar(Boolean)),BoolValues(values))
  { Items(seq(|values|, i requires 0 <= i < |values| => Atom(if values[i] then 1 else 0))) }
  predicate WordsFit(cache: C.Cache) { forall w <- cache.words :: Uint(w) }
  lemma {:fuel Pow2,10,11} ByteWidth(n: nat)
    ensures Pow2(8*n) == Pow256(n)
    decreases n
  { if n > 0 { ByteWidth(n-1); assert Pow2(8*n) == 256 * Pow2(8*(n-1)); } }
  lemma FullWidth()
    ensures Pow2(256) == Pow256(32)
  { ByteWidth(32); }
  ghost function WordValues(values: seq<nat>): Value
    requires forall w <- values :: Uint(w)
    ensures WellTyped(Array(Scalar(Unsigned(256))),WordValues(values))
  {
    FullWidth();
    assert forall i :: 0 <= i < |values| ==> Uint(values[i]);
    assert forall i :: 0 <= i < |values| ==> CanonicalWord(Unsigned(256),values[i]);
    var atoms := seq(|values|, i requires 0 <= i < |values| => Atom(values[i]));
    assert forall i :: 0 <= i < |atoms| ==> WellTyped(Scalar(Unsigned(256)),atoms[i]);
    Items(atoms)
  }
  ghost function CacheValue(cache: C.Cache): Value
    requires WordsFit(cache)
    ensures WellTyped(CacheType(),CacheValue(cache))
  { Items([ByteValues(cache.values),BoolValues(cache.ready),BoolValues(cache.dynamic),WordValues(cache.words)]) }
  ghost function ReturnValue(value: seq<Byte>, cache: C.Cache): Value
    requires WordsFit(cache)
    ensures WellTyped(ReturnType(),ReturnValue(value,cache))
  { Items([Buffer(value),CacheValue(cache)]) }
  // External return parameters are the argument frame, without the extra
  // enclosing single-value tuple offset.
  ghost function Wire(value: seq<Byte>, cache: C.Cache): seq<Byte>
    requires WordsFit(cache)
  { Body(ReturnType(),ReturnValue(value,cache)) }
  lemma FrameShape(value: seq<Byte>, cache: C.Cache)
    requires WordsFit(cache)
    ensures Wire(value,cache) == Frame([Piece(true,W.Blob(value)),Piece(true,Body(CacheType(),CacheValue(cache)))])
    ensures Encode(ReturnType(),ReturnValue(value,cache)) == Word(32)+Wire(value,cache)
  {
    var parts := Parts(ReturnType(),ReturnValue(value,cache));
    assert parts == [Piece(true,W.Blob(value)),Piece(true,Body(CacheType(),CacheValue(cache)))];
  }
  datatype Pair = Pair(value: seq<Byte>, cache: C.Cache)
  ghost function Project(value: Value): Pair
    requires WellTyped(ReturnType(),value)
  {
    var cs := value.values[1].values;
    Pair(value.values[0].payload,
         C.Cache(seq(|cs[0].values|, i requires 0 <= i < |cs[0].values| => cs[0].values[i].payload),
                 seq(|cs[1].values|, i requires 0 <= i < |cs[1].values| => cs[1].values[i].word == 1),
                 seq(|cs[2].values|, i requires 0 <= i < |cs[2].values| => cs[2].values[i].word == 1),
                 seq(|cs[3].values|, i requires 0 <= i < |cs[3].values| => cs[3].values[i].word)))
  }
  lemma Projection(value: seq<Byte>, cache: C.Cache)
    requires WordsFit(cache)
    ensures Project(ReturnValue(value,cache)) == Pair(value,cache)
  {
    var decoded := Project(ReturnValue(value,cache)).cache;
    assert decoded.values == cache.values;
    assert decoded.ready == cache.ready;
    assert decoded.dynamic == cache.dynamic;
    assert decoded.words == cache.words;
  }
  lemma RoundTrip(value: seq<Byte>, cache: C.Cache)
    requires WordsFit(cache) && Fits(ReturnType(),ReturnValue(value,cache))
    ensures Validate(ReturnType(),Word(32)+Wire(value,cache)) == Parsed(ReturnValue(value,cache),32+|Wire(value,cache)|)
    ensures Project(Validate(ReturnType(),Word(32)+Wire(value,cache)).value) == Pair(value,cache)
  {
    FrameShape(value,cache);
    ValidationComplete(ReturnType(),ReturnValue(value,cache));
    Projection(value,cache);
  }
}

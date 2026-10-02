// SPDX-License-Identifier: MIT
include "Validation.dfy"

module AbiExamples {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation

  lemma EmptyDynamicArray(t: AbiType)
    requires WellFormed(t)
    ensures WellTyped(Array(t),Items([]))
    ensures Encode(Array(t),Items([])) == Word(32)+Word(0)
  {
    assert Parts(Array(t),Items([])) == [];
    assert Frame([]) == [];
  }

  lemma EmptyTupleAndZeroFixedArray(t: AbiType)
    ensures !WellFormed(Tuple([]))
    ensures !WellFormed(FixedArray(t,0))
  {}

  // ABI strings are byte sequences here. No Unicode validity assumption.
  lemma BytesAndStrings(data: seq<Byte>)
    ensures WellTyped(Bytes,Buffer(data)) && WellTyped(String,Buffer(data))
    ensures Encode(Bytes,Buffer(data)) == Encode(String,Buffer(data))
  {}

  lemma OpaqueWord(w: nat)
    requires w < Pow256(32)
    ensures WellTyped(Scalar(Opaque),Atom(w))
    ensures Encode(Scalar(Opaque),Atom(w)) == Word(w)
  {}

  lemma BooleanRange(w: nat)
    requires w >= 2
    ensures !WellTyped(Scalar(Boolean),Atom(w))
  {}

  function ExpectedNestedTuple(): seq<Byte>
  { Word(32)+Word(1)+Word(2)+Word(96)+Word(2)+Word(64)+Word(96)+Word(0)+Word(1)+[255]+Zeros(31) }

  // Word values independently captured from viem in fixtures.json.
  // This example spans a static fixed array, a dynamic array, two dynamic
  // elements, an empty payload, a nonempty payload, and three offset bases.
  lemma NestedTupleFixture()
    ensures var t := Tuple([FixedArray(Scalar(Unsigned(8)),2),Array(Bytes)]);
            var v := Items([Items([Atom(1),Atom(2)]),Items([Buffer([]),Buffer([255])])]);
            WellTyped(t,v)
    ensures var t := Tuple([FixedArray(Scalar(Unsigned(8)),2),Array(Bytes)]);
            var v := Items([Items([Atom(1),Atom(2)]),Items([Buffer([]),Buffer([255])])]);
            Encode(t,v) == ExpectedNestedTuple()
  {
    assert Pow2(1) == 2;
    assert Pow2(2) == 4;
    assert Pow2(3) == 8;
    assert Pow2(4) == 16;
    assert Pow2(5) == 32;
    assert Pow2(6) == 64;
    assert Pow2(7) == 128;
    assert Pow2(8) == 256;
    var u := Scalar(Unsigned(8));
    var fixed := FixedArray(u,2);
    var numbers := Items([Atom(1),Atom(2)]);
    assert Body(u,Atom(1)) == Word(1);
    assert Body(u,Atom(2)) == Word(2);
    assert Parts(fixed,numbers) == [Piece(false,Word(1)),Piece(false,Word(2))];
    assert Body(fixed,numbers) == Word(1)+Word(2);
    var a := Array(Bytes);
    var strings := Items([Buffer([]),Buffer([255])]);
    assert Body(Bytes,Buffer([])) == Word(0);
    assert Body(Bytes,Buffer([255])) == Word(1)+[255]+Zeros(31);
    var empty := Piece(true,Word(0));
    var nonempty := Piece(true,Word(1)+[255]+Zeros(31));
    assert Parts(a,strings) == [empty,nonempty];
    SizesAppend([empty],[nonempty]);
    HeadsAppend([empty],[nonempty],64);
    TailsAppend([empty],[nonempty]);
    assert HeadSize([empty,nonempty]) == 64;
    assert Heads([empty,nonempty],64) == Word(64)+Word(96);
    assert Tails([empty,nonempty]) == Word(0)+Word(1)+[255]+Zeros(31);
    var arrayBody := Word(2)+Word(64)+Word(96)+Word(0)+Word(1)+[255]+Zeros(31);
    assert Body(a,strings) == arrayBody;
    var t := Tuple([fixed,a]);
    var v := Items([numbers,strings]);
    var ps := [Piece(false,Word(1)+Word(2)),Piece(true,arrayBody)];
    assert Parts(t,v) == ps;
    SizesAppend(ps[..1],ps[1..]);
    HeadsAppend(ps[..1],ps[1..],96);
    TailsAppend(ps[..1],ps[1..]);
    assert HeadSize(ps) == 96;
    assert Heads(ps,96) == Word(1)+Word(2)+Word(96);
    assert Tails(ps) == arrayBody;
  }

  lemma NestedTupleAccepted()
    ensures var t := Tuple([FixedArray(Scalar(Unsigned(8)),2),Array(Bytes)]);
            var v := Items([Items([Atom(1),Atom(2)]),Items([Buffer([]),Buffer([255])])]);
            Validate(t,ExpectedNestedTuple()) == Parsed(v,320)
  {
    NestedTupleFixture();
    var t := Tuple([FixedArray(Scalar(Unsigned(8)),2),Array(Bytes)]);
    var v := Items([Items([Atom(1),Atom(2)]),Items([Buffer([]),Buffer([255])])]);
    assert |Encode(t,v)| == 320;
    FitsFromSize(t,v);
    ValidationComplete(t,v);
  }

  lemma EmptyArrayAccepted(t: AbiType)
    requires WellFormed(t)
    ensures Validate(Array(t),Word(32)+Word(0)) == Parsed(Items([]),64)
  {
    EmptyDynamicArray(t);
    FitsFromSize(Array(t),Items([]));
    ValidationComplete(Array(t),Items([]));
  }

  lemma MalformedBytesFixtures()
    ensures Validate(Bytes,Word(32)+Word(1)+[255]+Zeros(30)+[1]).Rejected?
    ensures Validate(Bytes,Word(32)+Word(1)+[255]).Rejected?
    ensures Validate(Bytes,Word(64)+Word(0)).Rejected?
    ensures Validate(Bytes,Word(32)+Word(0)+[0]).Rejected?
  {
    NatBytesRoundTrip(1,32);
    NatBytesRoundTrip(32,32);
    NatBytesRoundTrip(64,32);
    var dirty := Word(1)+[255]+Zeros(30)+[1];
    assert dirty[..32] == Word(1);
    RejectDirtyPadding(dirty,63);
    assert Walk(Bytes,dirty) == Rejected;
    var short := Word(1)+[255];
    assert short[..32] == Word(1);
    RejectTruncatedBytes(short);
    assert Walk(Bytes,short) == Rejected;
    RejectEnvelope(Bytes,Word(64),Word(0));
    FitsFromSize(Bytes,Buffer([]));
    RejectTrailing(Bytes,Buffer([]),[0]);
    assert (Word(32)+dirty)[32..] == dirty;
    assert (Word(32)+short)[32..] == short;
    assert Validate(Bytes,Word(32)+dirty) == Rejected;
    assert Validate(Bytes,Word(32)+short) == Rejected;
    assert Word(32)+Word(1)+[255]+Zeros(30)+[1] == Word(32)+dirty;
    assert Validate(Bytes,Word(32)+Word(1)+[255]+Zeros(30)+[1]) == Rejected;
  }
}

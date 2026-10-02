// SPDX-License-Identifier: MIT
include "Endpoints.dfy"

module AbiConstructionInverses {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiParserCompleteness
  import opened AbiConnectionModel
  import opened AbiDynamicSemantics
  import opened AbiConstructionModel
  import opened AbiConstructionContext
  import opened AbiConstructionPack
  import opened AbiConstructionSplitting
  import opened AbiConstructionUnpack

  lemma TotalBound(vs: seq<seq<Byte>>, i: nat)
    requires i < |vs|
    ensures |vs[i]| <= TotalBytes(vs)
    decreases i
  { if i > 0 { TotalBound(vs[1..],i-1); } }

  lemma RoomForSmaller(s: Descriptor, maximum: nat, length: nat)
    requires Good(s) && length <= maximum
    requires Uint(maximum+32*0x100000000*|Render(s)|)
    ensures Uint(length) && CursorRoom(s,length)
  {
    assert Uint(length+32*0x100000000*|Render(s)|);
    RoomFromText(s,length);
  }

  lemma DecodedIndex(fs: seq<Descriptor>, vs: seq<seq<Byte>>)
    requires ValidInputs(fs,vs)
    ensures forall i :: 0 <= i < |fs| ==> Decoded(fs,vs)[i] == Validate(TypeOf(fs[i]),vs[i]).value
    decreases |fs|
  { if |fs| > 0 { DecodedIndex(fs[1..],vs[1..]); } }

  lemma Reencode(s: Descriptor, vs: seq<seq<Byte>>)
    requires ValidInputs(Copies(s,|vs|),vs)
    ensures forall i :: 0 <= i < |vs| ==> WellTyped(TypeOf(s),Decoded(Copies(s,|vs|),vs)[i])
    ensures Encodings(TypeOf(s),Decoded(Copies(s,|vs|),vs)) == vs
  {
    DecodedIndex(Copies(s,|vs|),vs);
    forall i | 0 <= i < |vs|
      ensures WellTyped(TypeOf(s),Decoded(Copies(s,|vs|),vs)[i]) && Encode(TypeOf(s),Decoded(Copies(s,|vs|),vs)[i]) == vs[i]
    { ValidationSound(TypeOf(s),vs[i]); }
    assert Encodings(TypeOf(s),Decoded(Copies(s,|vs|),vs)) == vs;
  }

  // No chosen depth or array-count bound: one explicit arithmetic budget
  // supplies the actual checked-cursor requirements. Allocation/gas assumptions
  // remain the same as the source correspondence, including for this inverse.
  ghost method {:isolate_assertions} UnpackPack(t: seq<Byte>, s: Descriptor, vs: seq<seq<Byte>>)
    returns (packed: seq<Byte>, unpacked: seq<seq<Byte>>)
    requires Admissible(s) && t == Render(s) && Uint(|t|) && Uint(|vs|)
    requires ValidInputs(Copies(s,|vs|),vs)
    requires Uint(64+TotalBytes(vs)+32*0x100000000*|t|)
    ensures unpacked == vs
  {
    ModelType(s); Accept(t,0,|t|,s);
    forall i | 0 <= i < |vs|
      ensures Uint(|vs[i]|) && CursorRoom(s,|vs[i]|)
    { TotalBound(vs,i); RoomFromText(s,|vs[i]|); }
    var r: Result;
    packed,r := Pack(t,vs);
    assert r.Success?;
    var decoded := Decoded(Copies(s,|vs|),vs);
    var owner := Array(TypeOf(s));
    var value := Items(decoded);
    CanonicalPieces(Copies(s,|vs|),vs); FrameBudget(Copies(s,|vs|),vs);
    Sizes(Pieces(Copies(s,|vs|),vs),HeadSize(Pieces(Copies(s,|vs|),vs)));
    assert |packed| == 64+TotalBytes(vs);
    FitsFromSize(owner,value); ValidationComplete(owner,value);
    RoomFromText(s,|packed|);
    var raw: Outcome;
    unpacked,raw := UnpackParsed(t,packed,s);
    assert raw.Ok?;
    Reencode(s,vs);
  }

  ghost method {:isolate_assertions} PackUnpack(t: seq<Byte>, s: Descriptor, encoded: seq<Byte>)
    returns (values: seq<seq<Byte>>, repacked: seq<Byte>)
    requires Admissible(s) && t == Render(s) && Uint(|t|)
    requires WellFormed(Array(TypeOf(s))) && Validate(Array(TypeOf(s)),encoded).Parsed?
    requires Uint(|encoded|+32*0x100000000*|t|)
    ensures repacked == encoded
  {
    ModelType(s); Accept(t,0,|t|,s);
    var owner := Array(TypeOf(s));
    ValidationSound(owner,encoded);
    var value := Validate(owner,encoded).value;
    FitsFromSize(owner,value); BodiesAreFrames(owner,value);
    RoomFromText(s,|encoded|);
    var raw: Outcome;
    values,raw := UnpackParsed(t,encoded,s);
    assert raw.Ok? && values == Encodings(TypeOf(s),value.values);
    var ps := Parts(owner,value);
    MinimumHead(ps); Sizes(ps,HeadSize(ps));
    assert |ps| == |values|;
    var fs := Copies(s,|values|);
    forall i | 0 <= i < |values|
      ensures ValidInput(s,values[i]) && Uint(|values[i]|) && CursorRoom(s,|values[i]|)
      ensures Validate(TypeOf(s),values[i]).value == value.values[i]
    {
      ChildEncodingBound(owner,value,i);
      ValidationComplete(TypeOf(s),value.values[i]);
      assert |values[i]| <= |encoded|;
      RoomForSmaller(s,|encoded|,|values[i]|);
    }
    assert ValidInputs(fs,values);
    CanonicalPieces(fs,values); DecodedIndex(fs,values); CopyLayout(s,|values|);
    assert Decoded(fs,values) == value.values;
    assert TypesOf(fs) == Children(owner,|values|);
    AggregateParts(owner,value.values);
    assert Pieces(fs,values) == ps;
    FrameBudget(fs,values);
    assert 64+TotalBytes(values) == |encoded|;
    var r: Result;
    repacked,r := Pack(t,values);
    assert r.Success?;
  }
}

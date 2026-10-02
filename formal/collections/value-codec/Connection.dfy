// SPDX-License-Identifier: MIT
include "Pack.generated.dfy"
include "Unpack.generated.dfy"
module CollectionsValueCodecConnection {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiConnectionModel
  import opened AbiDynamicSemantics
  import opened AbiConstructionModel
  import opened AbiConstructionContext
  import opened AbiConstructionSplitting
  import M = CollectionsValueCodecModel
  import PackSource = CollectionsValueCodecPackSource
  import UnpackSource = CollectionsValueCodecUnpackSource
  import V = CollectionsValidationModel
  import Errors = CollectionsCodecErrorEncoding
  import Parser = AbiParserSource
  import Completeness = AbiParserCompleteness
  import Inverses = AbiConstructionInverses

  ghost method Pack(t: seq<Byte>,values: seq<seq<Byte>>) returns (out: seq<Byte>,r: Result,reason: seq<Byte>)
    requires Uint(|t|) && Uint(32*|values|) && Uint(64+TotalBytes(values))
    requires forall i :: 0 <= i < |values| ==> V.Room(t,values[i])
    ensures r.Success? ==> M.PackJudge(t,values) == M.Packed(out)
    ensures !r.Success? ==> M.PackJudge(t,values) == M.Failed(r) && reason == Errors.Encode(r)
    ensures Whole(t).Shaped? ==> r.Success? == ValidInputs(Copies(Whole(t).syntax,|values|),values)
    ensures r.Success? ==> |out| == 64+TotalBytes(values)
    ensures r.Success? ==> reason == [] && Whole(t).Shaped? && ValidInputs(Copies(Whole(t).syntax,|values|),values)
    ensures r.Success? ==> WellTyped(Array(TypeOf(Whole(t).syntax)),Items(Decoded(Copies(Whole(t).syntax,|values|),values)))
    ensures r.Success? ==> out == Encode(Array(TypeOf(Whole(t).syntax)),Items(Decoded(Copies(Whole(t).syntax,|values|),values)))
    ensures Whole(t).BadDescriptor? ==> r == InvalidDescriptor(Whole(t).at)
    ensures Whole(t).ArithmeticPanic? ==> r == Result.Panic(17)
  {
    out,r := PackSource.Pack(t,values);
    reason := Errors.Encode(r);
    Errors.Error(r);
  }
  ghost method Unpack(t: seq<Byte>,encoded: seq<Byte>) returns (values: seq<seq<Byte>>,r: Result,reason: seq<Byte>)
    requires Uint(|t|) && Uint(|encoded|)
    requires Whole(t).Shaped? ==> CursorRoom(Whole(t).syntax,|encoded|) && CursorRoom(Dynamic(Whole(t).syntax),|encoded|)
    ensures r == M.UnpackResult(t,encoded)
    ensures reason == Errors.Encode(r)
    ensures Whole(t).Shaped? ==> WellFormed(Array(TypeOf(Whole(t).syntax)))
    ensures Whole(t).Shaped? ==> r.Success? == Validate(Array(TypeOf(Whole(t).syntax)),encoded).Parsed?
    ensures r.Success? ==> Whole(t).Shaped? && WellTyped(Array(TypeOf(Whole(t).syntax)),Validate(Array(TypeOf(Whole(t).syntax)),encoded).value)
    ensures r.Success? ==> values == Encodings(TypeOf(Whole(t).syntax),Validate(Array(TypeOf(Whole(t).syntax)),encoded).value.values)
    ensures !r.Success? ==> values == []
  {
    values := [];
    var parsed := Parser.Shape(t);
    if parsed.BadDescriptor? { r := InvalidDescriptor(parsed.at); }
    else if parsed.ArithmeticPanic? { r := Result.Panic(17); }
    else {
      var raw: Outcome;
      values,raw := UnpackSource.UnpackParsed(t,encoded,parsed.syntax);
      r := Route(raw,Context(ValueKind,0,0,0,0));
      if !r.Success? { values := []; }
    }
    reason := Errors.Encode(r);
    Errors.Error(r);
  }
  ghost method UnpackPack(t: seq<Byte>,s: Descriptor,values: seq<seq<Byte>>)
    returns (packed: seq<Byte>,unpacked: seq<seq<Byte>>)
    requires Admissible(s) && t == Render(s) && Uint(|t|) && Uint(32*|values|)
    requires ValidInputs(Copies(s,|values|),values)
    requires Uint(64+TotalBytes(values)+32*0x100000000*(|t|+2))
    ensures unpacked == values
  {
    ModelType(s); Completeness.Accept(t,0,|t|,s);
    forall i | 0 <= i < |values|
      ensures V.Room(t,values[i])
    {
      Inverses.TotalBound(values,i);
      assert Uint(|values[i]|+32*0x100000000*|t|);
      RoomFromText(s,|values[i]|);
    }
    var r: Result; var reason: seq<Byte>;
    packed,r,reason := Pack(t,values);
    assert r.Success?;
    var decoded := Decoded(Copies(s,|values|),values);
    FitsFromSize(Array(TypeOf(s)),Items(decoded));
    ValidationComplete(Array(TypeOf(s)),Items(decoded));
    RoomFromText(s,|packed|);
    assert |Render(Dynamic(s))| == |t|+2;
    RoomFromText(Dynamic(s),|packed|);
    unpacked,r,reason := Unpack(t,packed);
    Inverses.Reencode(s,values);
  }
  ghost method PackUnpack(t: seq<Byte>,s: Descriptor,encoded: seq<Byte>)
    returns (values: seq<seq<Byte>>,repacked: seq<Byte>)
    requires Admissible(s) && t == Render(s) && Uint(|t|)
    requires WellFormed(Array(TypeOf(s))) && Validate(Array(TypeOf(s)),encoded).Parsed?
    requires Uint(|encoded|+32*0x100000000*(|t|+2))
    ensures repacked == encoded
  {
    ModelType(s); Completeness.Accept(t,0,|t|,s);
    var owner := Array(TypeOf(s));
    ValidationSound(owner,encoded);
    var value := Validate(owner,encoded).value;
    FitsFromSize(owner,value); BodiesAreFrames(owner,value);
    RoomFromText(s,|encoded|);
    assert |Render(Dynamic(s))| == |t|+2;
    RoomFromText(Dynamic(s),|encoded|);
    var r: Result; var reason: seq<Byte>;
    values,r,reason := Unpack(t,encoded);
    assert r.Success? && values == Encodings(TypeOf(s),value.values);
    var ps := Parts(owner,value);
    MinimumHead(ps); Sizes(ps,HeadSize(ps));
    assert |ps| == |values|;
    var fs := Copies(s,|values|);
    forall i | 0 <= i < |values|
      ensures ValidInput(s,values[i]) && V.Room(t,values[i])
      ensures Validate(TypeOf(s),values[i]).value == value.values[i]
    {
      ChildEncodingBound(owner,value,i);
      ValidationComplete(TypeOf(s),value.values[i]);
      assert |values[i]| <= |encoded|;
      Inverses.RoomForSmaller(s,|encoded|,|values[i]|);
    }
    assert ValidInputs(fs,values);
    CanonicalPieces(fs,values); Inverses.DecodedIndex(fs,values); CopyLayout(s,|values|);
    assert Decoded(fs,values) == value.values;
    assert TypesOf(fs) == Children(owner,|values|);
    AggregateParts(owner,value.values);
    assert Pieces(fs,values) == ps;
    FrameBudget(fs,values);
    assert 64+TotalBytes(values) == |encoded|;
    assert Uint(32*|values|);
    repacked,r,reason := Pack(t,values);
    assert r.Success?;
  }

}

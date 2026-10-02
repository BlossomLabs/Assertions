// SPDX-License-Identifier: MIT
include "Assembly.generated.dfy"
include "Component.generated.dfy"

module AbiConstructionModel {
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiShapeSemantics
  import opened AbiConnectionModel
  import opened AbiConstructionAssembly

  ghost predicate ValidInput(s: Descriptor, v: seq<Byte>)
  { Good(s) && WellFormed(TypeOf(s)) && Validate(TypeOf(s),v).Parsed? }

  ghost predicate ValidInputs(fs: seq<Descriptor>, vs: seq<seq<Byte>>)
  { |fs| == |vs| && forall i :: 0 <= i < |fs| ==> ValidInput(fs[i],vs[i]) }

  function RawPiece(s: Descriptor, v: seq<Byte>): Piece
  { Piece(Dyn(s),if Dyn(s) then (if |v| >= 32 then v[32..] else []) else v) }

  function Pieces(fs: seq<Descriptor>, vs: seq<seq<Byte>>): seq<Piece>
    requires |fs| == |vs|
    ensures |Pieces(fs,vs)| == |fs|
    decreases |fs|
  { if |fs| == 0 then [] else [RawPiece(fs[0],vs[0])]+Pieces(fs[1..],vs[1..]) }

  lemma PiecesIndex(fs: seq<Descriptor>, vs: seq<seq<Byte>>)
    requires |fs| == |vs|
    ensures forall i :: 0 <= i < |fs| ==> Pieces(fs,vs)[i] == RawPiece(fs[i],vs[i])
    decreases |fs|
  { if |fs| > 0 { PiecesIndex(fs[1..],vs[1..]); } }

  ghost function Decoded(fs: seq<Descriptor>, vs: seq<seq<Byte>>): seq<Value>
    requires ValidInputs(fs,vs)
    ensures |Decoded(fs,vs)| == |fs|
    decreases |fs|
  { if |fs| == 0 then [] else [Validate(TypeOf(fs[0]),vs[0]).value]+Decoded(fs[1..],vs[1..]) }

  lemma CanonicalPiece(s: Descriptor, v: seq<Byte>)
    requires ValidInput(s,v)
    ensures |RawPiece(s,v).data| > 0 && |RawPiece(s,v).data| % 32 == 0
    ensures v == (if Dyn(s) then Word(32) else [])+RawPiece(s,v).data
    ensures (if Dyn(s) then 32 else |RawPiece(s,v).data|) == 32*Width(s)
    ensures WellTyped(TypeOf(s),Validate(TypeOf(s),v).value)
    ensures RawPiece(s,v) == Piece(IsDynamic(TypeOf(s)),Body(TypeOf(s),Validate(TypeOf(s),v).value))
  {
    ModelType(s); ValidationSound(TypeOf(s),v);
    var value := Validate(TypeOf(s),v).value;
    BodiesAreFrames(TypeOf(s),value); HeadFootprint(TypeOf(s),value);
    if Dyn(s) { assert v[32..] == Body(TypeOf(s),value); }
  }

  lemma CanonicalPieces(fs: seq<Descriptor>, vs: seq<seq<Byte>>)
    requires ValidInputs(fs,vs)
    ensures ValidPieces(Pieces(fs,vs)) && Values(Pieces(fs,vs)) == vs
    ensures HeadSize(Pieces(fs,vs)) == 32*WidthSum(fs)
    ensures TypedList(TypesOf(fs),Decoded(fs,vs))
    ensures Pieces(fs,vs) == ListParts(TypesOf(fs),Decoded(fs,vs))
    decreases |fs|
  {
    if |fs| > 0 {
      CanonicalPiece(fs[0],vs[0]); CanonicalPieces(fs[1..],vs[1..]);
      assert Values(Pieces(fs,vs))[1..] == Values(Pieces(fs[1..],vs[1..]));
      assert TypesOf(fs)[1..] == TypesOf(fs[1..]);
      assert Decoded(fs,vs)[1..] == Decoded(fs[1..],vs[1..]);
      SplitList(TypesOf(fs),Decoded(fs,vs));
    }
  }

  function TotalBytes(vs: seq<seq<Byte>>): nat
    decreases |vs|
  { if |vs| == 0 then 0 else |vs[0]|+TotalBytes(vs[1..]) }

  lemma FrameBudget(fs: seq<Descriptor>, vs: seq<seq<Byte>>)
    requires ValidInputs(fs,vs)
    ensures HeadSize(Pieces(fs,vs))+TailSize(Pieces(fs,vs)) == TotalBytes(vs)
    decreases |fs|
  {
    if |fs| > 0 { CanonicalPiece(fs[0],vs[0]); FrameBudget(fs[1..],vs[1..]); }
  }
}

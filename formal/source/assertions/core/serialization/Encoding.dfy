// SPDX-License-Identifier: MIT
include "Signatures.generated.dfy"

module CoreSerializationEncoding {
  import opened AbiFrames
  import S = CoreSerializationSignatures
  import Words = ResolutionWords
  import ABI = AbiEncoding

  datatype Arg = U(n: nat) | I(i: int) | Enum(n: nat) | Address(n: nat)
               | Four(data: seq<Byte>) | Word(n: nat) | Blob(data: seq<Byte>) | Text(data: seq<Byte>)
  datatype Packet = Bare | Error(kind: S.Error, args: seq<Arg>)
  function Tag(a: Arg): S.Tag {
    match a
    case U(_) => S.Unsigned
    case I(_) => S.Signed
    case Enum(_) => S.Enum
    case Address(_) => S.Address
    case Four(_) => S.Four
    case Word(_) => S.Word
    case Blob(_) => S.Blob
    case Text(_) => S.Text
  }
  function Tags(args: seq<Arg>): seq<S.Tag> { seq(|args|,i requires 0 <= i < |args| => Tag(args[i])) }
  predicate Shape(p: Packet) { p.Bare? || Tags(p.args) == S.Types(p.kind) }
  function BlobData(data: seq<Byte>): seq<Byte> { AbiFrames.Word(|data|)+Padded(data) }
  function FourWord(data: seq<Byte>): seq<Byte> {
    seq(4,i requires 0 <= i < 4 => if i < |data| then data[i] else 0)+Zeros(28)
  }
  function PieceOf(a: Arg): Piece {
    match a
    case I(i) => Piece(false,AbiFrames.Word((i % Words.Limit()) as nat))
    case Four(data) => Piece(false,FourWord(data))
    case Blob(data) => Piece(true,BlobData(data))
    case Text(data) => Piece(true,BlobData(data))
    case _ => Piece(false,AbiFrames.Word(a.n))
  }
  function Pieces(args: seq<Arg>): seq<Piece> { seq(|args|,i requires 0 <= i < |args| => PieceOf(args[i])) }
  function Encode(p: Packet): seq<Byte> {
    if p.Bare? then [] else S.Selector(p.kind)+Frame(Pieces(p.args))
  }
  predicate ArgFits(a: Arg) {
    match a
    case I(i) => -(Words.Limit()/2 as int) <= i < Words.Limit()/2
    case Enum(n) => n < 256
    case Address(n) => n < Words.AddressLimit()
    case Four(data) => |data| == 4
    case Blob(data) => |data| < Words.Limit()
    case Text(data) => |data| < Words.Limit()
    case _ => a.n < Words.Limit()
  }
  predicate Fits(p: Packet) {
    p.Bare? || (Shape(p) && (forall i :: 0 <= i < |p.args| ==> ArgFits(p.args[i])) &&
                |Frame(Pieces(p.args))| < Words.Limit())
  }
  lemma FourExact(data: seq<Byte>)
    requires |data| == 4
    ensures FourWord(data) == data+Zeros(28)
  { assert seq(4,i requires 0 <= i < 4 => if i < |data| then data[i] else 0) == data; }
  lemma NaturalExact(a: Arg)
    requires ArgFits(a) && (a.U? || a.Enum? || a.Address? || a.Word?)
    ensures ReadNat(PieceOf(a).data) == a.n && |PieceOf(a).data| == 32
  {
    Words.PowerConstants();
    NatBytesRoundTrip(a.n,32);
  }
  lemma SignedExact(i: int)
    requires -(Words.Limit()/2 as int) <= i < Words.Limit()/2
    ensures ReadNat(PieceOf(I(i)).data) == (if i < 0 then i+Words.Limit() else i)
    ensures |PieceOf(I(i)).data| == 32
  {
    Words.PowerConstants();
    NatBytesRoundTrip((i % Words.Limit()) as nat,32);
  }
  lemma ValidArgumentPieces(args: seq<Arg>)
    ensures ValidPieces(Pieces(args))
  {
    forall i | 0 <= i < |args|
      ensures |Pieces(args)[i].data| > 0 && |Pieces(args)[i].data| % 32 == 0
    {
      if args[i].Blob? || args[i].Text? { PaddingLayout(args[i].data); }
    }
  }
  function Buffers(values: seq<seq<Byte>>): seq<ABI.Value> {
    seq(|values|,i requires 0 <= i < |values| => ABI.Buffer(values[i]))
  }
  function BlobPieces(values: seq<seq<Byte>>): seq<Piece> {
    seq(|values|,i requires 0 <= i < |values| => Piece(true,BlobData(values[i])))
  }
  function Gather(values: seq<seq<Byte>>): seq<Byte> {
    AbiFrames.Word(32)+AbiFrames.Word(|values|)+Frame(BlobPieces(values))
  }
  lemma GatherCanonical(values: seq<seq<Byte>>)
    ensures ABI.WellTyped(ABI.Array(ABI.Bytes),ABI.Items(Buffers(values)))
    ensures Gather(values) == ABI.Encode(ABI.Array(ABI.Bytes),ABI.Items(Buffers(values)))
  {
    assert forall i :: 0 <= i < |values| ==> ABI.WellTyped(ABI.Bytes,Buffers(values)[i]);
    assert ABI.Parts(ABI.Array(ABI.Bytes),ABI.Items(Buffers(values))) == BlobPieces(values);
  }
  lemma ErrorEnvelope(p: Packet)
    ensures p.Bare? ==> Encode(p) == []
    ensures p.Error? ==> |Encode(p)| >= 4 && Encode(p)[..4] == S.Selector(p.kind) &&
                         Encode(p)[4..] == Frame(Pieces(p.args))
  {}
}

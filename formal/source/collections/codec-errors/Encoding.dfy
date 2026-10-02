// SPDX-License-Identifier: MIT
include "Signatures.generated.dfy"
include "../admission/Connection.dfy"

module CollectionsCodecErrorEncoding {
  import opened AbiFrames
  import V = AbiConstructionContext
  import S = CollectionsCodecErrorSignatures

  datatype Arg = U(value: nat) | Address(value: nat) | Four(value: nat) | WordValue(value: nat)
  function Kind(a: Arg): S.Tag {
    match a
    case U(_) => S.U
    case Address(_) => S.Address
    case Four(_) => S.Four
    case WordValue(_) => S.Word
  }
  function Args(r: V.Result): seq<Arg> {
    match r
    case Success => []
    case InvalidValue(offset) => [U(offset)]
    case InvalidComponentValue(index,offset) => [U(index),U(offset)]
    case InvalidComponentLength(index,expected,actual) => [U(index),U(expected),U(actual)]
    case InvalidComponentEnvelope(index,length,head) => [U(index),U(length),WordValue(head)]
    case ComponentCountMismatch(expected,actual) => [U(expected),U(actual)]
    case InvalidCallbackResult(operation,index,other,target) => [Four(operation),U(index),U(other),Address(target)]
    case InvalidDescriptor(at) => [U(at)]
    case Panic(code) => [U(code)]
  }
  function Selector(r: V.Result): seq<Byte>
    ensures |Selector(r)| == (if r.Success? then 0 else 4)
  {
    match r
    case Success => []
    case InvalidValue(_) => S.InvalidValue()
    case InvalidComponentValue(_,_) => S.InvalidComponentValue()
    case InvalidComponentLength(_,_,_) => S.InvalidComponentLength()
    case InvalidComponentEnvelope(_,_,_) => S.InvalidComponentEnvelope()
    case ComponentCountMismatch(_,_) => S.ComponentCountMismatch()
    case InvalidCallbackResult(_,_,_,_) => S.InvalidCallbackResult()
    case InvalidDescriptor(_) => S.InvalidTypeDescriptor()
    case Panic(_) => S.Panic()
  }
  function Types(r: V.Result): seq<S.Tag> {
    match r
    case Success => []
    case InvalidValue(_) => S.InvalidValueTypes()
    case InvalidComponentValue(_,_) => S.InvalidComponentValueTypes()
    case InvalidComponentLength(_,_,_) => S.InvalidComponentLengthTypes()
    case InvalidComponentEnvelope(_,_,_) => S.InvalidComponentEnvelopeTypes()
    case ComponentCountMismatch(_,_) => S.ComponentCountMismatchTypes()
    case InvalidCallbackResult(_,_,_,_) => S.InvalidCallbackResultTypes()
    case InvalidDescriptor(_) => S.InvalidTypeDescriptorTypes()
    case Panic(_) => S.PanicTypes()
  }
  function Bytes(a: Arg): seq<Byte>
    ensures |Bytes(a)| == 32
  { if a.Four? then NatBytes(a.value,4)+Zeros(28) else Word(a.value) }
  function Words(args: seq<Arg>): seq<Byte>
    ensures |Words(args)| == 32*|args|
    decreases |args|
  { if |args| == 0 then [] else Bytes(args[0])+Words(args[1..]) }
  function Pieces(args: seq<Arg>): seq<Piece>
    decreases |args|
  { if |args| == 0 then [] else [Piece(false,Bytes(args[0]))]+Pieces(args[1..]) }
  function Encode(r: V.Result): seq<Byte> { Selector(r)+Words(Args(r)) }
  predicate ArgFits(a: Arg) {
    a.value < Pow256(if a.Four? then 4 else if a.Address? then 20 else 32)
  }
  predicate Fits(r: V.Result) { forall i :: 0 <= i < |Args(r)| ==> ArgFits(Args(r)[i]) }

  lemma Schema(r: V.Result)
    ensures seq(|Args(r)|,i requires 0 <= i < |Args(r)| => Kind(Args(r)[i])) == Types(r)
  {}
  lemma FrameWords(args: seq<Arg>, tail: nat)
    ensures HeadSize(Pieces(args)) == 32*|args|
    ensures Heads(Pieces(args),tail) == Words(args)
    ensures Tails(Pieces(args)) == []
    ensures Frame(Pieces(args)) == Words(args) && ValidPieces(Pieces(args))
    decreases |args|
  {
    if |args| > 0 { FrameWords(args[1..],tail); FrameWords(args[1..],32*|args|); }
  }
  lemma Powers(a: nat, b: nat)
    requires a <= b
    ensures Pow256(a) <= Pow256(b)
    decreases b-a
  { if a < b { Powers(a,b-1); } }
  lemma Argument(a: Arg)
    requires ArgFits(a)
    ensures a.Four? ==> ReadNat(Bytes(a)[..4]) == a.value && Bytes(a)[4..] == Zeros(28)
    ensures !a.Four? ==> ReadNat(Bytes(a)) == a.value
  {
    if a.Four? { NatBytesRoundTrip(a.value,4); }
    else { Powers(20,32); NatBytesRoundTrip(a.value,32); }
  }
  lemma WordAt(args: seq<Arg>, i: nat)
    requires i < |args|
    ensures Words(args)[32*i..32*(i+1)] == Bytes(args[i])
    decreases i
  { if i > 0 { WordAt(args[1..],i-1); } }
  lemma Error(r: V.Result)
    ensures Encode(r) == Selector(r)+Frame(Pieces(Args(r)))
    ensures r.Success? ==> Encode(r) == []
    ensures !r.Success? ==> |Encode(r)| == 4+32*|Args(r)| && Encode(r)[..4] == Selector(r)
    ensures !r.Success? ==> (forall i :: 0 <= i < |Args(r)| ==> Encode(r)[4+32*i..4+32*(i+1)] == Bytes(Args(r)[i]))
  {
    Schema(r); FrameWords(Args(r),0);
    if !r.Success? {
      forall i | 0 <= i < |Args(r)|
        ensures Encode(r)[4+32*i..4+32*(i+1)] == Bytes(Args(r)[i])
      { WordAt(Args(r),i); }
    }
  }
  lemma RoundTrip(r: V.Result)
    requires Fits(r) && !r.Success?
    ensures forall i :: 0 <= i < |Args(r)| ==>
                          (if Args(r)[i].Four? then
                             ReadNat(Encode(r)[4+32*i..8+32*i]) == Args(r)[i].value &&
                             Encode(r)[8+32*i..4+32*(i+1)] == Zeros(28)
                           else ReadNat(Encode(r)[4+32*i..4+32*(i+1)]) == Args(r)[i].value)
  {
    Error(r);
    forall i | 0 <= i < |Args(r)|
      ensures (if Args(r)[i].Four? then
                 ReadNat(Encode(r)[4+32*i..8+32*i]) == Args(r)[i].value &&
                 Encode(r)[8+32*i..4+32*(i+1)] == Zeros(28)
               else ReadNat(Encode(r)[4+32*i..4+32*(i+1)]) == Args(r)[i].value)
    {
      var word := Encode(r)[4+32*i..4+32*(i+1)];
      assert word == Bytes(Args(r)[i]);
      if Args(r)[i].Four? {
        assert word[..4] == Encode(r)[4+32*i..8+32*i];
        assert word[4..] == Encode(r)[8+32*i..4+32*(i+1)];
      }
      Argument(Args(r)[i]);
    }
  }

}

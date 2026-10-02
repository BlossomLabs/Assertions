// SPDX-License-Identifier: MIT
include "../compound/Source.generated.dfy"
include "../evaluation/CacheBridge.dfy"
module ExpressionCodecErrorEncoding {
  import opened AbiFrames
  import C = AbiConstructionContext
  import E = ExpressionEvaluationControl
  import B = AbiByteSemantics

  function InvalidValueSelector(): seq<Byte> { [0x60,0x72,0x74,0x2c] }
  function LengthSelector(): seq<Byte> { [0x30,0x62,0x0a,0x1b] }
  function EnvelopeSelector(): seq<Byte> { [0xdc,0x5d,0x12,0x62] }
  function ComponentSelector(): seq<Byte> { [0xdf,0x06,0xc5,0x1e] }
  function CountSelector(): seq<Byte> { [0x1e,0xc6,0xa9,0x56] }
  function CallbackSelector(): seq<Byte> { [0x24,0x44,0x8a,0x11] }
  function DescriptorSelector(): seq<Byte> { [0x9a,0x67,0xd1,0x26] }
  function PanicSelector(): seq<Byte> { [0x4e,0x48,0x7b,0x71] }
  function Selector(r: C.Result): seq<Byte>
    requires !r.Success?
    ensures |Selector(r)| == 4
  {
    match r
    case InvalidValue(_) => InvalidValueSelector()
    case InvalidComponentLength(_,_,_) => LengthSelector()
    case InvalidComponentEnvelope(_,_,_) => EnvelopeSelector()
    case InvalidComponentValue(_,_) => ComponentSelector()
    case ComponentCountMismatch(_,_) => CountSelector()
    case InvalidCallbackResult(_,_,_,_) => CallbackSelector()
    case InvalidDescriptor(_) => DescriptorSelector()
    case Panic(_) => PanicSelector()
  }
  function Fields(r: C.Result): seq<nat>
    requires !r.Success?
  {
    match r
    case InvalidValue(offset) => [offset]
    case InvalidComponentLength(index,expected,actual) => [index,expected,actual]
    case InvalidComponentEnvelope(index,length,head) => [index,length,head]
    case InvalidComponentValue(index,offset) => [index,offset]
    case ComponentCountMismatch(expected,actual) => [expected,actual]
    // Context.operation denotes the uint32 selector, not an already padded word.
    case InvalidCallbackResult(operation,index,other,target) => [operation*Pow256(28),index,other,target]
    case InvalidDescriptor(at) => [at]
    case Panic(code) => [code]
  }
  function Words(fields: seq<nat>): seq<Byte>
    ensures |Words(fields)| == 32*|fields|
    decreases |fields|
  { if |fields| == 0 then [] else Word(fields[0])+Words(fields[1..]) }
  function Pieces(fields: seq<nat>): seq<Piece>
    decreases |fields|
  { if |fields| == 0 then [] else [Piece(false,Word(fields[0]))]+Pieces(fields[1..]) }
  lemma StaticFrame(fields: seq<nat>, tail: nat)
    ensures HeadSize(Pieces(fields)) == 32*|fields|
    ensures Heads(Pieces(fields),tail) == Words(fields)
    ensures Tails(Pieces(fields)) == []
    ensures Frame(Pieces(fields)) == Words(fields)
    ensures |Words(fields)| == 32*|fields|
    decreases |fields|
  {
    if |fields| > 0 {
      StaticFrame(fields[1..],tail);
      StaticFrame(fields[1..],32*|fields|);
    }
  }
  lemma WordAt(fields: seq<nat>, index: nat)
    requires index < |fields| && fields[index] < Pow256(32)
    ensures ReadNat(Words(fields)[32*index..32*(index+1)]) == fields[index]
    decreases index
  {
    StaticFrame(fields,0);
    if index == 0 {
      NatBytesRoundTrip(fields[0],32);
      assert Words(fields)[..32] == Word(fields[0]);
    } else {
      WordAt(fields[1..],index-1);
      assert Words(fields)[32*index..32*(index+1)] == Words(fields[1..])[32*(index-1)..32*index];
    }
  }
  function Encoded(r: C.Result): seq<Byte>
    requires !r.Success?
  { Selector(r)+Words(Fields(r)) }
  lemma ExactError(r: C.Result)
    requires !r.Success?
    ensures Encoded(r) == Selector(r)+Frame(Pieces(Fields(r)))
    ensures |Encoded(r)| == 4+32*|Fields(r)|
    ensures Encoded(r)[..4] == Selector(r)
    ensures forall i :: 0 <= i < |Fields(r)| && Fields(r)[i] < Pow256(32) ==>
                          ReadNat(Encoded(r)[4+32*i..4+32*(i+1)]) == Fields(r)[i]
  {
    StaticFrame(Fields(r),0);
    forall i | 0 <= i < |Fields(r)| && Fields(r)[i] < Pow256(32)
      ensures ReadNat(Encoded(r)[4+32*i..4+32*(i+1)]) == Fields(r)[i]
    {
      WordAt(Fields(r),i);
      assert Encoded(r)[4+32*i..4+32*(i+1)] == Words(Fields(r))[32*i..32*(i+1)];
    }
  }
  function Receipt(r: C.Result, value: seq<Byte>): E.Raw {
    if r.Success? then E.Produced(value) else E.Aborted(E.Error(Encoded(r)))
  }
  lemma ValidationError(checked: B.Outcome, value: seq<Byte>)
    ensures checked.Ok? ==> Receipt(C.Route(checked,C.Context(C.ValueKind,0,0,0,0)),value) == E.Produced(value)
    ensures checked.Invalid? ==> Receipt(C.Route(checked,C.Context(C.ValueKind,0,0,0,0)),value) ==
                                 E.Aborted(E.Error(InvalidValueSelector()+Word(checked.offset)))
    ensures checked.Panic? ==> Receipt(C.Route(checked,C.Context(C.ValueKind,0,0,0,0)),value) ==
                               E.Aborted(E.Error(PanicSelector()+Word(checked.code)))
  {
    if checked.Invalid? {
      assert C.Route(checked,C.Context(C.ValueKind,0,0,0,0)) == C.InvalidValue(checked.offset);
      assert Fields(C.InvalidValue(checked.offset)) == [checked.offset];
      assert Words([checked.offset]) == Word(checked.offset);
      assert Encoded(C.InvalidValue(checked.offset)) == InvalidValueSelector()+Word(checked.offset);
    } else if checked.Panic? {
      assert C.Route(checked,C.Context(C.ValueKind,0,0,0,0)) == C.Panic(checked.code);
      assert Fields(C.Panic(checked.code)) == [checked.code];
      assert Words([checked.code]) == Word(checked.code);
      assert Encoded(C.Panic(checked.code)) == PanicSelector()+Word(checked.code);
    }
  }
}

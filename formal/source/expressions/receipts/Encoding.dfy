// SPDX-License-Identifier: MIT
include "../calls/Source.generated.dfy"
module ExpressionReceiptEncoding {
  import opened AbiFrames
  import C = ExpressionCallModel
  import E = ExpressionEvaluationControl
  import R = ResolutionModel

  function ForbiddenSelector(): seq<Byte> { [0xb0,0x83,0x95,0x3a] }
  function InvalidTargetSelector(): seq<Byte> { [0x25,0x6c,0xb2,0x5f] }
  function FailedSelector(): seq<Byte> { [0xdf,0xdd,0x75,0x53] }
  function DidNotRevertSelector(): seq<Byte> { [0x82,0x60,0xeb,0xb4] }
  function UnexpectedSelector(): seq<Byte> { [0xaa,0xc5,0x34,0x3e] }
  function Blob(data: seq<Byte>): seq<Byte> { Word(|data|)+Padded(data) }
  function Selector(error: C.Error): seq<Byte> {
    match error
    case Forbidden => ForbiddenSelector()
    case InvalidTarget(_,_) => InvalidTargetSelector()
    case NodeCallFailed(_,_,_,_) => FailedSelector()
    case OutOfGas => R.Signal()
    case DidNotRevert(_,_) => DidNotRevertSelector()
    case Unexpected(_,_) => UnexpectedSelector()
  }
  predicate Fields(error: C.Error) {
    match error
    case InvalidTarget(i,_) => i < Pow256(32)
    case NodeCallFailed(i,_,_,_) => i < Pow256(32)
    case Unexpected(expected,actual) => |expected| == 4 && |actual| == 4
    case _ => true
  }
  function Arguments(error: C.Error): seq<Piece>
    requires Fields(error)
  {
    match error
    case Forbidden => []
    case InvalidTarget(i,t) => [Piece(false,Word(i)),Piece(false,Word(t))]
    case NodeCallFailed(i,t,data,reason) =>
      [Piece(false,Word(i)),Piece(false,Word(t)),Piece(true,Blob(data)),Piece(true,Blob(reason))]
    case OutOfGas => []
    case DidNotRevert(t,data) => [Piece(false,Word(t)),Piece(true,Blob(data))]
    case Unexpected(expected,actual) => [Piece(false,expected+Zeros(28)),Piece(false,actual+Zeros(28))]
  }
  // Custom errors encode a tuple of arguments without an enclosing dynamic
  // single-value offset. This specification uses the independent ABI frame.
  function Spec(error: C.Error): seq<Byte>
    requires Fields(error)
  { Selector(error)+Frame(Arguments(error)) }

  function Encoded(error: C.Error): seq<Byte>
    requires Fields(error)
  {
    Selector(error) +
    match error
    case Forbidden => []
    case OutOfGas => []
    case InvalidTarget(i,t) => Word(i)+Word(t)
    case NodeCallFailed(i,t,data,reason) => Word(i)+Word(t)+Word(128)+Word(128+|Blob(data)|)+Blob(data)+Blob(reason)
    case DidNotRevert(t,data) => Word(t)+Word(64)+Blob(data)
    case Unexpected(expected,actual) => expected+Zeros(28)+actual+Zeros(28)
  }
  lemma {:fuel HeadSize,8,9} {:fuel Heads,8,9} {:fuel Tails,8,9} EncodingCorrespondence(error: C.Error)
    requires Fields(error)
    ensures Encoded(error) == Spec(error)
    ensures Encoded(error)[..4] == Selector(error)
    ensures |Encoded(error)| >= 4
  {
    var args := Arguments(error);
    match error
    case Forbidden =>
    case OutOfGas =>
    case InvalidTarget(_,_) =>
      assert args[1..] == [args[1]];
    case NodeCallFailed(_,_,_,_) =>
      assert args[1..] == [args[1],args[2],args[3]];
      assert args[2..] == [args[2],args[3]];
      assert args[3..] == [args[3]];
      assert HeadSize(args) == 128;
      assert Heads(args,128) == Word(error.index)+Word(error.target)+Word(128)+Word(128+|Blob(error.callData)|);
      assert Tails(args) == Blob(error.callData)+Blob(error.reason);
    case DidNotRevert(_,_) =>
      assert args[1..] == [args[1]];
    case Unexpected(_,_) =>
      assert args[1..] == [args[1]];
  }
  lemma FailedPayloads(index: nat, target: R.Address, data: seq<Byte>, reason: seq<Byte>)
    requires index < Pow256(32)
    requires 128+|Blob(data)| < Pow256(32)
    requires |data| < Pow256(32) && |reason| < Pow256(32)
    ensures var encoded := Encoded(C.NodeCallFailed(index,target,data,reason));
            ReadNat(encoded[4..36]) == index &&
            ReadNat(encoded[68..100]) == 128 &&
            ReadNat(encoded[100..132]) == 128+|Blob(data)| &&
            encoded[164..164+|data|] == data &&
            encoded[164+|Blob(data)|..164+|Blob(data)|+|reason|] == reason
  {
    NatBytesRoundTrip(index,32);
    NatBytesRoundTrip(128,32);
    NatBytesRoundTrip(128+|Blob(data)|,32);
    PaddingLayout(data); PaddingLayout(reason);
    var encoded := Encoded(C.NodeCallFailed(index,target,data,reason));
    assert encoded[4..36] == Word(index);
    assert encoded[68..100] == Word(128);
    assert encoded[100..132] == Word(128+|Blob(data)|);
  }
  function Receipt(result: C.Result): E.Raw
    requires result.Failed? ==> Fields(result.error)
  { if result.Returned? then E.Produced(result.data) else E.Aborted(E.Error(Encoded(result.error))) }
}

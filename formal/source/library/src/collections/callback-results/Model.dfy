// SPDX-License-Identifier: MIT
include "../traversal/Model.dfy"

module CollectionsCallbackResultsModel {
  import opened AbiFrames
  import T = CollectionsTraversalModel

  datatype CallOutcome = Returned(data: seq<Byte>) | Reverted(reason: seq<Byte>)
  datatype Context = Context(operation: seq<Byte>, index: nat, other: nat, target: nat)
  datatype PredicateOutcome = Truth(value: bool) | Failure(reason: seq<Byte>) | Invalid(context: Context)

  function Signal(): seq<Byte> { [0xd2,0x71,0x06,0x0e] }
  // Independent canonical-byte criterion, rather than accepting nonzero words.
  function Judge(call: CallOutcome, c: Context): PredicateOutcome {
    if call.Reverted? then Failure(call.reason) else
    if call.data == Word(0) then Truth(false) else
    if call.data == Word(1) then Truth(true) else Invalid(c)
  }
  predicate Reject(gasBefore: nat, gasAfter: nat, reason: seq<Byte>) {
    reason == Signal() || gasAfter <= gasBefore/63
  }
  predicate Fits(c: Context) {
    |c.operation| == 4 && c.index < Pow256(32) && c.other < Pow256(32) && c.target < Pow256(20)
  }
  function InvalidBytes(c: Context): seq<Byte> {
    // InvalidCallbackResult(bytes4,uint256,uint256,address); checked against solc.
    [0x24,0x44,0x8a,0x11] + c.operation + Zeros(28) + Word(c.index) + Word(c.other) + Word(c.target)
  }
  function Project(result: PredicateOutcome): T.Reply {
    match result
    case Truth(value) => T.Ok([],value)
    case Failure(reason) => T.Error(reason)
    case Invalid(context) => T.Error(InvalidBytes(context))
  }
  lemma CanonicalWord(data: seq<Byte>)
    requires |data| == 32
    ensures (ReadNat(data) == 0) == (data == Word(0))
    ensures (ReadNat(data) == 1) == (data == Word(1))
  {
    assert Pow256(32) > 1;
    BytesNatRoundTrip(data);
    NatBytesRoundTrip(0,32);
    NatBytesRoundTrip(1,32);
  }
}

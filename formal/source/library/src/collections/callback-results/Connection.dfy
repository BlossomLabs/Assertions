// SPDX-License-Identifier: MIT
include "Source.generated.dfy"

module CollectionsCallbackResultsConnection {
  import opened AbiFrames
  import opened CollectionsCallbackResultsModel
  import S = CollectionsCallbackResultsSource
  import T = CollectionsTraversalModel

  ghost method PredicateReply(call: CallOutcome, c: Context) returns (reply: T.Reply)
    ensures reply == Project(Judge(call,c))
    ensures call.Reverted? ==> reply == T.Error(call.reason)
    ensures call.Returned? ==> (reply.Ok? == (call.data == Word(0) || call.data == Word(1)))
    ensures call.Returned? && reply.Ok? ==> reply.truth == (call.data == Word(1))
    ensures call.Returned? && reply.Error? ==> reply.reason == InvalidBytes(c)
  {
    var result := S.Predicate(call,c);
    reply := Project(result);
    assert Pow256(32) > 1;
    NatBytesRoundTrip(0,32);
    NatBytesRoundTrip(1,32);
  }

  lemma ErrorWire(c: Context)
    requires Fits(c)
    ensures |InvalidBytes(c)| == 132
    ensures InvalidBytes(c)[..4] == [0x24,0x44,0x8a,0x11]
    ensures InvalidBytes(c)[4..8] == c.operation
    ensures InvalidBytes(c)[8..36] == Zeros(28)
    ensures ReadNat(InvalidBytes(c)[36..68]) == c.index
    ensures ReadNat(InvalidBytes(c)[68..100]) == c.other
    ensures ReadNat(InvalidBytes(c)[100..132]) == c.target
  {
    S.ErrorSelector();
    assert Pow256(20) <= Pow256(32) by {
      var i: nat := 20;
      while i < 32
        invariant 20 <= i <= 32
        invariant Pow256(20) <= Pow256(i)
        decreases 32-i
      { i := i+1; }
    }
    assert InvalidBytes(c)[36..68] == Word(c.index);
    assert InvalidBytes(c)[68..100] == Word(c.other);
    assert InvalidBytes(c)[100..132] == Word(c.target);
    NatBytesRoundTrip(c.index,32);
    NatBytesRoundTrip(c.other,32);
    NatBytesRoundTrip(c.target,32);
  }

  ghost method Exhaustion(gasBefore: nat, gasAfter: nat, reason: seq<Byte>) returns (rejected: bool)
    ensures rejected == Reject(gasBefore,gasAfter,reason)
    ensures reason == Signal() ==> rejected
    ensures gasAfter <= gasBefore/63 ==> rejected
    ensures gasAfter > gasBefore/63 && reason != Signal() ==> !rejected
    ensures gasAfter > gasBefore/63 && |reason| > 4 && reason[..4] == Signal() ==> !rejected
  {
    rejected := S.RejectOutOfGas(gasBefore,gasAfter,reason);
  }
}

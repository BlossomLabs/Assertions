// SPDX-License-Identifier: MIT
// Collections.sol SHA256: $HASH
include "Model.dfy"

module CollectionsCallbackResultsSource {
  import opened AbiFrames
  import opened CollectionsCallbackResultsModel

  // call is the complete actual _callValue outcome, including its prepared
  // state/trace receipt in the caller. This adapter adds no external call.
  ghost method Predicate(call: CallOutcome, c: Context) returns (result: PredicateOutcome)
    ensures result == Judge(call,c)
  {
    if call.Reverted? { result := Failure(call.reason); return; }
    var data := call.data;
    if $LENGTH { result := Invalid(c); return; }
    var answer := ReadNat(data[$OFFSET..$OFFSET+32]);
    assert data[0..32] == data;
    assert answer == ReadNat(data);
    CanonicalWord(data);
    if $BOUND { result := Invalid(c); return; }
    result := Truth($TRUTH);
  }

  ghost method RejectOutOfGas(gasBefore: nat, gasAfter: nat, reason: seq<Byte>) returns (rejected: bool)
    ensures rejected == Reject(gasBefore,gasAfter,reason)
  {
    var head: seq<Byte> := [0,0,0,0];
    if $SIGNAL_LENGTH { head := reason[..4]; }
    rejected := $EXHAUSTED;
  }

  lemma ErrorSelector()
    ensures [$ERROR_SELECTOR] == [0x24,0x44,0x8a,0x11]
  {}
}

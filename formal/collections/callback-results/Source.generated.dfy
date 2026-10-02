// SPDX-License-Identifier: MIT
// Collections.sol SHA256: 0fb54250a53bceb5c8d1e530144ae5c46eb499ce4456051914b5ff95af9d9ba4
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
    if (|data| != 32) { result := Invalid(c); return; }
    var answer := ReadNat(data[0..0+32]);
    assert data[0..32] == data;
    assert answer == ReadNat(data);
    CanonicalWord(data);
    if (answer > 1) { result := Invalid(c); return; }
    result := Truth((answer == 1));
  }

  ghost method RejectOutOfGas(gasBefore: nat, gasAfter: nat, reason: seq<Byte>) returns (rejected: bool)
    ensures rejected == Reject(gasBefore,gasAfter,reason)
  {
    var head: seq<Byte> := [0,0,0,0];
    if (|reason| == 4) { head := reason[..4]; }
    rejected := ((gasAfter <= (gasBefore / 63)) || (head == Signal()));
  }

  lemma ErrorSelector()
    ensures [0x24,0x44,0x8a,0x11] == [0x24,0x44,0x8a,0x11]
  {}
}

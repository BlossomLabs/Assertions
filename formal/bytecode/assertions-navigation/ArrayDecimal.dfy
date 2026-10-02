// SPDX-License-Identifier: MIT
// Independent decimal numeral semantics, including arbitrary leading zeroes.
include "../scans/Machine.dfy"
module AssertionsNavigationArrayDecimal {
  import S = BytecodeScanMachine
  predicate Digits(data: seq<S.Byte>,start: nat,stop: nat) {
    start <= stop <= |data| &&
    forall i {:trigger data[i]} :: start <= i < stop ==> 48 <= data[i] <= 57
  }
  function Number(data: seq<S.Byte>,start: nat,stop: nat,initial: nat): nat
    requires Digits(data,start,stop)
    decreases stop-start
  {
    if start == stop then initial
    else Number(data,start+1,stop,initial*10+data[start]-48)
  }
  lemma Monotone(data: seq<S.Byte>,start: nat,stop: nat,initial: nat)
    requires Digits(data,start,stop)
    ensures initial <= Number(data,start,stop,initial)
    decreases stop-start
  {
    if start < stop {
      Monotone(data,start+1,stop,initial*10+data[start]-48);
      assert initial <= initial*10+data[start]-48;
    }
  }
  lemma Advance(data: seq<S.Byte>,start: nat,stop: nat,initial: nat)
    requires Digits(data,start,stop) && start < stop
    ensures Digits(data,start+1,stop)
    ensures Number(data,start,stop,initial) == Number(data,start+1,stop,initial*10+data[start]-48)
    ensures initial*10+data[start]-48 <= Number(data,start,stop,initial)
  {
    Monotone(data,start+1,stop,initial*10+data[start]-48);
  }
}

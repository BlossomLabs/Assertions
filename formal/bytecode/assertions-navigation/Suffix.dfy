// SPDX-License-Identifier: MIT
// Independent descriptor-tail property; physical instruction refinement is separate.
include "../scans/Machine.dfy"
module AssertionsNavigationSuffix {
  import S = BytecodeScanMachine
  type Byte = S.Byte
  predicate Digit(b: Byte) { 48 <= b <= 57 }
  predicate Trail(t: seq<Byte>,ts: nat,te: nat,j: nat) {
    ts <= j && j+2 <= te <= |t| &&
    forall k {:trigger t[k]} :: j < k < te-1 ==> Digit(t[k])
  }
  predicate Suffix(t: seq<Byte>,ts: nat,te: nat,j: nat) {
    Trail(t,ts,te,j) && t[j] == 91 && t[te-1] == 93
  }
  lemma Initial(t: seq<Byte>,ts: nat,te: nat)
    requires ts+2 <= te <= |t|
    ensures Trail(t,ts,te,te-2)
  {}
  lemma Descend(t: seq<Byte>,ts: nat,te: nat,j: nat)
    requires Trail(t,ts,te,j) && j > ts && Digit(t[j])
    ensures Trail(t,ts,te,j-1)
  {
    forall k {:trigger t[k]} | j-1 < k < te-1
      ensures Digit(t[k])
    { if k != j { assert j < k; } }
  }
  lemma Finish(t: seq<Byte>,ts: nat,te: nat,j: nat)
    requires Trail(t,ts,te,j) && t[j] == 91 && t[te-1] == 93
    ensures Suffix(t,ts,te,j)
  {}
  lemma Unique(t: seq<Byte>,ts: nat,te: nat,left: nat,right: nat)
    requires Suffix(t,ts,te,left) && Suffix(t,ts,te,right)
    ensures left == right
  {
    if left < right { assert Digit(t[right]); }
    else if right < left { assert Digit(t[left]); }
  }
}

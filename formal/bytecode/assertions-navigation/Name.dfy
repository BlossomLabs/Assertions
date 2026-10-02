// SPDX-License-Identifier: MIT
// Descriptor identifiers accept lowercase ASCII letters and decimal digits.
include "../scans/Machine.dfy"
module AssertionsNavigationName {
  import S = BytecodeScanMachine
  predicate Character(b: S.Byte) { 97 <= b <= 122 || 48 <= b <= 57 }
  function End(t: seq<S.Byte>,p: nat,limit: nat): nat
    requires p <= limit <= |t|
    ensures p <= End(t,p,limit) <= limit
    decreases limit-p
  { if p == limit || !Character(t[p]) then p else End(t,p+1,limit) }
  predicate Prefix(t: seq<S.Byte>,p: nat,q: nat,limit: nat) {
    p <= q <= limit <= |t| &&
    forall k {:trigger t[k]} :: p <= k < q ==> Character(t[k])
  }
  lemma Advance(t: seq<S.Byte>,p: nat,q: nat,limit: nat)
    requires Prefix(t,p,q,limit) && q < limit && Character(t[q])
    ensures Prefix(t,p,q+1,limit)
  {
    forall k {:trigger t[k]} | p <= k < q+1
      ensures Character(t[k])
    { if k != q { assert k < q; } }
  }
  lemma Result(t: seq<S.Byte>,p: nat,limit: nat)
    requires p <= limit <= |t|
    ensures Prefix(t,p,End(t,p,limit),limit)
    ensures End(t,p,limit) == limit || !Character(t[End(t,p,limit)])
    decreases limit-p
  {
    if p < limit && Character(t[p]) {
      Result(t,p+1,limit);
      forall k {:trigger t[k]} | p <= k < End(t,p,limit)
        ensures Character(t[k])
      { if k != p { assert p+1 <= k; } }
    }
  }
  lemma Unique(t: seq<S.Byte>,p: nat,q: nat,limit: nat)
    requires Prefix(t,p,q,limit)
    requires q == limit || !Character(t[q])
    ensures q == End(t,p,limit)
    decreases q-p
  {
    if p < q {
      assert Character(t[p]);
      Unique(t,p+1,q,limit);
    }
  }
}

// SPDX-License-Identifier: MIT
module SourceMemoOrderV1 {
  predicate Extends<V>(a: map<nat,V>,b: map<nat,V>) {
    a.Keys <= b.Keys && forall i | i in a :: b[i] == a[i]
  }
  predicate Footprint<V>(a: map<nat,V>,b: map<nat,V>,bound: nat) {
    forall i | i in b && i !in a :: i <= bound
  }
  lemma ExtensionsCompose<V>(a: map<nat,V>,b: map<nat,V>,c: map<nat,V>)
    requires Extends(a,b) && Extends(b,c)
    ensures Extends(a,c)
  {
    forall i | i in a
      ensures c[i] == a[i]
    { assert i in b; }
  }
  lemma FootprintsCompose<V>(a: map<nat,V>,b: map<nat,V>,c: map<nat,V>,bound: nat)
    requires a.Keys <= b.Keys && b.Keys <= c.Keys
    requires Footprint(a,b,bound) && Footprint(b,c,bound)
    ensures Footprint(a,c,bound)
  {
    forall i | i in c && i !in a
      ensures i <= bound
    { if i in b { } else { } }
  }
}

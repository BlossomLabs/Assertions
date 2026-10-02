// SPDX-License-Identifier: MIT
// Pure Euclidean arithmetic; no interpreter or recursive power definitions.
module BytecodeCollectionsWordEuclidean {
  lemma RemainderUnique(n: nat,d: nat,q: nat,r: nat)
    requires d > 0 && r < d && n == d*q+r
    ensures n/d == q && n%d == r
  {
    var actual := n/d;
    assert n == actual*d+n%d && 0 <= n%d < d;
    if actual > q {
      assert actual >= q+1;
      assert actual*d >= (q+1)*d;
      assert n >= (q+1)*d;
      assert n < (q+1)*d;
      assert false;
    }
    if actual < q {
      assert actual+1 <= q;
      assert (actual+1)*d <= q*d;
      assert n < (actual+1)*d;
      assert n >= q*d;
      assert false;
    }
    assert actual == q;
    assert n%d == r;
  }
  lemma Multiple(d: nat,q: nat)
    requires d > 0
    ensures (d*q)%d == 0
  { RemainderUnique(d*q,d,q,0); }
  lemma Small(n: nat,d: nat)
    requires n < d
    ensures n%d == n
  { RemainderUnique(n,d,0,n); }
  lemma TopRemainder(n: nat,limit: nat,d: nat)
    requires 0 < d <= limit && limit%d == 0
    requires limit-d <= n < limit
    ensures n%d == n-(limit-d)
  {
    var q := limit/d;
    assert limit == q*d && q > 0;
    var r := n-(limit-d);
    assert r < d && n == d*(q-1)+r;
    RemainderUnique(n,d,q-1,r);
  }
  lemma SignFixed(n: nat,limit: nat,d: nat)
    requires n < limit && 0 < d <= limit && limit%d == 0 && d%2 == 0
    ensures (if n%d < d/2 then n%d else limit-d+n%d) == n <==>
            n < d/2 || n >= limit-d/2
  {
    assert 2*(d/2) == d;
    if n < d/2 { Small(n,d); }
    if n >= limit-d/2 {
      assert n >= limit-d;
      TopRemainder(n,limit,d);
      assert n%d >= d/2;
      assert limit-d+n%d == n;
    }
    if n%d >= d/2 { assert limit-d+n%d >= limit-d/2; }
  }
}

include "Model.dfy"
module OperationsIntegerRootSeed {
  import M = OperationsIntegerRootModel
  import B = OperationsBinaryLogModel
  lemma PowerMonotone(n: nat,m: nat)
    requires n <= m
    ensures B.Power(n) <= B.Power(m)
    decreases m
  { if n < m { PowerMonotone(n,m-1); } }
  lemma Advance(a: nat,e: nat,k: nat,aa: nat,t: nat)
    requires k > 0 && e+k <= 127
    requires aa == a/B.Power(2*e) && t == B.Power(e)
    requires 1 <= aa < B.Power(4*k)
    ensures var next := e+(if aa >= B.Power(2*k) then k else 0);
            1 <= a/B.Power(2*next) < B.Power(2*k)
    ensures var next := e+(if aa >= B.Power(2*k) then k else 0);
            (if aa >= B.Power(2*k) then aa/B.Power(2*k) else aa) == a/B.Power(2*next)
    ensures var next := e+(if aa >= B.Power(2*k) then k else 0);
            B.Power(next) == t*(if aa >= B.Power(2*k) then B.Power(k) else 1)
  {
    B.PowerAdd(e,e);
    if aa >= B.Power(2*k) {
      B.PowerAdd(2*k,2*k);
      B.QuotientUpper(aa,B.Power(2*k),B.Power(2*k));
      M.QuotientLower(aa,B.Power(2*k),1);
      B.DivideNested(a,B.Power(2*e),B.Power(2*k));
      B.PowerAdd(2*e,2*k);
      B.PowerAdd(e,k);
    }
  }
  lemma Bounds(a: nat,e: nat)
    requires e <= 127 && 1 <= a/B.Power(2*e) < 4
    ensures B.Power(e)*B.Power(e) <= a < 4*B.Power(e)*B.Power(e)
    ensures 1 <= B.Power(e) <= B.Power(127)
  {
    B.PowerAdd(e,e);
    PowerMonotone(e,127);
    var d := B.Power(2*e);
    assert a == (a/d)*d+a%d;
    B.ProductMonotone(1,a/d,d);
    B.ProductMonotone(a/d+1,4,d);
    assert a < (a/d+1)*d <= 4*d;
    assert 4*d == 4*B.Power(e)*B.Power(e);
  }
  lemma Coarse(a: nat,t: nat,x: nat)
    requires 1 <= t <= B.Power(127) && t*t <= a < 4*t*t
    requires t <= x <= 8*t+8
    ensures M.Newton(a,x) <= 8*t+8
    ensures x+a/x < B.Word
  {
    B.KnownPowers();
    assert B.Power(128) == 2*B.Power(127);
    B.QuotientUpper(a,x,4*t);
    assert x+a/x < 12*t+8;
  }
}

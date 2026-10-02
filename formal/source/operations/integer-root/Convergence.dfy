include "Seed.dfy"
module OperationsIntegerRootConvergence {
  import M = OperationsIntegerRootModel
  import S = OperationsIntegerRootSeed
  import B = OperationsBinaryLogModel
  lemma DivideStrict(n: real,d: real,u: real)
    requires d > 0.0 && n < u*d
    ensures n/d < u
  {
    assert (n/d)*d == n;
    if n/d >= u {
      M.RealProductNonnegative(n/d-u,d);
      assert (n/d-u)*d == n-u*d;
      assert false;
    }
  }
  lemma Narrow(t: real)
    requires 16.0 <= t <= 170141183460469231731687303715884105728.0
    ensures (t/6058287395472553279488.0+3.0)*(t/6058287395472553279488.0+3.0) < 2.0*t
  {
    var k := 6058287395472553279488.0;
    var limit := 170141183460469231731687303715884105728.0;
    M.RealProductNonnegative(t,limit-t);
    assert t*t <= t*limit;
    M.RealProductNonnegative(t,k*k/4.0-limit);
    assert t*t <= t*k*k/4.0;
    M.DivideUpper(t*t,k*k,t/4.0);
    M.DivideUpper(6.0*t,k,t/4.0);
    assert 9.0 <= t;
    assert (t/k+3.0)*(t/k+3.0) == t*t/(k*k)+6.0*t/k+9.0;
  }
  lemma SplitFraction(n: real,r: real,x: real)
    requires x > 0.0
    ensures (n+2.0*r)/(2.0*x) == n/(2.0*x)+r/x
  {
    var lhs := (n+2.0*r)/(2.0*x);
    var rhs := n/(2.0*x)+r/x;
    assert lhs*(2.0*x) == n+2.0*r;
    assert (n/(2.0*x))*(2.0*x) == n;
    assert (r/x)*x == r;
    assert (r/x)*(2.0*x) == 2.0*((r/x)*x);
    assert rhs*(2.0*x) == n+2.0*r;
    if lhs > rhs {
      M.RealProductPositive(lhs-rhs,2.0*x);
      assert (lhs-rhs)*(2.0*x) == 0.0;
      assert false;
    } else if lhs < rhs {
      M.RealProductPositive(rhs-lhs,2.0*x);
      assert (rhs-lhs)*(2.0*x) == 0.0;
      assert false;
    }
  }
  lemma QuadraticRatio(err: real,x: real,r: real,t: real,e: real)
    requires 0.0 < t <= r <= x && 0.0 <= err*err <= e < 2.0*t
    ensures (err*err+2.0*r)/(2.0*x) < 2.0
  {
    M.FractionUpper(err*err,2.0*x,e,2.0*t);
    M.DivideUpper(r,x,1.0);
    DivideStrict(e,2.0*t,1.0);
    SplitFraction(err*err,r,x);
    assert err*err/(2.0*x) < 1.0;
  }
  lemma FinalError(a: nat,t: nat,r: nat,x: nat)
    requires t >= 16 && t <= B.Power(127) && M.Root(a,r) && t <= r <= x
    requires (x as real)-(r as real) <= (t as real)/6058287395472553279488.0+3.0
    ensures r <= M.Newton(a,x) <= r+1
  {
    B.KnownPowers();
    assert B.Power(128) == 2*B.Power(127);
    var tr := t as real;
    var k := 6058287395472553279488.0;
    var e := (tr/k+3.0)*(tr/k+3.0);
    Narrow(tr);
    M.NewtonLower(a,x,r);
    M.NewtonRealUpper(a,x,r);
    var err := (x as real)-(r as real);
    M.SquareRange(err,tr/k+3.0);
    assert 0.0 <= err*err <= e;
    QuadraticRatio(err,x as real,r as real,tr,e);
    calc {
       (M.Newton(a,x) as real)-(r as real);
    <= (err*err+2.0*(r as real))/(2.0*(x as real));
    < 2.0;
    }
  }
  lemma Six(a: nat,t: nat,x0: nat,x1: nat,x2: nat,x3: nat,x4: nat,x5: nat,x6: nat)
    requires a < B.Word
    requires 1 <= t <= B.Power(127) && t*t <= a < 4*t*t
    requires x0 == (3*t)/2
    requires x1 == M.Newton(a,x0) && x2 == M.Newton(a,x1)
    requires x3 == M.Newton(a,x2) && x4 == M.Newton(a,x3)
    requires x5 == M.Newton(a,x4) && x6 == M.Newton(a,x5)
    ensures M.Spec(a) <= x6 <= M.Spec(a)+1
  {
    var r := M.Spec(a);
    M.SeedRoot(a,t,r);
    M.InitialError(a,t,r);
    if t < 16 {
      assert x1 <= r+4;
      M.TightStep(a,r,x1);
      M.TightStep(a,r,x2);
      M.TightStep(a,r,x3);
      M.TightStep(a,r,x4);
      M.TightStep(a,r,x5);
    } else {
      M.ErrorStep(a,t,r,x1,12.0);
      M.ErrorStep(a,t,r,x2,288.0);
      M.ErrorStep(a,t,r,x3,165888.0);
      M.ErrorStep(a,t,r,x4,55037657088.0);
      var k := 6058287395472553279488.0;
      assert (x5 as real)-(r as real) <= (t as real)/k+3.0;
      FinalError(a,t,r,x5);
      assert x6 <= r+1;
    }
  }
}

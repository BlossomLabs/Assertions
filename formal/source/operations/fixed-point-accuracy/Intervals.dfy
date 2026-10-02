include "Spec.dfy"
module OperationsFixedPointAccuracyIntervals {
  import B = OperationsBinaryLogModel
  import R = OperationsFixedPointAccuracySeries
  import S = OperationsFixedPointAccuracySpec
  datatype Interval = Interval(lower: real,upper: real)
  ghost predicate Contains(bounds: Interval,value: real) { bounds.lower <= value <= bounds.upper }
  ghost function ExpBounds(t: real,n: nat): Interval {
    var center := R.ExpSum(t,n);
    Interval(center-R.ExpRadius(t,n),center+R.ExpRadius(t,n))
  }
  ghost function LnBounds(y: real,n: nat): Interval
    requires y > 0.0
  {
    R.LogArgumentRange(y);
    var z := R.LogArgument(y);
    var center := R.AtanhSum(z,n);
    Interval(center-R.AtanhRadius(z,n),center+R.AtanhRadius(z,n))
  }
  ghost function Add(a: Interval,b: Interval): Interval { Interval(a.lower+b.lower,a.upper+b.upper) }
  ghost function Subtract(a: Interval,b: Interval): Interval { Interval(a.lower-b.upper,a.upper-b.lower) }
  ghost function Scale(factor: real,a: Interval): Interval {
    if factor >= 0.0 then Interval(factor*a.lower,factor*a.upper)
    else Interval(factor*a.upper,factor*a.lower)
  }
  lemma AddContains(a: Interval,b: Interval,x: real,y: real)
    requires Contains(a,x) && Contains(b,y)
    ensures Contains(Add(a,b),x+y)
  { }
  lemma SubtractContains(a: Interval,b: Interval,x: real,y: real)
    requires Contains(a,x) && Contains(b,y)
    ensures Contains(Subtract(a,b),x-y)
  { }
  lemma ScaleContains(factor: real,a: Interval,x: real)
    requires Contains(a,x)
    ensures Contains(Scale(factor,a),factor*x)
  { if factor < 0.0 { } }
  lemma ExpContains(t: real,n: nat,e: real)
    requires R.ExpPoint(t,e) && 2.0*R.Abs(t) <= (n+1) as real
    ensures Contains(ExpBounds(t,n),e)
  { R.ExpLimitEnclosure(t,n,e); }
  lemma LnContains(y: real,n: nat,l: real)
    requires R.LnPoint(y,l)
    ensures Contains(LnBounds(y,n),l)
  { R.LnLimitEnclosure(y,n,l); }
  // entry/2^log and WAD/2^59 are in [1,2). The exact logarithmic
  // decomposition is a separate addition/power-law obligation.
  ghost function NormalizedLnBounds(entry: int,log: nat,n: nat): Interval
    requires entry > 0
  {
    var mantissa := (entry as real)/(B.Power(log) as real);
    var wadMantissa := S.Wad/(B.Power(59) as real);
    Add(Subtract(LnBounds(mantissa,n),LnBounds(wadMantissa,n)),
        Scale((log as real)-59.0,LnBounds(2.0,n)))
  }
  lemma NormalizedLnContains(entry: int,log: nat,n: nat,lm: real,lw: real,l2: real)
    requires entry > 0
    requires R.LnPoint((entry as real)/(B.Power(log) as real),lm)
    requires R.LnPoint(S.Wad/(B.Power(59) as real),lw) && R.LnPoint(2.0,l2)
    ensures Contains(NormalizedLnBounds(entry,log,n),lm-lw+((log as real)-59.0)*l2)
  {
    LnContains((entry as real)/(B.Power(log) as real),n,lm);
    LnContains(S.Wad/(B.Power(59) as real),n,lw); LnContains(2.0,n,l2);
    SubtractContains(LnBounds((entry as real)/(B.Power(log) as real),n),
                     LnBounds(S.Wad/(B.Power(59) as real),n),lm,lw);
    ScaleContains((log as real)-59.0,LnBounds(2.0,n),l2);
    AddContains(Subtract(LnBounds((entry as real)/(B.Power(log) as real),n),LnBounds(S.Wad/(B.Power(59) as real),n)),
                Scale((log as real)-59.0,LnBounds(2.0,n)),lm-lw,((log as real)-59.0)*l2);
  }
  lemma PowerMonotone(a: real,b: real,n: nat)
    requires 0.0 <= a <= b
    ensures R.Power(a,n) <= R.Power(b,n)
    decreases n
  {
    if n > 0 {
      PowerMonotone(a,b,n-1); R.PowerNonnegative(a,n-1); R.PowerNonnegative(b,n-1);
      R.MultiplyOrder(R.Power(a,n-1),R.Power(b,n-1),a);
      R.MultiplyOrder(a,b,R.Power(b,n-1));
      assert R.Power(a,n) == a*R.Power(a,n-1);
      assert R.Power(b,n) == b*R.Power(b,n-1);
      assert b*R.Power(b,n-1)-a*R.Power(a,n-1) ==
             (b-a)*R.Power(b,n-1)+a*(R.Power(b,n-1)-R.Power(a,n-1));
    }
  }
  ghost function NormalizedRadius(n: nat): real {
    (9.0/4.0)*R.Power(1.0/3.0,2*n+1)/((2*n+1) as real)
  }
  lemma NormalizedAtanhRadius(y: real,n: nat)
    requires 1.0 <= y <= 2.0
    ensures R.AtanhRadius(R.LogArgument(y),n) <= NormalizedRadius(n)
  {
    R.LogArgumentRange(y);
    var z := R.LogArgument(y);
    assert z == (y-1.0)/(y+1.0);
    assert y+1.0 > 0.0;
    assert 3.0*(y-1.0) <= y+1.0;
    R.DivideOrder(y-1.0,(y+1.0)/3.0,y+1.0);
    assert 0.0 <= z <= 1.0/3.0;
    R.MultiplyOrder(z,1.0/3.0,z);
    R.MultiplyOrder(z,1.0/3.0,1.0/3.0);
    assert 1.0-z*z >= 8.0/9.0;
    R.PowerAbs(z,2*n+1); PowerMonotone(z,1.0/3.0,2*n+1);
    R.PowerNonnegative(z,2*n+1);
    R.PowerNonnegative(1.0/3.0,2*n+1);
    assert R.Power(z,2*n+1) >= 0.0;
    assert R.Abs(R.AtanhTerm(z,n)) == 2.0*R.Power(z,2*n+1)/((2*n+1) as real);
    var term := R.Abs(R.AtanhTerm(z,n));
    var maximum := 2.0*R.Power(1.0/3.0,2*n+1)/((2*n+1) as real);
    R.MultiplyOrder(R.Power(z,2*n+1),R.Power(1.0/3.0,2*n+1),2.0);
    R.DivideOrder(2.0*R.Power(z,2*n+1),2.0*R.Power(1.0/3.0,2*n+1),(2*n+1) as real);
    assert 0.0 <= term <= maximum;
    R.DivideOrder(term,maximum,1.0-z*z);
    R.DivideDenominator(maximum,8.0/9.0,1.0-z*z);
    assert maximum/(1.0-z*z) <= maximum/(8.0/9.0);
    R.DivideProduct(2.0*R.Power(1.0/3.0,2*n+1),(2*n+1) as real,8.0/9.0);
    R.DivideScale(R.Power(1.0/3.0,2*n+1),(2*n+1) as real,9.0/4.0);
    assert maximum/(8.0/9.0) == (9.0/4.0)*R.Power(1.0/3.0,2*n+1)/((2*n+1) as real);
    assert NormalizedRadius(n) == (9.0/4.0)*R.Power(1.0/3.0,2*n+1)/((2*n+1) as real);
    assert R.AtanhRadius(z,n) == term/(1.0-z*z);
    assert R.AtanhRadius(z,n) <= NormalizedRadius(n);
  }
}

include "../binary-log/Connection.dfy"
module OperationsIntegerRootModel {
  import B = OperationsBinaryLogModel
  predicate Root(a: nat,r: nat) { r*r <= a < (r+1)*(r+1) }
  function Search(a: nat,lo: nat,hi: nat): nat
    requires lo < hi && lo*lo <= a < hi*hi
    ensures lo <= Search(a,lo,hi) < hi && Root(a,Search(a,lo,hi))
    decreases hi-lo
  {
    if hi-lo == 1 then lo
    else
      var mid := (lo+hi)/2;
      if mid*mid <= a then Search(a,mid,hi) else Search(a,lo,mid)
  }
  function Spec(a: nat): nat
    requires a < B.Word
    ensures Root(a,Spec(a)) && Spec(a) < B.Power(128)
  {
    B.KnownPowers();
    Search(a,0,B.Power(128))
  }
  function Newton(a: nat,x: nat): nat
    requires x > 0
  { (x+a/x)/2 }
  lemma ProductMonotone(a: nat,b: nat,c: nat)
    requires a <= b
    ensures a*c <= b*c
  { B.ProductMonotone(a,b,c); }
  lemma SquareMonotone(a: nat,b: nat)
    requires a <= b
    ensures a*a <= b*b
  { ProductMonotone(a,b,a); ProductMonotone(a,b,b); }
  lemma SquareNonnegative(x: real)
    ensures x*x >= 0.0
  { }
  lemma RealProductNonnegative(x: real,y: real)
    requires x >= 0.0 && y >= 0.0
    ensures x*y >= 0.0
  { }
  lemma DivideUpper(n: real,d: real,u: real)
    requires d > 0.0 && n <= u*d
    ensures n/d <= u
  { assert (n/d)*d == n; }
  lemma RealProductPositive(x: real,y: real)
    requires x > 0.0 && y > 0.0
    ensures x*y > 0.0
  { }
  lemma FractionUpper(n: real,d: real,limit: real,denom: real)
    requires 0.0 <= n <= limit && 0.0 < denom <= d
    ensures n/d <= limit/denom
  {
    RealProductNonnegative(limit-n,denom);
    RealProductNonnegative(limit,d-denom);
    assert n*denom <= limit*d;
    assert (n/d)*d == n;
    assert (limit/denom)*denom == limit;
    if n/d > limit/denom {
      RealProductPositive(n/d-limit/denom,d*denom);
      assert (n/d-limit/denom)*(d*denom) == n*denom-limit*d;
      assert false;
    }
  }
  lemma SquareRange(x: real,m: real)
    requires m >= 0.0 && -m <= x <= m
    ensures x*x <= m*m
  { RealProductNonnegative(m-x,m+x); assert m*m-x*x == (m-x)*(m+x); }
  lemma RootUnique(a: nat,r: nat,s: nat)
    requires Root(a,r) && Root(a,s)
    ensures r == s
  {
    if r < s { SquareMonotone(r+1,s); }
    if s < r { SquareMonotone(s+1,r); }
  }
  lemma RootPositive(a: nat,r: nat)
    requires a > 0 && Root(a,r)
    ensures r > 0
  { }
  lemma SeedRoot(a: nat,t: nat,r: nat)
    requires t > 0 && t*t <= a < 4*t*t && Root(a,r)
    ensures t <= r < 2*t
  {
    if r < t { SquareMonotone(r+1,t); }
    if r >= 2*t { SquareMonotone(2*t,r); assert (2*t)*(2*t) == 4*t*t; assert false; }
  }
  lemma QuotientLower(n: nat,d: nat,q: nat)
    requires d > 0 && q*d <= n
    ensures q <= n/d
  {
    var k := n/d;
    assert n == k*d+n%d;
    if k < q { ProductMonotone(k+1,q,d); assert (k+1)*d == k*d+d; }
  }
  lemma NewtonLower(a: nat,x: nat,r: nat)
    requires x > 0 && Root(a,r)
    ensures Newton(a,x) >= r
  {
    var q := a/x;
    assert a == q*x+a%x;
    if x+q < 2*r {
      assert q+1 <= 2*r-x;
      ProductMonotone(q+1,2*r-x,x);
      assert a < (q+1)*x;
      assert (2*r-x)*x == r*r-(x-r)*(x-r);
      assert (x-r)*(x-r) >= 0;
    }
  }
  lemma NewtonRealUpper(a: nat,x: nat,r: nat)
    requires x > 0 && Root(a,r)
    ensures (Newton(a,x) as real)-(r as real) <= (((x as real)-(r as real))*((x as real)-(r as real))+2.0*(r as real))/(2.0*(x as real))
  {
    var q := a/x;
    assert a == q*x+a%x;
    assert (q as real) <= (a as real)/(x as real);
    assert (Newton(a,x) as real) <= ((x as real)+(q as real))/2.0;
    assert a <= r*r+2*r;
  }
  lemma InitialError(a: nat,t: nat,r: nat)
    requires t > 0 && t*t <= a < 4*t*t && Root(a,r)
    ensures Newton(a,(3*t)/2) >= r
    ensures (Newton(a,(3*t)/2) as real)-(r as real) <= (t as real)/12.0+3.0
  {
    var x := (3*t)/2;
    assert x > 0;
    SeedRoot(a,t,r);
    NewtonLower(a,x,r);
    NewtonRealUpper(a,x,r);
    assert ((3*t-1) as real)/2.0 <= (x as real) <= 3.0*(t as real)/2.0;
    assert -((t as real)+1.0)/2.0 <= (x as real)-(r as real) <= ((t as real)+1.0)/2.0;
    SquareRange((x as real)-(r as real),((t as real)+1.0)/2.0);
    var tr := t as real;
    var numerator := (tr+1.0)*(tr+1.0)/4.0+4.0*tr;
    var denom := 3.0*tr-1.0;
    assert (tr/12.0+3.0)*denom-numerator == 53.0*tr/12.0-13.0/4.0;
    DivideUpper(numerator,denom,tr/12.0+3.0);
    FractionUpper(((x as real)-(r as real))*((x as real)-(r as real))+2.0*(r as real),2.0*(x as real),numerator,denom);
  }
  lemma ErrorStep(a: nat,t: nat,r: nat,x: nat,k: real)
    requires t >= 16 && Root(a,r) && t <= r <= x && k >= 12.0
    requires (x as real)-(r as real) <= (t as real)/k+3.0
    ensures Newton(a,x) >= r
    ensures (Newton(a,x) as real)-(r as real) <= (t as real)/(2.0*k*k)+3.0
  {
    NewtonLower(a,x,r); NewtonRealUpper(a,x,r);
    SquareRange((x as real)-(r as real),(t as real)/k+3.0);
    var tr := t as real;
    assert k*k > 0.0;
    DivideUpper(3.0,k,1.0/4.0);
    DivideUpper(9.0,2.0*tr,9.0/32.0);
    assert (tr/k+3.0)*(tr/k+3.0)/(2.0*tr)+1.0 == tr/(2.0*k*k)+3.0/k+9.0/(2.0*tr)+1.0;
    assert (tr/k+3.0)*(tr/k+3.0)/(2.0*tr)+1.0 <= tr/(2.0*k*k)+3.0;
    FractionUpper(((x as real)-(r as real))*((x as real)-(r as real)),2.0*(x as real),(tr/k+3.0)*(tr/k+3.0),2.0*tr);
    DivideUpper(r as real,x as real,1.0);
    assert (((x as real)-(r as real))*((x as real)-(r as real))+2.0*(r as real))/(2.0*(x as real)) == ((x as real)-(r as real))*((x as real)-(r as real))/(2.0*(x as real))+(r as real)/(x as real);
  }
  lemma TightStep(a: nat,r: nat,x: nat)
    requires Root(a,r) && r > 0 && r <= x <= r+4
    ensures r <= Newton(a,x) <= r+1
  {
    NewtonLower(a,x,r);
    var q := a/x;
    assert a <= r*r+2*r;
    if x+q >= 2*r+4 {
      assert q >= 2*r+4-x;
      ProductMonotone(2*r+4-x,q,x);
      var d := x-r;
      assert 0 <= d <= 4;
      ProductMonotone(0,d,4-d);
      assert (2*r+4-x)*x == r*r+4*r+d*(4-d);
      assert (2*r+4-x)*x > r*r+2*r;
      assert q*x <= a;
    }
  }
  lemma FinalCorrection(a: nat,r: nat,x: nat)
    requires Root(a,r) && r > 0 && r <= x <= r+1
    ensures x-(if x > a/x then 1 else 0) == r
  {
    if x == r { QuotientLower(a,r,r); }
    else {
      assert x == r+1 && a < x*x;
      assert a == (a/x)*x+a%x;
      if a/x >= x { ProductMonotone(x,a/x,x); }
    }
  }
}

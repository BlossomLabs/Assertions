include "Power.dfy"
module OperationsModularPowerInverseModel {
  import B = OperationsBinaryLogModel
  import E = OperationsModularPowerEuclid
  import P = OperationsFullMulDivProduct
  import V = OperationsFullMulDivInverse
  import Q = OperationsModularPowerPower
  datatype Pair = Pair(first: int,second: int)
  lemma BezoutIdentity(g: nat,r: nat,s: int,t: int)
    requires r > 0
    ensures g*t+r*(s-(g/r)*t) == r*s+(g%r)*t
  {
    assert g == (g/r)*r+g%r;
    calc {
       g*t+r*(s-(g/r)*t);
    == r*s+(g-(g/r)*r)*t;
    == r*s+(g%r)*t;
    }
  }
  function Extended(g: nat,r: nat): Pair
    ensures g*Extended(g,r).first+r*Extended(g,r).second == E.Gcd(g,r)
    decreases r
  {
    if r == 0 then Pair(1,0)
    else var e := Extended(r,g%r);
         BezoutIdentity(g,r,e.first,e.second);
         Pair(e.second,e.first-(g/r)*e.second)
  }
  function Representative(a: nat,n: nat): nat
    requires n > 0
  { Extended(n,a%n).second%n }
  lemma BezoutReduction(a: nat,n: nat,u: int,v: int)
    requires n > 0 && n*u+(a%n)*v == 1
    ensures a*v == 1+n*((a/n)*v-u)
  {
    assert a == (a/n)*n+a%n;
    calc {
       a*v;
    == ((a/n)*n+a%n)*v;
    == n*((a/n)*v)+(a%n)*v;
    == 1+n*((a/n)*v-u);
    }
  }
  lemma RepresentativeCorrect(a: nat,n: nat)
    requires n > 1 && E.Gcd(n,a%n) == 1
    ensures 0 < Representative(a,n) < n
    ensures (a*Representative(a,n))%n == 1
  {
    var e := Extended(n,a%n);
    BezoutReduction(a,n,e.first,e.second);
    P.ShiftRemainder(a*e.second,1,(a/n)*e.second-e.first,n);
    E.CanonicalRemainder(Representative(a,n),n);
    assert Representative(a,n) == e.second%n;
    Q.ProductSameMod(a,Representative(a,n),a,e.second,n);
    if Representative(a,n) == 0 { assert (a*Representative(a,n))%n == 0; }
  }
  lemma CancellationRing(a: int,u: int,v: int)
    ensures a*(u-v) == a*u-a*v
    ensures u*(a*(u-v)) == (a*u)*(u-v)
  { }
  lemma Unique(a: nat,n: nat,u: nat,v: nat)
    requires n > 1 && u < n && v < n
    requires (a*u)%n == 1 && (a*v)%n == 1
    ensures u == v
  {
    CancellationRing(a,u,v);
    E.DifferenceResidue(a*u,a*v,n);
    assert (a*(u-v))%n == 0;
    Q.ProductZeroMod(u,a*(u-v),n);
    Q.UnitMod(a*u,u-v,n);
    assert (u-v)%n == 0;
    if u < v { P.ShiftRemainder(u-v,n+u-v,-1,n); assert 0 < n+u-v < n; }
  }
  function Spec(a: nat,n: nat): nat
  { if n == 0 || n == 1 || E.Gcd(n,a%n) != 1 then 0 else Representative(a,n) }
}

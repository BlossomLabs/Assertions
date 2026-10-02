include "../full-mul-div/Connection.dfy"
module OperationsModularPowerEuclid {
  import B = OperationsBinaryLogModel
  import P = OperationsFullMulDivProduct
  import M = OperationsFullMulDivModel
  import V = OperationsFullMulDivInverse
  import H = OperationsFullMulDivSignedHelpers
  function Gcd(g: nat,r: nat): nat
    decreases r
  { if r == 0 then g else Gcd(r,g%r) }
  function Abs(v: int): nat { if v < 0 then -v else v }
  lemma ProductNonnegative(a: int,b: int)
    requires a >= 0 && b >= 0
    ensures a*b >= 0
  { B.ProductNonnegative(a,b); }
  lemma OppositeDifference(x: int,y: int,q: nat)
    requires x*y <= 0
    ensures Abs(x-q*y) == Abs(x)+q*Abs(y)
    ensures y*(x-q*y) <= 0
  {
    if x >= 0 && y <= 0 {
      B.ProductNonnegative(q,-y);
      B.ProductNonnegative(-y,x-q*y);
    } else {
      B.ProductNonnegative(q,y);
      B.ProductNonnegative(y,-x+q*y);
    }
  }
  lemma Determinant(g: nat,r: nat,x: int,y: int,n: nat)
    requires 0 < r < g && x*y <= 0
    requires Abs(x)*r+Abs(y)*g == n
    ensures Abs(y)*(g%r)+Abs(x-(g/r)*y)*r == n
    ensures y*(x-(g/r)*y) <= 0
    ensures 2*Abs(y) <= n
    ensures g%r > 0 ==> 2*Abs(x-(g/r)*y) <= n
  {
    OppositeDifference(x,y,g/r);
    assert g == (g/r)*r+g%r;
    calc {
       Abs(y)*(g%r)+Abs(x-(g/r)*y)*r;
    == Abs(y)*(g%r)+(Abs(x)+(g/r)*Abs(y))*r;
    == Abs(x)*r+Abs(y)*((g/r)*r+g%r);
    == n;
    }
    B.ProductNonnegative(Abs(x),r);
    assert g >= 2;
    B.ProductMonotone(2,g,Abs(y));
    if g%r > 0 {
      assert r >= 2;
      B.ProductNonnegative(Abs(y),g%r);
      B.ProductMonotone(2,r,Abs(x-(g/r)*y));
    }
  }
  lemma DifferenceResidue(a: int,b: int,d: nat)
    requires d > 0
    ensures (a-b)%d == (a%d-b%d)%d
  {
    assert a == (a/d)*d+a%d;
    assert b == (b/d)*d+b%d;
    calc { a-b; == (a/d)*d+a%d-((b/d)*d+b%d); == a%d-b%d+(a/d-b/d)*d; }
    P.ShiftRemainder(a-b,a%d-b%d,a/d-b/d,d);
  }
  lemma GcdPositive(g: nat,r: nat)
    requires g > 0
    ensures Gcd(g,r) > 0
    decreases r
  { if r > 0 { GcdPositive(r,g%r); } }
  lemma GcdCommon(g: nat,r: nat,d: nat)
    requires d > 0
    ensures Gcd(g,r)%d == 0 <==> g%d == 0 && r%d == 0
    decreases r
  {
    if r > 0 {
      GcdCommon(r,g%r,d);
      V.ProductResidue(g/r,r,d);
      DifferenceResidue(g,(g/r)*r,d);
      assert g%r == g-(g/r)*r;
    }
  }
  lemma SignedResidue(v: int)
    ensures H.Signed(v)%B.Word == v%B.Word
  {
    var r := v%B.Word;
    if r >= M.Half { P.ShiftRemainder(r-B.Word,r,-1,B.Word); }
  }
  lemma WrappedStep(x: int,y: int,q: nat)
    requires q < B.Word
    ensures H.Signed(x-H.Signed(y*H.Signed(q))) == H.Signed(x-y*q)
  {
    SignedResidue(q);
    V.ProductResidue(y,H.Signed(q),B.Word);
    V.ProductResidue(y,q,B.Word);
    SignedResidue(y*H.Signed(q));
    DifferenceResidue(x,H.Signed(y*H.Signed(q)),B.Word);
    DifferenceResidue(x,y*q,B.Word);
  }
  lemma CoefficientRange(v: int,n: nat)
    requires n < B.Word && 2*Abs(v) <= n
    ensures M.Signed(v) && H.Int256(v)
  { }
  lemma RingDifference(a: int,x: int,q: int,y: int)
    ensures a*(x-q*y) == a*x-q*(a*y)
  { }
  lemma CongruenceStep(a: nat,n: nat,g: nat,r: nat,x: int,y: int,q: nat)
    requires n > 0 && g-q*r >= 0
    requires (a*x)%n == g%n && (a*y)%n == r%n
    ensures (a*(x-q*y))%n == (g-q*r)%n
  {
    RingDifference(a,x,q,y);
    DifferenceResidue(a*x,q*(a*y),n);
    DifferenceResidue(g,q*r,n);
    V.ProductResidue(q,a*y,n);
    V.ProductResidue(q,r,n);
  }
  lemma QuotientStep(g: nat,r: nat)
    requires 0 < r < g < B.Word
    ensures P.Div(g,r) < B.Word
    ensures 0 <= r*P.Div(g,r) <= g < B.Word
    ensures g-r*P.Div(g,r) == g%r
    ensures ((g-(r*P.Div(g,r))%B.Word)%B.Word) == g%r
  {
    B.ProductMonotone(1,r,B.Word);
    B.QuotientUpper(g,r,B.Word);
    assert g == (g/r)*r+g%r;
  }
  lemma CanonicalRemainder(r: nat,n: nat)
    requires n > 0 && r < n
    ensures r%n == r
  { P.Euclidean(0,r,n); }
}

include "Euclid.dfy"
module OperationsModularPowerPower {
  import B = OperationsBinaryLogModel
  import V = OperationsFullMulDivInverse
  import C = OperationsFullMulDivRecombine
  import E = OperationsModularPowerEuclid
  function Multiply(a: nat,b: nat): nat
    ensures Multiply(a,b) == a*b
  { B.ProductNonnegative(a,b); a*b }
  function Power(a: nat,n: nat): nat
    decreases n
  { if n == 0 then 1 else Multiply(a,Power(a,n-1)) }
  lemma PowerAdd(a: nat,m: nat,n: nat)
    ensures Power(a,m+n) == Power(a,m)*Power(a,n)
    decreases m
  {
    if m > 0 {
      PowerAdd(a,m-1,n);
      C.Associate(a,Power(a,m-1),Power(a,n));
    }
  }
  lemma SquareProduct(a: nat,b: nat)
    ensures (a*b)*(a*b) == (a*a)*(b*b)
  { }
  lemma PowerDouble(a: nat,n: nat)
    ensures Power(a,2*n) == Power(Multiply(a,a),n)
    decreases n
  {
    PowerAdd(a,n,n);
    if n > 0 {
      PowerDouble(a,n-1);
      PowerAdd(a,n-1,n-1);
      SquareProduct(a,Power(a,n-1));
    }
  }
  lemma BinaryPower(a: nat,n: nat)
    ensures Power(a,n) == (if n%2 == 1 then a else 1)*Power(Multiply(a,a),n/2)
  {
    assert n == 2*(n/2)+n%2;
    PowerDouble(a,n/2);
    if n%2 == 1 { PowerAdd(a,2*(n/2),1); }
  }
  lemma PowerResidue(a: nat,b: nat,n: nat,m: nat)
    requires m > 0 && a%m == b%m
    ensures Power(a,n)%m == Power(b,n)%m
    decreases n
  {
    if n > 0 {
      PowerResidue(a,b,n-1,m);
      V.ProductResidue(a,Power(a,n-1),m);
      V.ProductResidue(b,Power(b,n-1),m);
    }
  }
  lemma ProductZeroMod(a: int,b: int,m: nat)
    requires m > 0 && b%m == 0
    ensures (a*b)%m == 0
  { V.ProductResidue(a,b,m); }
  lemma UnitMod(a: int,b: int,m: nat)
    requires m > 1 && a%m == 1
    ensures (a*b)%m == b%m
  { V.ProductResidue(a,b,m); E.CanonicalRemainder(b%m,m); }
  lemma ProductSameMod(a: int,b: int,c: int,d: int,m: nat)
    requires m > 0 && a%m == c%m && b%m == d%m
    ensures (a*b)%m == (c*d)%m
  { V.ProductResidue(a,b,m); V.ProductResidue(c,d,m); }
  lemma Finish(r: nat,a: nat,m: nat)
    requires r < m
    ensures Multiply(r,Power(a,0))%m == r
  { E.CanonicalRemainder(r,m); }
  lemma Start(a: nat,n: nat,m: nat)
    requires m > 0
    ensures Power(a%m,n)%m == Power(a,n)%m
    ensures Multiply(1%m,Power(a%m,n))%m == Power(a,n)%m
  {
    E.CanonicalRemainder(a%m,m);
    PowerResidue(a%m,a,n,m);
    ProductSameMod(1%m,Power(a%m,n),1,Power(a,n),m);
  }
  lemma TailState(r: nat,a: nat,n: nat,m: nat)
    requires m > 0
    ensures var nextR := if n%2 == 1 then Multiply(r,a)%m else r;
            var nextN := n/2;
            var nextA := if nextN > 0 then Multiply(a,a)%m else a;
            Multiply(nextR,Power(nextA,nextN))%m == Multiply(r,Power(a,n))%m
  {
    BinaryPower(a,n);
    var nextR := if n%2 == 1 then Multiply(r,a)%m else r;
    var nextN := n/2;
    var nextA := if nextN > 0 then Multiply(a,a)%m else a;
    if nextN > 0 { PowerResidue(nextA,Multiply(a,a),nextN,m); }
    var pTail := Power(nextA,nextN);
    var pSquare := Power(Multiply(a,a),nextN);
    assert pTail%m == pSquare%m;
    ProductSameMod(nextR,pTail,nextR,pSquare,m);
    if n%2 == 1 {
      E.CanonicalRemainder(nextR,m);
      ProductSameMod(nextR,pSquare,Multiply(r,a),pSquare,m);
      assert (nextR*pTail)%m == ((r*a)*pSquare)%m;
      C.Associate(r,a,pSquare);
      assert (r*a)*pSquare == r*Power(a,n);
    } else { assert nextR == r && pSquare == Power(a,n); }
  }
}

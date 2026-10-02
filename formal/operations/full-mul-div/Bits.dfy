include "Product.dfy"
module OperationsFullMulDivBits {
  import B = OperationsBinaryLogModel
  import P = OperationsFullMulDivProduct
  function And(a: nat,b: nat): nat
    decreases a+b
  { if a == 0 || b == 0 then 0 else (a%2)*(b%2)+2*And(a/2,b/2) }
  function Or(a: nat,b: nat): nat
    decreases a+b
  { if a+b == 0 then 0 else (if a%2+b%2 > 0 then 1 else 0)+2*Or(a/2,b/2) }
  function Xor(a: nat,b: nat): nat
    decreases a+b
  { if a+b == 0 then 0 else (a%2+b%2)%2+2*Xor(a/2,b/2) }
  function Twos(d: nat): nat
    requires d > 0
    ensures Twos(d) > 0
    decreases d
  { if d%2 == 1 then 1 else 2*Twos(d/2) }
  lemma AndComplement(w: nat,a: nat)
    requires a < B.Power(w)
    ensures And(a,B.Power(w)-1-a) == 0
    decreases w
  {
    if w > 0 {
      var limit := B.Power(w-1);
      assert B.Power(w) == 2*limit;
      assert a/2 < limit;
      assert (2*limit-1-a)/2 == limit-1-a/2;
      assert a%2+(2*limit-1-a)%2 == 1;
      AndComplement(w-1,a/2);
    }
  }
  lemma Lowest(w: nat,d: nat)
    requires 0 < d < B.Power(w)
    ensures And(d,B.Power(w)-d) == Twos(d)
    decreases w
  {
    assert w > 0;
    var limit := B.Power(w-1);
    assert B.Power(w) == 2*limit;
    if d%2 == 1 {
      assert (2*limit-d)/2 == limit-1-d/2;
      assert (2*limit-d)%2 == 1;
      AndComplement(w-1,d/2);
    } else {
      assert d/2 > 0 && d/2 < limit;
      assert (2*limit-d)/2 == limit-d/2;
      assert (2*limit-d)%2 == 0;
      Lowest(w-1,d/2);
    }
  }
  lemma Factors(w: nat,d: nat)
    requires 0 < d < B.Power(w)
    ensures d%Twos(d) == 0 && B.Power(w)%Twos(d) == 0
    ensures (d/Twos(d))%2 == 1
    ensures exists k: nat :: k < w && Twos(d) == B.Power(k)
    decreases w
  {
    assert w > 0;
    if d%2 == 1 {
      assert Twos(d) == B.Power(0);
    } else {
      assert d/2 > 0 && d/2 < B.Power(w-1);
      Factors(w-1,d/2);
      var q := d/2/Twos(d/2);
      assert d == 2*(d/2);
      assert d/2 == q*Twos(d/2);
      B.Quotient(q,0,2*Twos(d/2));
      var scale := B.Power(w-1)/Twos(d/2);
      assert B.Power(w-1) == scale*Twos(d/2);
      B.Quotient(scale,0,2*Twos(d/2));
      var k: nat :| k < w-1 && Twos(d/2) == B.Power(k);
      assert Twos(d) == B.Power(k+1);
    }
  }
  lemma XorCommute(a: nat,b: nat)
    ensures Xor(a,b) == Xor(b,a)
    decreases a+b
  { if a+b > 0 { XorCommute(a/2,b/2); } }
  lemma XorBound(a: nat,b: nat,w: nat)
    requires a < B.Power(w) && b < B.Power(w)
    ensures Xor(a,b) < B.Power(w)
    decreases w
  {
    if w > 0 && a+b > 0 {
      assert B.Power(w) == 2*B.Power(w-1);
      assert a/2 < B.Power(w-1) && b/2 < B.Power(w-1);
      XorBound(a/2,b/2,w-1);
    }
  }
  lemma XorCancel(a: nat,b: nat)
    ensures Xor(a,Xor(a,b)) == b
    decreases a+b
  {
    if a == 0 {
      XorCommute(0,b); XorZero(b);
    } else {
      XorCancel(a/2,b/2);
      var v := Xor(a,b);
      var low := (a%2+b%2)%2;
      assert v == 2*Xor(a/2,b/2)+low;
      B.Quotient(Xor(a/2,b/2),low,2);
      assert v/2 == Xor(a/2,b/2) && v%2 == low;
      assert (a%2+low)%2 == b%2;
      assert b == 2*(b/2)+b%2;
    }
  }
  lemma XorZero(b: nat)
    ensures Xor(b,0) == b
    decreases b
  { if b > 0 { XorZero(b/2); assert b == 2*(b/2)+b%2; } }
  lemma XorTwo(b: nat)
    ensures Xor(b,2) == (if (b/2)%2 == 0 then b+2 else b-2)
  {
    XorZero(b/4);
    assert b/2 == 2*(b/4)+(b/2)%2;
    assert b == 2*(b/2)+b%2;
    if b == 0 { assert Xor(0,2) == 2; }
  }
  lemma OrZero(b: nat)
    ensures Or(0,b) == b
    decreases b
  { if b > 0 { OrZero(b/2); assert b == 2*(b/2)+b%2; } }
  lemma OrSplit(a: nat,b: nat,n: nat)
    requires a < B.Power(n)
    ensures Or(a,b*B.Power(n)) == a+b*B.Power(n)
    decreases n
  {
    if n == 0 { OrZero(b); }
    else {
      assert B.Power(n) == 2*B.Power(n-1);
      assert a/2 < B.Power(n-1);
      OrSplit(a/2,b,n-1);
      P.ShiftRemainder(b*B.Power(n),0,b*B.Power(n-1),2);
      assert (b*B.Power(n))/2 == b*B.Power(n-1);
      assert a == 2*(a/2)+a%2;
    }
  }
}

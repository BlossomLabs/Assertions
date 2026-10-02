include "Bits.dfy"
module OperationsFullMulDivInverse {
  import B = OperationsBinaryLogModel
  import P = OperationsFullMulDivProduct
  import I = OperationsFullMulDivBits
  function Update(d: nat,i: nat): nat
  { (i*((2-(d*i)%B.Word)%B.Word))%B.Word }
  lemma ProductResidue(x: int,y: int,m: int)
    requires m > 0
    ensures (x*y)%m == ((x%m)*(y%m))%m
  {
    assert x == (x/m)*m+x%m;
    assert y == (y/m)*m+y%m;
    var k := (x/m)*(y/m)*m+(x/m)*(y%m)+(y/m)*(x%m);
    assert x*y == (x%m)*(y%m)+k*m;
    P.ShiftRemainder(x*y,(x%m)*(y%m),k,m);
  }
  lemma Nested(v: int,w: int,m: int)
    requires w > 0 && m > 0 && w%m == 0
    ensures (v%w)%m == v%m
  {
    assert w == (w/m)*m;
    assert v == v%w+(v/w)*(w/m)*m;
    P.ShiftRemainder(v,v%w,(v/w)*(w/m),m);
  }
  lemma Lift(d: int,i: int,m: int)
    requires m >= 2 && (d*i)%m == 1
    ensures (d*(i*(2-d*i)))%(m*m) == 1
  {
    var q := (d*i)/m;
    assert d*i == q*m+1;
    assert d*(i*(2-d*i)) == 1-q*q*(m*m);
    P.ShiftRemainder(d*(i*(2-d*i)),1,-q*q,m*m);
  }
  lemma UpdateExact(d: nat,i: nat)
    ensures Update(d,i) == (i*(2-d*i))%B.Word
  {
    var di := (d*i)%B.Word;
    assert d*i == (d*i/B.Word)*B.Word+di;
    P.ShiftRemainder(2-d*i,2-di,-(d*i/B.Word),B.Word);
    ProductResidue(i,(2-di)%B.Word,B.Word);
    ProductResidue(i,2-di,B.Word);
    ProductResidue(i,2-d*i,B.Word);
  }
  lemma Seed(d: nat)
    requires d < B.Word && d%2 == 1
    ensures (d*I.Xor((3*d)%B.Word,2))%16 == 1
  {
    B.KnownPowers();
    assert B.Word%16 == 0;
    var v := (3*d)%B.Word;
    I.XorTwo(v);
    Nested(3*d,B.Word,16);
    var q := d/16;
    var r := d%16;
    assert d == 16*q+r;
    assert r in {1,3,5,7,9,11,13,15};
    assert v%16 == (3*r)%16;
    var sign := if (v/2)%2 == 0 then 2 else -2;
    assert I.Xor(v,2) == v+sign;
    assert ((v/2)%2) == ((v%16)/2)%2;
    ProductResidue(d,v+sign,16);
    P.ShiftRemainder(v+sign,(3*r)%16+sign,v/16,16);
    P.ShiftRemainder(3*r+sign,(3*r)%16+sign,(3*r)/16,16);
    assert (v+sign)%16 == (3*r+sign)%16;
    assert (d*(v+sign))%16 == (r*((3*r+sign)%16))%16;
    if r == 1 { assert sign == -2; }
    else if r == 3 { assert sign == 2; }
    else if r == 5 { assert sign == -2; }
    else if r == 7 { assert sign == 2; }
    else if r == 9 { assert sign == -2; }
    else if r == 11 { assert sign == 2; }
    else if r == 13 { assert sign == -2; }
    else { assert r == 15 && sign == 2; }
  }
  lemma Hensel(d: nat,i: nat,n: nat)
    requires 4 <= n && 2*n <= 256
    requires (d*i)%B.Power(n) == 1
    ensures (d*Update(d,i))%B.Power(2*n) == 1
  {
    B.KnownPowers();
    B.PowerAdd(n,n);
    B.PowerAdd(2*n,256-2*n);
    assert B.Word == B.Power(2*n)*B.Power(256-2*n);
    B.Quotient(B.Power(256-2*n),0,B.Power(2*n));
    assert B.Word%B.Power(2*n) == 0;
    Lift(d,i,B.Power(n));
    UpdateExact(d,i);
    var raw := i*(2-d*i);
    assert raw == Update(d,i)+(raw/B.Word)*B.Word;
    assert d*raw == d*Update(d,i)+d*(raw/B.Word)*B.Power(256-2*n)*B.Power(2*n);
    P.ShiftRemainder(d*raw,d*Update(d,i),d*(raw/B.Word)*B.Power(256-2*n),B.Power(2*n));
  }
}

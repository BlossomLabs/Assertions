// SPDX-License-Identifier: MIT
// Independent finite-word/unbounded-intermediate mathematics; native checks pending.
module OperationsSignedModularMath {
  const Half: nat := 57896044618658097711785492504343953926634992332820282019728792003956564819968
  const Modulus: nat := 2 * Half
  type Word = x: nat | x < Modulus witness 0

  function Signed(a: Word): int { if a < Half then a else a - Modulus }
  function Abs(a: int): nat { if a < 0 then -a else a }
  function Magnitude(a: Word): Word { Abs(Signed(a)) }
  function Negation(a: Word): Word { (Modulus-a)%Modulus }
  function Restore(a: Word, negative: bool): Word { if negative then Negation(a) else a }
  function Remainder(n: int, d: nat): int
    requires d > 0
  { if n < 0 then -((Abs(n)%d) as int) else Abs(n)%d }
  function Specification(n: int, m: Word): Word
    requires m != 0
  { (Remainder(n,Magnitude(m)) % Modulus) as nat }
  function Add(a: Word,b: Word,m: Word): Word
    requires m != 0
  { Specification(Signed(a)+Signed(b),m) }
  function Multiply(a: Word,b: Word,m: Word): Word
    requires m != 0
  { Specification(Signed(a)*Signed(b),m) }

  lemma Representation(a: Word)
    ensures -(Half as int) <= Signed(a) < Half
    ensures Signed(a)%Modulus==a
    ensures Magnitude(a) <= Half
    ensures (Magnitude(a)==0) == (a==0)
    ensures Signed(a)<0 ==> a>=Half && Magnitude(a)==Modulus-a
    ensures Signed(a)>=0 ==> a<Half && Magnitude(a)==a
  {}

  lemma WordRoundTrip(a: int)
    requires -(Half as int) <= a < Half
    ensures Signed((a%Modulus) as nat)==a
  {
    if a < 0 { assert a%Modulus==a+Modulus; }
    else { assert a%Modulus==a; }
  }

  lemma RemainderBound(n: int,d: nat)
    requires d>0
    ensures -(d as int) < Remainder(n,d) < d
    ensures n>=0 ==> Remainder(n,d)>=0
    ensures n<=0 ==> Remainder(n,d)<=0
    ensures Remainder(n,d)==n-d*(if n<0 then -((Abs(n)/d) as int) else Abs(n)/d)
  {
    assert Abs(n)==d*(Abs(n)/d)+Abs(n)%d;
    if n==0 { assert Abs(n)%d==0; }
  }

  lemma Outcome(n: int,m: Word)
    requires m!=0
    ensures Signed(Specification(n,m))==Remainder(n,Magnitude(m))
    ensures -(Magnitude(m) as int) < Signed(Specification(n,m)) < Magnitude(m)
  {
    Representation(m);
    RemainderBound(n,Magnitude(m));
    WordRoundTrip(Remainder(n,Magnitude(m)));
  }

  lemma MagnitudeNegation(a: Word)
    requires Signed(a)<0
    ensures Negation(a)==Magnitude(a)
  { Representation(a); }

  lemma RestoreSmall(a: Word,negative: bool)
    requires a<Half
    ensures Signed(Restore(a,negative))==(if negative then -(a as int) else a)
  {
    WordRoundTrip(if negative then -(a as int) else a);
    if negative { assert Negation(a)==(-(a as int))%Modulus; }
  }

  lemma RestoreRemainder(n: int,mag: nat,negative: bool,m: Word)
    requires m!=0 && n==(if negative then -(mag as int) else mag)
    ensures Restore(mag%Magnitude(m),negative)==Specification(n,m)
  {
    Representation(m);
    assert mag%Magnitude(m)<Half;
    RestoreSmall(mag%Magnitude(m),negative);
    Outcome(n,m);
    if mag==0 { assert Remainder(n,Magnitude(m))==0; }
    if negative { assert Remainder(n,Magnitude(m))==-((mag%Magnitude(m)) as int); }
    else { assert Remainder(n,Magnitude(m))==mag%Magnitude(m); }
    Representation(Restore(mag%Magnitude(m),negative));
    Representation(Specification(n,m));
    assert Restore(mag%Magnitude(m),negative)%Modulus==Specification(n,m)%Modulus;
  }

  lemma SameSignAdd(a: Word,b: Word,m: Word)
    requires m!=0 && (Signed(a)<0)==(Signed(b)<0)
    ensures Restore((Magnitude(a)+Magnitude(b))%Magnitude(m),Signed(a)<0)==Add(a,b,m)
  {
    Representation(a); Representation(b);
    RestoreRemainder(Signed(a)+Signed(b),Magnitude(a)+Magnitude(b),Signed(a)<0,m);
  }

  lemma OppositeSignAdd(a: Word,b: Word,m: Word)
    requires m!=0 && (Signed(a)<0)!=(Signed(b)<0)
    ensures (if Magnitude(a)>=Magnitude(b)
             then Restore((Magnitude(a)-Magnitude(b))%Magnitude(m),Signed(a)<0)
             else Restore((Magnitude(b)-Magnitude(a))%Magnitude(m),Signed(b)<0))==Add(a,b,m)
  {
    Representation(a); Representation(b);
    if Magnitude(a)>=Magnitude(b) {
      RestoreRemainder(Signed(a)+Signed(b),Magnitude(a)-Magnitude(b),Signed(a)<0,m);
    } else {
      RestoreRemainder(Signed(a)+Signed(b),Magnitude(b)-Magnitude(a),Signed(b)<0,m);
    }
  }

  lemma ProductSign(a: Word,b: Word,m: Word)
    requires m!=0
    ensures Restore((Magnitude(a)*Magnitude(b))%Magnitude(m),(Signed(a)<0)!=(Signed(b)<0))==Multiply(a,b,m)
  {
    Representation(a); Representation(b);
    var x: int:=Magnitude(a); var y: int:=Magnitude(b);
    if Signed(a)<0 {
      if Signed(b)<0 { assert Signed(a)*Signed(b)==x*y; }
      else { assert Signed(a)*Signed(b)==-(x*y); }
    } else {
      if Signed(b)<0 { assert Signed(a)*Signed(b)==-(x*y); }
      else { assert Signed(a)*Signed(b)==x*y; }
    }
    RestoreRemainder(Signed(a)*Signed(b),(x*y) as nat,(Signed(a)<0)!=(Signed(b)<0),m);
  }
}

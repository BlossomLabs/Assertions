include "Inverse.dfy"
module OperationsFullMulDivRecombine {
  import B = OperationsBinaryLogModel
  import P = OperationsFullMulDivProduct
  import I = OperationsFullMulDivBits
  import V = OperationsFullMulDivInverse
  lemma Associate(a: nat,b: nat,c: nat)
    ensures a*(b*c) == (a*b)*c
    ensures a*(b*c) == a*(c*b)
  { }
  lemma Flip(t: nat)
    requires 0 < t < B.Word && B.Word%t == 0
    ensures (((-(t as int))%B.Word)/t+1)%B.Word == (B.Word/t)%B.Word
  {
    var q := B.Word/t;
    assert B.Word == q*t;
    assert q > 0;
    assert (-(t as int))%B.Word == B.Word-t;
    assert B.Word-t == (q-1)*t;
    P.Euclidean(q-1,0,t);
  }
  lemma ShiftResidue(h: nat,k: nat)
    requires k <= 256
    ensures (h*B.Power(256-k))%B.Word == (h%B.Power(k))*B.Power(256-k)
  {
    B.KnownPowers();
    B.PowerAdd(k,256-k);
    var scale := B.Power(256-k);
    var radix := B.Power(k);
    assert B.Word == radix*scale;
    assert h == (h/radix)*radix+h%radix;
    assert h*scale == (h/radix)*B.Word+(h%radix)*scale;
    B.ProductMonotone(h%radix+1,radix,scale);
    assert (h%radix)*scale < B.Word;
    P.ShiftRemainder(h*scale,(h%radix)*scale,h/radix,B.Word);
  }
  lemma ShiftIdentity(h: nat,t: nat,s: nat)
    requires t > 0
    ensures h*s == (h%t)*s+(h/t)*(t*s)
  {
    assert h == (h/t)*t+h%t;
    calc {
       h*s;
    == ((h/t)*t+h%t)*s;
    == (h%t)*s+(h/t)*(t*s);
    }
  }
  lemma JoinBound(a: nat,b: nat,t: nat,s: nat)
    requires a < s && b < t
    ensures a+b*s < t*s
  {
    B.ProductMonotone(b+1,t,s);
    assert a+b*s < (b+1)*s <= t*s;
  }
  lemma Combine(h: nat,low: nat,k: nat,q: nat,odd: nat)
    requires h < B.Word && low < B.Word && k <= 255
    requires h*B.Word+low == q*(B.Power(k)*odd)
    ensures I.Or(P.Div(low,B.Power(k)),(h*(B.Word/B.Power(k)))%B.Word) == (q*odd)%B.Word
  {
    B.KnownPowers();
    B.PowerAdd(k,256-k);
    var t := B.Power(k);
    var scale := B.Power(256-k);
    assert B.Word == t*scale;
    B.Quotient(scale,0,t);
    assert B.Word/t == scale;
    var divided := h*scale+low/t;
    assert h*B.Word+low == divided*t+low%t;
    assert h*B.Word+low == (q*odd)*t;
    B.Quotient(q*odd,0,t);
    B.Quotient(divided,low%t,t);
    assert divided == q*odd && low%t == 0;
    B.QuotientUpper(low,t,scale);
    ShiftResidue(h,k);
    I.OrSplit(low/t,h%t,256-k);
    var combined := low/t+(h%t)*scale;
    B.ProductMonotone(h%t+1,t,scale);
    JoinBound(low/t,h%t,t,scale);
    assert combined < B.Word;
    ShiftIdentity(h,t,scale);
    assert divided == combined+(h/t)*B.Word;
    P.ShiftRemainder(divided,combined,h/t,B.Word);
  }
  lemma Final(q: nat,odd: nat,low: nat,inverse: nat)
    requires q < B.Word && low < B.Word
    requires low == (q*odd)%B.Word && (odd*inverse)%B.Word == 1
    ensures (low*inverse)%B.Word == q
  {
    V.ProductResidue(q,odd*inverse,B.Word);
    V.ProductResidue(q*odd,inverse,B.Word);
    V.ProductResidue(low,inverse,B.Word);
    assert (q*(odd*inverse))%B.Word == q;
    assert (q*odd)*inverse == q*(odd*inverse);
  }
}

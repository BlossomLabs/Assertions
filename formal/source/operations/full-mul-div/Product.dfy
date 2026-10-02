include "../binary-log/Connection.dfy"
module OperationsFullMulDivProduct {
  import B = OperationsBinaryLogModel
  function ReconstructedHigh(x: nat,y: nat): nat
    requires x < B.Word && y < B.Word
  {
    var mm := (x*y)%(B.Word-1);
    var low := (x*y)%B.Word;
    (mm-low-(if mm < low then 1 else 0))%B.Word
  }
  lemma FullBound(x: nat,y: nat)
    requires x < B.Word && y < B.Word
    ensures x*y < B.Word*(B.Word-1)
    ensures x*y/B.Word < B.Word-1
  {
    B.ProductNonnegative(x,y);
    B.ProductMonotone(x,B.Word-1,y);
    B.ProductMonotone(y,B.Word-1,B.Word-1);
    assert x*y <= (B.Word-1)*(B.Word-1) < B.Word*(B.Word-1);
    B.QuotientUpper(x*y,B.Word,B.Word-1);
  }
  lemma DivideNonnegative(n: nat,d: nat)
    requires d > 0
    ensures n/d >= 0
  {
    var q := n/d;
    assert n == q*d+n%d;
    if q < 0 {
      B.ProductMonotone(1,-q,d);
      assert q*d <= -d;
      assert n < 0;
    }
  }
  function Div(n: nat,d: nat): nat
    requires d > 0
    ensures Div(n,d) == n/d
  { DivideNonnegative(n,d); n/d }
  lemma Euclidean(q: int,r: nat,d: nat)
    requires d > 0 && r < d
    ensures (q*d+r)/d == q && (q*d+r)%d == r
  {
    var n := q*d+r;
    var actual := n/d;
    assert n == actual*d+n%d;
    if actual < q {
      B.ProductMonotone(1,q-actual,d);
      assert (q-actual)*d == n%d-r;
      assert false;
    } else if actual > q {
      B.ProductMonotone(1,actual-q,d);
      assert (actual-q)*d == r-n%d;
      assert false;
    }
  }
  lemma ShiftRemainder(n: int,base: int,q: int,d: int)
    requires d > 0 && n == base+q*d
    ensures n%d == base%d
  {
    assert base == (base/d)*d+base%d;
    assert n == (base/d+q)*d+base%d;
    Euclidean(base/d+q,base%d,d);
  }
  lemma CRT(x: nat,y: nat)
    requires x < B.Word && y < B.Word
    ensures ReconstructedHigh(x,y) == x*y/B.Word
    ensures x*y == ReconstructedHigh(x,y)*B.Word+(x*y)%B.Word
  {
    FullBound(x,y);
    var h := x*y/B.Word;
    var low := (x*y)%B.Word;
    var mm := (x*y)%(B.Word-1);
    assert x*y == h*B.Word+low;
    assert x*y == h*(B.Word-1)+(h+low);
    ShiftRemainder(x*y,h+low,h,B.Word-1);
    assert mm == (h+low)%(B.Word-1);
    if h+low < B.Word-1 {
      assert mm == h+low && mm >= low;
    } else {
      assert B.Word-1 <= h+low < 2*(B.Word-1);
      assert 0 <= h+low-(B.Word-1) < B.Word-1;
      B.Quotient(1,h+low-(B.Word-1),B.Word-1);
      assert mm == h+low-(B.Word-1) < low;
      assert mm-low-1 == h-B.Word;
      ShiftRemainder(h-B.Word,h,-1,B.Word);
    }
  }
  lemma Borrow(h: nat,low: nat,rem: nat)
    requires h < B.Word && low < B.Word && rem < B.Word
    requires rem <= h*B.Word+low
    ensures (h-(if rem > low then 1 else 0))%B.Word < B.Word
    ensures ((h-(if rem > low then 1 else 0))%B.Word)*B.Word+(low-rem)%B.Word == h*B.Word+low-rem
  {
    if rem <= low {
      assert 0 <= low-rem < B.Word;
    } else {
      assert h > 0;
      assert 0 <= low-rem+B.Word < B.Word;
      ShiftRemainder(low-rem,low-rem+B.Word,-1,B.Word);
    }
  }
}

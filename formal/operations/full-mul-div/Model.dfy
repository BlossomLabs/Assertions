include "Recombine.dfy"
module OperationsFullMulDivModel {
  import B = OperationsBinaryLogModel
  const Half: int := 0x8000000000000000000000000000000000000000000000000000000000000000
  datatype Outcome = Value(result: int) | Panic(code: nat)
  predicate Signed(v: int) { -Half <= v < Half }
  function Abs(v: int): nat { if v < 0 then -v else v }
  function Sign(a: int,b: int,d: int): bool { ((a < 0) != (b < 0)) != (d < 0) }
  function Rounded(n: nat,d: nat,negative: bool,rounding: nat): nat
    requires d > 0 && rounding <= 2
  {
    n/d+(if n%d != 0 && ((negative && rounding == 1) || (!negative && rounding == 2)) then 1 else 0)
  }
  function UnsignedSpec(a: nat,b: nat,d: nat,rounding: nat): Outcome
    requires a < B.Word && b < B.Word && d < B.Word && rounding <= 2
  {
    if d == 0 then Panic(18)
    else var q := Rounded(a*b,d,false,rounding);
         if q >= B.Word then Panic(17) else Value(q)
  }
  function SignedSpec(a: int,b: int,d: int,rounding: nat): Outcome
    requires Signed(a) && Signed(b) && Signed(d) && rounding <= 2
  {
    if d == 0 then Panic(18)
    else var negative := Sign(a,b,d);
         var q := Rounded(Abs(a)*Abs(b),Abs(d),negative,rounding);
         if q > (if negative then Half else Half-1) then Panic(17)
         else Value(if negative then -(q as int) else q as int)
  }
  lemma Magnitude(v: int)
    requires Signed(v)
    ensures 0 <= Abs(v) <= Half && Abs(v) < B.Word
  { }
  lemma QuotientOverflow(p: nat,d: nat)
    requires d > 0
    ensures p/d >= B.Word <==> p/B.Word >= d
  {
    var q := p/d;
    var high := p/B.Word;
    assert p == q*d+p%d;
    assert p == high*B.Word+p%B.Word;
    if q >= B.Word { B.ProductMonotone(B.Word,q,d); }
    if high >= d { B.ProductMonotone(d,high,B.Word); }
  }
  lemma UnsignedRounding(a: nat,b: nat,d: nat,rounding: nat)
    requires a < B.Word && b < B.Word && 0 < d < B.Word && rounding <= 2
    ensures Rounded(a*b,d,false,rounding) == a*b/d+(if rounding == 2 && (a*b)%d != 0 then 1 else 0)
  { }
}

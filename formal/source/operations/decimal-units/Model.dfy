include "../decimal-render/Control.generated.dfy"
module OperationsDecimalUnitsModel {
  import R = OperationsDecimalRenderModel
  import M = OperationsModularMath
  datatype Outcome = Text(data: seq<bv8>) | InvalidPrecision(precision: int)
  function Power(d: nat): nat
    ensures Power(d) > 0
    decreases d
  { if d == 0 then 1 else 10*Power(d-1) }
  lemma PowerBound(d: nat)
    requires d <= 77
    ensures Power(d) < M.Word
    decreases 77-d
  {
    if d < 77 { PowerBound(d+1); }
    else { Power77(); }
  }
  lemma Power77()
    ensures Power(77) == 100000000000000000000000000000000000000000000000000000000000000000000000000000
  {
    assert Power(0) == 1;
    assert Power(1) == 10;
    assert Power(2) == 100;
    assert Power(3) == 1000;
    assert Power(4) == 10000;
    assert Power(5) == 100000;
    assert Power(6) == 1000000;
    assert Power(7) == 10000000;
    assert Power(8) == 100000000;
    assert Power(9) == 1000000000;
    assert Power(10) == 10000000000;
    assert Power(11) == 100000000000;
    assert Power(12) == 1000000000000;
    assert Power(13) == 10000000000000;
    assert Power(14) == 100000000000000;
    assert Power(15) == 1000000000000000;
    assert Power(16) == 10000000000000000;
    assert Power(17) == 100000000000000000;
    assert Power(18) == 1000000000000000000;
    assert Power(19) == 10000000000000000000;
    assert Power(20) == 100000000000000000000;
    assert Power(21) == 1000000000000000000000;
    assert Power(22) == 10000000000000000000000;
    assert Power(23) == 100000000000000000000000;
    assert Power(24) == 1000000000000000000000000;
    assert Power(25) == 10000000000000000000000000;
    assert Power(26) == 100000000000000000000000000;
    assert Power(27) == 1000000000000000000000000000;
    assert Power(28) == 10000000000000000000000000000;
    assert Power(29) == 100000000000000000000000000000;
    assert Power(30) == 1000000000000000000000000000000;
    assert Power(31) == 10000000000000000000000000000000;
    assert Power(32) == 100000000000000000000000000000000;
    assert Power(33) == 1000000000000000000000000000000000;
    assert Power(34) == 10000000000000000000000000000000000;
    assert Power(35) == 100000000000000000000000000000000000;
    assert Power(36) == 1000000000000000000000000000000000000;
    assert Power(37) == 10000000000000000000000000000000000000;
    assert Power(38) == 100000000000000000000000000000000000000;
    assert Power(39) == 1000000000000000000000000000000000000000;
    assert Power(40) == 10000000000000000000000000000000000000000;
    assert Power(41) == 100000000000000000000000000000000000000000;
    assert Power(42) == 1000000000000000000000000000000000000000000;
    assert Power(43) == 10000000000000000000000000000000000000000000;
    assert Power(44) == 100000000000000000000000000000000000000000000;
    assert Power(45) == 1000000000000000000000000000000000000000000000;
    assert Power(46) == 10000000000000000000000000000000000000000000000;
    assert Power(47) == 100000000000000000000000000000000000000000000000;
    assert Power(48) == 1000000000000000000000000000000000000000000000000;
    assert Power(49) == 10000000000000000000000000000000000000000000000000;
    assert Power(50) == 100000000000000000000000000000000000000000000000000;
    assert Power(51) == 1000000000000000000000000000000000000000000000000000;
    assert Power(52) == 10000000000000000000000000000000000000000000000000000;
    assert Power(53) == 100000000000000000000000000000000000000000000000000000;
    assert Power(54) == 1000000000000000000000000000000000000000000000000000000;
    assert Power(55) == 10000000000000000000000000000000000000000000000000000000;
    assert Power(56) == 100000000000000000000000000000000000000000000000000000000;
    assert Power(57) == 1000000000000000000000000000000000000000000000000000000000;
    assert Power(58) == 10000000000000000000000000000000000000000000000000000000000;
    assert Power(59) == 100000000000000000000000000000000000000000000000000000000000;
    assert Power(60) == 1000000000000000000000000000000000000000000000000000000000000;
    assert Power(61) == 10000000000000000000000000000000000000000000000000000000000000;
    assert Power(62) == 100000000000000000000000000000000000000000000000000000000000000;
    assert Power(63) == 1000000000000000000000000000000000000000000000000000000000000000;
    assert Power(64) == 10000000000000000000000000000000000000000000000000000000000000000;
    assert Power(65) == 100000000000000000000000000000000000000000000000000000000000000000;
    assert Power(66) == 1000000000000000000000000000000000000000000000000000000000000000000;
    assert Power(67) == 10000000000000000000000000000000000000000000000000000000000000000000;
    assert Power(68) == 100000000000000000000000000000000000000000000000000000000000000000000;
    assert Power(69) == 1000000000000000000000000000000000000000000000000000000000000000000000;
    assert Power(70) == 10000000000000000000000000000000000000000000000000000000000000000000000;
    assert Power(71) == 100000000000000000000000000000000000000000000000000000000000000000000000;
    assert Power(72) == 1000000000000000000000000000000000000000000000000000000000000000000000000;
    assert Power(73) == 10000000000000000000000000000000000000000000000000000000000000000000000000;
    assert Power(74) == 100000000000000000000000000000000000000000000000000000000000000000000000000;
    assert Power(75) == 1000000000000000000000000000000000000000000000000000000000000000000000000000;
    assert Power(76) == 10000000000000000000000000000000000000000000000000000000000000000000000000000;
    assert Power(77) == 100000000000000000000000000000000000000000000000000000000000000000000000000000;
  }
  function Fixed(n: nat,d: nat): seq<bv8>
    requires n < Power(d)
    ensures |Fixed(n,d)| == d
    decreases d
  { if d == 0 then [] else Fixed(n/10,d-1)+[R.Digit(n%10)] }
  lemma FixedValue(n: nat,d: nat)
    requires n < Power(d)
    ensures R.Value(Fixed(n,d)) == n
    decreases d
  { if d > 0 { FixedValue(n/10,d-1); } }
  function Trim(s: seq<bv8>): seq<bv8>
    ensures |Trim(s)| <= |s|
    decreases |s|
  { if |s| == 0 || s[|s|-1] != 48 then s else Trim(s[..|s|-1]) }
  lemma TrimPositive(s: seq<bv8>)
    requires R.Value(s) > 0
    ensures |Trim(s)| > 0
    decreases |s|
  { if s[|s|-1] == 48 { TrimPositive(s[..|s|-1]); } }
  lemma ProductNonnegative(a: nat,b: nat)
    ensures a*b >= 0
  {}
  lemma QuotientBound(n: nat,d: nat)
    requires d > 0
    ensures n/d <= n
  {
    assert n == (n/d)*d+n%d;
    assert 0 <= n%d < d;
    assert n/d >= 0;
    var q := n/d;
    assert d >= 1 && q >= 0;
    ProductNonnegative(q,d-1);
    assert q*d == q+q*(d-1);
    assert q <= q*d;
  }
  function Quotient(n: nat,d: nat): nat
    requires d > 0
    ensures Quotient(n,d) == n/d && Quotient(n,d) <= n
  { QuotientBound(n,d); n/d }
  lemma TrimStep(s: seq<bv8>)
    requires |s| > 0 && s[|s|-1] == 48 && R.Value(s) > 0
    ensures |s| > 1 && R.Value(s[..|s|-1]) > 0
    ensures Trim(s) == Trim(s[..|s|-1])
  { assert R.Value(s) == R.Value(s[..|s|-1])*10; }
  function Units(n: nat,d: nat): Outcome {
    if d > 77 then InvalidPrecision(d)
    else if d == 0 then Text(R.Decimal(n))
    else if n%Power(d) == 0 then Text(R.Decimal(Quotient(n,Power(d))))
    else Text(R.Decimal(Quotient(n,Power(d)))+[46]+Trim(Fixed(n%Power(d),d)))
  }
  function SignedUnits(n: int,d: nat): Outcome
    requires -M.Half <= n < M.Half
  {
    var r := Units(if n < 0 then -n else n,d);
    if r.Text? then Text((if n < 0 then [45] else [])+r.data) else r
  }
}

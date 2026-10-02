include "../modular/Math.generated.dfy"
module OperationsDecimalRenderModel {
  import M = OperationsModularMath
  const Word: int := M.Word
  function Count(n: nat): nat
    ensures Count(n) <= n
    ensures n > 0 ==> Count(n) > 0
    decreases n
  { if n == 0 then 0 else 1+Count(n/10) }
  function Digit(d: int): bv8
    requires 0 <= d <= 9
    ensures Digit(d) as int == 48+d
  { (48+d) as bv8 }
  function Nonzero(n: nat): seq<bv8>
    ensures |Nonzero(n)| == Count(n)
    decreases n
  { if n == 0 then [] else Nonzero(n/10)+[Digit(n%10)] }
  function Decimal(n: nat): seq<bv8> { if n == 0 then [48] else Nonzero(n) }
  function Value(s: seq<bv8>): int
    decreases |s|
  { if |s| == 0 then 0 else Value(s[..|s|-1])*10+(s[|s|-1] as int)-48 }
  lemma DecimalValue(n: nat)
    ensures Value(Decimal(n)) == n
    ensures n > 0 ==> 49 <= (Decimal(n)[0] as int) <= 57
    decreases n
  {
    if n > 0 {
      DecimalValue(n/10);
      if n/10 == 0 { assert n%10 == n; }
    }
  }
  function SignedDecimal(n: int): seq<bv8>
    requires -M.Half <= n < M.Half
  { (if n < 0 then [45] else [])+Decimal(if n < 0 then -n else n) }
}

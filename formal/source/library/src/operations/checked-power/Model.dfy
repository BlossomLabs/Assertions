module OperationsCheckedPowerModel {
  const Word: int := 0x10000000000000000000000000000000000000000000000000000000000000000
  const Half: int := Word/2
  datatype Outcome = Value(result: int) | Panic(code: int)
  predicate Signed(n: int) { -Half <= n < Half }
  function Power(a: int,b: nat): int
    decreases b
  { if b == 0 then 1 else a*Power(a,b-1) }
  function Unsigned(a: nat,b: nat): Outcome
  { if Power(a,b) >= Word then Panic(17) else Value(Power(a,b)) }
  function Trace(a: int,b: nat,result: int): Outcome
    requires Signed(a) && Signed(result)
    decreases b
  {
    if b == 0 then Value(result)
    else
      var product := result*a;
      if b%2 == 1 && !Signed(product) then Panic(17)
      else
        var acc := if b%2 == 1 then product else result;
        var half := b/2;
        if half == 0 then Value(acc)
        else
          var square := a*a;
          if !Signed(square) then Panic(17) else Trace(square,half,acc)
  }
  function SignedSpec(a: int,b: nat): Outcome
    requires Signed(a)
  { Trace(a,b,1) }
  lemma PowerNonnegative(a: nat,b: nat)
    ensures Power(a,b) >= 0
    decreases b
  { if b > 0 { PowerNonnegative(a,b-1); } }
  lemma PowerAdd(a: int,b: nat,c: nat)
    ensures Power(a,b+c) == Power(a,b)*Power(a,c)
    decreases b
  { if b > 0 { PowerAdd(a,b-1,c); } }
  lemma SquarePower(a: int,b: nat)
    ensures Power(a*a,b) == Power(a,2*b)
    decreases b
  {
    if b > 0 {
      SquarePower(a,b-1);
      PowerAdd(a,2*(b-1),2);
      assert Power(a,2) == a*a;
    }
  }
  lemma PowerBinary(a: int,b: nat)
    ensures Power(a,b) == (if b%2 == 1 then a else 1)*Power(a*a,b/2)
  {
    var half := b/2;
    assert b == 2*half+b%2;
    PowerAdd(a,2*half,b%2);
    SquarePower(a,half);
    assert b%2 == 0 || b%2 == 1;
  }
  lemma TraceMath(a: int,b: nat,result: int)
    requires Signed(a) && Signed(result)
    ensures Trace(a,b,result).Value? ==> Trace(a,b,result).result == result*Power(a,b)
    decreases b
  {
    if b > 0 {
      var product := result*a;
      if b%2 == 0 || Signed(product) {
        var acc := if b%2 == 1 then product else result;
        var half := b/2;
        PowerBinary(a,b);
        if half > 0 && Signed(a*a) { TraceMath(a*a,half,acc); }
        if half == 0 { assert b == 1; }
      }
    }
  }
}
